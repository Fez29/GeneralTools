    ServiceNodes=$(curl -s -X POST http://$ServiceNode_IP:$ServiceNode_RPC_Port/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
    ServiceNodesCheck=$(echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
    TimeStamp=$(env TZ=UTC date '+%Y-%m-%dT%H:%M:%S.%3NZ')
    echo -n "ServiceNodesCheck" > result.txt
    TimeStampSeconds=$(echo $(($(date +%s) - $(date +%s -r result.txt))))

function GetSNStatsFromLokiBlocks(){
    TimeSinceLastModified=$(echo $(($(date +%s) - $(date +%s -r result.txt))))
    ServiceNode_IP="lokiblocks.com"
    ServiceNode_RPC_Port="22023"
    JSON_headers="{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}"
    Service_Node_Pubkey="$1"
    TimeStampSeconds=$(echo $(($(date +%s) - $(date +%s -r result.txt)))) 
    ServiceNodes=$(curl -s -X POST http://$ServiceNode_IP:$ServiceNode_RPC_Port/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
    ServiceNodesCheck=$(echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
    echo -n "$ServiceNodesCheck" > $Service_Node_Pubkey.txt
}

function GetSNStatsFromCustomNode(){
    ### LokiBlocksCheck
    ServiceNode_IP="$2"
    ServiceNode_RPC_Port="$3"
    JSON_headers="{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}"
    Service_Node_Pubkey="$1"
    ServiceNodes=$(curl -s -X POST http://$ServiceNode_IP:$ServiceNode_RPC_Port/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
    ServiceNodesCheck=$(echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
    echo -n "$ServiceNodesCheck" > $Service_Node_Pubkey.txt
}

function lastUptimeProof(){
    ServiceNodes=$(curl -s -X POST http://$ServiceNode_IP:$ServiceNode_RPC_Port/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
    ServiceNodesCheck=$(echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
    CheckUptimeProofs=$(echo -n $ServiceNodesCheck | jq '.last_uptime_proof')
    LastUpdateTime=$(date -d @$CheckUptimeProofs +%H:%M:%S)
    TimeSubtract=$(("$CurrentTime"-"$CheckUptimeProofs"))
    TimeSinceLastUpdate=$(env TZ=UTC date -d @$TimeSubtract +%H:%M:%S)
}

if [ "GetSNStatsFromLokiBlocks" == "$1" ];
then
GetSNStatsFromLokiBlocks $2
fi

if [ "GetSNStatsFromCustomNode" == "$1" ];
then
GetSNStatsFromCustomNode $2 $3 $4
fi

#Grapql Queries

#curl 'http://lokidashboard.com:3999/' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Origin: http://lokidashboard.com:3999' --data-binary '{"query":" {\n  serviceNode(publicKey: \"45ffeee44dfc469ec75bbd7550dc2375f8c80331c0a73f5b04e59b56926e67c3\")\n  {\n    lastUptimeProof\n    storageServerReachable\n  }\n}"}' --compressed