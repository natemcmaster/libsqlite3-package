#!/usr/bin/env bash

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    printf "${CYAN}info : $@ ${NC}\n"
}

set -e

_clean() {
    log "Clean $(pwd)/artifacts/"
    rm -rf artifacts
    mkdir -p artifacts
}

_compile() {
    sqliteVersion="$(cat .sqlite-version)"
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

# main
log "Build target = $buildTarget"

_clean

_compile

printf "${GREEN}Done${NC}\n"
