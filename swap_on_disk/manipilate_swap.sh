https://help.ubuntu.com/community/SwapFaq
##count=1048576 : 1GB
#Add swap partition into main OS file system

sudo fallocate -l 1g /mnt/20GiB.swap

sudo dd if=/dev/zero of=/mnt/20GiB.swap bs=1024 count=20971520

sudo chmod 600 /mnt/20GiB.swap

sudo mkswap /mnt/20GiB.swap

sudo swapon /mnt/20GiB.swap

echo '/mnt/20GiB.swap swap swap defaults 0 0' | sudo tee -a /etc/fstab

#Check unused swap partiion and delete

sudo pvs -v --segments /dev/sda1

#Delete line if not exist partition swap (by name, and be carefull)
vim /etc/fstab

#standard for enable on boot
vim /etc/fstab

/dev/mapper/ubuntu--vg-swap_1    none    swap    sw    0   0


------

#tool+

sudo apt-get install partitionmanager

