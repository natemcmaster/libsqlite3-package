#!/usr/bin/env bash

set -e

DOTNET_HOME="$(pwd)/.dotnet"
dotnet="$DOTNET_HOME/dotnet"
if [[ ! -e $dotnet ]]; then
    curl -sSL https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0-preview2/scripts/obtain/dotnet-install.sh | bash -s -- -i $DOTNET_HOME --version 1.0.0-preview2-003131
fi

pushd test

    $dotnet restore
    $dotnet test

popd
