#!/bin/bash

THIS_DIR=$(cd $(dirname ${BASH_SOURCE}) && pwd)

source ${THIS_DIR}/lib_common
source ${THIS_DIR}/lib_crypt

VPN_CONF_INTERFACE=wg-client

if [ $# -gt 1 ]; then
    VPN_CONF_INTERFACE=$2
fi

# configs:
SECRET_STORAGE_PATH=${HOME}/._Personal
VPN_CONF_NAME=${VPN_CONF_INTERFACE}.conf
MASTER_KEY_TMP=/tmp/master.XXXXXX

if [[ -z $1 ]]; then
    print_error "Usage $(basename ${BASH_SOURCE}) start|stop"
    exit 1
elif [[ ! $1 =~ start|stop ]]; then
    print_error "Invalid key. Usage $(basename ${BASH_SOURCE}) start|stop"
    exit 2
fi

if [[ ! -f ${HOME}/.ssh/id_rsa ]]; then 
    print_error "There is no key to encrypt VPN config"
else
    SECURE_TMP=$(mktemp ${MASTER_KEY_TMP})
    echo -n "MASTER Key. "
    SECURE_MEMO=$(open_default_key)
    if [ ! -n "${SECURE_MEMO}" ]; then
        print_error "Incorrect passphrase"
        exit 5
    fi
    echo -n ${SECURE_MEMO} > ${SECURE_TMP}
fi

init_sudo

VPN_CONFIG=${SECRET_STORAGE_PATH}/${VPN_CONF_NAME}
if [[ -f ${VPN_CONFIG}.~ ]]; then
    ${UNSUDO} ccdecrypt -k ${SECURE_TMP} -S .~ ${VPN_CONFIG}.~
    cleanup_key ${SECURE_TMP}
elif [[ ! -f ${VPN_CONFIG} ]]; then
    print_error "There is no VPN config"
    exit 2
fi

IS_WG_UP=$(ifconfig ${VPN_CONF_INTERFACE} 2>/dev/null)

if [ -n "${IS_WG_UP}" ]; then
    ${SUDO} wg-quick down ${VPN_CONFIG} 1>&2 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "WireFuard has stopped."
    fi
fi

if [[ $1 == "start" ]]; then
    ${SUDO} wg-quick up ${VPN_CONFIG} 1>&2 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "WireFuard has started. Current IP is $(dig +short myip.opendns.com @resolver1.opendns.com)"
    fi
else
    echo "Current IP is $(dig +short myip.opendns.com @resolver1.opendns.com)"
fi
if [ ! -f ${SECURE_TMP} ]; then
    SECURE_TMP=$(mktemp ${MASTER_KEY_TMP})
    if [ ! -n "${SECURE_MEMO}" ]; then
        print_error "There is no key to encrypt/decrypt"
        exit 2
    fi
    echo -n ${SECURE_MEMO} > ${SECURE_TMP}
    SECURE_MEMO='Empty'
fi
${UNSUDO} ccencrypt -k ${SECURE_TMP} -S .~ ${VPN_CONFIG}
cleanup_key ${SECURE_TMP}
