#!/usr/bin/env python3
# minimal-fake-dbus.py   ← 这个最推荐！！！

from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
import dbus
import dbus.service

DBusGMainLoop(set_as_default=True)

bus = dbus.SystemBus()
name = dbus.service.BusName("xyz.openbmc_project.State.Mock", bus)

class MockObject(dbus.service.Object):
    def __init__(self, path, interfaces):
        super().__init__(bus, path)
        self.interfaces = interfaces

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        return self.interfaces.get(interface, {})

# 必须的最小集合
objects = [
    ("/xyz/openbmc_project/inventory/system/host0", {
        "xyz.openbmc_project.Inventory.Item": {"Present": True},
        "xyz.openbmc_project.State.Boot.Progress": {"ProgressCode": "xyz.openbmc_project.State.Boot.Progress.ProgressStages.Off"}
    }),
    ("/xyz/openbmc_project/state/host0", {
        "xyz.openbmc_project.State.Host": {"CurrentHostState": "xyz.openbmc_project.State.Host.HostState.Off"}
    }),
    ("/xyz/openbmc_project/state/chassis0", {
        "xyz.openbmc_project.State.Chassis": {"CurrentPowerState": "xyz.openbmc_project.State.Chassis.PowerState.Off"}
    })
]

for path, ifaces in objects:
    MockObject(path, ifaces)
    print(f"[+] Fake {path}")

print("假对象已就绪，可运行 phosphor-host-state-manager --host 0")
GLib.MainLoop().run()