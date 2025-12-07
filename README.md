# dalias

This repository has tools to easy create and use environments inside docker containers.

## Usage

### dalias
```
dalias [options] [name[=value] ... ]
```

Create alias commands to run inside a Docker environment. You can use this tool
to make your life easy and fast have some command-line tool usable in your
system without install it.

For example:

```console
dalias php='php:8.2-cli-alpine php "$@"' composer='composer:2.7 "$@"'
```

After run this simple command line is possible to use PHP and composer in your
system without install it, just running inside docker containers.

You can use the "daliases" just like normal binaries in your system. You just
need to add `~/.dalias/bin` to your PATH variable and be happy.

More examples:

```console
dalias node='node:20-alpine node "\$@"'
dalias yarnd='&node:20-alpine yarn "\$@"'  # Run in background mode
dalias php='php:8.2-cli "\$@"'
dalias php-server='-p\${1-8000}:\${1-8000} php:8.2-cli-alpine php -S 0.0.0.0:\${1-8000}'
```

### denv
```
denv [options] <command> [command-specific-options] [args]
```

Create a environment inside a docker container to easy install and use tools without polute
your host system with packages that you will no longer use for another purposes.

Example:

```console
denv create sandbox
```

After create the environment, you can open a shell inside the container with:

```console
sandbox bash
```

Another examples:

```console
# Mount current path inside the container
denv create -v .:/app compile-project
```

```console
# Create an environment using Kali image
denv create -i kalilinux/kali-rolling kali
```

## Install

Install with one line:

```console
curl -sSL https://s.freedev.com.br/dalias-install | sudo bash -s -- -r
```

To see help:

```console
dalias --help
denv --help
```

## Uninstall

**Note**: To uninstall, just run `./install.sh -u`. You can also delete
`~/.dalias` directory for remove no more needed configuration files,
volumes and scripts.


```console
sudo ./install.sh -u
```

## WARNING!

For security reasons, **DO NOT** add your user to `docker` group. An attacker
can escalate privileges in a system using an user account in `docker` group
as easy as run the command below:

```console
docker run --rm -it -v /:/root/host bitnami/minideb:bullseye chroot /root/host
```

Instead, you can configure Docker rootless for your user. Please, read the
following documentation:

- <https://docs.docker.com/engine/security/rootless/>
