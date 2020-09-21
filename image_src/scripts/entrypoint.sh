#!/bin/bash

INIT_DIR="/app/init"
USER_FILE="/app/users"
ROOT_DIR="/etc/openvpn"
SERVERS=()  # Lists conf files in server folder


# Functions

### Util functions

function check_files {  # TODO this is shit

  # Check file structure
  local struct=$(find ${ROOT_DIR} -maxdepth 1 -type d)
  local missing=()
  local j=0
  if [[ ! $struct =~ "certs" ]];    then missing[j]="certs";    ((j=j+1)); fi
  if [[ ! $struct =~ "servers" ]];   then missing[j]="servers";   ((j=j+1)); fi
  if [[ ! ${#missing[*]} -eq 0 ]]
  then
    echo "Missing Folder(s): ${missing[*]}"
    exit 1
  fi

}

function parse_servers {

  # Check conf files
  local i=0
  for path in $(find ${ROOT_DIR}/servers -name '*.conf')
  do
    SERVERS[i]=$path
    ((i=i+1))
  done
  if [[ i -eq 0 ]]
  then
    echo "Error parsing server files, or there are none."
    exit 1
  fi

}

function folder_init {

  echo "Starting folder initialization."
  echo "Existing files are only overwritten if there are newer versions available."

  # Create dirs
  mkdir ${ROOT_DIR}/certs
  mkdir ${ROOT_DIR}/certs/server
  mkdir ${ROOT_DIR}/certs/clients
  mkdir ${ROOT_DIR}/ccd
  mkdir ${ROOT_DIR}/client-configs
  mkdir ${ROOT_DIR}/servers

  # Default server conf
  cp -r ${INIT_DIR}/udp.conf.template ${ROOT_DIR}/servers/udp.conf
  # Default client conf
  cp -r ${INIT_DIR}/base.conf.template ${ROOT_DIR}/client-configs/base.conf

  echo "Initialization finished."
  echo "Please create certs, keys and dh params now."
  exit 0

}

### Create functions

function create_dh_primes {
  echo "Creating DH primes..."
  openssl dhparam -out ${ROOT_DIR}/dh.pem $1
  exit 0
}

function create_tls_key {
  echo "Creating TLS key..."
  openvpn --genkey --secret ${ROOT_DIR}/ta.key
  exit 0
}

function create_ovpn {
  echo "Creating OVPN client config..."
  make_config.sh $1
  echo "Done. Outfile: ${ROOT_DIR}/client-configs/${1}.ovpn"
  exit 0
}

### run function

function run {

  echo "Setting up PAM users..."
  if [ ! -f ${USER_FILE} ]
  then
    echo "Error: Cannot read users file from ${USER_FILE}"
    exit 1
  fi
  while IFS= read -r line
  do
    IFS=':'; read -ra creds <<< ${line}
    useradd -MNs /dev/null ${creds[0]}
    echo "${creds[0]}:${creds[1]}" | chpasswd
  done < ${USER_FILE}
  echo "Done."

  echo "Setting up NAT routes..."
  iptables -t nat -A POSTROUTING -s 192.168.180.0/24 -o eth0 -j MASQUERADE

  echo "Checking neccessairy files..."
  check_files

  echo "Parsing server files..."
  parse_servers

  echo "Starting OpenVPN..."
  # Itarate through server confs found out by parse_servers
  for conf_path in ${SERVERS[@]}
  do
    IFS='/'; read -ra temp <<< ${conf_path}
    IFS='.'; read -ra temp2 <<< ${temp[-1]}
    IFS=' '
    local conf_name_only=${temp2[0]}   # part between last / and .conf
    openvpn \
      --config ${conf_path} \
      --daemon ovpn-${conf_name_only} \
      --cd ${ROOT_DIR} \
      --script-security 2
  done
  # Block execution
  tail -f /var/log/openvpn/openvpn.log
  exit 0

}


# Main (parse arguments)

case $1 in
  "run")
    run
    ;;
  "init")
    folder_init
    ;;
  "create")
    case $2 in
      "dh")
        if [[ -n $3 ]]
        then
          create_dh_primes $3
        else
          echo "Error: Third argument has to be the DH size"
        fi
        ;;
      "ovpn"|"client-config")
        if [[ -n $3 ]]
        then
          create_ovpn $3
        else
          echo "Error: Third argument has to be the client certs cn"
        fi
        ;;
      "tls-key"|"ta"|"ta-key")
        create_tls_key
        ;;
      *)
        echo "Error parsing second argument"
        ;;
    esac
    ;;
  *)
    echo "Error parsing first argument"
    ;;
esac
exit 0