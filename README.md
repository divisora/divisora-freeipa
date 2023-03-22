# Instructions
This is a mockup of how you could create and run FreeIPA.

## Build
```
git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
podman build -t freeipa-alma9 -f Dockerfile.almalinux-9 .
```

## Run 
```
# NOTICE! Do not run FreeIPA on the same machine as divisora-node-manager
# NOTICE! Change ip / name as needed

root@ipa:~$ hostnamectl hostname ipa.domain.internal
root@ipa:~$ sudo mkdir -p /opt/divisora_freeipa/data"
root@ipa:~$ sudo chown -R $USER: /opt/divisora_freeipa"
root@ipa:~$ podman run --name divisora_freeipa_installer --dns=127.0.0.1 -ti -h ipa.domain.internal -v /opt/divisora_freeipa/data:/data:Z freeipa-alma9 exit-on-finished"
root@ipa:~$ podman rm divisora_freeipa_installer"
root@ipa:~$ sudo sh -c 'echo "net.ipv4.ip_unprivileged_port_start=53" >> /etc/sysctl.conf'"
root@ipa:~$ sudo sysctl --system"
root@ipa:~$ podman run -d --name divisora_freeipa --dns=127.0.0.1 -h ipa.domain.internal -p 10.0.0.1:53:53/udp -p 10.0.0.1:53:53/tcp -p 8080:80/tcp -p 8443:443/tcp -p 389:389/tcp -p 636:636/tcp -p 88:88/tcp -p 464:464/tcp -p 88:88/udp -p 464:464/udp -p 123:123/udp --read-only --sysctl net.ipv6.conf.all.disable_ipv6=0 -v /opt/divisora_freeipa/data:/data:Z localhost/freeipa-alma9"

change /etc/systemd/resolved.conf to point to 10.0.0.1
```

## Setup up permissions
### ipa.domain.internal
```
root@ipa:~$ kinit admin

# Create a group and add Nodes
root@ipa:~$ ipa hostgroup-add --desc="Nodes for cubicles" nodes
root@ipa:~$ ipa hostgroup-add-member --hosts=node-1.domain.internal nodes

# Add cubicle
root@ipa:~$ ipa host-add cubicle-user1-ubuntu.domain.internal --force
root@ipa:~$ ipa host-allow-create-keytab cubicle-user1-ubuntu.domain.internal --hostgroups=nodes
root@ipa:~$ ipa host-allow-retrieve-keytab cubicle-user1-ubuntu.domain.internal --hostgroups=nodes
```

### node-1.domain.internal
```
# Try retrieving keytabs with the node-1 keytab
root@node-1:~$ mkdir -p /opt/keytabs
root@node-1:~$ kdestroy
root@node-1:~$ kinit -k -t /etc/krb5.keytab
root@node-1:~$ ipa-getkeytab -v -Y GSSAPI -s ipa.domain.internal -p host/cubicle-user1-ubuntu.domain.internal -k /opt/keytabs/cubicle-user1-ubuntu.domain.internal.keytab
root@node-1:~$ klist -k /opt/keytabs/cubicle-user1-ubuntu.domain.internal.keytab

# Remove it (divisora-node-manager will retrive it later)
root@node-1:~$ rm /opt/keytabs/cubicle-user1-ubuntu.domain.internal.keytab
```