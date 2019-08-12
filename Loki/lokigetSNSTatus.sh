#!/bin/bash
SN_IP="127.0.0.1"
SN_RPC_PORT="38157"
SN_COUNT="2"
#Testnet Script
Service_Node_Pubkey_1="882a1480cbedb3556959c1c7d8da05e2b5ec752df1066684c6470df5055cfb28"
Service_Node_Pubkey_2="850767204d28b1aa0f8032cb7a74e30d7b88a6538d2098fb6971a0f882c1f96a"
Service_Node_Pubkey_3=""
Service_Node_Pubkey_4=""
Service_Node_Pubkey_5=""

SN_KEY=($Service_Node_Pubkey_1 $Service_Node_Pubkey_2 $Service_Node_Pubkey_3 $Service_Node_Pubkey_4 $Service_Node_Pubkey_5)

while true; do

function GetSample()
{
if ((${#SN_COUNT[@]}));
		then
		for (( c=1; c<=$SN_COUNT; c++ ));
		do

Service_Node_Pubkey=${SN_KEY[$c-1]}
test=`curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result'`
ServiceNodes=`curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}'`
ServiceNodesCheck=`echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)'`
CheckUptimeProofs=`echo -n $ServiceNodesCheck | jq '.last_uptime_proof'`
LastUpdateTime=`date -d @$CheckUptimeProofs +%H:%M:%S`
CurrentTime3=`date -u +%s`
TimeSubtract=$(("$CurrentTime3"-"$CheckUptimeProofs"))
TimeSinceLastUpdate=`date -d @$TimeSubtract +%M:%S`

Active=`if (($TimeSubtract < 3900))
	then
	echo "TRUE"
	else
	echo "false"
	fi`

#echo "'$ServiceNodesCheck'"
#echo "$CheckUptimeProofs"
#echo "$TimeSubtract"
#echo "$CurrentTime3 & $CheckUptimeProofs"
#echo "LastUpdate: $TimeSinceLastUpdate"
#echo "$Active"

CreateJSON=`echo "{\"jsonrpc\":\"2.0\",\"id\": 0,\"result\":{\"items\": {\"ServiceNodeActive\": \"$Active\", \"LastUpdateTime\": \"$TimeSinceLastUpdate\"} }, \"PubKey\": \"$Service_Node_Pubkey\"}"`
JSON=`echo -n "$CreateJSON" | jq .`
echo -n "$JSON"

sleep 1
    done;
fi

}
GetSample
sleep 120; #that would mean running the actual script every 5 mins
done

