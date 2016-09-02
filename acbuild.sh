#!/bin/sh

acbuild begin
acbuild set-name jianqing.wang/openvpn
acbuild dependency add quay.io/coreos/alpine-sh

acbuild run -- sh -c 'echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories'
acbuild run -- sh -c 'echo "http://dl-4.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories'
acbuild run -- apk add --update openvpn iptables bash easy-rsa
acbuild run -- ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin
acbuild run -- rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

acbuild copy-to-dir bin/* /usr/local/bin/
acbuild run -- sh -c 'chmod +x /usr/local/bin/*'

OPENVPN=/etc/openvpn
echo $OPENVPN | acbuild environment add OPENVPN -
acbuild environment add EASYRSA /usr/share/easy-rsa
echo "$OPENVPN/pki" | acbuild environment add EASYRSA_PKI -
echo "$OPENVPN/vars" | acbuild environment add EASYRSA_VARS_FILE -

echo '{ "set": ["CAP_NET_ADMIN"] }' | acbuild isolator add "os/linux/capabilities-retain-set" -

echo $OPENVPN | acbuild mount add openvpn-conf -

acbuild port add 1194-tcp tcp 1194
acbuild port add 1194-udp udp 1194

acbuild set-exec -- ovpn_run
acbuild write --overwrite openvpn.aci

acbuild end
