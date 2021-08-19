# Plug and Play DHCP Container

This a disconnected fork of [networkboot/dhcpd][ref001] at commit
[2ca8dcf9][ref002]. This fork makes two major modifications and a
bunch of minor modifications to ease this container's incorporation
into an Enterprise environment.

1. A `compose.yaml` file and a `.env` file are available at
[https://github.com/dafydd2277/dhcpd][ref003] for virtually "instant
on" operation via `docker-compose up -d`.
1. Output is logged into via the `rsyslog` plugin. This allows
administrators to manage dhcpd logging with minimal configuration
changes to their existing system.

This container uses ISC DHCP server which is bundled with the latest Ubuntu
LTS distribution.

[ref001]: https://hub.docker.com/r/networkboot/dhcpd
[ref002]: https://github.com/networkboot/docker-dhcpd/commit/2ca8dcf99743808fa3bbc401698bd64d4fb28b07
[ref003]: https://github.com/dafydd2277/dhcpd


## How to use

1. Install Docker or Podman as appropriate for your underlying
operating system. This fork was developed on [CentOS 8][ref011] using
[docker][ref012].
1. Add or uncomment these lines in `/etc/rsyslog.conf`.
    ```
    module(load="imudp") # needs to be done just once
    input(type="imudp" port="514")

    module(load="imtcp") # needs to be done just once
    input(type="imtcp" port="514")
    ```
    If you want to limit `rsyslog` to only listen to specific
    interfaces, change the `input` lines to something like this:
    ```
    input(type="imudp" port="514" address="192.168.1.1")
    input(type="imtcp" port="514" address="192.168.1.1")
    ```
    See [here for UDP][ref015], and [here for TCP][ref016].
1. Create [a location to hold the container files][ref013].
    ```
    mkdir /srv/containers
    cd /srv/containers
    git clone git@github.com:dafydd2277/dhcpd.git
    cd dhcpd
    ```
1. Copy the rsyslog file from the project and restart `rsyslog`.
    ```
    cp -i ./etc/rsyslog.d/10-containers.conf /etc/rsyslog.d/
    systemctl restart rsyslog
    ```
    The `-i` switch is to force a confirmation question if a file
    called `10-containers.conf` already exists in that directory. If
    that is the case, merge the two files as appropriate for your
    environment.
1. Copy the logrotate file from the project.
    ```
    cp -i ./etc/logrotate.d/containers /etc/logrotate.d/
    ```
    The `-i` switch is to force a confirmation question if a file
    called `containers` already exists in that directory. If that is
    the case, merge the two files as appropriate for your environment.
1. Modify `.env` to suit your environment.
1. Modify `compose.yaml` to suit your environment. Note that you have
to uncomment the appropriate `ports` entry. If you want to listen to
more than one interface, but not all interfaces, you can c/p several
copies of the second option, modifying the `${s_host_internal_ip}`
value as appropriate.
1. [Modify][ref014] `./etc/dhcp/dhcpd.conf` to suit your environment.
    * Pay particular attention to the opportunty to set up an RNDC
    key to allow you to have `dhcpd` automatically update `named` to
    add DNS entries as new hosts join the subnet. Execute these
    commands to generate the key.
        ```
        cd /tmp
        dnssec-keygen -a hmac-md5 -b 256 -n USER dhcpupdate
        egrep '^Key' Kdhcpupdate.*.private | cut -d' ' -f2
        ```
        Replace the `FIXME` in the `dhcpd.conf` file with the resulting
        hash. You'll use the same hash in `named.conf` to give `dhcpd`
        the privilege of updating DNS records automatically. Don't
        forget to `rm -f Kdhcpupdate*` when you're done.
    * Have a good look through the file to make sure you have updated
    every IP address to suit your environment.
1.  As root, execute `docker-compose up -d`.

[ref011]: https://centos.org/
[ref012]: https://docs.docker.com/engine/install/centos/ 
[ref013]: https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s17.html
[ref014]: https://linux.die.net/man/5/dhcpd.conf
[ref015]: https://rsyslog.readthedocs.io/en/latest/configuration/modules/imudp.html
[ref016]: https://rsyslog.readthedocs.io/en/latest/configuration/modules/imtcp.html


## DHCPv6

> dafydd2277 says: This is straight from `networkboot/dhcpd`.
I have not tested this with my fork. I suspect you will only need to
modify the `DHCPD_PROTOCOL` environment variable in `.env` and/or
`compose.yaml`. If that doesn't set you up properly, please create an
Issue. Or better yet, a Pull Request with whatever modifications you
needed to make for DHCPv6 to work.

To use a DHCPv6-Server you have to pass `DHCPD_PROTOCOL=6` as enviroment variable

`docker run -it --rm --init -e DHCPD_PROTOCOL=6 --net host -v "$(pwd)/data":/data networkboot/dhcpd eth0`


## Notes

- If you want to try merging this work with the LDAP configuration at
`networkboot/dhcpd`, be my guest. I don't have the resources to
try it. If you get it work, I'll happily take a PR incorporating
whatever modifications or merges you needed to do to combine the
feature sets.

- The entrypoint script from `networkboot/dhcpd` has been
heavily modified to suit the changes built in to this fork.


## Acknowledgements

This image uses the following software components:

- Ubuntu Linux distribution from <https://www.ubuntu.com>.
- ISC DHCP server from <https://www.isc.org/downloads/dhcp/>.
- The first hints at using the `rsyslog` driver came from
https://techroads.org/docker-logging-to-the-local-os-that-works-with-compose-and-rsyslog/


## Copyright & License

This project is copyright 2021 David Barr <dafydd@dafydd.com>,
extending work that is copyright 2017-2021 Robin Smidsrød
<robin@smidsrod.no>.

It is licensed under the Apache 2.0 license. See the
[LICENSE file][ref051] for details.

[ref051]: https://github.com/dafydd2277/dhcpd/blob/main/LICENSE

