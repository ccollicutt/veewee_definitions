#!/bin/bash

DATE=`date +"%Y%m%d-%H%M"`
CURRENT_VERSION=`veewee version`
# regular expresion
EXPECTED_VERSION="0.3.0"

# Check to see if the version reported by veewee contains 0.3.0
# earlier versions of veewee don't even have a version option
if [[ ! "$CURRENT_VERSION" == *"$EXPECTED_VERSION"* ]]; then
	echo "ERROR: Unexpected veewee version"
	exit 1
fi

if [ -z "$1" ]; then
	echo "Usage: $0 veewee-defintion-to-export"
	echo "eg. $0 'centos6-64'"
    exit 1
else
	BOX=$1
fi

echo "====> Building box..."
if ! veewee vbox build $BOX --force; then
	echo "veewee vbox build $BOX failed, exiting..."
	exit 1
fi
echo "Removing old box export file..."
if [ -e $BOX.box ]; then
	rm -f $BOX.box
fi
echo "====> Exporting new box file..."
if ! vagrant basebox export $BOX; then
	echo "vagrant baseboxe export '$BOX' failed, exiting..."
	exit 1
fi
echo "====> Untarring the box file to convert vmdk to qcow2"
tar xvf $BOX.box
echo "====> Converting vmdk to qcow2..."
qemu-img convert -O qcow2 box-disk1.vmdk $BOX.qcow2.$DATE
echo "====> Zipping up qcow2 img into $BOX.zip.$DATE..."
gzip -c $BOX.qcow2.$DATE > $BOX.zip.$DATE
