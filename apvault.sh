#!/bin/bash

# Point me to your collection!
Vault_Videos_Path="/data/Videos"
Vault_Images_Path="/data/Pictures"
# Change to true when configured. Make sure you review bannedKeywords.lst and remove anything you want to keep!
isConfigured=false

# Do not edit below this line.
####################
#
# Arctic Porn Vault
# Porn collection management scripts
#
# Copyright 2021 kermie@arcticpornvault.org
#
####################

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_PATH/lib/lintRoller.sh"
source "$SCRIPT_PATH/lib/ingest.sh"
source "$SCRIPT_PATH/lib/decompress.sh"

function sub_lint-roll () {
	targetPath="$2"
	isDryRun="$3"
	lintRoller.lintRollByPath "$SCRIPT_PATH" "$targetPath" "$isDryRun"
}

function sub_decompress () {
	targetPath="$2"
	decompress.recursiveDecompressByPath "$targetPath"
}

function sub_ingest () {
	targetPath="$2"
	if [ "$isConfigured" = false ]; then
		echo "ERROR: You must first configure your vault directory in apvault.sh"
		exit 1;
	fi

	decompress.recursiveDecompressByPath "$targetPath" && \
	lintRoller.lintRollByPath "$SCRIPT_PATH" "$targetPath" && \
	ingest.ingestByPathInteractive "$targetPath" "$Vault_Videos_Path" "$Vault_Images_Path"
}

function sub_copy-images () {
	fromPath="$2"
	toPath="$3"
	ingest.rsyncImages "$fromPath" "$toPath"
}

function sub_help () {
cat <<"EOF"

Usage: apvault.sh <subcommand> <path> [options]
Make sure you review bannedKeywords.lst to fit your needs, it is very opinionated by default!

Examples:
apvault.sh lint-roll <path> [--dry-run]		Deletes unwanted files, see definitions in bannedKeywords.lst and derivedContent.lst.

apvault.sh decompress <path>			Recursively decompresses all .zip, .rar, .7z archives in the path.

apvault.sh ingest <path>			Decompresses, lint-rolls, copies files into the vault. Will prompt for vault location.
						Will not overwrite any files.

apvault.sh copy-images <path> <target path>	Copies all images in path into your images path, keeping the directory structure.
						Good for migrating into a Videos + Images structure for your collection.
EOF
}
subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        sub_"${subcommand}" "$@"
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run 'apvault.sh --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
