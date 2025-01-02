#!/bin/bash

CONFIG_DIR=~/.dalias
BIN_DIR="$CONFIG_DIR/bin"
VOLUMES_DIR="$CONFIG_DIR/volumes"
DEFAULT_VOLUME_PATH="/root/host"


function show_help() {
    cat <<:EOF
Developed by Luiz Felipe Silva <silva97@freedev.com.br>
Create environments inside Docker containers.

USAGE
  denv [options] <command> [command-specific-options] [args]

  -h,--help        Show this help message.

EXAMPLE
  \$ denv create sandbox
  \$ sandbox bash

SHORTCUTS
  After create a new environment, a shortcut script is created to easy run a
  command inside the environemnt's container. For instance, if the
  environment is named "myenv", then:

    $ myenv bash

  Will open a bash terminal inside the container. Or:

    $ myenv cat /etc/hosts

  Will run a specific command inside the container and exit.

  Note: To be able to use these shortcuts, ensure that the following directory
  is in your PATH environment variable:
    $BIN_DIR

COMMANDS
  create [options] <name>
                    Create a new environment with the given name.

    -v,--volume     Mount the given volume on the container.
                    By default a volume is mounted on path "$DEFAULT_VOLUME_PATH"
                    inside the environment's container. All the volumes can be
                    found on "$VOLUMES_DIR" directory. The syntax is the same
                    of \`--volume\` option of \`docker run\` command.
                    i.e.:
                        [host-path]:[container-path]:[options]

    -p,--port       Bind the specified port to the host. The syntax is the same
                    of \`--publish\` option of \`docker run\` command.
                    i.e.:
                        [host-port]:[container-port]

    -i,--image      Specify the Docker image used to create the container.
                    Default: "debian:latest".

  rm <name>         Delete the environment with the given name.
  stop <name>       Stop the environment's container.
  start <name>      Start the environment's container.
  ps                List all environment's containers.
:EOF
}

function main() {
    local command="$1"
    shift

    case "$command" in
        create)
            cmd_create "$@"
            ;;
        rm)
            cmd_rm "$@"
            ;;
        stop)
            cmd_stop "$@"
            ;;
        start)
            cmd_start "$@"
            ;;
        ps)
            cmd_ps "$@"
            ;;
        -h|--help|help|"")
            show_help
            exit 0
            ;;
        *)
            error "Invalid command '$command'!"
            exit 1
            ;;
    esac
}

function cmd_create() {
    local opt_image="debian:latest"
    local extra_flags=""

    while [ "${1:0:1}" == "-" ]; do
        case "$1" in
            -v|--volume)
                extra_flags+="-v $2 "
                shift 1
                ;;
            -p|--port)
                extra_flags+="-p $2 "
                shift 1
                ;;
            -i|--image)
                opt_image="$2"
                shift 1
                ;;
        esac

        shift 1
    done

    local name="$1"
    [ -z "$name" ] && fatal 1 "Argument <name> is not set! See help: denv --help"

    mkdir -p "$VOLUMES_DIR/$name"
    info "Volume '$VOLUMES_DIR/$name' created."

    docker run \
        --interactive \
        --detach \
        --hostname "$name" \
        --workdir /root \
        --volume "$VOLUMES_DIR/$name:$DEFAULT_VOLUME_PATH" \
        --name "denv-$name" \
        $extra_flags \
        "$opt_image" \
        "cat"

    mkdir -p "$BIN_DIR"

    {
        echo "#!/bin/sh"
        echo "# This file is auto-generated by 'denv' tool. Please, do not"
        echo "# update this file manually. See \`denv --help\` for help."
        echo "set -x"
        echo "docker exec -it "denv-$name" \$@"
    } > "$BIN_DIR/$name"

    chmod +x "$BIN_DIR/$name"
}

function cmd_rm() {
    local name="$1"

    [ -z "$1" ] && fatal 1 "Argument <name> is not set! See help: denv --help"

    cmd_stop "$name"

    info "Removing container..."
    docker rm "denv-$name" > /dev/null

    rm -rf "$VOLUMES_DIR/$name"
    rm -f "$BIN_DIR/$name"
}

function cmd_stop() {
    local name="$1"

    [ -z "$1" ] && fatal 1 "Argument <name> is not set! See help: denv --help"

    info "Stopping environment '$name'..."
    docker stop "denv-$name" > /dev/null
}

function cmd_start() {
    local name="$1"

    [ -z "$1" ] && fatal 1 "Argument <name> is not set! See help: denv --help"

    info "Starting environment '$name'..."
    docker start "denv-$name" > /dev/null
}

function cmd_ps() {
    docker ps -af 'name=denv-'
}


function info() {
    echo -e "$@"
}

function error() {
    echo -e "$@" >&2
}

function fatal() {
    local exit_code="$1"

    shift 1
    error "$@"

    exit "$exit_code"
}


main "$@"
