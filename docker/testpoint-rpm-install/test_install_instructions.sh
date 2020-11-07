#!/usr/bin/bash

declare -a REPOS=("perfsonar-tools" "perfsonar-testpoint" "perfsonar-core" "perfsonar-centralmanagement" "perfsonar-toolkit")
TEXT_STATUS=""
docker-compose down
for REPO in ${REPOS[@]}; do
    echo "BUILD REPO $REPO"
    docker-compose build --no-cache --force-rm --build-arg repo="$REPO"  centos_clean
    STATUS=$?
    echo "$REPO Tried to build; status: $STATUS"
    if [ "$STATUS" -eq "0" ]; then
        echo "$REPO SUCCEDED!"
        TEXT_STATUS+="$REPO SUCCEEDED!\n"
        #exit;
    else
        echo "$REPO FAILED!"
        TEXT_STATUS+="$REPO FAILED!\n"
    fi
    docker-compose down

    echo -e $TEXT_STATUS
done

echo -e $TEXT_STATUS

