export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib64/pkgconfig

SUBDIRS := \
	src/phosphor-power \
	src/phosphor-inventory-manager \
	src/phosphor-objmgr \
	src/phosphor-state-manager \
	src/phosphor-settingsd \
	src/phosphor-networkd \
	src/dbus-sensors

.PHONY: all $(SUBDIRS) clean print-subdirs clone

all: clone setup-deps $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

print-subdirs:
	@echo "SUBDIRS=($(SUBDIRS))"

clone:
	@if [ ! -d "/usr/local/include/function2" ]; then \
        git clone https://github.com/Naios/function2.git && \
        cp -r function2/include/function2 /usr/local/include/ && \
        rm -rf function2; \
	else \
		echo "/usr/local/include/function2 already exists."; \
	fi
setup-deps:
	@echo "🔧 Installing Python dependencies via pip3..."
	@pip3 install --break-system-packages meson ninja inflection mako jsonschema || \
	 (echo "❌ Failed to install Python packages"; exit 1)

	@echo "🔁 Updating APT package list..."
	@apt update && \
	apt install -y --no-install-recommends \
		cmake \
		make \
		gcc \
		g++ \
		unzip \
		wget \
		npm \
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
		python3-yaml && \
	echo "✅ All system packages installed successfully." || \
	(echo "❌ Failed to install APT packages"; exit 1)

	@echo "🎉 Dependency setup complete!"