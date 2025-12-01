#!/usr/bin/env python3
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

class Power(dbus.service.Object):
    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='ss', out_signature='v')
    def Get(self, interface, prop):
        if prop == 'pgood':
            return dbus.Int32(1, variant_level=1)
        raise dbus.exceptions.DBusException('Unknown property')

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        return {'pgood': dbus.Int32(1, variant_level=1)}

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
name = dbus.service.BusName('org.openbmc.control.Power', bus)
obj = Power(bus, '/org/openbmc/control/power0')
print("Mock pgood=1 server running...")
GLib.MainLoop().run()