#!/bin/sh

SCRIPT_VERSION=1.0

# Set defaults
SRCDIR=.
DESTDIR=./build
BUILDTYPE=html
MACROFILE=
CLEAN=

# Read command line arguments
for arg in "$@"
do
    case "$arg" in
    --srcdir=*)
        SRCDIR=$( echo "$arg" | sed -e 's/--srcdir=//' -e 's/\/$//' )
        ;;
    --destdir=*)
        DESTDIR=$( echo "$arg" | sed -e 's/--destdir=//' -e 's/\/$//' )
        ;;
    --buildtype=*)
        BUILDTYPE=$( echo "$arg" | sed -e 's/--buildtype=//' )
        ;;
    --macrofile=*)
        MACROFILE=$( echo "$arg" | sed -e 's/--macrofile=//' )
        ;;
    --clean)
        CLEAN=true
        ;;
    --help)
        echo "Groff Builder Version $SCRIPT_VERSION"
        echo ''
        echo 'Usage:'
        echo '    ./build.sh [options]'
        echo ''
        echo 'Options:'
        echo ''
        echo '--srcdir=<dir>'
        echo '    The directory containing the ms source files.'
        echo ''
        echo '--destdir=<dir>'
        echo '    The directory where the built files should be deployed to.'
        echo ''
        echo '--buildtype=<dir>'
        echo '    Sets the output type. For possible types see `man 1 groff`.'
        echo ''
        echo '--macrofile=<dir>'
        echo '    The macro file to be included.'
        echo ''
        echo '--clean'
        echo '    If present, the contents of destdir will be erased.'
        exit
    esac
done

if [ "$CLEAN" = "true" ]
then
    printf '[-] Cleaning up "%s"...\n' "$DESTDIR/*"
    rm -rf "$DESTDIR"/*
fi

# Find all .ms files
printf '[*] Looking for files to build in "%s"...\n' "$SRCDIR"
FILES=$( find "$SRCDIR" -name '*.ms' -type f )

# Build each file to the destination directory
for f in $FILES
do
    printf '    [+] Building file "%s"...\n' "$f"

    outfile=$( echo "$f" | sed -e "s;$SRCDIR;$DESTDIR;" -e "s;\.ms\$;\.$BUILDTYPE;" )
    mkdir -p  "$( dirname "$outfile" )"

    if [ -z "$MACROFILE" ]
    then
        groff -ms "$f" -T "$BUILDTYPE" > "$outfile"
    else
        groff -ms "$f" -T "$BUILDTYPE" -m "$MACROFILE" > "$outfile"
    fi
done
printf '[*] No more files to build.\n'

