# Plug and Play DHCP Container

> 2021-08-06: This is a WORK IN PROGRESS. If you clone this project,
don't expect anything to work.


This a split fork of [networkboot/dhcpd-docker][ref001] at commit
[2ca8dcf9][ref002]. This fork makes three modifications to ease its
incorporation into an Enterprise environment.

1. Using a named volume, the source `dhcpd.conf` file is kept in the
`/srv` [directory structure][ref003] in a way that minimizes file name
or location collisions.
1. Output is logged into the `/var/log` [directory structure][ref004]
via another named volume. This allows administrators to manage dhcpd
logging with minimal configuration changes to their existing system.
1. SELinux customization files are included in the
[GitHub repository][ref005] to allow this container to run in an
SELinux `enforcing` environment.

This container uses ISC DHCP server which is bundled with the latest Ubuntu
LTS distribution.

[ref001]: https://hub.docker.com/r/networkboot/dhcpd
[ref002]: https://github.com/networkboot/docker-dhcpd/commit/2ca8dcf99743808fa3bbc401698bd64d4fb28b07
[ref003]: https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s17.html
[ref004]: https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s10.html
[ref005]: https://github.com/dafydd2277/pnp-dhcpd


## How to use

1.  Install Docker or Podman as appropriate for your underlying
operating system. This fork was developed on [CentOS 8][ref011] using
[podman][ref012].
1.  Create a `dhcpd.conf` file
[appropriate for your environment][ref021], and place that file in
`/srv/cnt/dhcpd/dhcpd.conf`.
1.  As root on the host system, execute `mkdir --parents
/var/log/cnt-dhcpd/`.
1.  Clone this repository onto your host system, and `cd` into the
cloned directory.
1.  If you're running in a SELinux `enforcing` environment, execute
    ```
    semodule -i php_dhcpd.cil \
    /usr/share/udica/templates/{base_container.cil,net_container.cil,home_container.cil}
    ```
    See [here][ref013] for more information.
1.  As root, execute `podman-compose up` or `docker-compose up`, as appropriate
for your underlying OS.

[ref011]: https://centos.org/
[ref012]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/index
[ref013]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/creating-selinux-policies-for-containers_using-selinux



## DHCPv6

> dafydd2277 says: This is straight from `networkboot/docker-dhcpd`.
I have not tested this with my fork. I suspect you will only need to
modify the `DHCPD_PROTOCOL` environment variable in `compose.yaml`. If
that doesn't set you up properly, please create an Issue. Or, better
yet, a Pull Request with whatever modifications you needed to make for
DHCPv6 to work.

To use a DHCPv6-Server you have to pass `DHCPD_PROTOCOL=6` as enviroment variable

`docker run -it --rm --init -e DHCPD_PROTOCOL=6 --net host -v "$(pwd)/data":/data networkboot/dhcpd eth0`


## Notes

- If you want to try merging this work with the LDAP configuration at
`networkboot\docker-dhcpd`, be my guest. I don't have the resources to
try it. If you get it work, I'll happily take a pull request
incorporating whatever modifications or merges you needed to do to
combine the feature sets.

- The entrypoint script from `networkboot/docker-dhcpd` has been
heavily modified to suit the three changes built in to this fork.


## Acknowledgements

This image uses the following software components:

- Ubuntu Linux distribution from <https://www.ubuntu.com>.
- ISC DHCP server from <https://www.isc.org/downloads/dhcp/>.


## Copyright & License

This project is copyright 2021 David Barr <dafydd@dafydd.com>,
extending work that is copyright 2017-2021 Robin Smidsrød
<robin@smidsrod.no>.

It is licensed under the Apache 2.0 license.

See the file LICENSE for full legal details.

