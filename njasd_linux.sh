#!/usr/bin/env bash
#
# NJASD (Not Just A System Debloater) v1.2.
# By mdp43140
#

### Config ###
BASE_DIR_HOST="."
BASE_DIR_PHONE="/sdcard/njasd"
BLOATWARES_LIST_UNINSTALL_SYSTEM="$BASE_DIR_HOST/Bloatware_List.txt"
INSTALL_APPS_DIR="$BASE_DIR_HOST/Install_Apps"
color_prompt="auto"
DETECT_ROOT_ALTER="auto"
KEEP_DATA=0
# Here are the lists of caches that can be removed
PHONE_CACHE_DIRECTORIES_ROOT=(
	'/data/data/*/cache/*'
	'/data/data/*/code_cache/*'
	'/data/data/*/app_google_tagmanager'
	'/data/data/*/app_textures'
	'/data/data/*/app_fiverocks'
	'/data/data/*/app_webview'
	'/data/data/*/no_backup/.flurryNoBackup'
	'/data/data/*/files/.com.google.firebase.crashlytics'
	'/data/data/*/files/.Fabric'
	'/data/data/*/files/al'
	'/data/data/*/files/audience_network.dex'
	'/data/data/*/files/CountlyINSTALLATION'
	'/data/data/*/files/oat/audience_network.dex*'
	'/data/data/*/databases/webviewCache'
	'/data/data/*/databases/google_app_measurement*.db*'
	'/data/data/*/databases/google_tagmanager.db*'
	'/data/anr/*'
	'/data/log/*'
	'/data/local/tmp/*'
	'/data/system/dropbox/*'
	'/data/system/usagestats/*'
	'/data/backup/pending/*'
	'/data/tombstones/*'
	'/cache/*'
)
# Here are the lists of caches that can be removed without root access
PHONE_CACHE_DIRECTORIES=(
	'/sdcard/Android/data/*/cache'
	'/sdcard/Android/data/*/files/il2cpp'
	'/sdcard/Android/data/*/files/Unity'
	'/sdcard/Android/data/*/files/logs'
	'/sdcard/Android/data/*/files/vungle_cache'
	'/storage/*-*/Android/data/*/cache'
	'/storage/*-*/Android/data/*/files/il2cpp'
	'/storage/*-*/Android/data/*/files/Unity'
	'/storage/*-*/Android/data/*/files/logs'
	'/storage/*-*/Android/data/*/files/vungle_cache'
)
#############

### Other stuff ###
NJASD_VERSION='1.5'
NJASD_LAST_CHANGED='07/06/2022 10:00'
NJASD_RELEASE_BRANCH='MAIN'
set -uo pipefail # Safer bash script (especially on command pipes and stuff, add -e for easier debugging (abort on any non-zero exit code, aka. error))
PHONE_CACHE_DIRECTORIES_ROOT="${PHONE_CACHE_DIRECTORIES_ROOT[@]}"
PHONE_CACHE_DIRECTORIES="${PHONE_CACHE_DIRECTORIES[@]}"
HOST_TYPE="$([ -f '/system' ] && echo android || echo linux)"
###################

### "CLGUI" menu ###
MAIN(){
	print_header;echo -en $C_YELLOW
	echo -e "[1] Remove bloatware "$C_END"("$C_GREEN"Recommended"$C_END")"$C_YELLOW
	echo -e "[2] Deny bloatware package's permission"
	echo -e "[3] Install your custom packages"
	echo -e "[4] Install open-source alternative packages "$C_END"(TODO, "$C_GREEN"Recommended for root users"$C_END")"$C_YELLOW
	echo -e "[5] Restore uninstalled bloatwares"
	echo -e "[r] Restart your android phone"
	echo -e "[ ] Reload"
	echo -e "[R] Root options"
	echo -e "[a] ADB Connection manager"
	echo -e "[X] Stop ADB Server and Exit"
	echo -e $C_LRED"[Ctrl+C] Exit"
	read -sn1
	print_header
	case $REPLY in
		X) echo -e "$INFO Stopping ADB Server and Exiting..."
			 adb kill-server
			 fxbgyclr
	;;1|2|3|4|5|r) if ! adb get-state &>/dev/null;then echo -e "$ERROR No Devices Detected";unset REPLY;sleep 1;MAIN;fi
 ;;\ ) MAIN
	;;a) MAIN_adb
	;;R) MAIN_root
	esac
	case $REPLY in
		1) debloat_wrapper
	;;2) restrict_appops
	;;3) install_packages
	;;4) install_foss
	;;5) restore_packages
	;;r) echo -e "$WARN Restarting your connected Android phone..."
			 adb reboot
	;;*) echo -e "$ERROR Invalid option";sleep 1;;
	esac
	MAIN
}
MAIN_adb(){
	print_header
	echo -e $INFO" ADB Connection manager"$C_YELLOW
	echo -e "[1] Restart ADB listening on TCP "$C_END"("$C_YELLOW"Wireless ADB, make sure you're connected to an access point"$C_END")"$C_YELLOW
	echo -e "[2] Restart ADB listening on USB "$C_END"("$C_YELLOW"Wired ADB"$C_END")"$C_YELLOW
	echo -e "[3] Connect a device "$C_END"("$C_YELLOW"only if the device is set to listen TCP previously"$C_END")"$C_RED
	echo -e "[4] Disconnect everything"$C_YELLOW
	echo -e "[5] List connected devices"$C_YELLOW
	echo -e "[ ] Reload"
	echo -e "[x] Go back"
	read -sn1
	print_header
	case $REPLY in
		x) MAIN
	;;1|2|3|4|5|6|r) if ! adb get-state &>/dev/null;then echo -e "$ERROR No Devices Detected";unset REPLY;sleep 1;MAIN;fi
 ;;\ ) MAIN_adb
	esac
	case $REPLY in
		1) echo -e "$INFO Reinitiating connection to TCP port 5555..."
			 adb tcpip 5555
	;;2) echo -e "$INFO Reinitiating connection to USB..."
			 adb usb
	;;3) echo -e "$INFO Type your device Local IP (port is optional, make sure the server and the device is on the same network)\n\> "
			 prompt
			 if ! [ "$REPLY" = "" ];then
				 echo -e "$INFO Connecting to $REPLY..."
				 adb connect $REPLY
			 fi
	;;4) echo -e "$INFO Disconnecting all devices..."
			 adb disconnect
	;;5) adb devices
			 pause
	;;*) echo -e "$ERROR Invalid option";sleep 1;;
	esac
	MAIN_adb
}
MAIN_root(){
	print_header;echo -en $C_YELLOW
	echo -e "For-Root-user options"
	echo -e "[1] Clean App Cache "$C_END"("$C_GREEN"Recommended"$C_END")"$C_YELLOW
	echo -e "[ ] Reload"
	echo -e "[x] Go back"
	echo -e $C_LRED"[Ctrl+C] Exit"
	read -sn1
	print_header
	case $REPLY in
		1) if ! adb get-state &>/dev/null;then echo -e "$ERROR No Devices Detected";unset REPLY;sleep 1;MAIN;fi
	;;x) MAIN
 ;;\ ) MAIN_root
	esac
	case $REPLY in
		1) cleancache_wrapper
	;;*) echo -e "$ERROR Invalid option";sleep 1;;
	esac
	MAIN_root
}
debloat_wrapper(){
	print_header
	if [ "$(detect_root)" = "1" ];then
		echo -e "$SUCCESS Root user detected, using root method is "$C_GREEN"recommended"$C_END
	elif [ $(fetch_info_from_device android_version) -ge 9 ];then
		echo -e "$INFO Non-root and Android 8+, using default method is "$C_GREEN"recommended"$C_END
	else
		echo -e "$WARN Detected using Android 8-."
	fi
	echo -e "$INFO Choose the method of removing bloatware "$C_END"("$C_YELLOW"remember, these will also "$C_LRED"CLEAR data"$C_YELLOW". to "$C_GREEN"keep data"$C_YELLOW", RERUN this script with "$C_END$C_BOLD"--keep-data"$C_END$C_YELLOW" argument"$C_END"):"
	echo -e $C_LRED"[R] Delete APK Directly "$C_END"("$C_GREEN"root required"$C_END")"
	echo -e $C_YELLOW"[U] Uninstall "$C_END"(default)"
	echo -e $C_GREEN"[D] Disable "$C_END"(if you want to easy-reinstall w/o pc)"$C_END
	echo -e $C_LRED"[F] Delete Bloatware-related system files "$C_END"("$C_GREEN"root required"$C_END")"
	echo -e "[p] View the list of apps/files that going to be removed ("$C_GREEN"recommended"$C_END" before you "$C_YELLOW"do removal process"$C_END")"
	echo -e "[x] Go back"
	echo -e $C_LRED"[Ctrl+C] Exit"$C_END
	read -sn1
	print_header
	case $REPLY in
		R) debloat_root
	;;U) debloat
	;;D) debloat_disable
	;;F) debloat_filesystems
	;;p) declare -A BLOAT_LIST=();local tmp0
			 associate_path_with_package BLOAT_LIST
			 echo -e "$INFO Apps that going to be removed:"
			 for i in ${!BLOAT_LIST[@]};do tmp0+="$i ${BLOAT_LIST[$i]}\n";done
			 if [ "$tmp0" = "" ];then
				 echo -e "$SUCCESS No apps that are going to be removed."
			 else
				 echo -e "$C_LGRAY$tmp0" | sort -ui
			 fi
			 echo -e "$C_END"
			 unset BLOAT_LIST tmp0
			 echo -e "$INFO Files that going to be removed:$C_LGRAY"
			 cat System_Bloatwares.txt
			 pause
			 debloat_wrapper
	;;x) MAIN
	;;*) echo -e "$ERROR Invalid option";sleep 1;debloat_wrapper;;
	esac
	home
}
cleancache_wrapper(){
	print_header
	if [ "$(detect_root)" = "1" ];then
		echo -e "$SUCCESS Root user detected, everything should work as intended"$C_END
	else
		echo -e "$WARN Non-root detected. without root, NJASD cant clean everything"
	fi
	echo -e $C_RED"[C] Clean caches"$C_END
	echo -e $C_YELLOW"[T] Wreck tracking properties (Experimental)"$C_END
	echo -e "[c] View the list of caches that going to be removed ("$C_GREEN"recommended"$C_END" before you "$C_YELLOW"do cleanup process"$C_END")"
	echo -e "[t] View the list of tracking xml that going to be modified"
	echo -e "[x] Go back"
	echo -e $C_LRED"[Ctrl+C] Exit"$C_END
	read -sn1
	print_header
	case $REPLY in
		C) cleancache
			 pause
	;;T) voluntarywrenchtracker
			 pause
	;;c) echo -e $C_LGRAY
			 if [ "$(detect_root)" = "1" ];then
				 adb shell "su -c ls -Aqd1 $PHONE_CACHE_DIRECTORIES_ROOT"
			 else
				 echo -e $WARN' No root'
			 fi
			 adb shell "ls -Aqd1 $PHONE_CACHE_DIRECTORIES"
			 pause
			 cleancache_wrapper
	;;t) echo -e $C_LGRAY
			 if [ "$(detect_root)" = "1" ];then
				 adb shell 'su -c ls -Aqd1 /data/data/*/shared_prefs/{_HANSEL_FILTERS_SP,_HANSEL_TRACKER_SP,adjust_preferences,com.applovin.sdk.1,com.applovin.sdk.impl.postbackQueue.domain,com.applovin.sdk.preferences.*,com.applovin.sdk.shared,com.crashlytics.prefs,com.crashlytics.sdk.android:answers:settings,com.dynatrace.android.dtxPref,com.google.android.gms.measurement.prefs,com.google.android.gms.appid,com.google.firebase.crashlytics,com.facebook.sdk.appEventPreferences,com.facebook.sdk.attributionTracking,com.facebook.sdk.USER_SETTINGS,com.fyber.unity.ads.OfferWallUnityActivity,com.medallia.*,FBAdPrefs,FirebaseAppHeartBeat,fiverocks,FyberPreferences,fyber*,tjcPrefrences,TwitterAdvertisingInfoPreferences}.xml'
			 else
				 echo -e $WARN' No root'
			 fi
			 pause
			 cleancache_wrapper
	;;x) MAIN
	;;*) echo -e "$ERROR Invalid option";sleep 1;cleancache_wrapper;;
	esac
	cleancache_wrapper
}
restore_packages(){
	print_header
	echo -e "$INFO This menu allows you to restore apps that has been uninstalled"
	echo "using normal method (pm uninstall --user 0 [package_name])"
	echo
	echo -e "$ERROR WIP (Work In Progress..., this area should show uninstalled package names)"
	echo
	echo -e "$INFO Type the package name you want to restore (eg com.facebook.katana)"
	echo "and press Enter to confirm the option"
	echo "[] Go Back (press enter without typing anything)"
	echo -en $C_LRED"[Ctrl+C] Exit"$C_END"\n > "
	prompt
	case $REPLY in
	 "") MAIN
	;;*) print_header
			 if [ "$(adb shell 'pm list packages -u'|grep $REPLY)" = "package:$REPLY" ];then
				 echo -en $SUCCESS Package $REPLY found, Reinstalling $REPLY...
				 adb shell "pm install-existing $REPLY"
			 else
				 echo -e $ERROR Package $REPLY not found.
			 fi
			 pause
	;;
	esac
	MAIN
}
####################

### Core Functions ###
debloat(){
	local RESULT
	local COMMAND
	for i in $(get_bloatware_list);do
		COMMAND+="echo -e \"$INFO Uninstalling $i... \""
		if [ "$KEEP_DATA" = "0" ];then
			COMMAND+="am force-stop $i;pm uninstall $i || pm uninstall --user 0 $i"
		else
			COMMAND+="am force-stop $i;pm uninstall -k $i || pm uninstall --user 0 -k $i"
		fi
		COMMAND+="'[ \"$RESULT\" = \"Success\" ] && [ \"$?\" = \"0\" ] && echo -e \"$SUCCESS Success\" || echo -e \"$ERROR $RESULT\"'"
	done
	adb shell "$COMMAND"
	echo -e $SUCCESS Done!
	pause
}
debloat_root(){
	if [ $(fetch_info_from_device android_version) -gt 9 ];then
		echo -en "$INFO Android 9+ detected\n$INFO remounting / as read-write...\r"
		adb shell "su -c 'mount -wo remount /'" && echo -e "\033[0K$SUCCESS / remounted as read-write" || echo -e "\033[0K$ERROR Failed to remount / as read-write"
	else
		echo -en "$INFO Android 9 or below detected\n$INFO remounting /system as read-write...\r"
		adb shell "su -c 'mount -wo remount /system'" && echo -e "\033[0K$SUCCESS /system remounted as read-write" || echo -e "\033[0K$ERROR Failed to remount /system as read-write"
	fi
	echo -en "$INFO Remounting /odm as Read-write...\r"
	adb shell "su -c 'mount -wo remount /odm'" && echo -e "\033[0K$SUCCESS /odm remounted as read-write" || echo -e "\033[0K$ERROR Failed to remount /odm as read-write"
	declare -A BLOAT_LIST=()
	associate_path_with_package BLOAT_LIST
	for i in "${!BLOAT_LIST[@]}";do
		echo -en "$WARN Deleting $i (${BLOAT_LIST[$i]})...\r"
	 #TODO: should remove /system/app/NAME instead of just its ./NAME.apk, maybe use basename??
	 #for now, we use workaround, remove blank folders in /system/app and /system/priv-app
		adb shell "am force-stop $i &>/dev/null;pm clear $i &>/dev/null;pm uninstall --user 0 $i &>/dev/null;su -c rm -r ${BLOAT_LIST[$i]} &>/dev/null"
		[ "$?" = "0" ] && echo -e "\033[0K$SUCCESS $i (${BLOAT_LIST[$i]}) Removed!" || echo -e "\033[0K$ERROR Can't remove $i (${BLOAT_LIST[$i]}). Error code: $?"
	done
	echo -e $INFO' Cleaning empty folders in /system/app...'$C_LGRAY
	adb shell "su -c find /system/app -type d -empty -print -delete -o -type f -empty -print -delete"
	echo -e $INFO' Cleaning empty folders in /system/priv-app...'$C_LGRAY
	adb shell "su -c find /system/priv-app -type d -empty -print -delete -o -type f -empty -print -delete"
	echo -e $INFO 'Remounting /system as Read-only (for security reason)...'
	adb shell "su -c mount -fro remount /"
	echo -e $SUCCESS' Done! reboot is recommended'
	pause
}
debloat_disable(){
	for i in $(get_bloatware_list);do
		if [ "$KEEP_DATA" = "0" ];then
			echo -en "$INFO $C_YELLOW(clearing data)$C_END and disabling $i...\r"
			adb shell "pm clear $i &>/dev/null" || echo -e "$ERROR Can't clear $i data. Error code: $?"
		else
			echo -en "$INFO Disabling $i..."
		fi
		adb shell "am force-stop $i &>/dev/null;pm disable $i &>/dev/null;pm disable-user $i &>/dev/null"
		[ "$?" = "0" ] && echo -e "$SUCCESS $i Disabled!" || echo -e "$ERROR Can't disable $i. Error code: $?"
	done
	echo -e $SUCCESS Done!
	pause
}
debloat_filesystems(){
	echo -e "$ERROR Work-in-progress, this section should remove bloatware-related files defined in System_Bloatwares."
}
restrict_appops(){
	echo -e $WARN This feature is still barebone
	if [ -f "modules/DenyBloatPermsNOps.sh" ];then
		modules/DenyBloatPermsNOps.sh
		echo -e $SUCCESS Done!
	else
		echo -e "$ERROR modules/DenyBloatPermsNOps.sh did'nt exist! make sure ./modules folder exist"
	fi
	pause
}
install_packages(){
	if ! [ -d "$INSTALL_APPS_DIR" ];then
		echo -e $WARN" $INSTALL_APPS_DIR didn't exist, creating one..."
		mkdir -p "$INSTALL_APPS_DIR"
	fi
	echo -e $INFO" Now put any APKs you want to install to $INSTALL_APPS_DIR."
	echo -e $INFO" If you have split apk, put it in a directory (TODO), or zipped with .apkm/.apks as extension (TODO)"
	echo -e $INFO" Note: Installed APK on the directory will be removed"
	pause
	for i in $(ls $INSTALL_APPS_DIR/*.apk);do
		echo -en $INFO" Installing $i... "
		adb install "$INSTALL_APPS_DIR/$i" && rm -r "$INSTALL_APPS_DIR/$i" || read -N1 -t10
	done
 #TODO
	for i in $(ls *.{apkm,apks,zip});do
		ii=${i%.apkm}
		ii=${ii%.apks}
		ii=${ii%.zip}
		mv -T $i $ii.zip
		echo "Unpacking $ii..."
		unzip $ii.zip *.apk -d $ii
		echo "Installing $ii... "
		installSplitApk $ii
	done
	echo -e $SUCCESS' Done!'
	pause
}
install_foss(){
	echo -e "$INFO To be implemented, coming soon";sleep 1
}
cleancache(){
	#Clear any caches that can be cleaned (root)
	if [ "$(detect_root)" = "1" ];then
		echo -e $INFO' Root detected, the procedure can begin now'
		for i in $(adb shell "su -c ls -Aqd1 $PHONE_CACHE_DIRECTORIES_ROOT" | grep -E '^/');do
			echo -e "$INFO Removing $i..."
			#adb shell 'su -c rm -r $i/*'
		done
	else
		echo -e "$WARN No root detected. Can't clean files/folders that requires root access"
		echo -e "$WARN Ignoring the error, and continuing clearing possible directories"
	fi

	#Clear Caches in Internal/external(sdcard) storage
	for i in $(adb shell echo $PHONE_CACHE_DIRECTORIES);do
		echo -e "$INFO Removing $i..."
	 #adb shell 'rm -rf $i'
	done

	#Clear logcat logs
	adb logcat -c

}
voluntarywrenchtracker(){
	echo -e $C_LGRAY
	echo -e $WARN This might overwrite wrong files, make sure to have a backup!
	echo -e $WARN This is a very barebone and experimental work-in-progress script!
	if [ "$(detect_root)" = "1" ];then
		if [ -d "modules/WrenchTrackers" ] && [ -f "modules/WrenchTrackers/WrenchTrackers.sh" ];then
			adb shell "rm -r $BASE_DIR_PHONE"
			echo -e "$INFO Pushing required files to phone... ($BASE_DIR_PHONE/WrenchTrackers)"
			adb push $BASE_DIR_HOST/modules/WrenchTrackers $BASE_DIR_PHONE/WrenchTrackers > /dev/null
			echo -e "$INFO Executing shell script on phone..."
			adb shell "su -c sh $BASE_DIR_PHONE/WrenchTrackers/WrenchTrackers.sh"
			echo -e "$INFO Phone-side script exited with exit code $?"
			echo -e "$INFO Removing temporary njasd files located on phone..."
			adb shell "rm -r $BASE_DIR_PHONE"
			echo -e $SUCCESS Done!
		else
			echo -e "$ERROR modules/WrenchTrackers did'nt exist! make sure its exist"
		fi
	else
		echo -e $ERROR' This requires root, but no root detected.'
	fi
}
optimize_sql_databases(){
	echo -e $ERROR' Work-in-progress, this should query all possible SQL databases and optimize them'
	pause
}
######################







### Helper functions ###
prompt(){ # only used when inputting text, not choice
	tput cnorm
	read $@
	tput civis
}
pause(){
	echo -en $INFO Press any key to continue...;
	read -sn1
}
associate_path_with_package(){
	local -n ASSOCIATE="$1"
	declare -a PACKAGES=()
	readarray -t PACKAGES < <(adb shell 'pm list packages -f'|sed 's/^package://'|grep -F "$(cat $BLOATWARES_LIST_UNINSTALL_SYSTEM|sed '/^#/d'|egrep -hv "^[[:space:]]*$"|awk '{gsub(/^[ \t]+|[ \t]+$/,"");print}')"|sort -ui)
	for i in "${PACKAGES[@]}";do
		ASSOCIATE["${i##*=}"]="${i%=*}"
	done
}
get_bloatware_list(){
	adb shell 'pm list packages'|sed 's/^package://'|grep -F "$(cat $BLOATWARES_LIST_UNINSTALL_SYSTEM|sed '/^#/d'|egrep -hv "^[[:space:]]*$"|awk '{gsub(/^[ \t]+|[ \t]+$/,"");print}')"|sort -ui
}
detect_root(){
	if [ "$DETECT_ROOT_ALTER" = "auto" ];then
		if [ "$(adb shell su -c whoami)" = "root" ];then
			echo 1
		else
			echo 0
		fi
	elif [ "$DETECT_ROOT_ALTER" = "yes" ];then
		echo 1
	elif [ "$DETECT_ROOT_ALTER" = "no" ];then
		echo 0
	fi
}
fetch_info_from_device(){
	if [ "$1" = "brand" ];then
		local brand
		brand=$(adb shell getprop ro.product.brand | tr -d '\r' | awk '{print tolower($0)}')
		case "$brand" in
		"redmi"|"poco") echo xiaomi
		;;		 "honor") echo oppo
		;;					 *) echo $brand
		esac
	elif [ "$1" = "Brand" ];then
		local brand
		brand=$(adb shell getprop ro.product.brand | tr -d '\r')
		case "$(echo $brand | awk '{print tolower($0)}')" in
		"redmi"|"poco") echo Xiaomi
		;;		 "honor") echo Oppo
		;;					 *) echo $brand
		esac
	elif [ "$1" = "android_sdk_version" ];then
		local ANDROID_SDK_VERSION
		ANDROID_SDK_VERSION=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
		echo $ANDROID_SDK_VERSION
	elif [ "$1" = "android_version" ];then
		local ANDROID_SDK_VERSION
		ANDROID_SDK_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')
		echo $ANDROID_SDK_VERSION
#	elif [ "$1" = "installed_packages" ];then
#
	fi
}
print_header(){
	TITLE="NJASD v$NJASD_VERSION (PC, Linux)"
	clear
	echo -e $C_LBLUE$(printf "=%.0s" $(seq -s' ' $COLUMNS))
	echo -e $C_LGREEN" $TITLE"$C_END
	if adb get-state &>/dev/null;then
		echo -e " Brand: "$C_YELLOW$(fetch_info_from_device Brand)$C_END", Android version: "$C_YELLOW$(fetch_info_from_device android_version)$C_END", Android SDK version: "$C_YELLOW$(fetch_info_from_device android_sdk_version)$C_END
	else
		echo -e "$C_LRED No devices detected"$C_END
		echo -e "$C_END Make sure "$C_YELLOW"USB Debugging"$C_END" is "$C_GREEN"enabled"$C_END" on your phone"
	fi
	echo -e $C_LBLUE$(printf "=%.0s" $(seq -s' ' $COLUMNS))$C_END
}
start_adb_server(){
	TITLE="NJASD v$NJASD_VERSION (PC, Linux)"
	clear
	echo -e $C_LBLUE$(printf "=%.0s" $(seq -s' ' $COLUMNS))
	echo -e "$C_LGREEN $TITLE"
	echo -e $C_LBLUE$(printf "=%.0s" $(seq -s' ' $COLUMNS))$C_END
	echo -e "$INFO "$C_LGREEN"Starting ADB Server (if not running)..."$C_END
	adb start-server
	if [ "$?" = "0" ];then echo -e "$SUCCESS Success"
	elif [ "$?" = "127" ];then echo -e "$ERROR ADB Not found or not installed, try to install it by running \"apt install android-sdk-platform-tools\"";sleep 3
	else echo -e "Unknown error occured with code $?";sleep 3
	fi
}
installSplitApk(){ #TODO, ported from Batch version
 #Configuration
	DIR_OF_SPLIT_APKS=$1
 #For each APKs
	for i in $DIR_OF_SPLIT_APKS/*.apk;do
	 #Calculate all of the APK in a directory, and move them to device temporary directory
		APK_SIZE=$((APK_SIZE + $(du -abc --apparent-size $i|grep -E "total$"|cut -f1)))
		adb push $i $BASE_DIR_PHONE/SA/$DIR_OF_SPLIT_APKS/$i
	done
 #Output of command below: `Success: created install session [451298401]`, TODO: grab that install session
	PM_INSTALL_SESSION=$(adb shell pm install-create -S $APK_SIZE) #<< apk + all the splits
 #Set the index to 0
	local APK_INDEX=0
 #For each APKs
	for i in $1/*.apk;do
	 #Get APK size
		APK_SIZE=$(du -abc --apparent-size $i|grep -E "total$"|cut -f1)
	 #Write the apks to buffer
		adb shell pm install-write -S $APK_SIZE $PM_SESSION $APK_INDEX $i
		APK_INDEX+=1
	done
 #And initialize install
	adb shell pm install-commit $PM_INSTALL_SESSION
}
########################

### Initialization ###
SUCCESS="[+]"
INFO="[i]"
DEBUG="[d]"
WARN="[!]"
ERROR="[-]"
print_version(){
	echo "NJASD (Not Just A System Debloater) v$NJASD_VERSION, by mdp43140"
	echo "Last changed: $NJASD_LAST_CHANGED"
	echo "Release state: $NJASD_RELEASE_BRANCH"
	echo "GitHub: https://github.com/mdp43140/NJASD_linux"
}
# argument processor...
for i in "$@";do
	case $(tr '[:upper:]' '[:lower:]' <<<"$i") in
		--color=*)
			color_prompt="${i#*=}"
		;;
		--detect-root=*)
			DETECT_ROOT_ALTER="${i#*=}"
		;;
		--bloatlist=*)
			BLOATWARES_LIST_UNINSTALL_SYSTEM="${i#*=}"
		;;
		--keep-data)
			KEEP_DATA=1
		;;
		-h|--help)
			echo " "
			echo " NJASD v$NJASD_VERSION, by mdp43140"
			echo " Usage: ./njasd_linux.sh [options]"
			echo "-------------------------"
			echo " [no parameter] | Opens NJASD in \"command-line gui\" mode"
			echo " -h --help      | Display this help page"
			echo " --color        | Use color (possible values:auto,yes,no. default:$color_prompt)"
			echo " --detect-root  | Force to return custom root state (possibly values:auto,yes,no. default:$DETECT_ROOT_ALTER)"
			echo " --bloatlist    | Use custom bloatware list (WARNING: bloatware list CANNOT contain blank spaces,supports comment by adding # on the start)"
			echo " --keep-data    | Chose whether to clear data or not on uninstall/disabling process (i recommend doing this if you deal with other peoples phone you not own, just in case it removes something bad)"
			echo " --no-header    | Don't print header"
			echo " -v --version   | Print version"
			echo ""
			exit 0
		;;
		-v|--version)
			print_version;exit 0
		;;
		*)
			echo "Invalid argument. try --help to show help page,"
			echo "or no arguments at all to open interactive clgui mode"
			exit 1
		;;
	esac
done
#below are settings that are customizable using arguments
if [ "$color_prompt" = "auto" ];then
	case "$TERM" in
		xterm-color|*-256color)color_prompt=yes;;
		*)color_prompt=no;;
	esac
fi
if [ "$color_prompt" = "yes" ];then
	readonly C_BLACK="\033[0;30m"
	readonly C_DGRAY="\033[1;30m"
	readonly C_RED="\033[0;31m"
	readonly C_LRED="\033[1;31m"
	readonly C_GREEN="\033[0;32m"
	readonly C_LGREEN="\033[1;32m"
	readonly C_BROWN="\033[0;33m"
	readonly C_YELLOW="\033[1;33m"
	readonly C_BLUE="\033[0;34m"
	readonly C_LBLUE="\033[1;34m"
	readonly C_PURPLE="\033[0;35m"
	readonly C_LPURPLE="\033[1;35m"
	readonly C_CYAN="\033[0;36m"
	readonly C_LCYAN="\033[1;36m"
	readonly C_LGRAY="\033[0;37m"
	readonly C_WHITE="\033[1;37m"
	readonly C_END="\033[0m"
	readonly C_BOLD="\033[1m"
	SUCCESS="$C_LGRAY[$C_GREEN+$C_LGRAY]$C_END"
	INFO="$C_LBLUE[$C_CYAN"i"$C_LBLUE]$C_END"
	DEBUG="$C_LGRAY[d]$C_END"
	WARN="$C_YELLOW[$C_BROWN!$C_YELLOW]$C_END"
	ERROR="$C_BROWN[$C_LRED-$C_BROWN]$C_END"
fi
# Hook the event that whenever NJASD:
# - quit in any way (except getting KILL signal), restore current text color to prevent kinda buggy color.
# - encountered error, show the error and encourage people to report on GitHub.
{ trap 'fxbgyclr $LINENO' ABRT ||:; trap 'fxbgyclr $LINENO' QUIT ||:; trap fxbgyclr INT ||:; trap 'fxbgyclr $LINENO' EXIT ||:; trap 'fxbgyclr $LINENO' TERM ||:; trap 'fxbgyclr $LINENO' HUP ||:; trap 'fxbgyclr $LINENO' ERR ||:; } 2>/dev/null
fxbgyclr(){
	local ERRCODE="$?"
	trap - EXIT
	clear
	[ "$ERRCODE" != "0" ] && (
		echo -e "$INFO NJASD (Not Just A System Debloater) v$NJASD_VERSION, by mdp43140"
		echo -e "$INFO Last changed: $NJASD_LAST_CHANGED"
		echo -e "$INFO Release state: $NJASD_RELEASE_BRANCH"
		[ "$1" = "" ] && (echo "Unknown error: $ERRCODE") || (echo -e "$ERROR$C_YELLOW Error code $C_LRED$ERRCODE$C_YELLOW. Something is wrong at line $C_LRED$1$C_YELLOW: $C_LGRAY$(sed -n $1p $0)$C_YELLOW")
		echo -e "$INFO If you think this is a bug, Report it on GitHub:"
		echo -e "$INFO https://github.com/mdp43140/PCCU/issues"
	)
	echo -en "$C_END\033[0K\r"
	tput cnorm
	exit $ERRCODE
}

# Make cursor invisible, make sure ADB server is started, and show the TUI menu
tput civis
start_adb_server
MAIN
######################
