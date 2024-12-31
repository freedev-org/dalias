#!/bin/bash

INSTALL_PATH="/usr/bin"

function main() {
    case "$1" in
        -r|--remote)
            init_remote "${2-main}"

            install || {
                echo "[ERROR] Installation failed!" >&2
            }

            finish_remote
            ;;
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

function init_remote() {
    local branch="$1"
    local path="$(mktemp -d)"

    (
        set -x

        git clone -b "$branch" --single-branch https://github.com/freedev-org/dalias "$path"
    )

    pushd "$path" > /dev/null
}

function finish_remote() {
    local path="$PWD"

    assert "[ '${path:0:5}' == '/tmp/' ]" \
        "PWD is not on temp dir and this assertion prevent to delete the wrong directory."

    popd > /dev/null

    (
        set -x

        rm -rf "$path"
    )
}


function to_install_path() {
    echo "$INSTALL_PATH/$(basename -s .sh "$1")"
}

function assert() {
    local assertion="$1"
    local message="$2"

    ( eval "$assertion" ) || {
        caller 0 | head -c-1
        echo ": assert: Assertion '$assertion' failed!" >&2

        if [ -n "$message" ]; then
            echo "  $message"
        fi

        exit 9
    }
}


main "$@"
