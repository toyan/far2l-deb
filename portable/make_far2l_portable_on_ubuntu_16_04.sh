#!/bin/bash
# Check if the argument "--gui" is present
gui_arg_present=false
for arg in "$@"
do
  if [ "$arg" == "--gui" ]; then
    gui_arg_present=true
    break
  fi
done
#
mkdir ~
cd ~
rm -rf far2l
mkdir far2l
cd far2l
apt-get update
if [ "$gui_arg_present" = true ]; then
    sudo apt install -y libwxgtk3.0-dev
    sudo apt install -y libwxgtk3.0-gtk3-dev
    sudo apt install -y libsmbclient-dev
fi
apt-get install -y libneon27-dev
apt-get install -y libspdlog-dev patchelf wget gawk m4 libx11-dev libxi-dev libxerces-c-dev libuchardet-dev libnss-mdns libssh-dev libssl-dev libnfs-dev libarchive-dev libpcre3-dev cmake g++ git
git clone https://github.com/elfmz/far2l
cd far2l
wget https://raw.githubusercontent.com/unxed/far2l-deb/master/portable/tty_tweaks.patch
git apply tty_tweaks.patch
wget https://raw.githubusercontent.com/unxed/far2l-deb/master/portable/xenial_fix.patch
git apply xenial_fix.patch
mkdir build
cd build
cmake -DLEGACY=no -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc --all)
cd install
rm -rf far2l_askpass
echo "#!/bin/bash" > far2l_askpass
echo "cd \"\$FARHOME\"" >> far2l_askpass
echo "exec -a far2l_askpass ./far2l \$*" >> far2l_askpass
chmod +x far2l_askpass
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
