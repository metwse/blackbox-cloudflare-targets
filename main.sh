#!/bin/bash


mkdir -p dist

if [ -e dist/subdomains.txt ]; then
    fetch_subdomains=0

    # Ignore current subdomains file and fetch current subdomains if -f flag
    # has given.
    for i in "$@"; do
        if [[ "$i" == '-f' ]]; then
            fetch_subdomains=1
        fi
    done
else
    fetch_subdomains=1
fi

if [ $fetch_subdomains == 1 ]; then
    ./get-subdomains.sh > dist/subdomains.txt
fi

if [ $? != 0 ]; then
    echo "ERROR: get-subdomains.sh failed!"
fi

./generate-blackbox-config.sh < dist/subdomains.txt > dist/blackbox.yml

echo "SUCCESS: dist/blackbox.yml"
