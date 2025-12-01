#!/usr/bin/env python3
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

# DBus 初始化
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()

# ★★★ 关键：注册 bus name ★★★
bus_name = dbus.service.BusName(
    "xyz.openbmc_project.State.Boot",
    bus=bus
)

# 定义 Progress 对象
class BootProgress(dbus.service.Object):
    def __init__(self, bus, path):
        dbus.service.Object.__init__(self, bus, path)

    @dbus.service.method("org.freedesktop.DBus.Properties",
                         in_signature="ss", out_signature="v")
    def Get(self, interface, prop):
        return dbus.String("xyz.openbmc_project.State.Boot.Progress.Booting")

# 定义 Raw 对象
class BootRaw(dbus.service.Object):
    def __init__(self, bus, path):
        dbus.service.Object.__init__(self, bus, path)

# 实例化 DBus 对象
BootRaw(bus, "/xyz/openbmc_project/state/boot/raw0")
BootProgress(bus, "/xyz/openbmc_project/state/boot/progress0")

print("BootProgress mock is running...")
GLib.MainLoop().run()

# busctl tree xyz.openbmc_project.State.Boot
