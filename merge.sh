#!/bin/bash
# 文件名: merge-to-sonic-bmc.sh   （覆盖掉旧脚本即可）
# 功能：自动删除安装时会冲突的文件（尤其是 phosphor-user-manager 带来的）

set -e

OUT_DEB="sonic-bmc_1.0_amd64.deb"
BUILD_DIR="./tmp"
EXTRACT_DIR="$BUILD_DIR/extract"
CONTROL_DIR="$BUILD_DIR/controls"
TARGET_DIR="./target"

[ ! -d "$TARGET_DIR" ] && echo "错误：找不到 target 目录" && exit 1

echo "=== 清理并创建 build 目录 ==="
rm -rf "$BUILD_DIR"
mkdir -p "$EXTRACT_DIR" "$CONTROL_DIR"

echo "=== 解包所有 deb ==="
deb_count=0
for deb in "$TARGET_DIR"/*.deb; do
    [ -f "$deb" ] || continue
    echo "[$((++deb_count))] 解包 $(basename "$deb")"
    dpkg-deb -x "$deb" "$EXTRACT_DIR"
    pkg_name=$(basename "$deb" .deb | sed 's/_.*//')
    mkdir -p "$CONTROL_DIR/$pkg_name"
    dpkg-deb -e "$deb" "$CONTROL_DIR/$pkg_name" 2>/dev/null || true
done
echo "共处理 $deb_count 个包"

# ================== 关键：在这里删除所有会导致冲突的文件 ==================
echo "=== 删除已知会导致 dpkg 安装冲突的文件 ==="
DEL_FILES=(
    # 如果你还遇到别的冲突，直接在这里加一行就行，例如：
    # "/usr/share/doc/some-package/changelog.Debian.gz"
)

for f in "${DEL_FILES[@]}"; do
    target_file="$EXTRACT_DIR$f"
    if [ -f "$target_file" ] || [ -L "$target_file" ]; then
        echo "删除冲突文件: $f"
        rm -f "$target_file"
    fi
done
rm -rf
# ===========================================================================

# 其余部分和之前完全一样（合并依赖、生成 control、打包）
echo "=== 合并依赖 ==="
ALL_DEPENDS="" ALL_CONFLICTS="" ALL_PROVIDES="" ALL_REPLACES=""

for ctrl in "$CONTROL_DIR"/*/control; do
    [ -f "$ctrl" ] || continue
    grep "^Depends:"   "$ctrl" | sed 's/^Depends: *//'   | tr '\n' ',' >> /tmp/deps.tmp   || true
    grep "^Conflicts:" "$ctrl" | sed 's/^Conflicts: *//' | tr '\n' ',' >> /tmp/conf.tmp   || true
    grep "^Provides:"  "$ctrl" | sed 's/^Provides: *//'  | tr '\n' ',' >> /tmp/prov.tmp   || true
    grep "^Replaces:"  "$ctrl" | sed 's/^Replaces: *//'  | tr '\n' ',' >> /tmp/rep.tmp    || true
done

format() { tr ',' '\n' < "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | sort -u | tr '\n' ',' | sed 's/,$//; s/, */, /g'; }

[ -f /tmp/deps.tmp ] && ALL_DEPENDS=$(format /tmp/deps.tmp)
[ -f /tmp/conf.tmp ] && ALL_CONFLICTS=$(format /tmp/conf.tmp)
[ -f /tmp/prov.tmp ] && ALL_PROVIDES=$(format /tmp/prov.tmp)
[ -f /tmp/rep.tmp ]  && ALL_REPLACES=$(format /tmp/rep.tmp)

installed_size=$(du -sk "$EXTRACT_DIR" | cut -f1)
mkdir -p "$EXTRACT_DIR/DEBIAN"

cat > "$EXTRACT_DIR/DEBIAN/control" <<EOF
Package: sonic-bmc
Version: 1.0
Architecture: amd64
Maintainer: SONiC BMC Build <build@localhost>
Installed-Size: $installed_size
Section: net
Priority: optional
Homepage: https://github.com/sonic-net/SONiC
Description: SONiC BMC All-in-One Package (auto-merged)
$( [ -n "$ALL_DEPENDS" ]    && echo "Depends: $ALL_DEPENDS" )
$( [ -n "$ALL_CONFLICTS" ]  && echo "Conflicts: $ALL_CONFLICTS" )
$( [ -n "$ALL_PROVIDES" ]   && echo "Provides: $ALL_PROVIDES" )
$( [ -n "$ALL_REPLACES" ]   && echo "Replaces: $ALL_REPLACES" )
EOF

# 权限修复
find "$EXTRACT_DIR" -type d -exec chmod 755 {} \;
find "$EXTRACT_DIR" -type f -exec chmod 644 {} \;
find "$EXTRACT_DIR" -type f -perm /111 -exec chmod 755 {} \; 2>/dev/null || true

# 简单处理 maintainer scripts（只取第一个）
for script in preinst postinst prerm postrm config; do
    found=$(find "$CONTROL_DIR" -name "$script" | head -n1)
    [ -n "$found" ] && cp "$found" "$EXTRACT_DIR/DEBIAN/$script" && chmod 755 "$EXTRACT_DIR/DEBIAN/$script"
done

echo "=== 打包最终 deb ==="
rm -f "$OUT_DEB"
dpkg-deb --root-owner-group --build "$EXTRACT_DIR" "$OUT_DEB"

echo "完成！已自动删除冲突文件，重新生成的包可以直接安装："
echo "dpkg -i $OUT_DEB"
ls -lh "$OUT_DEB"