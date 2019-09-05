#!/bin/bash

## Mainnet
LokiMainnetBlocksEndpoint="lokiblocks.com"
LokiMainnetBlocksRpcPort="22023"
LokiMainnetSN_IP="127.0.0.1"
LokiMainnetSN_RPC_PORT="22023"

## Testnet
LokiTestnetBlocksEndpoint="lokitestnet.com"
LokiTestnetBlocksRpcPort="38157"
LokiTestnetSN_IP="127.0.0.1"
LokiTestnetSN_RPC_PORT="38157"

## Additional Public Node
AdditionalLokiNodeConfigured="true"

## Ensure you set above to true if wanting to query additional public node
LokiMainnetAdditionalNodeEndpoint="FIX_ME"
LokiMainnetAdditionalNodeRpcPort="32022"

Environment=$(whiptail --title "Choose Loki Environment" --checklist --separate-output --cancel-button Cancel "Choose an option" 25 78 16 \
"mainnet" "" on  \
"testnet" "" off 3>&1 1>&2 2>&3)

if [ $Environment == "mainnet" ]
    then
    LokiBlocksEndpoint="$LokiMainnetBlocksEndpoint"
	LokiBlocksRpcPort="$LokiMainnetBlocksRpcPort"
    SN_IP="$LokiMainnetSN_IP"
    SN_RPC_PORT="$LokiMainnetSN_RPC_PORT"
    ## Additional Node
    LokiAdditionalNodeEndpoint="$LokiMainnetAdditionalNodeEndpoint"
    LokiAdditionalNodeRpcPort="$LokiMainnetAdditionalNodeRpcPort"
    ## Service Node Pubkeys
    Service_Node_Pubkey_1="4ac80f8bd37cfba3eb54fa144745b7280e391d2c9f82db8e1d4c92ab742385f0"
    Service_Node_Pubkey_2="45ffeee44dfc469ec75bbd7550dc2375f8c80331c0a73f5b04e59b56926e67c3"
    Service_Node_Pubkey_3=""
    Service_Node_Pubkey_4=""
    Service_Node_Pubkey_5=""
    Service_Node_Pubkey_6=""
    Service_Node_Pubkey_7=""
    Service_Node_Pubkey_8=""
    Service_Node_Pubkey_9=""
    Service_Node_Pubkey_10=""
    else
	LokiBlocksEndpoint="$LokiTestnetBlocksEndpoint"
	LokiBlocksRpcPort="$LokiTestnetBlocksRpcPort"
    SN_IP="$LokiTestnetSN_IP"
    SN_RPC_PORT="$LokiTestnetSN_RPC_PORT"
    Environment="testnet"
    ## Service Node Pubkeys
    Service_Node_Pubkey_1="882a1480cbedb3556959c1c7d8da05e2b5ec752df1066684c6470df5055cfb28"
    Service_Node_Pubkey_2="2fc86aeee0e39cead8c896fb0690353be17b36ee47a30db333a57acb7d72a75d"
    Service_Node_Pubkey_3=""
    Service_Node_Pubkey_4=""
    Service_Node_Pubkey_5=""
    Service_Node_Pubkey_6=""
    Service_Node_Pubkey_7=""
    Service_Node_Pubkey_8=""
    Service_Node_Pubkey_9=""
    Service_Node_Pubkey_10=""
fi

SN_KEY=($Service_Node_Pubkey_1 $Service_Node_Pubkey_2 $Service_Node_Pubkey_3 $Service_Node_Pubkey_4 $Service_Node_Pubkey_5 $Service_Node_Pubkey_6 $Service_Node_Pubkey_7 $Service_Node_Pubkey_8 $Service_Node_Pubkey_9 $Service_Node_Pubkey_10)

## Local Service Node Hostname
SN_HOST=`echo -n "$HOSTNAME"`

## Elastic Details
elastichost='192.178.200.100'
elastic_port="9200"
Elastic_Indice_1="lokiservice_node_pubkey_1_$Environment"
Elastic_Indice_2="lokiservice_node_pubkey_2_$Environment"
Elastic_Indice_3="lokiservice_node_pubkey_3_$Environment"
Elastic_Indice_4="lokiservice_node_pubkey_4_$Environment"
Elastic_Indice_5="lokiservice_node_pubkey_5_$Environment"
Elastic_Indice_6="lokiservice_node_pubkey_6_$Environment"
Elastic_Indice_7="lokiservice_node_pubkey_7_$Environment"
Elastic_Indice_8="lokiservice_node_pubkey_8_$Environment"
Elastic_Indice_9="lokiservice_node_pubkey_9_$Environment"
Elastic_Indice_10="lokiservice_node_pubkey_10_$Environment"
Elastic_Indice=($Elastic_Indice_1 $Elastic_Indice_2 $Elastic_Indice_3 $Elastic_Indice_4 $Elastic_Indice_5 $Elastic_Indice_6 $Elastic_Indice_7 $Elastic_Indice_8 $Elastic_Indice_9 $Elastic_Indice_10)

## Determine Iterations by Pubkeys Count
SnNumberByPubkeys=$(if ((${#SN_KEY[@]}));
                        then
                                for (( c=1; c<=10000; c++ ));
                                do
                                        if [ ${SN_KEY[$c-1]} ];
                                        then
                                                echo "$c"
                                        else
                                                echo ""
                                        fi
                    done;
fi)

SN_COUNT=$(echo "$SnNumberByPubkeys" | tail -n1)

while true; do

function GetSnStatus()
{
    if ((${#SN_COUNT[@]}));
		then
		for (( c=1; c<=$SN_COUNT; c++ ));
		do

        ## Local Service Node Queries
        Service_Node_Pubkey=${SN_KEY[$c-1]}
        GetInfo=$(curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result')
	    GetHeight=$(echo -n "$GetInfo" | jq '.height')
        ServiceNodes=$(curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
        ServiceNodesCheck=$(echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
        CheckStatus=$(echo -n $ServiceNodesCheck | jq '.active')

	## Loki Blockchain Explorer Queries
	LokiBlocksServiceNodes=$(curl -s -X POST $LokiBlocksEndpoint:$LokiBlocksRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
	LokiBlocksServiceNodesCheck=$(echo -n "$LokiBlocksServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
	LokiBlocksCheckStatus=$(echo -n $LokiBlocksServiceNodesCheck | jq '.active')

        ## Additional Node Queries
        function AdditionalNodeQuery()
        {
            LokiAdditionalServiceNodes=$(curl -s -X POST http://$LokiAdditionalNodeEndpoint:$LokiAdditionalNodeRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}')
            LokiAdditionalServiceNodesCheck=$(echo -n "$LokiAdditionalServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)')
            LokiAdditionalCheckStatus=$(echo -n $LokiAdditionalServiceNodesCheck | jq '.active')
            LokiAdditionalHeight=$(curl -s -X POST $LokiAdditionalNodeEndpoint:$LokiAdditionalNodeRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.height')
            LokiAdditionalDifficulty=$(curl -s -X POST $LokiAdditionalNodeEndpoint:$LokiAdditionalNodeRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.cumulative_difficulty')
            AdditionalNodeQueries=$(echo -n "true")
        }

        CheckIfAdditionalNodesSetToTrue=$(
            if [ $AdditionalLokiNodeConfigured == "true" ];
                then
			AdditionalNodeQuery
		else
                    echo "No Additional node configured"
            fi)

        UseElasticIndice=$(if [[ "$Service_Node_Pubkey" == "${SN_KEY[$c-1]}" ]]
                                then
                                        echo -n "${Elastic_Indice[$c-1]}"
                                else
                                        echo "snnotfound"
                                fi)

            function GetActiveSnStatus()
            {
                ## Local SN Checks
            	CheckUptimeProofs=$(echo -n $ServiceNodesCheck | jq '.last_uptime_proof')
            	LastUpdateTime=$(date -d @$CheckUptimeProofs +%H:%M:%S)
            	CurrentTime=$(date -u +%s)
            	TimeSubtract=$(("$CurrentTime"-"$CheckUptimeProofs"))
            	TimeSinceLastUpdate=$(env TZ=UTC date -d @$TimeSubtract +%H:%M:%S)
            	TimeStamp=$(env TZ=UTC date '+%Y-%m-%dT%H:%M:%S.%3NZ')
	            
                ## LokiBlocks Checks
	            LokiBlocksCheckUptimeProofs=$(echo -n $LokiBlocksServiceNodesCheck | jq '.last_uptime_proof')
            	LokiBlocksLastUpdateTime=$(date -d @$LokiBlocksCheckUptimeProofs +%H:%M:%S)
            	LokiBlocksTimeSubtract=$(("$CurrentTime"-"$LokiBlocksCheckUptimeProofs"))
            	LokiBlocksTimeSinceLastUpdate=$(env TZ=UTC date -d @$LokiBlocksTimeSubtract +%H:%M:%S)

                ## Additional Node Checks Function
                function AdditionalNodeChecks()
                {
                    AdditionalNodeCheckUptimeProofs=$(echo -n $LokiAdditionalServiceNodesCheck | jq '.last_uptime_proof')
            	    AdditionalNodeLastUpdateTime=$(date -d @$AdditionalNodeCheckUptimeProofs +%H:%M:%S)
            	    AdditionalNodeTimeSubtract=$(("$CurrentTime"-"$AdditionalNodeCheckUptimeProofs"))
            	    AdditionalNodeTimeSinceLastUpdate=$(env TZ=UTC date -d @$AdditionalNodeTimeSubtract +%H:%M:%S)
                    AdditionalNodeChecksPerformed=$(echo -n "true")
                }

                ## BlockHeightChecks
	        LocalHeight=$(curl -s -X POST 127.0.0.1:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.height')
	        LokiBlocksHeight=$(curl -s -X POST $LokiBlocksEndpoint:$LokiBlocksRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.height')
	            
                ## Version Comparison
		#Local
		LokidVersionLocalVariable1=$(echo -n "$ServiceNodesCheck" | jq '.service_node_version' | jq '.[0]')
		LokidVersionLocalVariable2=$(echo -n "$ServiceNodesCheck" | jq '.service_node_version' | jq '.[1]')
		LokidVersionLocalVariable3=$(echo -n "$ServiceNodesCheck" | jq '.service_node_version' | jq '.[2]')
		LokidVersionLocal=$(echo "$LokidVersionLocalVariable1,$LokidVersionLocalVariable2,$LokidVersionLocalVariable3")
		#LokiBlocks
		LokidVersionLokiBlocksVariable1=$(echo -n $LokiBlocksServiceNodesCheck | jq '.service_node_version' | jq '.[0]')
		LokidVersionLokiBlocksVariable2=$(echo -n $LokiBlocksServiceNodesCheck | jq '.service_node_version' | jq '.[1]')
		LokidVersionLokiBlocksVariable3=$(echo -n $LokiBlocksServiceNodesCheck | jq '.service_node_version' | jq '.[2]')
		LokidVersionLokiBlocks=$(echo "$LokidVersionLokiBlocksVariable1,$LokidVersionLokiBlocksVariable2,$LokidVersionLokiBlocksVariable3")
		        
                ## Difficulty
	        LocalDifficulty=$(curl -s -X POST 127.0.0.1:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.cumulative_difficulty')
	        LokiBlocksDifficulty=$(curl -s -X POST $LokiBlocksEndpoint:$LokiBlocksRpcPort/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result.cumulative_difficulty')

	        # LastUpdateTime aligned

                LokidVersionComparison=$(if (( $LokidVersionLocal == $LokidVersionLokiBlocks ));
                        then
                                echo "LokidVersionAligned"
                        else
                                echo "LokidVersionNotAligned"
                        fi)

                AdditionalNodeQueriesPerformed=$(if [ $AdditionalNodeQueries ];
                        then
                                if [ $AdditionalNodeQueries == "true" ];
                                        then
                                                AddtionalNode
                                        else
                                                echo "No Additional node queries"
                                        fi
                        else
                                echo "No Additional node queries performed"
                        fi)

                if [ "$AdditionalNodeChecksPerformed" == "true" ];
                    then
	                Active=$(if (( $TimeSubtract < 3900 )) || (( $LokiBlocksTimeSubtract < 3900 )) && (( $AdditionalNodeTimeSubtract < 3900 ));
                	        then
                	                echo "true"
                	        else
                	                echo "false"
                	        fi)

                        StatusOnNetwork=$(if [ $CheckStatus == "false" ] && [ $LokiBlocksCheckStatus == "false" ] && [ $LokiAdditionalCheckStatus == "false" ];
                                then
				        echo "Decommissioned"
			        else
                                        echo "SN is Active"
                                fi)

                        LocalVsOthersUpdateTimeCheck=$(if (( $TimeSubtract == $LokiBlocksTimeSubtract )) && (( $LokiBlocksTimeSubtract == $AdditionalNodeTimeSubtract ));
                                then
                                        echo "LastUpdateTimeAligned"
                                else
                                        echo "LastUpdateTimeNotAligned"
                                fi)

                        LokidVersionComparison=$(if (( $LokidVersionLocal == $LokidVersionLokiBlocks )) && (( $LokidVersionLocal == $LokidVersionLokiBlocks ));
                                then
                                        echo "LokidVersionAligned"
                                else
                                        echo "LokidVersionNotAligned"
                                fi)

                        Comparison=$(if (( $LocalHeight == $LokiBlocksHeight )) && (( $LocalDifficulty == $LokiBlocksDifficulty )) &&
                                    (( $LokiAdditionalHeight == $LokiBlocksHeight )) && (( $LokiAdditionalDifficulty == $LokiBlocksDifficulty ));
	        	        then
	        			echo "Aligned"
	        		else
	        			echo "Not Aligned"
	        		fi)

                        UseElasticIndice1=$(echo -n "$UseElasticIndice")

                        ## Start of CreateJSON
            	        CreateJSON=$(echo "{\"jsonrpc\":\"2.0\",\"id\": $CurrentTime,\"@timestamp\": \"$TimeStamp\", \"Host\": \"$SN_HOST\", 
                        \"message\":{\"items\": {\"ServiceNodeStatusOnNetwork\": \"$StatusOnNetwork\",\"ServiceNodeActive\": \"$Active\", 
                        \"LastUpdateTime\": \"$TimeSinceLastUpdate\",\"ExplorerLastUpdateTime\": \"$LokiBlocksTimeSinceLastUpdate\",
                        \"LocalHeight\": $LocalHeight,\"ExplorerHeight\": $LokiBlocksHeight,\"LocalCumulativeDifficulty\": \"$LocalDifficulty\",
                        \"ExplorerCumulativeDifficulty\": \"$LokiBlocksDifficulty\",\"ComparisonToExplorer\": \"$Comparison\",
                        \"LastUpdateTimeComparison\": \"$LocalVsOthersUpdateTimeCheck\",\"LokidVersionComparion\": \"$LokidVersionComparison\",
                        \"LastUpdateTime\": $TimeSubtract,\"ExplorerLastUpdateTime\": $LokiBlocksTimeSubtract,\"LokiAdditionalHeight\": $LokiAdditionalHeight,
                        \"LokiAdditionalLastUpdateTime\": $LokiAdditionalTimeSubtract,\"ExplorerLastUpdateTime\": $LokiAdditionalTimeSubtract } },
                        \"PubKey\": \"$Service_Node_Pubkey\"}")
                        ## End Of CreateJSON
                    else
                        Active=$(if (($TimeSubtract < 3900)) || (($LokiBlocksTimeSubtract < 3900));
                	        then
                	            echo "true"
                	        else
                	            echo "false"
                	        fi)
                        StatusOnNetwork=$(if [ $CheckStatus == "false" ] && [ $LokiBlocksCheckStatus == "false" ];
                            then
						        echo "Decommissioned"
				            else
                                echo "SN is Active"
                            fi)
                        LocalVsOthersUpdateTimeCheck=$(if (( $TimeSubtract == $LokiBlocksTimeSubtract ));
                            then
                                echo "LastUpdateTimeAligned"
                            else
                                echo "LastUpdateTimeNotAligned"
                            fi)
                        Comparison=$(if (( $LocalHeight == $LokiBlocksHeight )) && (( $LocalDifficulty == $LokiBlocksDifficulty ));
	        		        then
	        			        echo "Aligned"
	        		        else
	        			        echo "Not Aligned"
	        		        fi)
                        UseElasticIndice1=$(echo -n "$UseElasticIndice")
                        
                        ## Start of CreateJSON
            	        CreateJSON=$(echo "{\"jsonrpc\":\"2.0\",\"id\": $CurrentTime,\"@timestamp\": \"$TimeStamp\", \"Host\": \"$SN_HOST\", 
                        \"message\":{\"items\": {\"ServiceNodeStatusOnNetwork\": \"$StatusOnNetwork\",\"ServiceNodeActive\": \"$Active\", 
                        \"LastUpdateTime\": \"$TimeSinceLastUpdate\",\"ExplorerLastUpdateTime\": \"$LokiBlocksTimeSinceLastUpdate\",
                        \"LocalHeight\": $LocalHeight,\"ExplorerHeight\": $LokiBlocksHeight,\"LocalCumulativeDifficulty\": \"$LocalDifficulty\",
                        \"ExplorerCumulativeDifficulty\": \"$LokiBlocksDifficulty\",\"ComparisonToExplorer\": \"$Comparison\",
                        \"LastUpdateTimeComparison\": \"$LocalVsOthersUpdateTimeCheck\",\"LokidVersionComparion\": \"$LokidVersionComparison\",
                        \"LastUpdateTime\": $TimeSubtract,\"ExplorerLastUpdateTime\": $LokiBlocksTimeSubtract } },
                        \"PubKey\": \"$Service_Node_Pubkey\"}")
                        ## End Of CreateJSON
                fi

            	JSON=$(echo -n "$CreateJSON" | jq .)
                # Comment out below if not posting to ElasticSearch
            	InsertElastic=$(curl -X POST "$elastichost:$elastic_port/$UseElasticIndice1/_doc/?pretty" -H 'Content-Type: application/json' -d "$JSON")
            	echo  "$JSON"
                ## Uncomment below if you would like to log results to log/text file
                #echo  "$JSON" >> results.log
    }

        if [ "$ServiceNodesCheck" ] || [ "$LokiBlocksServiceNodesCheck" ] || [ "$LokiAdditionalServiceNodesCheck" ];
	        then
			    GetActiveSnStatus
	        else
			echo "Deregistered"
	    fi

	sleep 3
    done;
fi

}
GetSnStatus
sleep 300; # 300 = would mean running the actual function every 5 mins
done