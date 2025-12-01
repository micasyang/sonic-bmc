# === 获取当前 Makefile 所在目录 ===
ROOT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
BOOSTVERSION := 1.89.0
PROJ_NAME := boost-$(BOOSTVERSION)
PATCH_DIR := $(ROOT_DIR)/patch
SRC_DIR := $(ROOT_DIR)/$(PROJ_NAME)
INSTALL_PREFIX ?= /usr/local

.PHONY: all clone patch setup build install clean cleanall

all: install

# === 克隆源码 ===
clone:
	@if [ ! -f "$(ROOT_DIR)boost-$(BOOSTVERSION)-cmake.tar.gz" ]; then \
        echo "Downloading boost-$(BOOSTVERSION)..."; \
        wget -q -O "$(ROOT_DIR)boost-$(BOOSTVERSION)-cmake.tar.gz" "https://github.com/boostorg/boost/releases/download/boost-$(BOOSTVERSION)/boost-$(BOOSTVERSION)-cmake.tar.gz"; \
    else \
        echo "$(ROOT_DIR)boost-$(BOOSTVERSION)-cmake.tar.gz already exists."; \
    fi; \
    if [ ! -d "$(SRC_DIR)" ]; then \
        echo "Extracting $(ROOT_DIR)boost-$(BOOSTVERSION)-cmake.tar.gz..."; \
        tar xf "$(ROOT_DIR)boost-$(BOOSTVERSION)-cmake.tar.gz" -C "$(ROOT_DIR)"; \
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
	@if [ -d "$(SRC_DIR)" ]; then \
		cd $(SRC_DIR) && ./bootstrap.sh; \
	fi

# === 编译 ===
build: setup
	cd $(SRC_DIR) && ./b2 --prefix=/usr/local --with=all -j$(nproc)

# === 安装 ===
install: build
	cd $(SRC_DIR) && ./b2 install

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