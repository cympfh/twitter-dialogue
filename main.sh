#!/bin/bash

NAME=${1:-yukari_tamura}
echo "NAME=$NAME"

neru() {
    echo sleep $1
    sleep $(( $1 + RANDOM % 30 ))
}

while :; do

    ruby batch.rb "$NAME" > /tmp/append
    L=$(wc -l < /tmp/append)
    cat /tmp/append >> data

    echo "new $L lines"

    if [ $L -eq 0 ]; then
        neru $(( 1 * 60 * 60 ))
    elif [ $L -lt 3 ]; then
        neru $(( 30 * 60 ))
    elif [ $L -lt 10 ]; then
        neru $(( 10 * 60 ))
    else
        neru 300
    fi

done
