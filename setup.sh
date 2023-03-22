#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]
  then echo "Please do not run as root"
  exit
fi

mkdir -p /opt/divisora_freeipa/data
cp ipa-server-install-options /opt/divisora_freeipa/data/

git clone https://github.com/freeipa/freeipa-container.git
(cd freeipa-container && podman build -t freeipa-alma9 -f Dockerfile.almalinux-9 .)

# podman run --name divisora_freeipa --dns=127.0.0.1 -h ipa.domain.internal -p 10.0.0.1:53:53/udp -p 10.0.0.1:53:53/tcp -p 80:80/tcp -p 443:443/tcp -p 389:389/tcp -p 636:636/tcp -p 88:88/tcp -p 464:464/tcp -p 88:88/udp -p 464:464/udp -p 123:123/udp --read-only --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /opt/divisora_freeipa/data:/data:Z localhost/freeipa-alma9