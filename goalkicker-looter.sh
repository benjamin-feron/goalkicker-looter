#!/bin/bash

###########################
# goalkicker-looter 1.0.0 #
###########################

show_help () {
  echo "Usage: goalkicker-looter [OPTIONS] [NAME]

  Name:                  Book name. To list available books, use -n or --name option.
                         If not specified, will download all books.
  Options:
    -d, --destination    Destination directory, default: ./books.
    -l, --list           List available books.
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

# Make destination directory
[ -d "$DEST" ] || mkdir "$DEST"

# Obtain books list
books=$(curl -s $URL | grep -Eo 'href="[^"]*Book[0-9]*' | grep -Ev https\? | cut -c 7-)

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
  [[ $FORCE == 0 ]] && [ -f "$book_dest" ] && echo "File already exists, use -f option to force downloading." && [[ "$NAME" != "" ]] && break
  curl -s "$URL/$book_page_url/$book_file_name" -o "$book_dest"
  echo "Done."
  [[ "$NAME" != "" ]] && break
done

