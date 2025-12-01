# === 获取当前 Makefile 所在目录 ===
ROOT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
PROJ_NAME := CLI11-2.4.1
PATCH_DIR := $(ROOT_DIR)/patch
SRC_DIR := $(ROOT_DIR)/$(PROJ_NAME)
BUILD_DIR := builddir
BUILD_DIR_ALL := $(ROOT_DIR)/$(PROJ_NAME)/builddir
INSTALL_PREFIX ?= /usr/local

# 工具
GIT := git
MESON := meson
NINJA := ninja

.PHONY: all clone patch setup build install clean cleanall

all: install

# === 克隆源码 ===
clone:
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "Cloning sdeventplus..."; \
		if [ ! -f "v2.4.1.tar.gz" ]; then \
            wget https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.4.1.tar.gz; \
        fi; \
		tar xf v2.4.1.tar.gz ;\
	else \
		echo "$(SRC_DIR) already exists."; \
	fi

# === 打补丁 ===
patch: clone
	@echo "Looking for patches in $(PATCH_DIR)/"
	@for p in $$(ls $(PATCH_DIR)/*.patch 2>/dev/null || exit 0); do \
		echo "Applying $$p"; \
		$(GIT) -C $(SRC_DIR) apply "$$p"; \
	done

# === 配置构建 ===
setup: patch
	@if [ ! -d "$(SRC_DIR)/build" ]; then \
		cd $(SRC_DIR) && \
		mkdir -p build && cd build && \
		cmake .. \
			-DCMAKE_INSTALL_PREFIX=$(INSTALL_PREFIX) \
			-DCLI11_BUILD_TESTS=OFF \
			-DCLI11_BUILD_EXAMPLES=OFF \
			-DCLI11_BUILD_DOCS=OFF \
			-DCLI11_BUILD_COVERAGE=OFF \
			-DCLI11_SINGLE_HEADER=ON && \
		true; \
	fi

# === 编译 ===
build: setup
	@cd $(SRC_DIR)/build && cmake --build . -j$(nproc)

# === 安装 ===
install: build
	@cd $(SRC_DIR)/build && cmake --install .

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