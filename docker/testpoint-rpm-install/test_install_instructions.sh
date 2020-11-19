#!/usr/bin/bash

# default repo
REPO="nightly-minor"

# set repo if commandline argument is set
if [ -n "$1" ]; then
    REPO=$1
fi

echo "REPO: $REPO"

#declare -a BUNDLES=("perfsonar-tools" "perfsonar-testpoint" "perfsonar-core" "perfsonar-centralmanagement" "perfsonar-toolkit")
declare -a BUNDLES=("perfsonar-psconfig-web-admin-ui perfsonar-psconfig-web-admin-publisher" "perfsonar-tools" "perfsonar-testpoint" "perfsonar-core" "perfsonar-centralmanagement" "perfsonar-toolkit")
TEXT_STATUS=""
docker-compose down
docker-compose build --no-cache --force-rm --build-arg bundle="$BUNDLE"  centos_clean
for BUNDLE in ${BUNDLES[@]}; do
    echo "BUILD BUNDLE $BUNDLE"
    docker-compose up -d
    docker-compose exec centos_clean /usr/bin/ps_install_bundle.sh "$BUNDLE" "$REPO"

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

