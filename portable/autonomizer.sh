#!/bin/bash
rm -rf ./lib
mkdir lib
shopt -s globstar
for file in ./**/* ; do
    if file $file | grep ELF > /dev/null; then
        sl="${file//[^\/]}"
        c="${#sl}"
        c=$(expr $c - 1)
        str="\$ORIGIN"
        str2="."
        if [ "$c" -gt "0" ]; then
            for ((i=1; i<=$c; i++)); do
                str="${str}/.."
                str2="${str2}/.."
            done
        fi
        str="${str}/lib"
        str2="${str2}/lib"
        echo $file
        patchelf --remove-rpath $file
        ldd $file | grep "=> /" | awk '{print $1, $3}' | cut -d\  -f2 | \
        xargs -d '\n' -I{} cp --copy-contents {} ./lib
        patchelf --set-rpath $str $file
        patchelf --set-interpreter $str2/`ldconfig -p | grep "ld-linux-" | awk '{print $4}' | sed "s/.*\///"` $file
    fi
done
cp $(dirname "`ldconfig -p | grep "libnss_compat.so.2" | grep -v '/usr/' | awk '{print $8}'`")/libnss_* ./lib
for file in ./lib/* ; do
    if file $file | grep ELF > /dev/null; then
        echo $file
        patchelf --remove-rpath $file
        patchelf --set-rpath "\$ORIGIN" $file
        #patchelf --set-rpath "." $file
    fi
done
MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'i686' ]; then
    cp `ldconfig -p | grep "ld-linux" | awk '{print $4}'` ./lib
else
    cp `ldconfig -p | grep "ld-linux-" | awk '{print $4}'` ./lib
fi
