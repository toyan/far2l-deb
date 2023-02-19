#!/bin/bash
pushd "$(pwd)"
cd "$(dirname "$0")"
chmod +x lib/ld-linux*
chmod +x far2l
chmod +x far2l_sudoapp
chmod +x far2l_askpass
find . -type f -iname "*far-plug*" -exec chmod +x {} \;
find . -type f -iname "*.broker" -exec chmod +x {} \;
./far2l
popd
