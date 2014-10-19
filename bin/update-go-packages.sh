#!/bin/sh

usage() {
    cat << EOF
Usage: `basename $0`
EOF
    exit $1
}

gopkgs=(
    'code.google.com/p/go.tools/cmd/godoc'
    'github.com/josharian/impl'
    'github.com/motemen/ghq'
    'github.com/lib/pq'
    'github.com/mattn/go-sqlite3'
    'github.com/go-sql-driver/mysql'
    'github.com/peco/peco/cmd/peco'
    'github.com/peco/migemogrep'
)

for pkg in ${gopkgs[@]}; do
    go get -u -v $pkg
done
