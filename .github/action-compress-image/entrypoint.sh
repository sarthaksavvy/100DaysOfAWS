#!/bin/bash

LGREEN="\033[1;32m" # Light Green
NC='\033[0m'        # No Color

process_link_pids=()

random_32_char() {
    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
}

process_link() {
    link=$1
    markdownfile=$2
    imgfile="/tmp/$(random_32_char)"

    echo -e ">> ${LGREEN}downloading${NC} $link"
    wget --quiet $link -O $imgfile
    wait

    sha1sum=$(sha1sum $imgfile | awk '{print $1;}')
    mv $imgfile "/tmp/$sha1sum"

    echo -e ">>> ${LGREEN}compressing${NC} $link"
    imgfinal="./images/$sha1sum.jpeg"
    convert "/tmp/$sha1sum" -resize 50% -quality 90 $imgfinal

    echo -e ">>> ${LGREEN}updating${NC} $link"
    sed -i "s+$link+$imgfinal+g" $file
}

process_links() {
    linkfile=$1
    markdownfile=$2

    while IFS= read -r line;
    do
        process_link $line $markdownfile &
        process_link_pids+=($!)
    done < $linkfile
}

mkdir -p ./images

for file in `find . -type f -name 'Day-*.md'`
do
    echo -e "> ${LGREEN}processing${NC} $file ..."
    tmpfile="/tmp/$(random_32_char)"
    cat $file \
        | grep -Eo '\!\[.*\](\((https:\/\/user-images\.githubusercontent\.com.*)\))' \
        | grep -Eo 'https.*[^\)]' \
        >> $tmpfile

    process_links $tmpfile $file
done

for pid in ${process_link_pids[*]}; do
    wait $pid
done

echo -e "${LGREEN}✅ All clear${NC}"