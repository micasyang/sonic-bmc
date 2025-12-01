export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib64/pkgconfig

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
	src/bmcweb \
	src/phosphor-certificate-manager \
	src/phosphor-modbus \
	src/entity-manager \
	src/phosphor-user-manager \
	src/phosphor-host-ipmid \
	src/phosphor-power \
	src/phosphor-inventory-manager \
	src/phosphor-objmgr \
	src/phosphor-state-manager \
	src/phosphor-settingsd \
	src/phosphor-networkd \
	src/dbus-sensors

.PHONY: all $(SUBDIRS) clean

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean:
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

