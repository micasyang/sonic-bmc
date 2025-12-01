#!/usr/bin/env python3
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()

bus_name = dbus.service.BusName(
    "xyz.openbmc_project.State.Chassis",
    bus=bus
)

class ChassisState(dbus.service.Object):
    def __init__(self, bus, path):
        dbus.service.Object.__init__(self, bus, path)

    @dbus.service.method("org.freedesktop.DBus.Properties",
                         in_signature="ss", out_signature="v")
    def Get(self, interface, prop):
        if prop == "CurrentPowerState":
            return "xyz.openbmc_project.State.Chassis.PowerState.On"
        return ""

ChassisState(bus, "/xyz/openbmc_project/state/chassis0")
print("ChassisState mock running...")
GLib.MainLoop().run()
# 替代了 phosphor-chassis-state-manager  busctl tree xyz.openbmc_project.State.Chassis