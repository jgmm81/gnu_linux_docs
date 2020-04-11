#	https://askubuntu.com/questions/1017945/lvm-hard-disk-partitioning-after-ubuntu-installation/1019381
#
#	https://www.2daygeek.com/how-to-create-extend-swap-partition-in-linux-using-lvm/
#
#	https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-ubuntu#2

# ubuntu (resize lvm swap location)-----------------------------------------
#June 2019

#MAKE FIRST A COMPLETE DRIVE BACKUP!
#MAKE FIRST A COMPLETE DRIVE BACKUP!
#MAKE FIRST A COMPLETE DRIVE BACKUP!
#MAKE FIRST A COMPLETE DRIVE BACKUP!

#USE LIVE USB/DVD


#MIXED MODE ############################################

sudo apt-add-repository multiverse && sudo apt-get update
sudo apt-get install partitionmanager

#check if the unit have errors (using live usb)
sudo e2fsck -ff /dev/ubuntu-vg/root

#check lvm details and free space SSize
sudo pvs -v --segments /dev/sda1

#if use the live usb, returns a error, goto next line
sudo swapoff -v /dev/ubuntu-vg/swap_1
#-----
sudo lvremove /dev/ubuntu-vg/swap_1

sudo partitionmanager

#Resize /dev/ubuntu-vg/root
#for 16gb swap set new size 461.000 (with 500gb HDD) and apply changes

#In terminal, check again the unit
sudo resize2fs /dev/ubuntu-vg/root
sudo e2fsck -ff /dev/ubuntu-vg/root

#if return errors, hoo shit
#if done, yes!! goto to the next line

#lvcreate -n swap_1 -l 'SSize' ubuntu-vg
# 3978 = 15.5GB
#sudo lvcreate -n swap_1 -l 3959 ubuntu-vg
sudo lvcreate -n swap_1 -L 20480M ubuntu-vg
sudo mkswap /dev/ubuntu-vg/swap_1

sudo lvresize -l +100%FREE /dev/ubuntu-vg/root
sudo resize2fs /dev/ubuntu-vg/root

sudo swapon /dev/ubuntu-vg/swap_1

--------

#check before reebot
sudo e2fsck -ff /dev/ubuntu-vg/root


#MANUAL MODE ###########################################

#Optional
#if you have less than 10% of use in drive and not sensitive data, no problem

sudo mount /dev/ubuntu-vg/root /mnt
sudo e4defrag /mnt

sudo umount /dev/ubuntu-vg/root

#show lvm info
lvs

#check if the unit have errors (using live usb)
sudo e2fsck -ff /dev/ubuntu-vg/root

#check lvm details and free space SSize
sudo pvs -v --segments /dev/sda1

#if use the live usb, returns a error, goto next line
sudo swapoff -v /dev/ubuntu-vg/swap_1

sudo lvremove /dev/ubuntu-vg/swap_1

#Pretending to use 15G of swap
#sudo resize2fs /dev/ubuntu-vg/root 15G
sudo resize2fs /dev/ubuntu-vg/root 20G
sudo lvreduce -L -14.51G /dev/ubuntu-vg/root

#check again the unit
sudo resize2fs /dev/ubuntu-vg/root
sudo e2fsck -ff /dev/ubuntu-vg/root

sudo lvreduce -L -14.51G /dev/ubuntu-vg/root

#check lvm details and free space SSize
sudo pvs -v --segments /dev/sda1

#lvcreate -n swap_1 -l 'SSize' ubuntu-vg
# 3978 = 15.5GB
sudo lvcreate -n swap_1 -l 3959 ubuntu-vg
sudo mkswap /dev/ubuntu-vg/swap_1

sudo lvresize -l +100%FREE /dev/ubuntu-vg/root
sudo resize2fs /dev/ubuntu-vg/root

sudo swapon /dev/ubuntu-vg/swap_1


--------

#check before reebot
sudo e2fsck -ff /dev/ubuntu-vg/root






