#
# "light" warning:
# before executing this script, make sure
# the script is executable, and run it as root
# and also, mount command below may not work (may throw error that something look like " '/system' not in /proc/mounts " or " '/' not in /proc/mounts ", may vary from device-to-device),
# if thats the case, try to search the working
# solution on internet
#
# BIG WARNING:
# MAKE SURE to have a custom recovery (IMPORTANT!), and working /system BACKUP backed up from custom recovery (IMPORTANT!)
# because this script MAY MESS file/folder permission.
# which renders your phone USELESS, unless if you restore using the backup.
#
# what this script does:
# change permission and owner directory below | to
# make sure its detected and working          |
# (and also for more security)                V
#

# affects file and folders in: vv
clear
echo "Remounting /system Partition as read-write"
#the conventional solution wont work anymore on android 10
#mount -o rw,remount /system
mount -wo remount /
clear
for a in "system/app" "system/priv-app" "system/xbin" "system/media/audio" "system/build.prop";do
	cd "$b"
 #each directory had different file structure, so the "if" comes to play here
	if [ "$a" = "system/app" ] || [ "$a" = "system/priv-app" ];then
		for b in $(ls /$a);do
		 #just standard things you usually do (as root), but automated
		 	echo Changing "/$a/$b" ...
			chown -f -R root:root "/$a/$b"
			chmod -f 755 "/$a/$b"
			chmod -f 644 "/$a/$b/$b.apk"
			#disabled for now cuz it kinda complex
			#if [ -e /$a/$b/oat ];then
			# 	chmod -f 755 "/$a/$b/oat"
			# 	chmod -f 644 "/$a/$b/oat/$b.odex"
			# 	chmod -f 644 "/$a/$b/oat/$b.vdex"
		 	#fi
		done
	elif [ "$a" = "system/xbin" ];then
		for b in /$a/*;do
		 	echo Changing "$b" ...
			chown -f root:root "$b"
			chmod -f 644 "$b"
		done
	elif [ "$a" = "system/media/audio" ];then
	 #change /system/media/audio owner to root
		chown -f -R root:root "$a"
	 #in /system/media/audio
		for b in /$a/*;do
		 	echo Changing "$b" ...
			chmod -f 755 "$b"
		 #in /system/media/audio/whateverfolderexistthere
			for c in $b/*;do
			 #change every audio file permissions
			 #why below is used instead of just chmod? because samsung roms mess these shit with that stupid "engaging sound themes"
				if [ -f "$c" ];then
					chmod -f 644 "$c"
				elif [ -d "$c" ];then
					chmod -f 755 "$c"
				fi
			done
		done
	elif [ "$a" = "system/build.prop" ];then
		chown -f root:root "$a"
		chmod -f 600 "$a"
	fi
done
echo "Remounting /system Partition as read-only (for security reason, you can mount again as read-write by running: \"mount -o rw,remount /system\")"
mount -o ro,remount /system
