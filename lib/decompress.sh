#!/bin/bash

function decompress.recursiveDecompressByPath () {
	targetPath=$1

	if [[ -z "$targetPath" ]] || [[ ! -d "$targetPath" ]]; then
		echo "ERROR: APVault: Path ""$targetPath"" not found."
		return 1;
	fi

	hasUnrar=true
	hasUnzip=true
	has7z=true

	if [[ ! -x "$(command -v unzip)" ]]; then
		hasUnzip=false
		echo "WARNING: APVault: Unzip not installed, skipping .zip files..."
	fi
	if [[ ! -x "$(command -v unrar)" ]]; then
		hasUnrar=false
		echo "WARNING: APVault: Unrar not installed, skipping .rar files..."
	fi
	if [[ ! -x "$(command -v 7z)" ]]; then
		has7z=false
		echo "WARNING: APVault: 7z not installed, skipping .7z files..."
	fi

	if [[ "$hasUnzip" = true ]]; then
		echo "APVault: Decompressing zips..."
		find "$targetPath" -type f -iname '*.zip' -print0 -execdir unzip -o -d '{}_extracted' '{}' \; -delete
	fi
	if [[ "$hasUnrar" = true ]]; then
		echo "APVault: Decompressing rars..."
		find "$targetPath" -type f -iname '*.rar' -print0 -execdir unrar e -y -kb '{}' '{}_extracted/' \; -delete
	fi
	if [[ "$has7z" = true ]]; then
		echo "APVault: Decompressing 7zs..."
		find "$targetPath" -type f -iname '*.7z'  -print0 -execdir 7z x -y -o'{}_extracted' '{}' \; -delete
	fi
}
