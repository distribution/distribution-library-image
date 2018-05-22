#!/bin/bash

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./update.sh <docker/distribution major.minor>"
	exit
fi

VERSION=$1

# cd to the current directory so the script can be run from anywhere.
cd "$(dirname "$0")/$VERSION"

echo "Updating distribution $VERSION..."

FULL_VERSION="$(
	git ls-remote https://github.com/docker/distribution.git 'refs/tags/v*' \
		| cut -d/ -f3 \
		| cut -d^ -f1 \
		| cut -dv -f2- \
		| sort --unique --version-sort \
		| grep -E "^$VERSION[.]" \
		| tail -n1
)"

echo "Full version: $FULL_VERSION"

sed -ri -e "s/^(ENV REGISTRY_VERSION) .*/\1 $FULL_VERSION/" Dockerfile

echo "Done."
