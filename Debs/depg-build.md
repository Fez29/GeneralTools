Building from source
Step 1. GPG key

The first thing you need is generate a gpg key. Package will be signed by this key. Run this commands in your terminal:

gpg --gen-key
gpg -a --output ~/.gnupg/YOUR_NAME.gpg --export 'YOUR NAME'
gpg --import ~/.gnupg/YOUR_NAME.gpg

It's important to remember that in next stage it will be necessary to use the same name and email that were used for creating the key.
Step 2. Prepare the environment

You need install these packages for further building:

sudo apt-get install build-essential autoconf automake \
autotools-dev dh-make debhelper devscripts fakeroot \
xutils lintian pbuilder

Step 1

sudo apt-get install build-essential fakeroot devscripts
