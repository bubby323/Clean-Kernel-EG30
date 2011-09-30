#!/sbin/sh
# DRockstar/Bubby323 Clean Kernel recovery.sh called from recovery.rc and fota.rc

/sbin/busybox mount -o remount,rw / /

# Install recovery busybox to /sbin
/sbin/busybox ls /res/sbin | while read line
do
  /sbin/busybox mv -f /res/sbin/$line /sbin/$line
done
rmdir /res/sbin

# Fix permissions in /sbin, just in case
/sbin/busybox chmod 755 /sbin/*

# Fix screwy ownerships
for blip in lib res sbin default.prop fota.rc init init.goldfish.rc init.rc init.smdkc210.rc init_kernel_only.rc lpm.rc recovery.rc ueventd.goldfish.rc ueventd.rc ueventd.smdkc210.rc
do
  chown root.system /$blip
  chown root.system /$blip/*
done

chown root.system /lib/modules/*
chown root.system /res/images/*

mkdir /etc
cp /res/etc/recovery.fstab /etc/recovery.fstab
/sbin/recovery

