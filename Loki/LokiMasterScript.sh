
CompileLokid=$(whiptail --title "Compile Lokid" --checklist --separate-output --cancel-button Cancel "Choose an option" 25 78 16 \
"Yes" "" on  \
"No" "" off 3>&1 1>&2 2>&3)

CompileStorageServer=$(whiptail --title "Compile loki-storage-server" --checklist --separate-output --cancel-button Cancel "Choose an option" 25 78 16 \
"Yes" "" on  \
"No" "" off 3>&1 1>&2 2>&3)

Environment=$(whiptail --title "Choose Loki Environment" --checklist --separate-output --cancel-button Cancel "Choose an option" 25 78 16 \
"Mainnet" "" on  \
"Testnet" "" off 3>&1 1>&2 2>&3)

#testnet
#########################################################################################################################################################################
################### loki Variables ###################
#########################################################################################################################################################################
lokibin="lokibuilddir_"
Lokibinpath="$lokibin"
GITLokiPATH=https://github.com/jagerman/loki.git
GITLokiCLONEDIR="loki"
LokibinDir="lokibin2"
LOKI_BRANCH=jdev

#########################################################################################################################################################################
############## Storage Server Variables ##############
#########################################################################################################################################################################

Storagebin="lokistorageserver_"
Storagebinpath="$StorageServer$(echo $(date +%m_%d_%Y))"
GITStorageServerPATH=https://github.com/loki-project/loki-storage-server.git
GITStorageCLONEDIR="loki-storage-server"
StorageBinDir="lokistorageserverbin"
STORAGESERVER_BRANCH=dev

#########################################################################################################################################################################
############### loki.service Variables ###############
#########################################################################################################################################################################

lokiTestnetServiceExists=`systemctl | grep lokid-testnet.service`
lokiMainnetServiceExists=`systemctl | grep lokid.service`
SnExternalIpAddress=`curl -s http://whatismyip.akamai.com/`
StorageServerPort=5678
RpcTestnetBindPort=38157

if [ $Environment == "mainnet" ]
    then
        RpcBindPort=22023
        configureExecStartLokiService="/home/$USER/$LokibinDir/lokid --detach --service-node --service-node-public-ip $SnExternalIpAddress --storage-server-port $StorageServerPort --rpc-bind-port=$RpcBindPort"
        systemctlFileName="lokid.service"
    else
        RpcBindPort=38157
        configureExecStartLokiService="/home/$USER/$LokibinDir/lokid --testnet --detach --service-node --service-node-public-ip $SnExternalIpAddress --storage-server-port $StorageServerPort --rpc-bind-port=$RpcBindPort"
        systemctlFileName="lokid-testnet.service"
fi

#########################################################################################################################################################################
### Start of loki.service systemctl file variable ###
#########################################################################################################################################################################

lokidServiceFile="[Unit]
Description=lokilauncher
After=network-online.target

[Service]
Type=simple
User=snode
ExecStart=$configureExecStartLokiService
Restart=always
RestartSec=30s

[Install]
WantedBy=multi-user.target"

#########################################################################################################################################################################
### END of loki.service systemctl file variable ###
#########################################################################################################################################################################



#########################################################################################################################################################################
############################################################## Start of CompileLokid function ###########################################################################
#########################################################################################################################################################################
function CompileLokid(){
n=`ls -d /home/snode/$Lokibinpath* | wc -l`
for i in $(echo $n) ; do
let n=$n+1
done

#DIR="$lokibin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"
DIR="$Lokibinpath$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"

cd && sudo rm -f -r ~/$GITLokiCLONEDIR && git clone --recursive -b $LOKI_BRANCH $GITLokiPATH && mkdir -p ~/$DIR/logs && cd ~/$DIR && cmake -DENABLE_SYSLOG=ON ~/$GITLokiCLONEDIR && \ 
make -j 1 && cd ~/$DIR/bin/ && ~/$DIR/bin/lokid --version > version.txt && ln -snf ~/$DIR/bin/ ~/$LokibinDir

SetupLokidSystemCtl=$(whiptail --title "Setup Lokid systemd environmet" --checklist --separate-output --cancel-button Cancel "Choose an option" 25 78 16 \
"Yes" "" on  \
"No" "" off 3>&1 1>&2 2>&3)

LokiVersion=`cat ~/$DIR/bin/version.txt`

variable=`tput setaf 6`
text=`tput setaf 2`
reset=`tput sgr0`

echo "${text}Build files written to ${variable}~/$DIR/bin/${reset} and linked to ${variable}~/$LokibinDir${reset}, use ${variable}~/$LokibinDir/lokid${reset} for example to launch"

echo "${text}Build files written to ${variable}~/$StorageDIR/httpserver/${reset}"
#and linked to ${variable}~/$LokibinDir${reset}, use ${variable}~/$LokibinDir/lokid${reset} for example to launch"
}

#########################################################################################################################################################################
################################################################ Start of CompileStorageServer function #################################################################
#########################################################################################################################################################################

function CompileStorageServer(){
############## Storage Server ##############
n=`ls -d /home/snode/$Storagebinpath* | wc -l`
for i in $(echo $n) ; do
let n=$n+1
done

StorageDIR="$Storagebin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"

cd && sudo rm -f -r ~/$GITStorageCLONEDIR && git clone --recursive -b $STORAGESERVER_BRANCH $GITStorageServerPATH && mkdir -p ~/$StorageDIR/logs && cd ~/$StorageDIR && \ 
cmake -DENABLE_SYSLOG=ON ~/$GITStorageCLONEDIR && make -j 1 && ln -snf ~/$StorageDIR/bin/ ~/$StorageBinDir

variable=`tput setaf 6`
text=`tput setaf 2`
reset=`tput sgr0`

echo "${text}Version = ${variable}$LokiVersion${reset}"
}

#########################################################################################################################################################################
################################################################ Start of StartLokidService function ####################################################################
#########################################################################################################################################################################

function StartLokidService()
{
    #sudo sudo systemctl disable --now $systemctlFileName && \
    #sudo rm /etc/systemd/system/loki.service && \
    #echo -n "$lokidServiceFile" | sudo tee -a /etc/systemd/system/systemctlFileName && \
    #sudo sudo systemctl enable --now loki.service

    #sudo systemctl enable --now loki.service
    echo "Executing StartLokidService"
    echo "1"
    echo "2"
    echo "3"
    echo "$lokidServiceFile"
}

#########################################################################################################################################################################
################################################################ Start of SetupLokidSystemCtl function ####################################################################
#########################################################################################################################################################################

function SetupLokidSystemCtl(){
if [ $Environment == "mainnet" ];
    then
        if [ "$lokiMainnetServiceExists" ];
            then
                echo "mainnet loki.service exists, disabling and stopping service, adjusting path and user accordingly and starting"
                    #start lokid
                    StartLokidService
            else
                echo "mainnet loki.service not exists, configuring loki.service by setting up systemctl file and user accordingly and starting"
                    StartLokidService
    else
            if [ "$lokiTestnetServiceExists" ];
                then
                    echo "testnet loki.service exists, disabling and stopping service, adjusting path and user accordingly and starting"
                    StartLokidService
                else
                    echo "testnet loki.service not exists, configuring loki.service by setting up systemctl file and user accordingly and starting"
                    StartLokidService
    fi
}

if [ $CompileLokid == "Yes" ];
    then 
        CompileLokid
    fi

if [ $CompileStorageServer = "Yes"]
    then
        CompileStorageServer
    fi


