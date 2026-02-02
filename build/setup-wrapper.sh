#!/bin/sh

set -ex

mkdir "$GITHUB_WORKSPACE/$BUILDDIR"
mkdir "$GITHUB_WORKSPACE/$INSTALLDIR"

if test $(id -u) -eq 0; then
    case "$RUNNER_OS" in
	Linux)
	    chown -R "$RUNUSER" "$GITHUB_WORKSPACE/$BUILDDIR"
	    # This is necessary to put libskk.pot in $(srcdir)
	    chown -R "$RUNUSER" "$GITHUB_WORKSPACE/po"
	    ;;
	*)
	    echo "Unsupported OS: $RUNNER_OS" 1>&2
	    exit 1
	    ;;
    esac
fi
