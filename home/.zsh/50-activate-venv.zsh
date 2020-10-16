activate-venv() {
    local venv_path="${VENV_PATH:-.venv}"
    local cwd="$PWD"

    while true; do
        if [ -d "${cwd}/${venv_path}" ]; then
            . "${cwd}/${venv_path}/bin/activate"
            break
        fi
        if [ -z "${cwd}" ]; then
            if [ -n "$VIRTUAL_ENV" ]; then
                deactivate
            fi
            break
        fi
        cwd="${cwd%/*}"
    done
}
