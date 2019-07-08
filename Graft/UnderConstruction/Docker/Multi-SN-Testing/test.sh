#!/bin/bash

MAINNET_RPC_PORT="18981"
MAINNET_P2P_PORT="18980"
TESTNET_RPC_PORT="28881"
TESTNET_P2P_PORT="28880"

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

echo "$arg_test$test"

function setMainnetPorts(){
RPC_PORT="$MAINNET_RPC_PORT"
P2P_PORT="$MAINNET_P2P_PORT"
}

function setTestnetPorts(){
RPC_PORT="$TESTNET_RPC_PORT"
P2P_PORT="$TESTNET_P2P_PORT"
}

if [ "mainnet" == "$ENVIRONMENT" ];
then
setMainnetPorts
    else [ "testnet" == "$ENVIRONMENT" ];
    setTestnetPorts
fi

function SetupSupernode()
{
    while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done
    cp $CURRENT_DIR/config.ini $HOME_DIR_VAR/"$SN"/config.ini
    sed -i "s/wallet_var/$PUBLIC_WALLET_ADDRESS/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/rpc_port/$RPC_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/p2p_port/$P2P_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/port_var/$SN_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    $HOME_DIR_VAR/supernode/supernode --config-file $HOME_DIR_VAR/$SN/config.ini --log-file $HOME_DIR_VAR/$SN/logs/$SN.log --log-level 1 &
    echo "Wallet: $PUBLIC_WALLET_ADDRESS"
    echo "SN: $SN" 
    echo "RPC: $RPC_PORT"
    echo "P2P_PORT: $P2P_PORT"
    echo "SN_PORT: $SN_PORT"
}

wallets=($wallet1 $wallet2 $wallet3 $wallet4 $wallet5 $wallet6 $wallet7 $wallet8 $wallet9 $wallet10)

if ((${#SN_COUNT[@]}));
then
    for (( c=1; c<=$SN_COUNT; c++ ));
    do
        SN_NAME="sn"
        SN="$SN_NAME$(echo 000$c | tail -c 4)"
        SN_PORT=$((18690 + $c))
        #echo "${wallets[$c-1]}"
        SetupSupernode --PUBLIC_WALLET_ADDRESS ${wallets[$c-1]} --SN $SN --RPC_PORT $RPC_PORT --P2P_PORT $P2P_PORT --SN_PORT $SN_PORT
    	sleep 3
    done;
fi

$HOME_DIR_VAR/graftnetwork/graftnoded --$ENVIRONMENT --non-interactive --log-level 1

