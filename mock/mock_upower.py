import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

class UPowerDevice(dbus.service.Object):
    def __init__(self, bus, path):
        super().__init__(bus, path)
        self.props = {
            'Type': dbus.UInt32(1),        # 1 = LinePower
            'State': dbus.UInt32(2),       # 2 = Charging, 0=Unknown, 1=Charging, 2=Discharging
            'Percentage': dbus.Double(100.0),
            'Online': dbus.Boolean(True),  # 这才是关键！True 表示 AC 在线
        }

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='ss', out_signature='v')
    def Get(self, iface, prop):
        return self.props[prop]

    @dbus.service.method(dbus.PROPERTIES_IFACE, in_signature='s', out_signature='a{sv}')
    def GetAll(self, iface):
        return self.props

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
name = dbus.service.BusName('org.freedesktop.UPower', bus)

# 创建一个 LinePower 设备
UPowerDevice(bus, '/org/freedesktop/UPower/devices/line_power_AC')

print("Mock UPower LinePower Online=True running...")
GLib.MainLoop().run()