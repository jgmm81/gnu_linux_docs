#!/bin/bash

#  This script works for VMware WS/Player 15.0.3 and 15.0.4 and kernel 5.0.3 and should work with 5.0.4.


VMWARE_SRC=/usr/lib/vmware/modules/source/

UNPATCHEXT=unpatched
DATESTR=`date +%Y%m%d`


# Verify that patch files exist where we expect them.
for file in /tmp/hostif.c.diff /tmp/userif.c.diff; do

    if [[ ! -e $file ]]; then
	echo $file does not exist
	exit 1
    fi
done


# Verify that the VMware module source tar files exist.
# Also handle if this patch script had been run before.
for file in vmmon.tar vmnet.tar; do
    if [[ ! -e $VMWARE_SRC/$file ]]; then
	echo $VMWARE_SRC/$file not found.
	exit 1
    fi

    if [[ -e $VMWARE_SRC/$file.$UNPATCHEXT ]]; then
	mv $VMWARE_SRC/$file $VMWARE_SRC/$file.$DATESTR
	mv $VMWARE_SRC/$file.$UNPATCHEXT $VMWARE_SRC/$file
    fi
done



# Create a work area

WORKAREA=`mktemp -d`
cd $WORKAREA
echo Working area is $WORKAREA



# Fix up vmmon

echo Patching vmmon ....

cp $VMWARE_SRC/vmmon.tar .
tar xf vmmon.tar
cd vmmon-only/linux
patch -b hostif.c /tmp/hostif.c.diff
res=$?

if [[ $res -ne 0 ]]; then
    echo Patch of hostif returned error $res, exiting
    exit 1
fi

cd ../../
mv vmmon.tar vmmon.orig.tar
tar cf vmmon.tar vmmon-only



# Fix up vmnet

echo Patching vmnet ....

cp $VMWARE_SRC/vmnet.tar .
tar xf vmnet.tar
cd vmnet-only
patch -b userif.c /tmp/userif.c.diff
res=$?

if [[ $res -ne 0 ]]; then
    echo Patch of userif returned error $res, exiting
    exit 1
fi  

cd ../
mv vmnet.tar vmnet.tar.orig
tar cf vmnet.tar vmnet-only



# Copy the fixed-up tar files back to the VMware source.

cd $VMWARE_SRC

for file in vmmon.tar vmnet.tar; do
    mv $file $file.$UNPATCHEXT
    cp $WORKAREA/$file .
    echo $file with patch applied copied
done



# finally rebuild all the kernel modules

cd $WORKAREA
echo Rebuilding kernel modules, logging to vmware.build.log

vmware-modconfig --console --install-all 1>vmware.build.log 2>&1
res=$?

if [[ $res -eq 0 ]]; then
    echo "... looks like kernel module build worked"
    systemctl status vmware
else
    echo "... looks like kernel module build failed"
    echo "    check the log file"
fi




