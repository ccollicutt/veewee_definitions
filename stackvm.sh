#!/bin/bash

CURRENT_VERSION=`veewee version`
# regular expresion
EXPECTED_VERSION="0.3.0"

# Check to see if the version reported by veewee contains 0.3.0
# earlier versions of veewee don't even have a version option
if [[ ! "$CURRENT_VERSION" == *"$EXPECTED_VERSION"* ]]; then
	echo "ERROR: Unexpected veewee version"
	exit 1
fi

if [ -z "$1"]; then
	echo "Usage: $0 veewee-defintion-to-export"
	echo "eg. $0 'centos6-64'"
else
	BOX=$1

echo "====> Building box..."
veewee vbox build $BOX --force
echo "Removing old box export file..."
rm -f $BOX.box
echo "====> Exporting new box file..."
vagrant basebox export '$BOX'
echo "====> Untarring the box file to convert vmdk to qcow2"
tar xvf $BOX.box
echo "====> Converting vmdk to qcow2..."
qemu-img convert -O qcow2 box-disk1.vmdk $BOX.qcow2
echo "====> Zipping up qcow2 img..."
gzip -c $BOX.qcow2 > $BOX.zip
