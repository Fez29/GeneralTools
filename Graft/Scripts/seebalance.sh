#!/bin/bash

# Wallets should all be in $WLTDIR (set this in .bashrc)
# Wallet names should be in $SNLIST (set this in .bashrc)
# graftnoded host address should be in $GNODED (set this in .bashrc)

# Get and cache wallet password (Note: must be the same for all wallets)
systemd-ask-password --keyname=seebal --accept-cached --timeout=12 "Password: " > /dev/null

for SN in $SNLIST
do
(cd $WLTDIR && systemd-ask-password --keyname=seebal --accept-cached --timeout=12 "Password: " |
graft-wallet-cli --daemon-host $GNODED --wallet-file $SN --command refresh) |
sed \
 -e '/^Graft /d ; /Logging to /d ; /^\*\*\*\*/d ; /Use \"help\"/d' \
 -e '/Starting refresh/d ; /Refresh done/d' \
 -e 's/Height .*\r\r//' \
 -e "s/Opened wallet: /$SN :: /" \
 -e "s/Balance: /$SN :: /" |
sed \
 -e "s/Height /$SN :: Height /"
echo
done


