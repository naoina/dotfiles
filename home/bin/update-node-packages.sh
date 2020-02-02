#!/bin/sh

usage() {
    cat << EOF
Usage: `basename $0`
EOF
    exit $1
}

nodepkgs=(
    'jshint'
    'coffee-script'
    'jsonlint'
    'coffeelint'
    'jade-lint'
    'pug-lint'
    'eslint'
    'eslint-plugin-vue'
    'eslint-plugin-import'
    'eslint-plugin-node'
    'eslint-plugin-promise'
    'eslint-plugin-standard'
    'grunt-cli'
    'gulp'
    'node-dev'
    'html2jade'
    'handlebars'
    'textlint'
    'textlint-rule-no-nfd'
    'textlint-rule-no-surrogate-pair'
    'textlint-rule-preset-jtf-style'
    'textlint-rule-no-mix-dearu-desumasu'
    'textlint-rule-ja-no-mixed-period'
    'textlint-rule-period-in-list-item'
    'textlint-rule-ja-hiragana-hojodoushi'
    'textlint-rule-ja-unnatural-alphabet'
    'textlint-rule-ja-no-successive-word'
    'textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet'
    'textlint-rule-ja-no-redundant-expression'
    'textlint-plugin-review'
    'prh'
    'vue-cli'
    'prettier'
    'prettier-eslint-cli'
    'eslint-config-prettier'
    'eslint-config-standard'
    'truffle'
    'table'
    'solium'
    'solium-plugin-security'
    'solhint'
    'remotedebug-ios-webkit-adapter'
    'typescript'
    'typescript-language-server'
    'vue-language-server'
)

for pkg in ${nodepkgs[@]}; do
    npm install -g $pkg
done
