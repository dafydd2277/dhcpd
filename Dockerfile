FROM ubuntu:latest

# MAINTAINER is deprecated. See
# https://docs.docker.com/engine/reference/builder/#maintainer-deprecated
LABEL com.dafydd.image.author="dafydd@dafydd.com"


# DEBIAN_FRONTEND doesn't need to be a separate ENV setting. See
# https://docs.docker.com/engine/reference/builder/#env
RUN DEBIAN_FRONTEND=noninteractive \
 apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install apt-utils \
 && rm /etc/dpkg/dpkg.cfg.d/excludes \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install dumb-init isc-dhcp-server man \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*


COPY ./bin/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

