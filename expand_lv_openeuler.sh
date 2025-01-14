#!/bin/bash

# Get the disk device name and the size to expand from the command line arguments
disk=$1  #  such as /dev/sdb
size=$2   # such as 19

# Define the volume group name and logical volume name
vgname="openeuler"
lvname="root"

# Create a physical volume
pvcreate $disk
if [ $? -eq 0 ]; then
    echo 'Physical volume has been created.'
    pvdisplay $disk
else
    echo "Failed to create the physical volume. Please check the error message."
    exit 1
fi

echo "Adding the pv to the vg"
# Add the physical volume to the specified volume group
vgextend $vgname $disk
if [ $? -eq 0 ]; then
    echo "The physical volume has been successfully added to the volume group $vgname."
else
    echo "Failed to add the physical volume to the volume group. Please check the error message."
    exit 1
fi

# Expand the specified logical volume
if [[ $size =~ ^[0-9]+$ ]]; then
    # If the size argument is a valid number, try to expand the LV with the given size
    lvresize -L +${size}G /dev/${vgname}/${lvname}
    if [ $? -eq 0 ]; then
        echo "The logical volume has been successfully expanded with the specified size."
    else
        echo "Failed to expand the logical volume with the specified size. There might be an issue with the given size or other factors. Now attempting to expand the LV to use all available VG space."
        # If expanding with the given size fails, try to expand the LV to use all available VG space
        lvresize -l +100%FREE /dev/${vgname}/${lvname}
        if [ $? -eq 0 ]; then
            echo "The logical volume has been successfully expanded to use all available VG space."
        else
            echo "Failed to expand the logical volume to use all available VG space. Please check the error message."
            exit 1
        fi
    fi
else
    # If the size argument is not a valid number, try to expand the LV to use all available VG space
    echo "The provided size argument is not a valid number. Now attempting to expand the LV to use all available VG space."
    lvresize -l +100%FREE /dev/${vgname}/${lvname}
    if [ $? -eq 0 ]; then
        echo "The logical volume has been successfully expanded to use all available VG space."
    else
        echo "Failed to expand the logical volume to use all available VG space. Please check the error message."
        exit 1
    fi
fi

echo ""
# Resize the file system to adapt to the expansion of the logical volume
resize2fs /dev/${vgname}/${lvname}
if [ $? -eq 0 ]; then
    echo "The file system has been successfully resized. The expansion operation is complete!"
else
    echo "Failed to resize the file system. Please check the error message."
    exit 1
fi
