#!/usr/bin/env python3
import asyncio
from dbus_next.service import ServiceInterface, method
from dbus_next.aio import MessageBus
from dbus_next import BusType

BUS_NAME = "org.openbmc.Control.Power"
OBJ_PATH = "/org/openbmc/control/power0"
IFACE = "org.openbmc.Control.Power"

class Power0(ServiceInterface):
    def __init__(self):
        super().__init__(IFACE)

    @method()
    def setPowerState(self, state: "s"):
        print("Power state set to:", state)

async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    bus.export(OBJ_PATH, Power0())
    await bus.request_name(BUS_NAME)
    print(f"Fake power0 online at {OBJ_PATH}")
    await asyncio.get_event_loop().create_future()

asyncio.run(main())
