#!/bin/sh

set -eu

usage() {
    cat << EOF
Usage: `basename $0`
EOF
    exit $1
}

gopkgs=(
    # 'github.com/motemen/ghq'
    'github.com/lib/pq'
    'github.com/jackc/pgx'
    'github.com/mattn/go-sqlite3'
    'github.com/go-sql-driver/mysql'
    'github.com/koron/gomigemo/cmd/gmigemo'
    'golang.org/x/tools/cmd/stringer'
    'github.com/cespare/prettybench'
    'github.com/gohugoio/hugo'
    'golang.org/x/tools/cmd/benchcmp'
    'golang.org/x/tools/gopls'
    'golang.org/x/perf/cmd/benchstat'
    'github.com/shurcooL/markdownfmt'
    'github.com/syohex/byzanz-window/cmd/byzanz-window'
    'github.com/dvyukov/go-fuzz'
    'github.com/dvyukov/go-fuzz-build'
    'github.com/github/git-lfs'
    'github.com/golang/dep/cmd/dep'
    'github.com/codegangsta/gin'
    'github.com/derekparker/delve/cmd/dlv'
    'github.com/cweill/gotests/...'
    'github.com/direnv/direnv'
    'github.com/ckaznocha/protoc-gen-lint'
    'github.com/mvdan/sh/cmd/shfmt'
    'github.com/junegunn/fzf'
)

for pkg in ${gopkgs[@]}; do
    go get -u -v $pkg
done
