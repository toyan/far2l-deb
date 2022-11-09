#!/bin/bash
mkdir ~
cd ~
rm -rf far2l
mkdir far2l
cd far2l
apt-get install -y libspdlog-dev patchelf wget gawk m4 libx11-dev libxi-dev libxerces-c-dev libuchardet-dev libssh-dev libssl-dev libnfs-dev libneon27-dev libarchive-dev libpcre3-dev cmake g++ git
git clone https://github.com/elfmz/far2l
cd far2l
mkdir build
cd build
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:george-edison55/cmake-3.x
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y cmake gcc-6 g++-6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
cmake -DUSEWX=no -DLEGACY=no -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc --all)
cd install
wget https://github.com/unxed/far2l-deb/raw/master/portable/autonomizer.sh
chmod +x autonomizer.sh
./autonomizer.sh
rm lib/libc.so.6
rm lib/libdl.so.2
rm lib/libgcc_s.so.1
rm lib/libm.so.6
rm lib/libpthread.so.0
rm lib/libstdc++.so.6
rm lib/libresolv.so.2
rm lib/librt.so.1
cd ..
mv install far2l_portable
git clone https://github.com/megastep/makeself.git
makeself/makeself.sh far2l_portable far2l_portable.run far2l ./far2l
