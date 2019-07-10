#testnet
############## loki Variables ##############
lokibin="lokibuilddir_"
GITLokiPATH=https://github.com/jagerman/loki.git
GITLokiCLONEDIR="loki"
LokibinDir="lokibin2"
LOKI_BRANCH=jdev
############## Storage Server Variables ##############
Storagebin="lokistorageserver_"
GITStorageServerPATH=https://github.com/loki-project/loki-storage-server.git
GITStorageCLONEDIR="loki-storage-server"
StorageBinDir="lokistorageserverbin"
STORAGESERVER_BRANCH=dev

############## Storage Server ##############

n=`ls -d /home/snode/$lokibin* | wc -l`
for i in $(echo $n) ; do
let n=$n+1
done

#DIR="$lokibin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"
DIR="$lokibin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"

cd && sudo rm -f -r ~/$GITLokiCLONEDIR && git clone --recursive -b $LOKI_BRANCH $GITLokiPATH && mkdir -p ~/$DIR/logs && cd ~/$DIR && cmake -DENABLE_SYSLOG=ON ~/$GITLokiCLONEDIR && \ 
make -j 1 && cd ~/$DIR/bin/ && ~/$DIR/bin/lokid --version > version.txt && ln -snf ~/$DIR/bin/ ~/$LokibinDir
############## End ##############

############## Storage Server ##############
n=`ls -d /home/snode/$Storagebin* | wc -l`
for i in $(echo $n) ; do
let n=$n+1
done

StorageDIR="$Storagebin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"

cd && sudo rm -f -r ~/$GITStorageCLONEDIR && git clone --recursive -b $STORAGESERVER_BRANCH $GITStorageServerPATH && mkdir -p ~/$StorageDIR/logs && cd ~/$StorageDIR && \ 
cmake -DENABLE_SYSLOG=ON ~/$GITStorageCLONEDIR && make -j 1 && ln -snf ~/$StorageDIR/bin/ ~/$StorageBinDir

LokiVersion=`cat ~/$DIR/bin/version.txt`

variable=`tput setaf 6`
text=`tput setaf 2`
reset=`tput sgr0`

echo "${text}Build files written to ${variable}~/$DIR/bin/${reset} and linked to ${variable}~/$LokibinDir${reset}, use ${variable}~/$LokibinDir/lokid${reset} for example to launch"

echo "${text}Build files written to ${variable}~/$StorageDIR/httpserver/${reset}"
#and linked to ${variable}~/$LokibinDir${reset}, use ${variable}~/$LokibinDir/lokid${reset} for example to launch"

echo "${text}Version = ${variable}$LokiVersion${reset}"