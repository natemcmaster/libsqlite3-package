#!/usr/bin/env bash

RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    printf "${CYAN}info : $@ ${NC}\n"
}

set -e

_compile() {
    sqliteVersion="$(cat .sqlite-version)"
    log "Compiling sqlite v$sqliteVersion"
    sqliteSrc="https://sqlite.org/2016/sqlite-autoconf-${sqliteVersion}.tar.gz"
    
    log "Clean obj/build/"
    rm -rf obj/build/
    mkdir -p obj/build/
    
    curl -sSL $sqliteSrc | tar zvx -C obj/build/
    if [[ "$rid" != "" ]]; then
        :
    elif [[ "$(uname)" == "Darwin" ]]; then
        rid="osx-x64"
    else
        rid="linux-x64"
    fi

    log "rid = $rid"

    artifactsDir="$(pwd)/artifacts/$rid"
    log "Clean $artifactsDir"
    rm -rf $artifactsDir
    mkdir -p $artifactsDir
    
    srcDir="obj/build/sqlite-autoconf-${sqliteVersion}"
    log "cwd = $srcDir"
    pushd $srcDir
        
        export CPPFLAGS="$CPPFLAGS -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_FTS4"
        if [[ "$(uname)" == "Darwin" ]]; then
            export CPPFLAGS="$CPPFLAGS -DSQLITE_ENABLE_FTS5"
        fi
        
        ./configure --prefix=$(pwd) \
                    --disable-dependency-tracking \
                    --enable-dynamic-extensions || return 1

        if [[ "$rid" == "alpine-x64" ]]; then
            log "Configuring libtool for alpine"
            sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	        sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
        fi

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

_compile

printf "${GREEN}Done${NC}\n"
