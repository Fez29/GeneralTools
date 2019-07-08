#Testnet Script
Service_Node_Pubkey="882a1480cbedb3556959c1c7d8da05e2b5ec752df1066684c6470df5055cfb28"
test=`curl -s -X POST http://127.0.0.1:38157/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result'`
ServiceNodes=`curl -s -X POST http://127.0.0.1:38157/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}'`
ServiceNodesCheck=`echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)'`
CheckUptimeProofs=`echo -n $ServiceNodesCheck | jq '.last_uptime_proof'`
LastUpdateTime=`date -d @$CheckUptimeProofs +%H:%M:%S`
CurrentTime3=`date -u +%s`
TimeSubtract=$(("$CurrentTime3"-"$CheckUptimeProofs"))
TimeSinceLastUpdate=`date -d @$TimeSubtract +%M:%S`


echo "'$GetInfo'"
echo "'$ServiceNodesCheck'"
echo "$CheckUptimeProofs"
echo "$TimeSubtract"
echo "$CurrentTime3 & $CheckUptimeProofs"
echo "$TimeSinceLastUpdate"