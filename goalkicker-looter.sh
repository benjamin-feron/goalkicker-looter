#!/bin/bash

###########################
# goalkicker-looter 1.0.0 #
###########################

show_help () {
  echo "Usage: goalkicker-looter [OPTIONS] [NAME]

  Name:                  Book name.
                         If not specified, will download all books.
                         To list available books, use -l or --list option.
  Options:
    -d, --destination    Destination directory, default: ./books.
    -l, --list           Only list available books, does not download them.
    -f, --force          Force downloading of already downloaded books.
    --help               Show help"
}

URL=https://goalkicker.com
DEST=./books

LIST=0
FORCE=0
NAME=""

while :; do
  case $1 in
    -d|--destination)
      DEST=${2}
      shift
      ;;
    -l|--list)
      LIST=1
      ;;
    -f|--force)
      FORCE=1
      ;;
    --help)
      show_help
      exit
      ;;
    --)
      shift
      break
      ;;
    -?*)
      printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
      ;;
    *)
      break
  esac
  shift
done

NAME="$1"
shift

# Requirements
command -v curl &> /dev/null || (echo 'Curl not found, you must install it' && exit 1)

# Make destination directory
[ -d "$DEST" ] || mkdir "$DEST"

# Obtain books list
echo "Obtening book list..."
books=$(curl -s $URL | grep -Eo 'href="[^"]*Book[0-9]*' | grep -Ev https\? | cut -c 7-)
echo 'Done.'

# Check existing of specified book
[ ! -z "$NAME" ] && [[ ! ${books[*]} =~ (^|[[:space:]])"${NAME}Book"($|[[:space:]]) ]] && echo "Book not found, use -l or --list option without -n to list all available books" && exit 1

# List books
if [ $LIST == 1 ]; then
  for book in $books; do
    [ ! -z "$NAME" ] && [[ ! $book =~ "${NAME}Book" ]] && continue
    echo "$book" | sed 's/\(.\+\)Book/\1/'
  done
  exit
fi

# Download books
for book in $books; do
  [ ! -z "$NAME" ] && [[ ! "$book" =~ "${NAME}Book" ]] && continue
  book_file_name=`curl -s "$URL/$book/" | grep -e '.*<button.\+class="download".\+[a-z]<\/button>' | sed "s/.\+onclick=\"location\.href='\(.\+\)'.\+/\1/"`
  book_dest="$DEST/$book_file_name"
  echo "Downloading $URL/$book_page_url/$book_file_name..."
  if ([[ $FORCE == 0 ]] && [ -f "$book_dest" ]); then
    echo "File already exists, use -f option to force downloading."
    [ ! -z "$NAME" ] && break || continue
  fi
  curl -s "$URL/$book_page_url/$book_file_name" -o "$book_dest"
  echo "Done."
  [ ! -z "$NAME" ] && break
done

