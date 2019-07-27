sudo apt update

PKGS="graft-blockchain-tools graftnoded graft-wallet graft-supernode"

function InstallGraft
{
        echo "Distro chosen: $choice" &&
        sudo apt update && sudo apt upgrade -y && sudo apt install curl gnupg2 -y &&
        curl -s https://deb.graft.community/public.gpg | sudo apt-key add - &&
        echo "deb [arch=amd64] https://deb.graft.community $distro main" | sudo tee /etc/apt/sources.list.d/graft.community.list &&
        sudo apt update && sudo apt install $PKGS -y &&
        echo "Successfully installed $PKGS"
}

choice=`lsb_release -c -s`

case $choice in
	"bionic")
		distro="bionic"
		;;
	"stretch")
		distro="stretch"
		;;
	"buster")
		distro="sid"
		;;
	"xenial")
		distro="xenial"
		;;
	"cosmic")
		distro="cosmic"
		;;
esac

InstallGraft
