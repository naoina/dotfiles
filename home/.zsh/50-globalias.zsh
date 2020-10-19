# Original function is copied from https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/globalias
function globalias() {
    # Get last word to the left of the cursor:
    # (z) splits into words using shell parsing
    # (A) makes it an array even if there's only one element
    local args=(${(Az)LBUFFER})
    local cmd=$args[1]
    case "$cmd" in
        git)
            cmd="$(git config --get "alias.$args[2]" 2>/dev/null)"
            if [[ "$cmd[1]" = "!" ]]; then
                cmd=(${(Aps: :)"${cmd:1}"})
                args[1]=${cmd[1]}
                args[2]=${cmd:1}
                LBUFFER="$args"
            elif [[ -n "$cmd" ]]; then
                args[2]="$cmd"
                LBUFFER="$args"
            fi
            ;;
        *)
            ;;
    esac
    local word=$args[-1]
    zstyle -a ':globalias:var' filters filters
    [[ -n "$filters" ]] || filters=()
    if [[ $filters[(Ie)$word] -ne 0 ]]; then
        zle _expand_alias
        zle expand-word
    fi
    if [[ "$KEYS" = ' ' ]]; then
        zle self-insert
    else
        zle accept-line
    fi
}
zle -N globalias

bindkey -M emacs " " globalias
bindkey -M viins " " globalias

bindkey -M emacs "^M" globalias
bindkey -M viins "^M" globalias
