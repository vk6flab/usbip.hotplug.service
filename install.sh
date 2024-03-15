#!/bin/bash

if [ "$EUID" -ne 0 ]
then
	echo "Please run as root to install the usbip service."
	exit 1
fi

case "$1" in
	client)
		service='attach'
		module='vhci_hcd'
		if [ -z "$2" ]
		then
			host='pi'
		else
			host="$2"
		fi
		;;
	server)
		service='bind'
		module='usbip-host'
		;;
	*)
		printf 'Usage: %s (client [hostname] | server)\n' "$(basename "$0")"
		exit 0
		;;
esac

echo -n "Creating installation directory ."
mkdir -p /opt/usbip
echo ". done."

echo -n "Installing application files ."
cp usbip-${service} /opt/usbip/usbip-${service}
cp usbip-${service}.service /etc/systemd/system/usbip-${service}.service
chmod +x /opt/usbip/usbip-${service}
echo ". done."

if [[ "${service}" == "attach" ]]
then
	echo -n "Setting server hostname to '${host}' ."
	sed -i "s|usbip_server_host_name|${host}|g" /opt/usbip/usbip-${service}
	echo ". done."
fi

echo -n "Loading kernel module '${module}' ."
if modprobe "${module}" >/dev/null 2>&1
then
	echo ". done."
else
	echo ". failed."
	exit 1
fi

echo -n "Reloading systemctl daemon ."
if systemctl daemon-reload >/dev/null 2>&1
then
	echo ". done."
else
	echo ". failed."
	exit 1
fi

echo -n "Enabling usbip-${service} service ."
if systemctl enable usbip-${service} >/dev/null 2>&1
then
	echo ". done."
else
	echo ". failed."
	exit 1
fi

echo -n "Starting usbip-${service} service ."
if systemctl start usbip-${service} >/dev/null 2>&1
then
	echo ". done."
else
	echo ". failed."
	exit 1
fi
