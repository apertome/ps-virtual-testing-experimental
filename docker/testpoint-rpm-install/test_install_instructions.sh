#!/usr/bin/bash

declare -a BUNDLES=("perfsonar-tools" "perfsonar-testpoint" "perfsonar-core" "perfsonar-centralmanagement" "perfsonar-toolkit")
TEXT_STATUS=""
docker-compose down
for BUNDLE in ${BUNDLES[@]}; do
    echo "BUILD BUNDLE $BUNDLE"
    docker-compose build --no-cache --force-rm --build-arg repo="$BUNDLE"  centos_clean
    STATUS=$?
    echo "$BUNDLE Tried to build; status: $STATUS"
    if [ "$STATUS" -eq "0" ]; then
        echo "$BUNDLE SUCCEDED!"
        TEXT_STATUS+="$BUNDLE SUCCEEDED!\n"
        #exit;
    else
        echo "$BUNDLE FAILED!"
        TEXT_STATUS+="$BUNDLE FAILED!\n"
    fi
    docker-compose down

    echo -e $TEXT_STATUS
done

echo -e $TEXT_STATUS

