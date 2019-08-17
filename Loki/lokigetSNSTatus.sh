#!/bin/bash
## Stores ID in ID.txt and increments every time function runs
SN_IP="127.0.0.1"
SN_RPC_PORT="FIX_ME"
SN_COUNT="2"
#Testnet Script
Service_Node_Pubkey_1="FIX_ME"
Service_Node_Pubkey_2="FIX_ME"
Service_Node_Pubkey_3=""
Service_Node_Pubkey_4=""
Service_Node_Pubkey_5=""
Elastic_Indice_1="FIX_ME"
Elastic_Indice_2="FIX_ME"
elastichost='FIX_ME'
elastic_port="FIX_ME"
SN_KEY=($Service_Node_Pubkey_1 $Service_Node_Pubkey_2 $Service_Node_Pubkey_3 $Service_Node_Pubkey_4 $Service_Node_Pubkey_5)
Elastic_Indice=($Elastic_Indice_1 $Elastic_Indice_2 $Elastic_Indice_3 $Elastic_Indice_4 $Elastic_Indice_5)
SN_HOST=`echo -n "$HOSTNAME"`

while true; do

function GetSnStatus()
{
    if ((${#SN_COUNT[@]}));
		then
		for (( c=1; c<=$SN_COUNT; c++ ));
		do

        Service_Node_Pubkey=${SN_KEY[$c-1]}
        test=`curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_info"}' | jq '.result'`
        ServiceNodes=`curl -s -X POST http://$SN_IP:$SN_RPC_PORT/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"get_all_service_nodes"}'`
        ServiceNodesCheck=`echo -n "$ServiceNodes" | jq '.result.service_node_states' | jq --arg Service_Node_Pubkey $Service_Node_Pubkey '.[] | select(.service_node_pubkey==$Service_Node_Pubkey)'`
        CheckStatus=`echo -n $ServiceNodesCheck | jq '.active'`

        UseElasticIndice=`if [[ "$Service_Node_Pubkey" == "${SN_KEY[$c-1]}" ]]
                                then
                                        echo -n "${Elastic_Indice[$c-1]}"
                                else
                                        echo "snnotfound"
                                fi`

            function GetActiveSnStatus(){

            CheckUptimeProofs=`echo -n $ServiceNodesCheck | jq '.last_uptime_proof'`
            LastUpdateTime=`date -d @$CheckUptimeProofs +%H:%M:%S`
            CurrentTime3=`date -u +%s`
            echo "$CurrentTime3-$CheckUptimeProofs"
            TimeSubtract=$(("$CurrentTime3"-"$CheckUptimeProofs"))
            TimeSinceLastUpdate=`env TZ=UTC date -d @$TimeSubtract +%H:%M:%S`
            TimeStamp=`env TZ=UTC date '+%Y-%m-%dT%H:%M:%S.%3NZ'`
            ID_Count=`cat ID.txt`

            Active=`if (($TimeSubtract < 3900))
            	then
            	echo "TRUE"
            	else
            	echo "false"
            	fi`

		StatusOnNetwork=`if [ "$ServiceNodesCheck" ];
                then
                        if [[ $CheckStatus == "false" ]];
                                then
                                        echo "Decommissioned"
				else
                                	echo "SN is Active"
                                fi
                        else
                                echo "Deregistered"
        fi`

            UseElasticIndice1=`echo -n "$UseElasticIndice"`
            CreateJSON=`echo "{\"jsonrpc\":\"2.0\",\"id\": $ID_Count,\"@timestamp\": \"$TimeStamp\", \"Host\": \"$SN_HOST\", \"message\":{\"items\": {\"ServiceNodeStatusOnNetwork\": \"$StatusOnNetwork\",\"ServiceNodeActive\": \"$Active\", \"LastUpdateTime\": \"$TimeSinceLastUpdate\"} }, \"PubKey\": \"$Service_Node_Pubkey\"}"`
            JSON=`echo -n "$CreateJSON" | jq .`
            InsertElastic=`curl -X POST "$elastichost:$elastic_port/$UseElasticIndice1/_doc/?pretty" -H 'Content-Type: application/json' -d "$JSON"`
            NEW_INC_COUNTER=$((ID_Count+1))
            echo  "$JSON"
            echo -n "$InsertElastic" >> logs/InsertIntoElastic.log
            echo -n $NEW_INC_COUNTER > ID.txt

    }

if [ "$ServiceNodesCheck" ];
	then
		if [[ $CheckStatus == "false" ]];
                	then
				GetActiveSnStatus
			else
				GetActiveSnStatus
			fi
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