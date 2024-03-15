# USBip Hot Plug Implementation
This project implements hot plugging for USB devices over TCP/IP. The project creates a `systemctl` service on both the client and the server that binds all available devices.

Both installation and un-installation scripts are provided. The service files load kernel modules as required.

During installation, the required kernel modules are loaded. If this fails, it is likely that the `usbip` package in your distribution is not installed. Note that this needs to be installed on both the client and the server.

On Debian (derived) distributions the command to install `usbip` is shown below.:

* `apt-get install usbip`

To use this software you need to install this on both the client and the server.

# Security Warning
There is no security or authentication associated with `usbip`. This tool uses `usbip` as the means to bind and attach to services. Technically this could be achieved across the Internet, but anyone with access to the port could connect to the USB device.

There are reports of users tunnelling across `ssh`. This might address security issues, but the application as it is currently implemented will likely require tweaking to access local ports that are tunnelled to the server. I have not attempted this.

# How it works
When the `install.sh` script is run, the application is installed in `/opt/usbip`, and a service is installed, activated and started.

When the `uninstall.sh` script is run, the service is stopped, removed and the application and installation directory are removed.


## Server
The `usbip bind` command is run every 10 seconds for each locally available USB device. You can control the service using:

* `systemctl start|stop|disable usbip-bind`

### To install:

* `sudo ./install.sh server`

### To remove:

* `sudo ./uninstall.sh`


## Client
The `usbip attach` command is run every 10 seconds for each published device on the server. You can control the service using:

* `systemctl start|stop|disable usbip-attach`

### To install:
Determine the FQDN for the server and use it with the installation command.

* `sudo ./install.sh client FQDN_server`

### To remove:

* `sudo ./uninstall.sh`


# Notes
When a device that is bound and attached remotely is unplugged, the device is automatically detached on the client and unbound on the host. After that the state is the same as if it was never bound or attached.

The `usbip` commands for binding (on the host) and attaching (on the client) may be run repeatedly with the same arguments. While this issues an error message on already bound or attached devices, nothing bad happens! So one can just install background scripts that will repeatedly bind and attach the devices.

There are two delays when a USB device is plugged in. Each can be up to 10 seconds. Worst case scenario, 20 seconds will pass between a device being plugged in and it becoming available on the client.

Unplugging is almost instantaneous, managed by `usbip` itself.

# Roadmap

* Implement tunnelling across an insecure network.

# Credit
This code was presented as an answer on stackexchange. It mostly worked, but it hard-coded USB devices and was missing installation and removal scripts. There were several other (little) issues, in-part resolved by another answer on the same page.

* Origin: https://unix.stackexchange.com/a/406848
* Fixes: https://unix.stackexchange.com/a/558536

# Authors
* [Onno Benschop](mailto:onno@itmaze.com.au)
* [Sunday](https://unix.stackexchange.com/users/43571/sunday)
* [Magnus](https://unix.stackexchange.com/users/387404/magnus)
