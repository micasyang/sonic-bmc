# === 获取当前 Makefile 所在目录 ===
ROOT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME := webui-vue
PATCH_DIR := $(ROOT_DIR)/patch
SRC_DIR := $(ROOT_DIR)/$(PROJ_NAME)
BUILD_DIR := builddir
BUILD_DIR_ALL := $(ROOT_DIR)/$(PROJ_NAME)/builddir
INSTALL_PREFIX ?= /usr/local

TARGET_DIR :="$(abspath $(CURDIR)/../../target)"
include $(abspath $(ROOT_DIR)/../package.mk)

# 工具
GIT := git


.PHONY: all clone patch setup build install clean cleanall

all: install

# === 克隆源码 ===
clone:
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "Cloning webui-vue..."; \
		$(GIT) clone https://github.com/openbmc/webui-vue.git $(SRC_DIR); \
	else \
		echo "$(SRC_DIR) already exists."; \
	fi
	@$(GIT) -C $(SRC_DIR) checkout .  # 或 main,根据实际分支调整

# === 打补丁 ===
patch: clone
	@echo "Looking for patches in $(PATCH_DIR)/"
	@for p in $$(ls $(PATCH_DIR)/*.patch 2>/dev/null || exit 0); do \
		echo "Applying $$p"; \
		$(GIT) -C $(SRC_DIR) apply "$$p"; \
	done

# === 配置构建 ===
setup: patch
	@if [ ! -d "$(BUILD_DIR_ALL)" ]; then \
		cd $(SRC_DIR) && \
		npm install ; \
	fi

# === 编译 ===
build: setup
	cd $(SRC_DIR) && npm run build

# === 安装 ===
install: build
	rm -rf $(PKGROOT_DIR) && mkdir -p $(PKGROOT_DIR)/usr/share/www
	cp -r $(SRC_DIR)/dist/*  $(PKGROOT_DIR)/usr/share/www
	@$(package_deb)

# === 清理 ===
clean:
	@if [ -d "$(BUILD_DIR_ALL)" ]; then rm -rf $(BUILD_DIR_ALL); fi

cleanall:
	rm -rf $(SRC_DIR) $(BUILD_DIR_ALL)

# === 调试 ===
print-vars:
	@echo "ROOT_DIR=$(ROOT_DIR)"
	@echo "PATCH_DIR=$(PATCH_DIR)"
	@echo "SRC_DIR=$(SRC_DIR)"
	@echo "BUILD_DIR=$(BUILD_DIR)"
	@echo "INSTALL_PREFIX=$(INSTALL_PREFIX)"