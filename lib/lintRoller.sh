#!/bin/bash

function lintRoller.lintRollBannedKeywords () {
	# params 1) real path 2) target path 3) isDryRun
	# Matches regexes from bannedKeywords file to anywhere in path and filename
	realPath="$1"
	pathToLintRoll="$2"
	bannedKeywordsRegexFile="$realPath"/bannedKeywords.lst
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
	# params 1) real path 2) target path 3) isDryRun
	# Match regexes from derivedContentKeywords file to within the last two characters of filenames
	realPath="$1"
	pathToLintRoll="$2"
	derivedContentKeywordsFile="$realPath"/derivedContentKeywords.lst
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

function lintRoller.lintRollByPath () {
	# params 1) real path 2) target path
	# Run both types of lint roll against a path provided as parameter
	pathToRoll="$2"
	if [[ -z "$pathToRoll" ]] || [[ ! -d "$pathToRoll" ]]; then
		echo "WARNING: APVault: Path ""$pathToRoll"" not found. Using \"$(pwd)\"."
		pathToRoll="$(pwd)"
	fi
	read -r -p "APVault: Run the lint roller on \"$pathToRoll\"? This is a destructive action. (y/n): " answer
		case ${answer:0:1} in
		    y|Y )
			lintRoller.lintRollBannedKeywords "$1" "$pathToRoll" "$3"
			lintRoller.lintRollDerivedContent "$1" "$pathToRoll" "$3"
		    ;;
    		    * )
       		 	echo "APVault: Skipping lint-roll."
        		return 0
    		;;
		esac
	echo
}
