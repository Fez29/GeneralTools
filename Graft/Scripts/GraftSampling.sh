#!/bin/bash
while true; do

function GetSample()
{
IP_1='116.202.20.166:28690'
IP_2='85.214.63.205:28690'
IP_3='134.209.151.169:28690'

SN_COUNT="3"

IP=($IP_1 $IP_2 $IP_3 $IP_4 $IP_5)

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if ((${#SN_COUNT[@]}));
		then
		for (( c=1; c<=$SN_COUNT; c++ ));
		do
		IPCOunt=${IP[$c-1]}
		RANDOM_GEN=`echo $RANDOM`
		echo "SN: $IPCOunt PaymentID: $RANDOM_GEN"
		GetSampleSNList=`curl -s http://$IPCOunt/debug/auth_sample/$RANDOM_GEN`
		GetActiveSNList=`curl -s http://$IPCOunt/debug/supernode_list/0`
		GetBlockHeight=`echo -n "$GetSampleSNList" | jq '.result.height'`
		GetPublic=`echo -n "$GetSampleSNList" | jq --arg GetBlockHeight2 $GetBlockHeight '[.result.items[] | {"PublicID": .PublicId, "StakeAmount": .StakeAmount}]'`
		CountT1Tier=`echo -n "$GetActiveSNList" | jq '[.result.items[] | select (.StakeAmount < 900000000000000)]' | jq '.[].PublicId' | jq -s length`
		CountT2Tier=`echo -n "$GetActiveSNList" | jq '[.result.items[] | select (.StakeAmount < 1500000000000000)]' | jq '.[].PublicId' | jq -s length | awk -v var1="$CountT1Tier" '{print $1-var1}'`
		CountT3Tier=`echo -n "$GetActiveSNList" | jq '[.result.items[] | select (.StakeAmount < 2500000000000000)]' | jq '.[].PublicId' | jq -s length | awk -v var1="$CountT1Tier" -v var2="$CountT2Tier" '{print $1 - (var1 + var2)}'`
		CountT4Tier=`echo -n "$GetActiveSNList" | jq '[.result.items[] | select (.StakeAmount > 2500000000000000)]' | jq '.[].PublicId' | jq -s length`
		CreateJSON=`echo "{\"jsonrpc\":\"2.0\",\"id\":0,\"result\":{\"items\": "$GetPublic"}, \"height\": $GetBlockHeight, \"T1\": $CountT1Tier, \"T2\": $CountT2Tier, , \"T3\": $CountT3Tier, \"T4\": $CountT4Tier, , \"SN_IPandPORT\": $IPCOunt}"`
		JSON=`echo -n "$CreateJSON" | jq .`
		echo "T1 = $CountT1Tier"
		echo "T2 = $CountT2Tier"
		echo "T3 = $CountT3Tier"
		echo "T4 = $CountT4Tier"
		echo "$JSON"
		sleep 1
    done;
fi

}
GetSample
sleep 120; #that would mean running the actual script every 2 mins
done