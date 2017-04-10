#!/bin/sh

set -e

case "$1" in
    *.yaml|*.yml) set -- registry serve "$@" ;;
    serve|garbage-collect|help|-*) set -- registry "$@" ;;
    gc-and-serve)
        shift
        registry garbage-collect "$@" || true
        set -- registry serve "$@" ;;
esac

exec "$@"
