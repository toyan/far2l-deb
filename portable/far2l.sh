#!/bin/bash
pushd "$(pwd)"
cd "$(dirname "$0")"
chmod +x lib/ld-linux*
chmod +x far2l
find . -type f -iname "*far-plug*" -exec chmod +x {} \;
find . -type f -iname "*.broker" -exec chmod +x {} \;
./far2l
popd