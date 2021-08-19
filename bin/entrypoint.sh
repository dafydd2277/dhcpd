#!/bin/bash

set -e


# Support docker run --init parameter which obsoletes the use of dumb-init,
# but support dumb-init for those that still use it without --init
if [ -x "/dev/init" ]; then
    run="exec"
else
    run="exec /usr/bin/dumb-init --"
fi


data_dir="/data"
if [ ! -d "$data_dir" ]; then
    echo "Please ensure '$data_dir' folder is available."
    echo 'If you just want to keep your configuration in "data/", add -v "$(pwd)/data:/data" to the docker run command line.'
    exit 1
fi

dhcpd_conf="$data_dir/dhcpd.conf"
if [ ! -r "$dhcpd_conf" ]; then
    echo "Please ensure '$dhcpd_conf' exists and is readable."
    echo "Run the container with arguments 'man dhcpd.conf' if you need help with creating the configuration."
    exit 1
fi

uid=$(stat -c%u "$data_dir")
gid=$(stat -c%g "$data_dir")
if [ $gid -ne 0 ]; then
    groupmod -g $gid dhcpd
fi
if [ $uid -ne 0 ]; then
    usermod -u $uid dhcpd
fi

[ -e "$data_dir/dhcpd.leases" ] || touch "$data_dir/dhcpd.leases"
chown dhcpd:dhcpd "$data_dir/dhcpd.leases"
if [ -e "$data_dir/dhcpd.leases~" ]; then
    chown dhcpd:dhcpd "$data_dir/dhcpd.leases~"
fi

$run /usr/sbin/dhcpd -$DHCPD_PROTOCOL -f -d --no-pid -cf "$data_dir/dhcpd.conf" -lf "$data_dir/dhcpd.leases"

