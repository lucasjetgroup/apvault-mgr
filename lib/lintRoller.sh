#!/bin/bash

function lintRoller.lintRollBannedKeywords () {
	# params 1) script path 2) target path 3) isDryRun
	# Matches regexes from bannedKeywords.lst file to anywhere in path and filename

	scriptPath="$1"
	pathToLintRoll="$2"
	bannedKeywordsRegexFile="$scriptPath"/definitions/bannedKeywords.lst
	banned_findarg="\( -iregex \".*"
	banned_glue=".*\" -or -iregex \".*"
	regexes_found=0

	if [[ ! -f "$bannedKeywordsRegexFile" ]]; then
		echo "ERROR: APVault: Banned Keywords Regex File Not Found."
		return 1;
	fi

	while read -r p; do
   		[[ -z "$p" ]] && continue 	# ignore empty lines
  		[[ "$p" =~ ^[[:space:]]*# ]] && continue 	# ignore comments
			((regexes_found=regexes_found+1))
			banned_findarg=$banned_findarg$p$banned_glue
	done < "$bannedKeywordsRegexFile"

	if [[ $regexes_found -gt 1 ]]; then
		echo "APVault: Loaded ""$regexes_found"" banned regexes, searching and destroying matches in ""$pathToLintRoll""..."
		banned_findarg="find "\""$pathToLintRoll"\"" ${banned_findarg::-15}\) -printf 'Lint-rolling %p.\n'"
		# handle dry-run
		if [[ ! $3 = "--dry-run" ]]; then
			deleteOp=" -delete"
			banned_findarg="$banned_findarg""$deleteOp"
		else
			echo "APVault: Simulating for --dry-run"
		fi
		eval "$banned_findarg"
		return $?
	fi
	echo "ERROR: APVault: Need more than 1 regex to match"
	return 1
}

function lintRoller.lintRollDerivedContent {
	# params 1) script path 2) target path 3) isDryRun
	# Match regexes from derivedContentKeywords.lst file to within the last two characters of filenames

	scriptPath="$1"
	pathToLintRoll="$2"
	derivedContentKeywordsFile="$scriptPath"/definitions/derivedContentKeywords.lst
	screens_findarg="\( -iregex \".*"
	screens_glue=".?.?\" -or -iregex \".*"
	regexes_found=0

	if [[ ! -f "$derivedContentKeywordsFile" ]]; then
		echo "ERROR: APVault: Derived Content Keywords Regex File Not Found."
		return 1;
	fi

	while read -r p; do
   		[[ -z "$p" ]] && continue 	# ignore empty lines
  		[[ "$p" =~ ^[[:space:]]*# ]] && continue 	# ignore comments
		((regexes_found=regexes_found+1))
		screens_findarg=$screens_findarg$p$screens_glue
	done < "$derivedContentKeywordsFile"

	if [[ $regexes_found -gt 1 ]]; then
		screens_findarg="find "\""$pathToLintRoll"\"" ${screens_findarg::-15}\) -printf 'Lint-rolling %p.\n'"
		# handle dry-run
		if [[ ! $3 = "--dry-run" ]]; then
			screens_findarg+=" -exec rm -rf \"{}\" +"
		else
			echo "APVault: Simulating for --dry-run"
		fi
		echo "APVault: Pruning content-derived files..."
		eval "$screens_findarg"
		return $?
	fi
	echo "ERROR: APVault: Need more than 1 regex to match"
	return 1
}

function lintRoller.flattenRedundantStructure () {
	# params 1) script path 2) target path
	# Reads from redundantFolderNames.lst
	# Copies the contents of redundant folders to the parent,
	# ignoring the root. For instance, a Videos/Models/ModelName/Videos/* 
	# folder becomes Videos/Models/ModelName/*.

	scriptPath="$1"
	pathToLintRoll="$2"
	redundantFolderNamesFile="$scriptPath"/definitions/redundantFolderNames.lst
	redundant_findarg="\( -regex \".*"
	redundant_glue="\" -or -iregex \".*"
	regexes_found=0
	
	if [[ ! -f "$redundantFolderNamesFile" ]]; then
		echo "ERROR: APVault: Redundant Folder Names Regex File Not Found."
		return 1;
	fi

	while read -r p; do
   		[[ -z "$p" ]] && continue 	# ignore empty lines
  		[[ "$p" =~ ^[[:space:]]*# ]] && continue 	# ignore comments
		((regexes_found=regexes_found+1))
		redundant_findarg=$redundant_findarg$p$redundant_glue
	done < "$redundantFolderNamesFile"

	if [[ $regexes_found -gt 1 ]]; then
		redundant_findarg="find "\""$pathToLintRoll"\"" -depth -type d ${redundant_findarg::-15}\) -printf 'Flattening %p.\n'"
		# handle dry-run
		if [[ ! $3 = "--dry-run" ]]; then
			redundant_findarg+=" -execdir bash -c 'mv --no-clobber -v {}/* ./' \;"
		else
			echo "APVault: Simulating for --dry-run"
		fi
		echo "APVault: Flattening redundant directories..."
		eval "$redundant_findarg" && find "$targetPath" -depth -type d -empty -delete
		return $?
	fi
	echo "ERROR: APVault: Need more than 1 regex to match"
	return 1
}

function lintRoller.lintRollByPath () {
	# params 1) script path 2) target path
	# Run both types of lint roll against a path provided as parameter
	pathToRoll="$2"
	if [[ -z "$pathToRoll" ]] || [[ ! -d "$pathToRoll" ]]; then
		echo "WARNING: APVault: Path ""$pathToRoll"" not found. Using \"$(pwd)\"."
		pathToRoll="$(pwd)"
	fi
	
		read -r -p "APVault: Flatten redundant directories in \"$pathToRoll\"? This is a destructive action. (y/n): " answer1
		case ${answer1:0:1} in
		    y|Y )
			lintRoller.flattenRedundantStructure "$1" "$pathToRoll" "$3"
		    ;;
    		    * )
       		 	echo "APVault: Skipping flatten."
        		return 0
    		;;
		esac
	echo
	read -r -p "APVault: Run the lint roller on \"$pathToRoll\"? This is a destructive action. (y/n): " answer2
		case ${answer2:0:1} in
		    y|Y )
			lintRoller.lintRollDerivedContent "$1" "$pathToRoll" "$3"
			lintRoller.lintRollBannedKeywords "$1" "$pathToRoll" "$3"
		    ;;
    		    * )
       		 	echo "APVault: Skipping lint-roll."
        		return 0
    		;;
		esac
	echo
}
