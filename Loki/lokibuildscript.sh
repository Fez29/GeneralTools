bin="lokibuilddir_"
binpath="$bin$(echo $(date +%m_%d_%Y))"
GITPATH=https://github.com/jagerman/loki.git
GITCLONEDIR="loki"

n=`ls -d /home/snode/$binpath* | wc -l`
for i in $(echo $n) ; do
let n=$n+1
done

DIR="$bin$(echo $(date +%m_%d_%Y))_$(echo 000$n | tail -c 4)"

cd && sudo rm -f -r ~/$GITCLONEDIR && git clone --recursive -b jdev $GITPATH && mkdir -p ~/$DIR/logs && cd ~/$DIR && cmake -DENABLE_SYSLOG=ON ~/$GITCLONEDIR && make 1 && cd ~/$DIR/bin/ && \
~/$DIR/bin/lokid --version > version.txt && ln -snf ~/$DIR/bin/ ~/lokibin

Version=`cat ~/$DIR/bin/version.txt`

variable=`tput setaf 6`
text=`tput setaf 2`
reset=`tput sgr0`

echo "${text}Build files written to ${variable}~/$DIR/bin/${reset} and linked to ${variable}~/lokibin${reset}, use ${variable}~/lokibin/lokid${reset} for example to launch"

echo "${text}Version = ${variable}$Version${reset}"