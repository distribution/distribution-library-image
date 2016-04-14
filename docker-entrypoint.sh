#!/bin/sh

set -e

if [ -f $1 ]; then
    set -- /bin/registry serve "$@"
    exec "$@"
fi

if [ "$1" = "sh" ]; then
    shift
    set -- /bin/sh "$@"
    exec "$@"
fi

set -- /bin/registry "$@"

exec "$@"
