#!/bin/bash

NAME=${1:-yukari_tamura}
OUT="${NAME}.out"
TMP=`mktemp`
echo "NAME=$NAME"
echo "OUT=$OUT"
echo "TMP=$TMP"

neru() {
    echo sleep $1
    sleep $(( $1 + RANDOM % 30 ))
}

while :; do

    ruby batch.rb "$NAME" > $TMP
    L=$(wc -l < $TMP)
    cat $TMP >> $OUT

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
