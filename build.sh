#!/usr/bin/env bash

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    printf "${CYAN}info : $@ ${NC}\n"
}

set -e

versionSuffix=$DOTNET_BUILD_VERSION
buildTarget="package"

while [[ $# > 0 ]]; do
    case $1 in
        --version)
            shift
            versionSuffix=$1
            ;;
        compile)
            buildTarget="compile"
            ;;
        pack)
            buildTarget="package"
            ;;
        *)
            printf "${RED}Unrecognized argument $1${NC}\n"
            exit 1
    esac
    shift
done

installDir=".dotnet/"
dotnet="$installDir/dotnet"

dotnet() {
    log "dotnet $@"
    $dotnet $@
}

_clean() {
    rm -rf artifacts
    mkdir -p artifacts
}

_compile() {
    log "Compiling sqlite"
    dotnet run -p tools/SqliteCompiler/
}

_package() {
    dotnet run -p tools/PackageBuilder/ $@

    if [[ "$versionSuffix" == "" ]]; then
        versionSuffix="t$(date "+%s")"
    fi

    for f in src/*/project.json; do
        dotnet pack $f -o artifacts/build/ --version-suffix $versionSuffix
    done

    log "Cleanup useless symbols packages"
    rm artifacts/build/*.symbols.nupkg
}

# main
log "Build target = $buildTarget"

if [[ ! -e $dotnet ]]; then
    dotnetVersion="$(cat .dotnet-version)"
    log "Install dotnet $dotnetVersion"
    
    curl https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/dotnet-install.sh | bash -s -- -i $installDir -v $dotnetVersion
fi

_clean

dotnet restore --verbosity minimal

if [[ "$buildTarget" == "compile" ]]; then
    _compile
else
    _package --osx binaries/osx-x64.zip --linux-x86 binaries/linux-x86.zip --linux-x64 binaries/linux-x64.zip
fi

if type git 2>/dev/null; then
    log "Add commit hash to artifacts dir"
    git rev-parse HEAD >> artifacts/commit 
fi
printf "${GREEN}Done${NC}\n"
