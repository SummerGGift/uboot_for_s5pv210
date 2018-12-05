#
# Copyright (C) 2010 Samsung Electronics Co., Ltd.
#              http://www.samsung.com/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
####################################
reader_type1="/dev/sdb"
reader_type2="/dev/mmcblk0"
sd_device=""

if [ -z $1 ]
then
    echo "usage: ./sd_fusing.sh <SD Reader's device file>"
    exit 0
fi

if [ $1 = $reader_type1 ]||[ $1 = $reader_type2 ];then 
	sd_device="$11"
    echo "$1 reader is identified."
else
    echo "$1 is NOT identified."
    exit 0
fi

####################################
# make partition
echo "make sd card partition"
echo "./sd_fdisk $1" 
./sd_fdisk $1 
dd iflag=dsync oflag=dsync if=sd_mbr.dat of=$1 
rm sd_mbr.dat
 
####################################
# format
unmount $sd_device 2> /dev/null

echo "mkfs.vfat -F 32 $sd_device"
mkfs.vfat -F 32 $sd_device

####################################
#<BL1 fusing>
bl1_position=1
uboot_position=49

echo "BL1 fusing"
./mkbl1 ../u-boot.bin SD-bl1-8k.bin 8192
dd iflag=dsync oflag=dsync if=SD-bl1-8k.bin of=$1 seek=$bl1_position
rm SD-bl1-8k.bin

####################################
#<u-boot fusing>
echo "u-boot fusing"
dd iflag=dsync oflag=dsync if=../u-boot.bin of=$1 seek=$uboot_position

####################################
#<Message Display>
echo "U-boot image is fused successfully."
echo "Eject SD card and insert it again."
