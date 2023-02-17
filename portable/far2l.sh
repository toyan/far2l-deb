#!/bin/bash
pushd "$(pwd)"
cd "$(dirname "$0")"
chmod +x lib/ld-linux*
chmod +x far2l
./far2l
popd