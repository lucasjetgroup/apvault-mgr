# Arctic Porn Vault Manager

APVault-mgr is a utility to assist in growing, weeding, and managing extremely large porn collections. Cut through your torrent backlog quickly!

## Requirements
- bash
- unzip
- unrar
- 7z
- rsync

## Get Started

You need to edit the top of `apvault.sh` to point to your collection, and review `bannedKeywords.lst` to your tastes.

## Usage

```
# Grab a copy from git
git clone https://github.com/kermieisinthehouse/apvault-mgr

# Run the lint roller on a path
./apvault.sh lint-roll Downloads/

# Init the vault and create file paths (only needed for ingest command)
./apvault.sh init /mnt/encrypted/APVault/

# Ingest a path's contents into the vault, using a vault-relative path
./apvault.sh ingest MyFavoriteCamgirl/ Camgirls/OnlyFans/

# Recursively decompress all archives in a directory
./apvault.sh decompress Photo_Archives_2009/

```
## Lint-rolling your collection
The lint roller is a powerful, configurable system for automatically cleaning your large collection of genres you don't want to collect, and screenshots and other filesystem detritus. Megapacks give you stuff you don't want? The file `bannedKeywords.lst` accepts emacs-style regexes that will be searched-and-destroyed in paths and filenames. For example, to rid your library of unwanted adult diaper content, simply adding the line `adult.?diaper` and running the lint-roller is often enough. The file `derivedContentKeywords.lst` contains regexes for items such as screenshots, thumbnails, and contact sheets. You can run the lint-roller over your existing collection, and it runs automatically over new content as it's being ingested. 

## Theory of Operation
These tools were developed to help manage a library of 7+ million items.
Ingesting a path involves decompressing all archives, deleting unwanted files (see lint-rolling above), and copying files into a vault's structure, separating photos from other files. Images are separated to keep filesystem listings small in the video directory, so that scans of other tools `(stash, ncdu, du, find)` can be performant over very large collections.

### Recommendations
For browsing your content and logical organization, I recommend AGPL-Licensed [Stash](https://github.com/stashapp/stash). 
For a filesystem to store hundreds of terabytes, I always recommend [ZFS](https://github.com/openzfs/zfs).

## Contributing
Pull requests are welcome. Make sure any changes have zero warnings from shellcheck.

## License
GPL3 Licensed.
Copyright 2020 kermie@arcticpornvault.org
