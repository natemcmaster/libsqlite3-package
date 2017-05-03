#!/usr/bin/env bash

version='1.0.3'
dotnet="$(which dotnet)"

if [[ "$dotnet" == "" ]] || [[ "$($dotnet --version)" != "$version"  ]] ; then
    set -e
    DOTNET_HOME="$(pwd)/.dotnet"
    dotnet="$DOTNET_HOME/dotnet"
    if [[ ! -e $dotnet ]]; then
        curl -sSL https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/dotnet-install.sh \
            | bash -s -- -i $DOTNET_HOME --version $version
    fi
fi

if [[ "$(uname)" == "Darwin" ]]; then
    # Increase file descriptor limit so dotnet-restore won't fail
    ulimit -n 2048
fi

set -e

pushd test

    $dotnet restore
    $dotnet test

popd
