#!/bin/bash
mkdir ~
cd ~
rm -rf far2l
mkdir far2l
cd far2l
apt-get update
apt-get install -y libspdlog-dev patchelf wget gawk m4 libx11-dev libxi-dev libxerces-c-dev libuchardet-dev libssh-dev libssl-dev libnfs-dev libneon27-dev libarchive-dev libpcre3-dev cmake g++ git
git clone https://github.com/elfmz/far2l
cd far2l
wget https://raw.githubusercontent.com/unxed/far2l-deb/master/portable/tty_tweaks.patch
git apply tty_tweaks.patch
mkdir build
cd build
cmake -DUSEWX=no -DFARFTP=yes -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc --all)
cd install
wget https://github.com/unxed/far2l-deb/raw/master/portable/far2l.sh
chmod +x far2l.sh
wget https://github.com/unxed/far2l-deb/raw/master/portable/autonomizer.sh
chmod +x autonomizer.sh
./autonomizer.sh
rm -rf autonomizer.sh
cd ..
mv install far2l_portable
git clone https://github.com/megastep/makeself.git
makeself/makeself.sh far2l_portable far2l_portable.run far2l ./far2l
