# sonic-bmc
## 重建镜像
	docker rmi obmc-debian12:1 && docker build -t obmc-debian12:1 .
	docker build -f dockers/dockerfile-slim -t bmc:1 .

## 打patch:
	git diff > my_changes.patch
## run docker
	docker run -it --privileged -v /root/sonic-bmc:/app/sonic-bmc:rw -v /var/run/dbus:/var/run/dbus:rw --rm --network=host --name bmc obmc-debian12:1 bash

	docker run -it --privileged -v /root/sonic-bmc:/app/sonic-bmc:rw -v /var/run/dbus:/var/run/dbus:rw --network=host --name bmc obmc-debian12:1 bash

	docker run -it --privileged -v /var/run/dbus:/var/run/dbus:rw --network=host --name runbmc bmc:1 bash

	后台运行
	docker run -d --privileged -v /var/run/dbus:/var/run/dbus:rw --network=host --name runbmc bmc:1 bash

## 初始化配置
	groupadd redfish
	groupadd ipmi
	groupadd hostconsole
	groupadd priv-admin
	groupadd priv-operator
	groupadd priv-user

	password root

	usermod -aG redfish,priv-admin root

	cp supervisor/* /etc/supervisor/conf.d/

## supervisorctl
修改了supervisorctl配置需要执行如下

	supervisorctl reread && supervisorctl update && supervisorctl restart bmcweb
	tail -f /var/log/supervisor/bmcweb.log

## 启动依赖
    phosphor-user-manager
    bmcweb
    entity-manager
    /usr/local/libexec/phosphor-objmgr/mapperx

## 组件简介
### phosphor-user-manager
用户管理
### phosphor-state-manager
该仓库包含用于跟踪和控制OpenBMC中不同对象状态的软件。目前这些对象包括BMC、机箱、主机和虚拟机监视器（Hypervisor）。phosphor-state-manager (PSM) 软件最关键的特性是支持用户发出请求以开机或关机系统。

该软件还负责执行任何恢复策略（例如，在系统断电事件或BMC重置后自动开机），并确保在BMC重启而机箱或主机仍处于开机/运行状态的情况下，其状态能够正确更新。

该仓库还提供了一个命令行工具obmcutil，可在OpenBMC系统内使用，为查询和控制正在OpenBMC系统中运行的phosphor-state-manager应用程序提供基本的命令行支持。该工具本身运行于OpenBMC系统内部，并利用D-Bus API。这些D-Bus API主要用于开发和调试，不面向最终用户。

与所有OpenBMC应用程序一样，phosphor-state-manager中的接口和属性均基于D-Bus接口。这些接口随后被外部接口协议（如Redfish和IPMI）用来向最终用户报告和控制系统状态。
### bmcweb
webserver
### entity-manager
实体管理器是一种用于管理物理系统组件及映射的设计方案将它们连接到BMC内的软件资源。这些资源旨在允许系统在运行时的灵活调整，以及减少需要创建的独立系统配置数量。
### /usr/local/libexec/phosphor-objmgr/mapperx
mapper协助在D-Bus上查找项目

