#!/bin/bash
# Clone Repo and chmod the setupsn.sh
# Run this script from same git clone location

echo "Please input password to update apt and wait for prompts after completion"
sudo apt update

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
P2P_PORT=$(whiptail --inputbox "P2P port for Graftnoded - Mainnet Default = 18980 | Public Testnet Default = 28880" 10 30 18980 3>&1 1>&2 2>&3)
USER=$(whoami)
CURRENT_DIR=`pwd`
HOME_DIR_VAR=`awk -F: -v v="$USER" '{if ($1==v) print $6}' /etc/passwd`
ACTIVE_SSH_PORT=`sudo lsof -Pan -p $(ps aux | grep '[s]sh' | awk 'NR==1{print $2}') -i | awk 'NR==2{print $9}' | tr -d *:`

function SetupSN()
{
cd ~/
SN="$SN_NAME$(echo 000$n | tail -c 4)"
mkdir ~/$SN &&
cp $CURRENT_DIR/config.ini ~/"$SN"/config.ini &&
sudo cp $CURRENT_DIR/graft-supernode@.service /etc/systemd/system/graft-supernode-$USER@.service &&
sudo sed -i "s|EXEC_USER|$USER|g" /etc/systemd/system/graft-supernode-$USER@.service &&
sudo sed -i "s|HOME_DIR|$HOME_DIR_VAR|g" /etc/systemd/system/graft-supernode-$USER@.service &&
sed -i "s|data_dir_var|/home/$USER/$SN/|g" ~/"$SN"/config.ini &&
sed -i "s/wallet_var/$Wallet/g" ~/"$SN"/config.ini &&
sed -i "s/rpc_port/$RPC_PORT/g" ~/"$SN"/config.ini &&
sed -i "s/p2p_port/$P2P_PORT/g" ~/"$SN"/config.ini &&
sed -i "s/port_var/$SN_PORT/g" ~/"$SN"/config.ini &
}

function SetupSN-Systemd()
{
sudo systemctl enable graft-supernode-$USER@$SN.service
}

function SetupSN-Systemd-Start()
{
sudo systemctl start graft-supernode-$USER@$SN.service
}

function Allow-SN_PORT-Ufw()
{
UfwInstall=`sudo apt install ufw -y` &&
UfwSNPortConfig=`sudo ufw allow $SN_PORT/tcp` &&
UfwSSHPortConfig=`sudo ufw allow $ACTIVE_SSH_PORT/tcp`
}


SetupSN $SN $Wallet $SN_PORT $DATA_DIR $RPC_PORT $P2P_PORT $USER

if (whiptail --title "Setup systemd" --yesno "Setup systemd for this sn?" 10 60) then
  SetupSN-Systemd $SN
fi

if (whiptail --title "Start supernode" --yesno "Start supernode for this sn?" 10 60) then
  SetupSN-Systemd-Start $SN
fi

if (whiptail --title "ufw configuration" --yesno "Would you like to open the SN port on ufw?" 10 60) then
  Allow-SN_PORT-Ufw $SN_Port
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
echo "${text}Example command to restart supernode: ${variable}sudo systemctl restart graft-supernode-$USER@$SN.service"
echo "${text}SN will start automatically on reboot"
echo "${text}Install UFW result : ${variable}$UfwInstall"
echo "${text}UFW Port configure Result : ${variable}$UfwSNPortConfig + SSH port currently in use: $ACTIVE_SSH_PORT has been configured = $UfwSSHPortConfig"
echo "${text}Take note that ufw has not been enabled, please ensure your SSH port in use $ACTIVE_SSH_PORT is allowed before enabling with: ${variable} sudo ufw enable"

# For Future use
# Get port SSHD is currently using and listening on:
# Command
# sudo lsof -Pan -p $(ps aux | grep '[s]sh' | awk 'NR==1{print $2}') -i | awk 'NR==2{print $9}' | tr -d *:
# expected return for standard ssh port:
# 22
# Can be used to add value to allow ufw command and then enable ufw to ensure user is not locked out, need to build error handling so enable doesnt go ahead if this fails, Tested on Debian Buster