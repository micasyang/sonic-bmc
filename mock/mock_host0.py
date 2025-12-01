#!/usr/bin/env python3
# fake-host0-system.py
# Requires: pip3 install dbus-next
import asyncio
from dbus_next.service import ServiceInterface, dbus_property, PropertyAccess
from dbus_next.aio import MessageBus
from dbus_next import BusType

BUS_NAME = "xyz.openbmc_project.State.Host"
OBJ_PATH = "/xyz/openbmc_project/state/host0"
IFACE = "xyz.openbmc_project.State.Host"
HOST_STATE = "xyz.openbmc_project.State.Host.HostState.Off"


class Host0(ServiceInterface):
    def __init__(self):
        super().__init__(IFACE)
        self._state = HOST_STATE

    @dbus_property(access=PropertyAccess.READ)
    def CurrentHostState(self) -> "s":
        return self._state


async def main():
    # 连接 system bus（关键）
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

    # 导出对象到正确路径
    bus.export(OBJ_PATH, Host0())

    # 在 system bus 上请求名字（必须与其他组件一致）
    await bus.request_name(BUS_NAME)

    print(f"{BUS_NAME} exported at {OBJ_PATH} on system bus")
    await asyncio.get_event_loop().create_future()


if __name__ == "__main__":
    asyncio.run(main())
