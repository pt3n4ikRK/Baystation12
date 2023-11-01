#!/bin/sh
#--
BYONDMAJOR="514"
BYONDMINOR="1589"
GITUSER="baystation12"
GITREPO="baystation12"
DMENAME="baystation12"
HOSTCKEY="CHANGEME"
BYONDPORT="8000"
BYONDARGS="-invisible"
#--
dpkg --add-architecture i386
apt update
apt -y full-upgrade
apt -y install nano htop git wget curl zip unzip man software-properties-common build-essential cmake gcc-multilib lib32z1 lib32stdc++6 libmysqlclient-dev:i386
apt -y autoremove
git clone --depth 1 https://github.com/microsoft/mimalloc.git
git clone --depth 1 https://github.com/${GITUSER}/${GITREPO}.git ss13
wget http://www.byond.com/download/build/${BYONDMAJOR}/${BYONDMAJOR}.${BYONDMINOR}_byond_linux.zip
unzip ${BYONDMAJOR}.${BYONDMINOR}_byond_linux.zip
mkdir -p mimalloc/out/release
sed -n -i 'p;6a set(CMAKE_C_FLAGS \"${CMAKE_C_FLAGS} -m32\")' mimalloc/CMakeLists.txt
sed -n -i 'p;7a set(CMAKE_SHARED_LINKER_FLAGS \"${CMAKE_SHARED_LINKER_FLAGS} -m32\")' mimalloc/CMakeLists.txt
cd mimalloc/out/release
cmake ../..
make
make install
cd ../../../byond
mkdir -p /usr/share/man/man6
make install
cd ../ss13
cp config/example/* config/
echo "${HOSTCKEY} - Host" >> config/admins.txt
echo "LD_PRELOAD=/usr/local/lib/libmimalloc.so DreamDaemon ./${DMENAME}.dmb ${BYONDPORT} -trusted ${BYONDARGS}" > start.sh
chmod +x start.sh
DreamMaker "${DMENAME}.dme"
echo "Done! changedir to ${GITREPO} then run start.sh to start."
echo "Don't forget to edit your configuration!"
