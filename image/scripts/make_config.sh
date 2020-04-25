#!/bin/bash

# First argument: Client identifier

ROOT_DIR="/etc/openvpn"
OUTPUT_DIR="/etc/openvpn/client-configs"
BASE_CONFIG="/etc/openvpn/client-configs/base.conf"

cat ${BASE_CONFIG} \
    <(echo -e '\n\n<ca>') \
    ${ROOT_DIR}/certs/server/ca.crt \
    <(echo -e '</ca>\n\n<cert>') \
    ${ROOT_DIR}/certs/clients/${1}.crt \
    <(echo -e '</cert>\n\n<key>') \
    ${ROOT_DIR}/certs/clients/${1}.key \
    <(echo -e '</key>\n\n<tls-crypt>') \
    ${ROOT_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/${1}.ovpn