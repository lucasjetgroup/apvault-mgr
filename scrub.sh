#!/bin/bash
llpath="/mnt/encrypted/APVault/Videos/"

# banned words pass
banned_findarg=" \( -iregex \".*"
banned_glue=".*\" -or -iregex \".*"
banned_regexes=0

while read -r p; do
    if [ -z "$line" ]; then
	((banned_regexes=banned_regexes+1))
	banned_findarg=$banned_findarg$p$banned_glue
    fi
done < bannedKeywords
echo "Loaded "$banned_regexes" banned regexes, searching and destroying matches in "$llpath
echo
banned_findarg="find $llpath ${banned_findarg::-15}\) -print -delete"

eval "$banned_findarg"

# remove content-derived files, aka screens
screens_findarg="\( -iregex \".*"
screens_glue=".?.?\" -or -iregex \".*"
while read -r p; do
    if [ -z "$line" ]; then
	screens_findarg=$screens_findarg$p$screens_glue
    fi
done < derivedContentKeywords
screens_findarg="find $llpath ${screens_findarg::-15}\) -print -exec rm -rf \"{}\" +"

eval $screens_findarg

