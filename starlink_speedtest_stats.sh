#!/bin/bash

version=1.0
speedtest=false
dishy=false
apikey=""


help() {
    echo "Usage: starlink_speedtest_stats.sh [OPTIONS]";
    echo "";
    echo "-k | --apikey     API Key from Speedtest.StarlinkFans.eu"
    echo "-s | --speedtest  Enable Speedtest (requires Speedtest.net CLI, read README)"
    echo "-d | --dishy      Enable data from Dishy (requires gprcurl, read README)"
    echo "-h | --help       Show this help"
}

while [ "$1" != "" ]; do
    case $1 in
        -k | --key )            shift
                                apikey="$1"
                                ;;
        -s | --speedtest )      speedtest=true
                                ;;
        -d | --dishy )          dishy=true
                                ;;
        -h | --help )           help
                                exit
                                ;;
        * )                     help
                                exit 1
    esac
    shift
done

echo "Starlink Speedtest Stats by StarlinkFans.eu (v$version)"

if [ "$apikey" == "" ]
then
	help
    exit
fi
echo "API Key: $apikey"

api_send_url="http://starlink-fans-speedtest.local/api/send_result/${apikey}"
api_pingservers_url="http://starlink-fans-speedtest.local/api/ping_servers/${apikey}"

# Pinging servers
echo "Get ping servers from ${api_pingservers_url}";
pingservers=($(curl -s ${api_pingservers_url}))

if [ -z "$pingservers" ]
then
	pingservers=($(curl -s ${api_pingservers_url}))
fi

if [ "$pingservers" == "wrong_api_key" ]
then
	echo "Wrong API key"
	exit
fi

if [ "$pingservers" == "dishy_is_not_active" ]
then
	echo "Dishy is not active on Speedtest.StarlinkFans.eu"
	exit
fi

json_ping="{"

while IFS= read -r line; do
	sps_id=$(echo "$line" | jq -r '.sps_id')
	ping_server_host=$(echo "$line" | jq -r '.ping_server_host')
	pingres=$(ping -c 4 "${ping_server_host}" | awk -F '/' 'END {print $5}')
	echo "Ping to [${sps_id}] ${ping_server_host}: ${pingres}"
	json_ping+=" \"$sps_id\":\"$pingres\","
done < <(echo "$pingservers" | jq -c '.[]')

json_ping="${json_ping%,}"

json_ping+="}"

json_ip="{}"
json_ip=$(curl -s https://mojaipadresa.sk/json)


# Get data from Dishy if is allowed
if [ $dishy == true ]
then
    grpcurl --version >/dev/null && echo "Getting data from Dishy..." || { echo -e "\e[31mgrpcurl not found!\e[0m"; exit 1; }
    json_dishy=$(grpcurl -plaintext -emit-defaults -d '{"getStatus":{}}' 192.168.100.1:9200 SpaceX.API.Device.Device/Handle) || dishstatus="{}"
else
    json_dishy="{}"
fi

# Run Speedtest if is allowed
if [ $speedtest == true ]
then
    speedtest -V --accept-license --accept-gdpr >/dev/null && echo "Starting Speedtest..." || { echo -e "\e[31mSpeedtest CLI not found!\e[0m"; exit 1; }
    json_speedtest=$(speedtest  --accept-license --accept-gdpr -f json)
else
    json_speedtest="{}"
fi

# Create JSON and send
jsndata='{"api_key":"'$apikey'","json_ip":'$json_ip',"json_ping":'$json_ping',"json_speedtest":'$json_speedtest',"json_dishy":'$json_dishy',"sss_client_version":'$version'}'

curl -d "$jsndata" -H "Content-Type: application/json" -X POST $api_send_url
