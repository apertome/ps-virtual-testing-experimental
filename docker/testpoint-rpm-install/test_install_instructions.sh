#!/usr/bin/bash

# default repo
REPO="nightly-minor"

# set repo if commandline argument is set
if [ -n "$1" ]; then
    REPO=$1
fi

echo "REPO: $REPO"

#declare -a BUNDLES=("perfsonar-tools" "perfsonar-testpoint" "perfsonar-psconfig-web-admin-ui")
declare -a BUNDLES=("perfsonar-psconfig-web-admin-ui perfsonar-psconfig-web-admin-publisher" "perfsonar-tools" "perfsonar-core" "perfsonar-testpoint" "perfsonar-centralmanagement" "perfsonar-toolkit")
TEXT_STATUS=""
OUT=""
docker-compose down
docker-compose build --no-cache --force-rm --build-arg bundle="$BUNDLE"  centos_clean
docker rm -f single-sanity
for BUNDLE in ${BUNDLES[@]}; do
    echo "BUILD BUNDLE $BUNDLE"
    docker-compose up -d
    #CONTAINER="$BUNDLE-$REPO"
    #CONTAINER="$BUNDLE"
    LABEL="$BUNDLE-$REPO"
    CONTAINER="rpm-install-transient"
    echo "CONTAINER: $CONTAINER"
    docker-compose exec centos_clean /usr/bin/ps_install_bundle.sh "$BUNDLE" "$REPO"
    echo "LABEL: $LABEL"
    OUT+=`docker run --privileged --name single-sanity --network bundle_testing -v /data/sanity/single-sanity.pl:/app/single-sanity.pl --rm single-sanity $CONTAINER $BUNDLE $REPO`
    OUT+="\n"
    echo "LABEL: $LABEL"
    echo -e "OUT:\n$OUT\n"

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
    echo -e "OUT:\n$OUT\n"
    echo -e $OUT | jq .

echo -e $TEXT_STATUS

