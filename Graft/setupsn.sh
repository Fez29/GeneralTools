#!/bin/bash
# Clone Repo and chmod the setupsn.sh
# Run this script from same git clone location

# Get SN Number
n=0
for i in $(ls ~) ; do
let n=$n+1
done
# End Get SN Number

# Defaults
DEF_NAME="SN"
DEF_PORT=$((18000 + $n))
# End Defaults


SN_NAME=$(whiptail --inputbox "SN Number - Folder directory to be created for SN - exclude numbering - script will detect next SN number in directory" 10 30 $DEF_NAME 3>&1 1>&2 2>&3)
Wallet=$(whiptail --inputbox "Mainnet Wallet Address - Enter Wallet address for staking - Ctrl-Shift-V or Shift + Insert to paste from clipboard" 10 30 3>&1 1>&2 2>&3)
SN_PORT=$(whiptail --inputbox "SN Port - Port to be used for SN - must be unique per SN" 10 30 $DEF_PORT 3>&1 1>&2 2>&3)
RPC_PORT=$(whiptail --inputbox "RPC port for Graftnoded - Mainnet Defailt = 18981 | Public Testnet Default = 28881" 10 30 18981 3>&1 1>&2 2>&3)
P2P_PORT=$(whiptail --inputbox "P2P port for Graftnoded - Mainnet Default = 18980 | Public Testnet Default = 28880" 10 30 18981 3>&1 1>&2 2>&3)
USER=$(whoami)
CURRENT_DIR=`pwd`

function SetupSN()
{
cd /home/$USER/
SN="$SN_NAME$(echo 000$n | tail -c 4)"
mkdir ~/$SN &&
cp $CURRENT_DIR/config.ini ~/"$SN"/config.ini &&
sudo cp $CURRENT_DIR/graft-supernode@.service /etc/systemd/system/graft-supernode@.service &&
sed -i "s|data_dir_var|/home/$USER/$SN/|g" ~/"$SN"/config.ini &&
sed -i "s/wallet_var/$Wallet/g" ~/"$SN"/config.ini &&
sed -i "s/rpc_port/$RPC_PORT/g" ~/"$SN"/config.ini &&
sed -i "s/p2p_port/$P2P_PORT/g" ~/"$SN"/config.ini &&
sed -i "s/port_var/$SN_PORT/g" ~/"$SN"/config.ini &
}

function SetupSN-Systemd()
{
sudo systemctl enable graft-supernode@$SN.service
}

function SetupSN-Systemd-Start()
{
sudo systemctl start graft-supernode@$SN.service
}

SetupSN $SN $Wallet $SN_PORT $DATA_DIR $RPC_PORT $P2P_PORT $USER

if (whiptail --title "Setup systemd" --yesno "Setup systemd for this sn?" 10 60) then
  SetupSN-Systemd $SN
fi

if (whiptail --title "Start supernode" --yesno "Start supernode for this sn?" 10 60) then
  SetupSN-Systemd-Start $SN
fi

variable=`tput setaf 6`
text=`tput setaf 2`
reset=`tput sgr0`

echo "${text}SN Number - ${variable}$SN"
echo "${text}Mainnet Wallet Address - ${variable}$Wallet"
echo "${text}Data Directory - ${variable}$DATA_DIR"
echo "${text}RPC port for Graftnoded - ${variable}$RPC_PORT"
echo "${text}P2P port for Graftnoded - ${variable}$P2P_PORT"
echo "${text}Above values represent the values inserted and used for the setup of your supernode, please cd to ${variable}~/$SN"
echo "${text}Script and config.ini location - ${variable}$CURRENT_DIR${reset}"
echo "${text}sudo systemctl start graft-supernode@$SN.service"
echo "${text}run above command to start your SN - SN will start automatically on reboot"
