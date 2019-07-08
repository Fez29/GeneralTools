#!/bin/bash

PKGS="libnorm1"
MAINNET_RPC_PORT="18981"
MAINNET_P2P_PORT="18980"
TESTNET_RPC_PORT="28881"
TESTNET_P2P_PORT="28880"
CURRENT_DIR=`pwd`
# Get home directory of current user
HOME_DIR_VAR=`awk -F: -v v="$USER" '{if ($1==v) print $6}' /etc/passwd`

## Adds capability to pass variables into script like --VAR foo where $VAR will be equal to foo
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done
##

wallets=($wallet1 $wallet2 $wallet3 $wallet4 $wallet5 $wallet6 $wallet7 $wallet8 $wallet9 $wallet10 $wallet11 $wallet12 $wallet13 $wallet14 $wallet15 $wallet16 $wallet17 $wallet18 $wallet19 $wallet20)


/home/graft/graftnetwork/graftnoded --$ENVIRONMENT --non-interactive --log-level 1 &

function setMainnetPorts(){
RPC_PORT="$MAINNET_RPC_PORT"
P2P_PORT="$MAINNET_P2P_PORT"
}

function setTestnetPorts(){
RPC_PORT="$TESTNET_RPC_PORT"
P2P_PORT="$TESTNET_P2P_PORT"
}

function SetupSupernode()
{
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

    cp $CURRENT_DIR/config.ini $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/wallet_var/$PUBLIC_WALLET_ADDRESS/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/rpc_port/$RPC_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/p2p_port/$P2P_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    sed -i "s/port_var/$SN_PORT/g" $HOME_DIR_VAR/"$SN"/config.ini &&
    $HOME_DIR_VAR/supernode/supernode --config-file $HOME_DIR_VAR/$SN/config.ini --log-file $HOME_DIR_VAR/$SN/logs/$SN.log --log-level 1 &
    echo "Wallet: $PUBLIC_WALLET_ADDRESS SN: $SN RPC: $RPC_PORT P2P_PORT: $P2P_PORT SN_PORT: $SN_PORT"
}

if [ "mainnet" == "$ENVIRONMENT" ];
then
setMainnetPorts
    else [ "testnet" == "$ENVIRONMENT" ];
    setTestnetPorts
fi

if ((${#SN_COUNT[@]}));
then
    for (( c=1; c<=$SN_COUNT; c++ ));
    do
        SN_NAME="sn"
        SN="$SN_NAME$(echo 000$c | tail -c 4)"
        SN_PORT=$((18690 + $c))
        SetupSupernode --PUBLIC_WALLET_ADDRESS ${wallets[$c-1]} --SN $SN --RPC_PORT $RPC_PORT --P2P_PORT $P2P_PORT --SN_PORT $SN_PORT
    	sleep 1
    done;
fi

#### Need to do setup and copy of public wallet address or pass in values to script or docker run command, SN getting error of:
# 2019-06-26 20:10:13.953	    7fe8b6a257c0	ERROR	default	src/supernode/main.cpp:55	The program is terminated because of error: Configuration parameter 'wallet-public-address' cannot be empty.
# investigate passing in values at build time to config.ini


