Building and testing Deb Packages once merged

merge changes in branch according to "https://jagerman.com/updating-gc.txt"

at step 10 you can build the specific distro packages with - 

sudo apt install ubuntu-archive-keyring

Build packages
# Below Works - sid is equal to distro in first command
Debian unstable/testing DONE - 21 April
DIST=sid ARCH=amd64 git-pbuilder create
Debian 9 Stable - 21 April
DIST=stretch ARCH=amd64 git-pbuilder create
Ubuntu 18.04
DIST=bionic ARCH=amd64 git-pbuilder create --mirror http://ca.archive.ubuntu.com/ubuntu --components "main universe"
Ubuntu 16.04
DIST=xenial ARCH=amd64 git-pbuilder create --mirror http://ca.archive.ubuntu.com/ubuntu --components "main universe"
Ubuntu 18.10
DIST=cosmic ARCH=amd64 git-pbuilder create
### /var/cache/pbuilder/base-sid-amd64.cow is created
#Then
sudo gbp buildpackage --git-pbuilder -j4
GIT_PBUILDER_OUTPUT_DIR=~/BUILD_DIR_PATH/ gbp buildpackage --git-pbuilder -j4

##--git-export-dir=../build-area/
##--git-export-dir=../build-area/python-jsonschema
##--git-export-dir=../build-area/python-jsonschema

builds to ..
## If /Graft_Community_Official/GraftNetwork/ is you repo 
## builds to /Graft_Community_Official/

Then login to chroot
Debian unstable/testing
DIST=sid ARCH=amd64 git-pbuilder login --save-after-login
Debian Testing
DIST=stretch ARCH=amd64 git-pbuilder login --save-after-login
Ubuntu 16.04
DIST=xenial ARCH=amd64 git-pbuilder login --save-after-login
Ubuntu 18.04
DIST=bionic ARCH=amd64 git-pbuilder login --save-after-login
Ubuntu 18.10
DIST=cosmic ARCH=amd64 git-pbuilder login --save-after-login

Take note of:

forking: pbuilder login --buildplace /var/cache/pbuilder/build/cow.8709 --no-targz --internal-chrootexec 'chroot /var/cache/pbuilder/build/cow.8709 cow-shell'

--buildplace is directory where can copy the packages for testing

Go to .. (/Graft_Community_Official/) as per example above

cp *.deb to a build directory (anywhere)

cp <build directory> <--buildplace directory>

Now the <build directory> is available inside the chroot find with ls

then inside the chroot cd to the <build directory>
#then
apt install *.deb

GOOD to go!!!


# Random notes:

Amend commit message

--------------------

Latest commit

git commit --amend

git push --force-with-lease

----------------------

/var/cache/pbuilder/base-sid-amd64.cow

Login: for command DIST=sid ARCH=amd64 git-pbuilder create

DIST=sid  ARCH=amd64 git-pbuilder login --save-after-login

/var/cache/pbuilder/build/cow.2006

pdebuild

Testing packages

sudo gbp buildpackage --git-pdbuild -j4


upgraded debian-stretch deb to 1.7.5