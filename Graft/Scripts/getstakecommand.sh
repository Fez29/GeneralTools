#pass values in like ./getstakecommand #.#.#.# ##### StakeAmount StakeBlockpPeriod

IP="$1"
PORT="$2"

WALLET_PUBLIC_ADDRESS=`curl -s http://$IP:$PORT/dapi/v2.0/cryptonode/getwalletaddress | jq '.wallet_public_address' | tr -d '" '`
PUBLIC_ID=`curl -s http://$IP:$PORT/dapi/v2.0/cryptonode/getwalletaddress | jq '.id_key' | tr -d '" '`
SN_SIGNATURE=`curl -s http://$IP:$PORT/dapi/v2.0/cryptonode/getwalletaddress | jq '.signature' | tr -d '" '`

echo "stake_transfer $WALLET_PUBLIC_ADDRESS 90000 5000 $PUBLIC_ID $SN_SIGNATURE"
