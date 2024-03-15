#!/bin/bash

if [ "$EUID" -ne 0 ]
then
	echo "Please run as root to remove the usbip service."
	exit 1
fi

for service in 'bind' 'attach'
do
	if [ -f /etc/systemd/system/usbip-${service}.service ]
	then
		echo -n "Stopping usbip-${service} service ."
		if systemctl stop usbip-${service} >/dev/null 2>&1
		then
			echo ". done."
		else
			echo ". failed."
			exit 1
		fi

		echo -n "Disabling usbip-${service} service ."
		if systemctl disable usbip-${service} >/dev/null 2>&1
		then
			echo ". done."
		else
			echo ". failed."
			exit 1
		fi

		echo -n "Removing application files ."
		rm -f /etc/systemd/system/usbip-${service}.service
		rm -f /opt/usbip/usbip-${service}
		echo ". done."

		echo -n "Removing installation directory ."
		if rmdir /opt/usbip >/dev/null 2>&1
		then
			echo ". done."
		else
			echo ". failed."
		fi

		echo -n "Reloading systemctl daemon ."
		if systemctl daemon-reload >/dev/null 2>&1
		then
			echo ". done."
		else
			echo ". failed."
		fi
	fi
done

