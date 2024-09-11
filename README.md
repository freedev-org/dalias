# dalias
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


## Install

Install with one line:

```console
curl -sSL https://fd1.in/dalias | sudo tee /usr/bin/dalias >/dev/null && sudo chmod +x /usr/bin/dalias
```

To see help:

```console
dalias --help
```

## Uninstall

**Note**: To uninstall, just delete `/usr/bin/dalias`. You can also delete
`~/.dalias` for remove no more needed configuration files.

```console
sudo rm /usr/bin/dalias
rm -r ~/.dalias
```
