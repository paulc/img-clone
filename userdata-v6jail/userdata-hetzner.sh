#!/bin/sh

set -o pipefail
set -o errexit
set -o nounset

# Ensure /usr/local/bin on PATH
PATH="${PATH}:/usr/local/bin"

# Get network configuration from metadata
export IPV4_HOST=$(tr -d \" < /var/hcloud/public-ipv4)
export IPV6_HOST=$(/usr/local/bin/python3 -c 'import json;c=json.load(open("/var/hcloud/network-config"));print([x["address"].split("/")[0] for x in c["config"][0]["subnets"] if x.get("ipv6")][0])')
export IPV6_PREFIXLEN=128
export IPV4_ROUTE=
export IPV6_ROUTE=
# Get /65 subnet for jail network
export NAT64_NETWORK=$(/usr/local/bin/python3 -c 'import sys,ipaddress;print(next(list(ipaddress.IPv6Network(sys.argv[1],False).subnets())[1].hosts()))' ${IPV6_ADDRESS}/64)
export NAT64_PREFIXLEN=65
export ROOT_PK=
export HOSTNAME=$(/usr/local/bin/python3 -c 'import yaml;print(yaml.safe_load(open("/var/hcloud/cloud-config"))["fqdn"])')}
export MODE=ROUTED

. ./utils.sh
( . ./run.sh | tee /var/log/userdata.log ) || /bin/sh

