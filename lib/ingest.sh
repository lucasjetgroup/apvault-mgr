#!/bin/bash

function ingest.rsyncImages () {
	fromPath="$1"
	toPath="$2"
	rsync -ahmP --ignore-existing --remove-source-files --include='**/' --include='**/*.jpg' --include='**/*.JPG' \
		--include='**/*.png' --include='**/*.PNG' --include='**/*.jpeg' --include='**/*.JPEG' \
		--include='**/*.gif' --include='**/*.GIF' --exclude='*' "$fromPath" "$toPath";
	return $?
}

function ingest.ingestByPathInteractive () {
	targetPath="$1"
	vaultVideosPath="$2"
	vaultImagesPath="$3"

	# Check if vault paths exist, if not create
	if [[ -z "$vaultVideosPath" ]] || [[ -z "$vaultVideosPath" ]]; then
		echo "ERROR: APVault: Vault paths required."
		return 1;
	fi
	if [[ ! -d "$vaultVideosPath" ]]; then
		echo "WARNING: Video path ""$vaultVideosPath"" not found, creating"
		if mkdir -p "$vaultVideosPath"; then
			echo "ERROR: APVault: Could not create directory."
			return 1;
		fi
	fi
	if [[ ! -d "$vaultImagesPath" ]]; then
		echo "WARNING: Image path ""$vaultImagesPath"" not found, creating"
		if mkdir -p "$vaultImagesPath"; then
			echo "ERROR: APVault: Could not create directory."
			return 1;
		fi
	fi
	if [[ -z "$targetPath" ]] || [[ ! -d "$targetPath" ]]; then
		echo "ERROR: APVault: Path ""$targetPath"" not found."
		return 1;
	fi

	if [[ "${targetPath: -1}" == '/' ]]; then
		echo "INFO: APVault: Target has trailing slash, only ingesting contents."
	fi
	# prompt for vault-relative path, create if missing
	callDir="$(pwd)"
	cd "$vaultVideosPath" || return 1 # allow tab completion from vault path
	echo
	read -r -e -p "APVault: Where should we ingest this? (vault-relative, hit TAB): " VAULT_PATH
	VAULT_PATH="${VAULT_PATH//\\}"/ # unescape string
	mkdir -p "$vaultVideosPath"/"$VAULT_PATH" "$vaultImagesPath"/"$VAULT_PATH"

	echo "APVault: Ingesting files..."
	cd "$callDir" || return 1

	if [[ ! "$vaultVideosPath" = "$vaultImagesPath" ]]; then # if not using split directories, skip images step
		ingest.rsyncImages "$targetPath" "$vaultImagesPath"/"$VAULT_PATH"
		# delete now-empty folders
		find "$targetPath" -depth -type d -empty -delete
	fi

	# move everything else, use mv where possible
	mvTarget=""
	if [[ "${targetPath: -1}" == '/' ]]; then
		mvTarget="*"
	fi
	mv -v --no-clobber "$targetPath"$mvTarget "$vaultVideosPath"/"$VAULT_PATH"
	if [[ -d "$targetPath" ]]; then
		#there are directory name conflicts, use rsync to copy what we can, leaving what we can't
		rsync -ahmP --ignore-existing --remove-source-files "$targetPath" "$vaultVideosPath"/"$VAULT_PATH";
		# delete now-empty folders
		find "$targetPath" -depth -type d -empty -delete
		if [[ -d "$targetPath" ]]; then
			echo "APVault: Warning: Not all files have been ingested. APVault does not overwrite existing files."
			return 1
		fi
	fi
	echo
	echo "APVault: Finished ingesting."
}
