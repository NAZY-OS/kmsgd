# kmsgd - Kernel Message Daemon

A simple daemon that displays kernel messages to a TTY device.

## Installation

```sh
git clone https://github.com/NAZY-OS/kmsgd/kmsgd.git
cd kmsgd
sudo make install
```

## Uninstallation

```sh
sudo make uninstall
```

## Usage

```sh
sudo /sbin/kmsgd start [tty]  # Start daemon with optional TTY parameter
sudo /sbin/kmsgd stop         # Stop daemon
sudo /sbin/kmsgd restart      # Restart daemon
```


## Configuration


For systemd Edit:    /etc/systemd/system/kmsgd.service

For rc Edit:         /etc/rc.d/kmsgd

```sh
/sbin/kmsgd start 10  # For tty10
```



