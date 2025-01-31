function _activate() {
    local venv_dir="$1"

    # Don't reactivate an already activated virtual environment
    if [[ -z "$VIRTUAL_ENV" || "$venv_dir" != "$VIRTUAL_ENV" ]]; then
        source "$venv_dir/bin/activate"
    fi
}

function _deactivate() {
    # Don't deactivate if it's also a Pyenv virtual environment (co-exist fix)
    if [[ -n "$VIRTUAL_ENV" && -z "$PYENV_VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

# Gives the path to the nearest target file
function _check_path()
{
    local check_dir="$1"
    local check_file="$2"

    if [[ -d "${check_dir}/$check_file" ]]; then
        printf "${check_dir}/$check_file"
        return
    else
        # Abort search at file system root or HOME directory (latter is a performance optimisation).
        if [[ "$check_dir" = "/" || "$check_dir" = "$HOME" ]]; then
            return
        fi
        _check_path "$(dirname "$check_dir")" "$check_file"
    fi
}

function _check_venv()
{
    local venv_path="$(_check_path "$PWD" ".venv")"

    if [[ -n "$venv_path" ]]; then
        _activate "$venv_path"
    else
        _deactivate
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _check_venv

_check_venv
