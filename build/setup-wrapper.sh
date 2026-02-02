#!/bin/sh

set -ex

if test $(id -u) -eq 0; then
    case "$RUNNER_OS" in
	Linux)
	    chown -R "$RUNUSER" "$GITHUB_WORKSPACE"
	    mkdir "$GITHUB_WORKSPACE/$INSTALLDIR"
	    ;;
	*)
	    echo "Unsupported OS: $RUNNER_OS" 1>&2
	    exit 1
	    ;;
    esac
fi
