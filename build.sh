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

_dotnet() {
    log "dotnet $@"
    $dotnet $@
}

_clean() {
    log "Clean $(pwd)/artifacts/"
    rm -rf artifacts
    mkdir -p artifacts
}

_compile() {
    sqliteVersion="3120200"
    log "Compiling sqlite v$sqliteVersion"
    sqliteSrc="https://sqlite.org/2016/sqlite-autoconf-${sqliteVersion}.tar.gz"
    
    log "Clean obj/build/"
    rm -rf obj/build/
    mkdir -p obj/build/
    
    curl -sSL $sqliteSrc | tar zvx -C obj/build/
    if [[ "$(uname)" == "Darwin" ]]; then
        rid="osx-x64"
    else
        rid="linux-x64"
    fi
    artifactsDir="$(pwd)/artifacts/$rid"
    mkdir -p $artifactsDir
    
    srcDir="obj/build/sqlite-autoconf-${sqliteVersion}"
    log "cwd = $srcDir"
    pushd $srcDir
        
        export CPPFLAGS="$CPPFLAGS -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS4"
        if [[ "$(uname)" == "Darwin" ]]; then
            export CPPFLAGS="$CPPFLAGS -DSQLITE_ENABLE_FTS5"
        fi
        
        ./configure --prefix=$(pwd) --disable-dependency-tracking --enable-dynamic-extensions
        make install
        
        if [[ "$(uname)" == "Darwin" ]]; then
            dest="$artifactsDir/libsqlite3.dylib"
            log "Copy libsqlite3.0.dylib to $dest"
            cp lib/libsqlite3.0.dylib $dest
        else
            dest="$artifactsDir/libsqlite3.so"
            log "Copy libsqlite3.so.0.8.6 to $dest"
            cp lib/libsqlite3.so.0.8.6 $dest
        fi
        
    popd
    zip -j artifacts/$rid.zip $artifactsDir/libsqlite3*
}

_package() {
    if [[ ! -e $dotnet ]]; then
        dotnetVersion="$(cat .dotnet-version)"
        log "Install dotnet $dotnetVersion"
        
        curl https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0-preview1/scripts/obtain/dotnet-install.sh | bash -s -- -i $installDir -v $dotnetVersion --channel beta
    fi

    _dotnet restore --verbosity minimal

    _dotnet run -p tools/PackageBuilder/ $@

    if [[ "$versionSuffix" == "" ]]; then
        versionSuffix="t$(date "+%s")"
    fi

    for f in src/*/project.json; do
        _dotnet pack $f -o artifacts/build/ --version-suffix $versionSuffix
    done

    log "Cleanup useless symbols packages"
    rm artifacts/build/*.symbols.nupkg
}

# main
log "Build target = $buildTarget"

_clean

if [[ "$buildTarget" == "compile" ]]; then
    _compile
else
    _package --osx binaries/osx-x64.zip --linux binaries/linux-x64.zip
fi

printf "${GREEN}Done${NC}\n"
