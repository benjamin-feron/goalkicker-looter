#!/bin/bash

###########################
# goalkicker-looter 1.0.0 #
###########################

show_help () {
  echo "Usage: goalkicker-looter [OPTIONS]
  Options:
  -d, --destination    Destination directory (default: ./books).
    -l, --list           List available books.
    -n, --name           Book name. To list available books, une -n or --name option.
                         If not specified, will download all books.
    -f, --force          Force downloading of already downloaded books.
    --help               Show help"
}

URL=https://goalkicker.com
DEST=./books

LIST=0
NAME=""
FORCE=0

while :; do
  case $1 in
    -d|--destination)
      DEST=${2}
      shift
      ;;
    -l|--list)
      LIST=1
      shift
      ;;
    -n|--name)
      NAME=${2}
      shift
      ;;
    -f|--force)
      FORCE=1
      shift
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

# Make destination directory
[ -d "$DEST" ] || mkdir "$DEST"

# Obtain books list
books=$(curl -s $URL | grep -Eo 'href="[^"]*Book[0-9]*' | grep -Ev https\? | cut -c 7-)

# List books
if [ $LIST == 1 ]; then
  for book in $books; do
    [[ "$NAME" != "" ]] && [[ ! $book =~ "${NAME}Book" ]] && continue
    echo "$book" | sed 's/\(.\+\)Book/\1/'
  done
  exit
fi

# Download books
for book in $books; do
  [[ ! $book =~ "${NAME}Book" ]] && echo "Book not found, une -l or --list option to list available books" && exit 1
  book_file_name=`curl -s "$URL/$book/" | grep -e '.*<button.\+class="download".\+[a-z]<\/button>' | sed "s/.\+onclick=\"location\.href='\(.\+\)'.\+/\1/"`
  book_dest="$DEST/$book_file_name"
  echo "Downloading $URL/$book_page_url/$book_file_name..."
  if [[ $FORCE == 0 ]]; then
    [ -f "$book_dest" ] && echo "File already exists, use -f option to force downloading." && [[ "$NAME" != "" ]] && break
  fi
  curl -s "$URL/$book_page_url/$book_file_name" -o "$book_dest"
  echo "Done."
  [[ "$NAME" != "" ]] && break
done

