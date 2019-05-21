#curl -s --raw http://45.32.198.209:28690/debug/supernode_list/0 | jq '.result' | jq '.items' | jq '[.[] | {"StakeAmount": .StakeAmount}]' | jq '.[]' | jq '.StakeAmount' | echo $1

JSONdata=`curl -s --raw http://45.32.198.209:28690/debug/supernode_list/0`

T4Count=`echo -n $JSONdata | jq '.result' | jq '.items' | jq '[.[] | {"StakeAmount": .StakeAmount}]' \
| jq '.[]' | jq '.StakeAmount' | awk ' $1 >= 2500000000000000 ' | awk 'END{print NR}'`
T3Count1=`echo -n $JSONdata | jq '.result' | jq '.items' | jq '[.[] | {"StakeAmount": .StakeAmount}]' \
| jq '.[]' | jq '.StakeAmount' | awk ' $1 >= 1500000000000000 ' | awk 'END{print NR}'`
T3Count=`awk -v var1="$T3Count1" -v var2="$T4Count" 'BEGIN {print var1-var2}'`
T2Count1=`echo -n $JSONdata | jq '.result' | jq '.items' | jq '[.[] | {"StakeAmount": .StakeAmount}]' \
| jq '.[]' | jq '.StakeAmount' | awk ' $1 >= 900000000000000 ' | awk 'END{print NR}'`
T2Count=`awk -v var1="$T2Count1" -v var2="$T3Count1" -v var3="T4Count" 'BEGIN {print var1-var2-var3}'`
T1Count1=`echo -n $JSONdata | jq '.result' | jq '.items' | jq '[.[] | {"StakeAmount": .StakeAmount}]' \
| jq '.[]' | jq '.StakeAmount' | awk ' $1 >= 500000000000000 ' | awk 'END{print NR}'`
T1Count=`awk -v var1="$T1Count1" -v var2="$T2Count1" -v var3="T3Count1" -v var4="T4Count" 'BEGIN {print var1-var2-var3-var4}'`

T1_ROI=`awk -v var1="$T1Count" 'BEGIN {print var1/4/(var1*50000)}'`

#JSON=`echo "[{\"Tier Count\": [{\"T1\": \"$T1Count\"},{\"T2\": \"$T2Count\"},{\"T3\": \"$T3Count\"},{\"T4\": \"$T4Count\"}]}]" | jq 'map(.)'`
#JSON_PARSE='[{"Tier Count": [{"T1": "'"$T1Count"'"},{"T2": "'"$T2Count"'"},{"T3": "'"$T3Count"'"},{"T4": "'"$T4Count"'"}]}]'
#JSON=`echo "$JSON_PARSE" | jq 'map(.)'`
#JSON=`echo -n $JSON_PARSE | python -m json.tool`
JSON_PARSE='{ "'"T1"'":"'"$T1Count"'","'"T2"'":"'"$T2Count"'","'"T3"'":"'"$T3Count"'","'"T4"'":"'"$T4Count"'" }'



#JSON=`printf '%s\n' "$JSON_PARSE"`
echo -n $JSON_PARSE
echo -n $T1_ROI