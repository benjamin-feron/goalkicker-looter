# goalkicker-looter

A bash script that help to easily download books from https://goalkicker.com.

Requires curl.

## Repository

[https://github.com/benjamin-feron/goalkicker-looter](https://github.com/benjamin-feron/goalkicker-looter)

## Installation
```bash
$ git clone https://github.com/benjamin-feron/goalkicker-looter.git
```

## Usage
```
$ ./goalkicker-looter.sh [OPTIONS] [NAME]

  Name:                  Book name to download.
                         If not specified, will download all books.
                         To list available books, use -l or --list option.
  Options:
    -d, --destination    Destination directory, default: ./books.
    -l, --list           Only list available books, does not download them.
    -f, --force          Force downloading of already downloaded books.
    --help               Show help
```
