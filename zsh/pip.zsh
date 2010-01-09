#!/usr/bin/env zsh

export PIP_VIRTUALENV_BASE=$WORKON_HOME

PIP_BIN="`which pip`"
alias pip-sys="$PIP_BIN"

pip() {
    if [ -n "$VIRTUAL_ENV" ]
    then $PIP_BIN -E "$VIRTUAL_ENV" "$@"
    else echo "Not currently in a venv -- use pip-sys to work system-wide."
    fi
}