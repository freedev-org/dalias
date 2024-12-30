#!/bin/bash

INSTALL_PATH="/usr/bin"

function main() {
    case "$1" in
        -u|--uninstall)
            uninstall
            ;;
        *)
            install
    esac
}

function install() {
    for script in src/*.sh; do
        local path="$(to_install_path "$script")"

        (
            set -x
            cp -f "$script" "$path"
            chmod +x "$path"
        )
    done
}

function uninstall() {
    for script in src/*.sh; do
        local path="$(to_install_path "$script")"

        (
            set -x
            rm -f "$path"
        )
    done
}


function to_install_path() {
    echo "$INSTALL_PATH/$(basename -s .sh "$1")"
}


main "$@"
