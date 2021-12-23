#!/bin/bash

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./update.sh <distribution/distribution tag or branch>"
	exit
fi

VERSION=$1

if [ "$GOARCH" == "" ] ; then
	echo "Must set GOARCH in environment"
	exit
fi

# cd to the current directory so the script can be run from anywhere.
cd `dirname $0`

echo "Fetching and building distribution $VERSION..."

# Create a temporary directory.
TEMP=`mktemp -d --tmpdir distribution.XXXXXX`

git clone -b $VERSION https://github.com/distribution/distribution.git $TEMP
docker build --build-arg GOARCH=$GOARCH --build-arg GOARM=$GOARM -t distribution-builder-$GOARCH $TEMP

# Create a dummy distribution-build container so we can run a cp against it.
ID=$(docker create distribution-builder-$GOARCH)

# Update the local binary and config.
docker cp $ID:/bin/registry $GOARCH

# Cleanup.
docker rm -f $ID
docker rmi distribution-builder-$GOARCH

cp Dockerfile.noarch $GOARCH/Dockerfile
cp docker-entrypoint.sh config-example.yml $GOARCH

echo "Building Windows binary"

docker build --build-arg GOOS=windows -t distribution-builder:windows $TEMP

ID=$(docker create distribution-builder:windows)

docker cp $ID:/go/bin/registry windows/nanoserver/registry/registry.exe
cp registry/config-example.yml windows/nanoserver/registry
sed -i.bak 's_/var/lib/registry_c:\\data_' windows/nanoserver/registry/config-example.yml

cp windows/nanoserver/registry/ windows/windowsservercore/registry/

# Cleanup.
docker rm -f $ID
docker rmi distribution-builder:windows

echo "Done."
