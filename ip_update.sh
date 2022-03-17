#!/bin/bash

# Author: Atit Kharel

cr=$'\r'
read -p "Cloudflare Email: " AUTH_EMAIL
read -p "Cloudflare API Key: " -s AUTH_KEY 
echo ""
read -p "Domain Name: " DOMAIN
read -p "Subdomain Name: " SUBDOMAIN
read -p "Record Type (A or AAAA): " RECORD_TYPE
read -p "Proxy Status (true or false): " PROXY_STATUS

# get ipv6 and ipv4 address of the system from api
IPV6_ADDRESS=$(\
    curl -s -6 https://ifconfig.co/ip \
)
if [[ -z "$IPV6_ADDRESS" ]]; then
    echo "IPV6 Address can't be determined" 1>&2
    exit 1
fi

IPV4_ADDRESS=$(\
    curl -s -4 https://ifconfig.co/ip \
)
if [[ -z "$IPV4_ADDRESS" ]]; then
    echo "IPV4 Address can't be determined" 1>&2
    exit 1
fi

# get Zone ID of the domain
ZONE_ID=$(\
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=active" \
        -H "X-Auth-Email: $AUTH_EMAIL" \
        -H "X-Auth-Key: $AUTH_KEY" \
        -H "Content-Type: application/json" \
     | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['result'][0]['id'])" \
)
if [[ -z "$ZONE_ID" ]]; then
    echo "Zone ID can't be determined" 1>&2
    exit 1
fi
echo "Zone ID:" $ZONE_ID
ZONE_ID="${ZONE_ID%$cr}"

# Get Record ID of the subdomain
RECORD_ID=$(\
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$SUBDOMAIN&type=$RECORD_TYPE" \
        -H "X-Auth-Email: $AUTH_EMAIL" \
        -H "X-Auth-Key: $AUTH_KEY" \
        -H "Content-Type: application/json" \
     | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['result'][0]['id'])" \
)
if [[ -z "$RECORD_ID" ]]; then
    echo "Record ID can't be determined" 1>&2
    exit 1
fi
echo "Record ID:" $RECORD_ID
RECORD_ID="${RECORD_ID%$cr}"

if [ $RECORD_TYPE == "AAAA" ]
then
    echo "Your IPv6 Address: " $IPV6_ADDRESS
    IPV6_ADDRESS="${IPV6_ADDRESS%$cr}"
    IP_ADDRESS=$IPV6_ADDRESS
else
    echo "Your IPv4 Address: " $IPV4_ADDRESS
    IPV6_ADDRESS="${IPV4_ADDRESS%$cr}"
    IP_ADDRESS=$IPV4_ADDRESS
fi

IP_UPDATE_RESULT=$(\
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "X-Auth-Email: $AUTH_EMAIL" \
        -H "X-Auth-Key: $AUTH_KEY" \
        -H "Content-Type: application/json" \
        --data '{"type":"'"$RECORD_TYPE"'","name":"'"$SUBDOMAIN"'","content":"'"$IP_ADDRESS"'","ttl":1,"proxied":'${PROXY_STATUS}'}' \
    | \
        python3 -c "import sys, json; print(json.load(sys.stdin)['success'])" \
)
if [[ -z "$IP_UPDATE_RESULT" ]]; then
    echo "IP was not Updated" 1>&2
    exit 1
fi
echo "Success:" $IP_UPDATE_RESULT