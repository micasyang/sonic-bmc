PROJ_ROOT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib64/pkgconfig
export PATH := $(HOME)/venv/bmc/bin:$(PATH)

SUBDIRS := \
	src/lib/boost \
	src/lib/libpeci \
	src/lib/libpldm \
	src/lib/nlohmann_json \
	src/lib/CLI11 \
	src/lib/sdbusplus \
	src/lib/gpioplus \
	src/lib/stdplus \
	src/lib/sdeventplus \
	src/lib/phosphor-dbus-interfaces \
	src/lib/phosphor-logging \
	src/webui-vue \
	src/entity-manager \
	src/phosphor-settingsd

SUDO_SUBDIRS := \
	src/bmcweb \
	src/phosphor-networkd \
	src/phosphor-certificate-manager \
	src/phosphor-state-manager \
	src/phosphor-inventory-manager \
	src/phosphor-objmgr \
	src/phosphor-power \
	src/phosphor-host-ipmid \
	src/phosphor-user-manager \
	src/phosphor-modbus \
	src/dbus-sensors

.PHONY: all $(SUBDIRS) clean print-subdirs clone python-env $(SUDO_SUBDIRS)

all: merge

$(SUBDIRS): python-env
	PATH="$(PATH)" $(MAKE) -C $@

$(SUDO_SUBDIRS): $(SUBDIRS)
	sudo env "PATH=$(PATH)" $(MAKE) -C $@

python-env: setup-deps
	@python3 -m venv ~/venv/bmc || true
	@. ~/venv/bmc/bin/activate && \
	pip install --upgrade pip && \
	pip install --upgrade jsonschema && \
	pip3 install --upgrade meson && \
	pip3 install --break-system-packages meson ninja inflection mako jsonschema PyYAML

setup-deps:
	@sudo mkdir -p $(PROJ_ROOT_DIR)/build/include
	@sudo chmod -R 777 $(PROJ_ROOT_DIR)/build
	@sudo cp $(PROJ_ROOT_DIR)/dockers/format $(PROJ_ROOT_DIR)/build/include/format
	@if [ ! -d "$(PROJ_ROOT_DIR)/build/include/function2" ]; then \
        git clone https://github.com/Naios/function2.git $(PROJ_ROOT_DIR)/function2 && \
        sudo cp -r $(PROJ_ROOT_DIR)/function2/include/function2 $(PROJ_ROOT_DIR)/build/include/ && \
        rm -rf $(PROJ_ROOT_DIR)/function2; \
	else \
		echo "$(PROJ_ROOT_DIR)/function2 already exists."; \
	fi
	@sudo apt update && \
	sudo apt install -y --no-install-recommends \
		cmake \
		make \
		gcc \
		g++ \
		unzip \
		wget \
		npm \
		libnl-genl-3-dev \
		libnl-3-dev \
		libnl-genl-3-dev \
		libnl-3-dev \
		libi2c-dev \
		libxml2-dev \
		libgpiod-dev \
		liburing-dev \
		libcereal-dev \
		libldap2-dev \
		libsasl2-dev \
		zlib1g-dev \
		libssl-dev \
		libpam0g-dev \
		libnghttp2-dev \
		libzstd-dev \
		libtinyxml2-dev \
		systemd \
		libsystemd-dev \
		libfmt-dev \
		libdbus-1-dev \
		supervisor \
		vim \
		iproute2 \
		build-essential \
		devscripts \
		debhelper \
		dh-make \
		lintian \
		python3 \
		python3-dbus \
		python3-pip \
		python3-yaml

merge: $(SUDO_SUBDIRS)
	@$(PROJ_ROOT_DIR)/merge.sh

clean:
	@sudo rm -rf $(PROJ_ROOT_DIR)/build
	@sudo rm -rf $(PROJ_ROOT_DIR)/tmp
	@for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done
	@for d in $(SUDO_SUBDIRS); do sudo $(MAKE) -C $$d clean; done

print-subdirs:
	@echo "SUBDIRS=($(SUBDIRS))"
	@echo "HOME=($(HOME))"
	@echo "PATH=($(PATH))"
	@echo "PROJ_ROOT_DIR=($(PROJ_ROOT_DIR))"