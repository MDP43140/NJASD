#!/usr/bin/env bash
# This module should be executed from PC
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
readonly SUCCESS="$C_LGRAY[$C_GREEN+$C_LGRAY]$C_END"
readonly INFO="$C_LBLUE[$C_CYAN"i"$C_LBLUE]$C_END"
readonly WARN="$C_YELLOW[$C_BROWN!$C_YELLOW]$C_END"
readonly ERROR="$C_BROWN[$C_LRED-$C_BROWN]$C_END"

echo -en "$INFO Preparing...\033[0K\r"
declare -A INSTALLED_PKGS=()
declare -A PKGS_APPOPS=()
ash(){ adb shell $@; }
BASE_DIR_PHONE="/sdcard/njasd"
TEMP_PHONE="/data/local/tmp/"
INSTALLED_PKGS="$(ash pm list packages)"




pause(){
	echo -en $INFO Press any key to continue...;
	read -sn1
}
pm_deny(){
	local PKG_NAME="$1"
	shift
	for i in $@;do
		pm_check_pkg $PKG_NAME || continue
		echo -en "$INFO Denying $PKG_NAME permission... ($i)\033[0K\r"
		ash pm revoke $PKG_NAME $i >/dev/null 2>&1 || echo -e "$ERROR Failed to deny $PKG_NAME $i permission.\033[0K\r"
	done
}
pm_deny2(){
	local PERM_NAME="$1"
	shift
	for i in $@;do
		pm_check_pkg $i || continue
		echo -en "$INFO Denying $i permission... ($PERM_NAME)\033[0K\r"
		ash pm revoke $i $PERM_NAME >/dev/null 2>&1 || echo -e "$ERROR Failed to deny $i $PERM_NAME permission.\033[0K\r"
	done
}
pm_disable(){
	for i in $@;do
		pm_check_pkg $i || continue
		ash am force-stop $i
		ash pm clear $i
		ash pm disable $i
	done
}
ao_deny(){
	PKG_NAME="$1"
	shift
	for i in $@;do
		pm_check_ops $PKG_NAME $i || continue
		echo -en "$INFO Denying $PKG_NAME operation... ($i)\033[0K\r"
		ash appops set $PKG_NAME $i deny >/dev/null 2>&1 || echo -e "$ERROR Failed to deny $PKG_NAME $i operation.\033[0K\r"
	done
}
ao_deny2(){
	OPS_NAME="$1"
	shift
	for i in $@;do
		pm_check_ops $i $OPS_NAME || continue
		echo -en "$INFO Denying $i operation... ($OPS_NAME)\033[0K\r"
		ash appops set $i $OPS_NAME deny >/dev/null 2>&1 || echo -e "$ERROR Failed to deny $i $OPS_NAME operation.\033[0K\r"
	done
}
pm_check_pkg(){
	[ "$(echo $INSTALLED_PKGS | grep $1)" = "" ] && return 1 || return 0
}
pm_check_ops(){
 #Check if a package ops is used (with memoization too)
 #return if not exist
	pm_check_pkg $1 || return 1
 #sanitation required because arrays in bash cant handle certain characters (including .s used on the package name)
	local PKG_NAME_SANITIZED="$(echo $1 | sed 's/\.//g')"
 #create if not defined yet
	[ "${PKGS_APPOPS[$PKG_NAME_SANITIZED]+_}" = "" ] && PKGS_APPOPS[$PKG_NAME_SANITIZED]="$(ash appops get $1)"
 #and process that cache instead hehe
	echo "${PKGS_APPOPS[$PKG_NAME_SANITIZED]}" | grep -q $2 >/dev/null 2>&1
	return $?
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
	elif [ "$1" = "android_sdk_version" ];then
		local ANDROID_SDK_VERSION
		ANDROID_SDK_VERSION=$(adb shell getprop ro.build.version.sdk | tr -d '\r')
		echo $ANDROID_SDK_VERSION
	elif [ "$1" = "android_version" ];then
		local ANDROID_SDK_VERSION
		ANDROID_SDK_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')
		echo $ANDROID_SDK_VERSION
	fi
}
pm_reinstall_minimal(){
	PACKAGE_NAME="$1" # eg: com.facebook.katana
	echo -en "$INFO Reinstalling $PACKAGE_NAME without split apks...\033[0K\r"
	APK_DIR="$(ash pm list packages -f $PACKAGE_NAME | cut -d: -f2 | sed -E 's/\/base.apk=.+$//g')"
	if ! [ "$APK_DIR" ];then
		echo -e "$SUCCESS $PACKAGE_NAME isn't available.\033[0K\r"
		return
	elif [ "$(ash ls $APK_DIR/*.apk | wc -l)" = "1" ];then
		echo -e "$SUCCESS $PACKAGE_NAME already installed as minimal. no need to redo it again.\033[0K\r"
		return
	fi
	BASE_APK="$(ash ls $APK_DIR/base.apk)"
	ash cp "$BASE_APK" "$TEMP_PHONE/apk_reinstall.apk"
	ash pm install "$TEMP_PHONE/apk_reinstall.apk"
	[ "$?" = "0" ] && echo -e "$SUCCESS $PACKAGE_NAME Reinstalled as minimal.\033[0K\r" || echo -e "$ERROR Can't reinstall $PACKAGE_NAME as minimal. Error code: $?\033[0K\r"
	ash rm "$TEMP_PHONE/apk_reinstall.apk"
}

echo -e "$INFO Restricting Various apps Ability to run in bg, and at any time...\033[0K"
RUN_IN_BG_APPS=(
	"com.apps.MyXL"
	"com.android.calculator"
	"com.andromo.dev445584.app545102"
	"com.dts.freefireth"
	"com.eights.pool.ball.night"
	"com.estrongs.android.pop"
	"com.feelingtouch.zf3d"
	"com.finalwire.aida64"
	"com.foxdebug.acode"
	"com.google.android.calculator"
	"com.kitka.fallbuddies"
	"com.PoxelStudios.DudeTheftAuto"
	"com.samsung.android.game.gamehome"
	"com.samsung.android.game.gos"
	"com.samsung.android.stickercenter"
	"com.samsung.android.themestore"
	"com.sec.android.app.camera"
	"com.simplemobiletools.filemanager"
	"com.simplemobiletools.filemanager.pro"
	"com.simplemobiletools.gallery"
	"com.simplemobiletools.gallery.pro"
	"com.simplemobiletools.thankyou"
	"com.simplemobiletools.voicerecorder"
	"com.simplemobiletools.voicerecorder.pro"
	"com.simplycomplexapps.ASTellme"
	"com.teslacoilsw.launcher.prime"
	"com.tencent.ig"
	"com.whatsapp"
	"de.markusfisch.android.binaryeye"
	"jp.snowlife01.android.optimization"
	"net.apex_designs.payback2"
	"org.catrobat.paintroid"
	"org.zwanoo.android.speedtest"
	"osmanonurkoc.papirus"
	"simplehat.clicker"
	"ua.com.streamsoft.pingtools"
)
ao_deny2 RUN_IN_BACKGROUND ${RUN_IN_BG_APPS[@]}
ao_deny2 RUN_ANY_IN_BACKGROUND ${RUN_IN_BG_APPS[@]}

echo -e "$INFO Restricting Various apps to Ability to run after boot...\033[0K"
SIGBOOT_APPS=(
	"com.apps.MyXL"
	"com.PoxelStudios.DudeTheftAuto"
	"com.samsung.android.game.gamehome"
	"com.samsung.android.game.gos"
	"com.samsung.android.stickercenter"
	"com.samsung.android.themestore"
	"com.sec.android.app.camera"
	"org.zwanoo.android.speedtest"
	"simplehat.clicker"
	"ua.com.streamsoft.pingtools"
)
ao_deny ua.com.streamsoft.pingtools ${SIGBOOT_APPS[@]}

echo -e "$INFO Restricting Various apps Unnecesary Permission...\033[0K"
ao_deny com.andromo.dev445584.app545102 WAKE_LOCK
ao_deny com.andromo.dev445584.app545102 TOAST_WINDOW
ao_deny com.andromo.dev445584.app545102 READ_EXTERNAL_STORAGE
ao_deny com.andromo.dev445584.app545102 WRITE_EXTERNAL_STORAGE
ao_deny com.andromo.dev445584.app545102 START_FOREGROUND
ao_deny com.dumplingsandwich.portraitsketch TOAST_WINDOW
ao_deny com.eights.pool.ball.night WRITE_EXTERNAL_STORAGE
ao_deny net.apex_designs.payback2 SYSTEM_ALERT_WINDOW
ao_deny jp.snowlife01.android.optimization WAKE_LOCK
ao_deny jp.snowlife01.android.optimization TOAST_WINDOW

pm_reinstall_minimal com.facebook.katana

#This. Is. Ridicilous, Level of Tracking...
echo -e "$INFO Restricting Facebook Ability to track through AppOps..."
FACEBOOK_OPS=(
	"BOOT_COMPLETED"
	"CALL_PHONE"
	"CAMERA"
	"COARSE_LOCATION"
	"FINE_LOCATION"
	"GET_ACCOUNTS"
	"GET_USAGE_STATS"
	"LEGACY_STORAGE"
	"MONITOR_HIGH_POWER_LOCATION"
	"MONITOR_LOCATION"
	"PICTURE_IN_PICTURE"
	"READ_CALENDAR"
	"READ_CONTACTS"
	"READ_DEVICE_IDENTIFIERS"
	"READ_EXTERNAL_STORAGE"
	"READ_PHONE_NUMBERS"
	"READ_PHONE_STATE"
	"RECORD_AUDIO"
	"REQUEST_DELETE_PACKAGES"
	"RUN_ANY_IN_BACKGROUND"
	"RUN_IN_BACKGROUND"
	"SYSTEM_ALERT_WINDOW"
	"TOAST_WINDOW"
	"VIBRATE"
	"WAKE_LOCK"
	"WIFI_SCAN"
	"WRITE_CALENDAR"
	"WRITE_CLIPBOARD"
	"WRITE_CONTACTS"
	"WRITE_EXTERNAL_STORAGE"
	"WRITE_SMS"
)
ao_deny com.facebook.katana ${FACEBOOK_OPS[@]}

echo -e "$INFO Restricting FB Messenger Ability to track through AppOps...\033[0K"
FB_MLITE_OPS=(
	"GET_USAGE_STATS"
	"RUN_IN_BACKGROUND"
	"RUN_ANY_IN_BACKGROUND"
	"START_FOREGROUND"
	"TAKE_AUDIO_FOCUS"
	"WAKE_LOCK"
)
ao_deny com.facebook.mlite ${FB_MLITE_OPS[@]}

echo -e "$INFO Restricting UC Browser Ability to track...\033[0K"
UCB_OPS=(
	"AUDIO_MEDIA_VOLUME"
	"CHANGE_WIFI_STATE"
	"COARSE_LOCATION"
	"FINE_LOCATION"
	"LEGACY_STORAGE"
	"MONITOR_LOCATION"
	"READ_CLIPBOARD"
	"READ_DEVICE_IDENTIFIERS"
	"READ_EXTERNAL_STORAGE"
	"SYSTEM_ALERT_WINDOW"
	"TOAST_WINDOW"
	"VIBRATE"
	"WAKE_LOCK"
	"WIFI_SCAN"
	"WRITE_CLIPBOARD"
	"WRITE_EXTERNAL_STORAGE"
	"WRITE_SETTINGS"
)
ao_deny com.UCMobile.intl ${UCB_OPS[@]}

echo -e "$INFO Restricting Facebook Ability to track by denying ALL (hidden) permission using PM..."
echo -e $WARN "Expect this to fail on certain devices, its ok to ignore it."
FACEBOOK_PRMS=(
	"android.permission.ACCESS_BACKGROUND_LOCATION"
	"android.permission.ACCESS_COARSE_LOCATION"
	"android.permission.ACCESS_FINE_LOCATION"
	"android.permission.ACCESS_NETWORK_STATE"
	"android.permission.ACCESS_WIFI_STATE"
	"android.permission.AUTHENTICATE_ACCOUNTS"
	"android.permission.BATTERY_STATS"
	"android.permission.BLUETOOTH"
	"android.permission.BLUETOOTH_ADMIN"
	"android.permission.BROADCAST_STICKY"
	"android.permission.CALL_PHONE"
	"android.permission.CAMERA"
	"android.permission.CHANGE_NETWORK_STATE"
	"android.permission.CHANGE_WIFI_STATE"
	"android.permission.DOWNLOAD_WITHOUT_NOTIFICATION"
	"android.permission.FOREGROUND_SERVICE"
	"android.permission.GET_ACCOUNTS"
	"android.permission.GET_TASKS"
	"android.permission.INTERNET"
	"android.permission.MANAGE_ACCOUNTS"
	"android.permission.MODIFY_AUDIO_SETTINGS"
	"android.permission.NFC"
	"android.permission.READ_CALENDAR"
	"android.permission.READ_CONTACTS"
	"android.permission.READ_EXTERNAL_STORAGE"
	"android.permission.READ_PHONE_NUMBERS"
	"android.permission.READ_PHONE_STATE"
	"android.permission.READ_PROFILE"
	"android.permission.READ_SYNC_SETTINGS"
	"android.permission.RECEIVE_BOOT_COMPLETED"
	"android.permission.RECORD_AUDIO"
	"android.permission.SYSTEM_ALERT_WINDOW"
	"android.permission.USE_BIOMETRIC"
	"android.permission.USE_FINGERPRINT"
	"android.permission.USE_FULL_SCREEN_INTENT"
	"android.permission.VIBRATE"
	"android.permission.WAKE_LOCK"
	"android.permission.WRITE_CALENDAR"
	"android.permission.WRITE_CONTACTS"
	"android.permission.WRITE_EXTERNAL_STORAGE"
	"android.permission.WRITE_SYNC_SETTINGS"
	"com.amazon.device.messaging.permission.RECEIVE"
	"com.android.launcher.permission.INSTALL_SHORTCUT"
	"com.android.vending.BILLING"
	"com.facebook.appmanager.UNPROTECTED_API_ACCESS"
	"com.facebook.katana.permission.CREATE_SHORTCUT"
	"com.facebook.katana.permission.CROSS_PROCESS_BROADCAST_MANAGER"
	"com.facebook.katana.permission.RECEIVE_ADM_MESSAGE"
	"com.facebook.katana.provider.ACCESS"
	"com.facebook.mlite.provider.ACCESS"
	"com.facebook.orca.provider.ACCESS"
	"com.facebook.pages.app.provider.ACCESS"
	"com.facebook.permission.prod.FB_APP_COMMUNICATION"
	"com.facebook.receiver.permission.ACCESS"
	"com.facebook.services.identity.FEO2"
	"com.google.android.c2dm.permission.RECEIVE"
	"com.google.android.providers.gsf.permission.READ_GSERVICES"
	"com.htc.launcher.permission.READ_SETTINGS"
	"com.htc.launcher.permission.UPDATE_SHORTCUT"
	"com.nokia.pushnotifications.permission.RECEIVE"
	"com.sec.android.provider.badge.permission.READ"
	"com.sec.android.provider.badge.permission.WRITE"
	"com.sonyericsson.home.permission.BROADCAST_BADGE"
	"com.sonymobile.home.permission.PROVIDER_INSERT_BADGE"
)
pm_deny com.facebook.katana  ${FACEBOOK_PRMS[@]}

if [ "$(fetch_info_from_device brand)" = "samsung" ];then
	echo -e "$INFO Restricting Samsungapps Ability to track and run in bg...\033[0K"
	SAMSUNGAPPS_OPS=(
		"RUN_ANY_IN_BACKGROUND"
		"RUN_IN_BACKGROUND"
		"START_FOREGROUND"
		"SYSTEM_ALERT_WINDOW"
		"WAKE_LOCK"
	)
	ao_deny2 com.sec.android.app.samsungapps ${SAMSUNGAPPS_OPS[@]}

	echo -e "$INFO Restricting \"Galaxy Store\" ability to track users by denying ALL (hidden) permission using PM..."
	echo -e $WARN "Expect this to fail on certain devices, its ok to ignore it."
	SAMSUNGAPPS_PRMS=(
		"android.permission.ACCESS_NETWORK_STATE"
		"android.permission.ACCESS_WIFI_STATE"
		"android.permission.BLUETOOTH"
		"android.permission.BLUETOOTH_ADMIN"
		"android.permission.CHANGE_COMPONENT_ENABLED_STATE"
		"android.permission.CHANGE_NETWORK_STATE"
		"android.permission.CHANGE_WIFI_STATE"
		"android.permission.DELETE_PACKAGES"
		"android.permission.FOREGROUND_SERVICE"
		"android.permission.GET_ACCOUNTS"
		"android.permission.GET_ACCOUNTS_PRIVILEGED"
		"android.permission.GET_PACKAGE_SIZE"
		"android.permission.GET_TASKS"
		"android.permission.INSTALL_PACKAGES"
		"android.permission.INTERACT_ACROSS_USERS"
		"android.permission.INTERNET"
		"android.permission.NFC"
		"android.permission.PACKAGE_USAGE_STATS"
		"android.permission.QUERY_ALL_PACKAGES"
		"android.permission.READ_EXTERNAL_STORAGE"
		"android.permission.READ_PHONE_STATE"
		"android.permission.READ_PRIVILEGED_PHONE_STATE"
		"android.permission.READ_SEARCH_INDEXABLES"
		"android.permission.RECEIVE_BOOT_COMPLETED"
		"android.permission.REQUEST_INSTALL_PACKAGES"
		"android.permission.SET_PROCESS_LIMIT"
		"android.permission.START_ACTIVITIES_FROM_BACKGROUND"
		"android.permission.SUBSTITUTE_SHARE_TARGET_APP_NAME_AND_ICON"
		"android.permission.SYSTEM_ALERT_WINDOW"
		"android.permission.UPDATE_APP_OPS_STATS"
		"android.permission.VIBRATE"
		"android.permission.WAKE_LOCK"
		"android.permission.WIFI_LOCK"
		"android.permission.WRITE_APN_SETTINGS"
		"android.permission.WRITE_EXTERNAL_STORAGE"
		"android.permission.WRITE_INTERNAL_STORAGE"
		"android.permission.WRITE_SECURE_SETTINGS"
		"android.permission.WRITE_SETTINGS"
		"com.android.launcher.permission.INSTALL_SHORTCUT"
		"com.android.launcher.permission.UNINSTALL_SHORTCUT"
		"com.asus.msa.SupplementaryDID.ACCESS"
		"com.google.android.c2dm.permission.RECEIVE"
		"com.google.android.gms.permission.AD_ID"
		"com.msc.openprovider.OpenContentProvider.READ_CONTENT"
		"com.netflix.partner"
		"com.samsung.android.app.cocktailbarservice.permission.ENABLE_EDGE_PANEL"
		"com.samsung.android.app.spage.permission.READ_CARD_DATA"
		"com.samsung.android.app.spage.permission.WRITE_CARD_DATA"
		"com.samsung.android.bixby.agent.permission.READ_PUBLIC_SETTINGS"
		"com.samsung.android.game.gamehome.accesspermission.REQUEST_REWARDS"
		"com.samsung.android.game.gametools.permission.READ_KT_PLAY_GAMES"
		"com.samsung.android.gearplugin.permission.ACCESS_GEAR_PLUGIN"
		"com.samsung.android.iap.permission.BILLING"
		"com.samsung.android.launcher.permission.READ_SETTINGS"
		"com.samsung.android.mas.setting.ContentProvider.READ_VALUE"
		"com.samsung.android.permission.installApp"
		"com.samsung.android.rubin.app.ui.permission.LAUNCH_RUBIN_SETTING"
		"com.samsung.android.rubin.context.permission.READ_CONTEXT_MANAGER"
		"com.samsung.android.rubin.persona.permission.READ_PERSONA_MANAGER"
		"com.samsung.android.samsungaccount.permission.PROFILE_PROVIDER"
		"com.samsung.android.security.permission.SAMSUNG_KEYSTORE_PERMISSION"
		"com.samsung.android.stickercenter.permission.sticker.READ"
		"com.samsung.android.stickercenter.service.ACCESS"
		"com.samsung.kidshome.broadcast.DEFAULT_HOME_CHANGE_PERMISSION"
		"com.samsung.sea.retailagent.permission.RETAILMODE"
		"com.sec.android.app.clockpackage.permission.ACCESS_CELEB_VOICE"
		"com.sec.android.app.clockpackage.permission.READ_CELEB_VOICE"
		"com.sec.android.app.samsungapps.accesspermission.ACCOUNT_ACTIVITY"
		"com.sec.android.app.samsungapps.accesspermission.BILLING_ACTIVITY"
		"com.sec.android.app.samsungapps.accesspermission.CONTENT_ACTIVITY"
		"com.sec.android.app.samsungapps.accesspermission.COUNTRYSERACHEX_SERVICE"
		"com.sec.android.app.samsungapps.accesspermission.GENERNAL_ACTIVITY"
		"com.sec.android.app.samsungapps.accesspermission.HUN_EVENT"
		"com.sec.android.app.samsungapps.accesspermission.PURCHASE_PROTECTION_SERVICE"
		"com.sec.android.app.samsungapps.accesspermission.UPDATE_EXISTS"
		"com.sec.android.app.samsungapps.permission.DDI"
		"com.sec.android.fota.permission.PUSH"
		"com.sec.android.provider.badge.permission.READ"
		"com.sec.android.provider.badge.permission.WRITE"
		"com.sec.android.provider.samsungapps.permission.READ"
		"com.sec.android.provider.samsungapps.permission.WRITE"
		"com.sec.android.provider.una.astore.permission.READ"
		"com.sec.android.provider.una.astore.permission.WRITE"
		"com.sec.android.wallet.permission"
		"com.sec.spp.permission.TOKEN_2e584d01f317fdee32cc8e855153d01df2a62f8194c5c4e621bf45bcc3807f066f637c5329f12f95158279f36aae6250df4a72e8d51fc6e578e248fcf11e8339654d20216c79a9d36fed33741d7190e77939da234b8157e48c3cdde7bc93bffdba1de18b6415d62b81b8d2dd41756f099ecb13fc4d975077a6d8cde99df4405b"
		"com.sec.spp.push.permission.ACCESS_SPP_SERVER"
		"freemme.permission.msa"
		"sstream.app.StoryProvider.WRITE.PERMISSION"
	)
	pm_deny com.sec.android.app.samsungapps ${SAMSUNGAPPS_PRMS[@]}

	echo -e "$INFO Restricting Samsung's \"Customization Service\" Ability to track by denying ALL (hidden) permission using PM..."
	echo -e $WARN "Expect this to fail on certain devices, its ok to ignore it."
	SAMSUNGRUBIN_PRMS=(
		"android.permission.ACCESS_BACKGROUND_LOCATION"
		"android.permission.ACCESS_COARSE_LOCATION"
		"android.permission.ACCESS_FINE_LOCATION"
		"android.permission.ACCESS_NETWORK_STATE"
		"android.permission.ACCESS_WIFI_STATE"
		"android.permission.ACTIVITY_RECOGNITION"
		"android.permission.BLUETOOTH"
		"android.permission.BLUETOOTH_ADMIN"
		"android.permission.CHANGE_WIFI_STATE"
		"android.permission.GET_ACCOUNTS"
		"android.permission.INTERNET"
		"android.permission.MEDIA_CONTENT_CONTROL"
		"android.permission.PACKAGE_USAGE_STATS"
		"android.permission.PROCESS_OUTGOING_CALLS"
		"android.permission.READ_CALENDAR"
		"android.permission.READ_CALL_LOG"
		"android.permission.READ_CONTACTS"
		"android.permission.READ_EXTERNAL_STORAGE"
		"android.permission.READ_PRIVILEGED_PHONE_STATE"
		"android.permission.READ_SMS"
		"android.permission.REAL_GET_TASKS"
		"android.permission.RECEIVE_BOOT_COMPLETED"
		"android.permission.SET_ACTIVITY_WATCHER"
		"android.permission.SYSTEM_ALERT_WINDOW"
		"android.permission.WAKE_LOCK"
		"android.permission.WRITE_EXTERNAL_STORAGE"
		"com.android.browser.permission.READ_HISTORY_BOOKMARKS"
		"com.google.android.c2dm.permission.RECEIVE"
		"com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE"
		"com.msc.openprovider.OpenContentProvider.READ_CONTENT"
		"com.samsung.accessory.permission.ACCESSORY_FRAMEWORK"
		"com.samsung.android.bixby.agent.permission.READ_LANGUAGE"
		"com.samsung.android.bixby.bridge.provision.integrated.READ_PERMISSION"
		"com.samsung.android.cf.permission.ACCESS_CF_GEN"
		"com.samsung.android.gearoplugin.provider.Settings.READ"
		"com.samsung.android.hostmanager.permission.ACCESS_WEARABLE_STATE"
		"com.samsung.android.hostmanager.permission.CONTROL_WEARABLE_STATUS"
		"com.samsung.android.launcher.permission.READ_SETTINGS"
		"com.samsung.android.mas.setting.ContentProvider.READ_VALUE"
		"com.samsung.android.mobileservice.profile.READ"
		"com.samsung.android.oneconnect.permission.READ_CLOUD_LOCATION_PROVIDER"
		"com.samsung.android.providers.context.permission.WRITE_USE_APP_FEATURE_SURVEY"
		"com.samsung.android.providers.media.CMH"
		"com.samsung.android.providers.media.READ"
		"com.samsung.android.rubin.app.ui.permission.LAUNCH_RUBIN_SETTING"
		"com.samsung.android.rubin.context.permission.READ_CONTEXT_MANAGER"
		"com.samsung.android.rubin.context.permission.READ_PERSONA_MANAGER"
		"com.samsung.android.rubin.context.permission.WRITE_CONTEXT_MANAGER"
		"com.samsung.android.rubin.debugmode.ACCESS_DEBUG_MODE"
		"com.samsung.android.rubin.inferenceengine.datalogging.LOG_WRITE"
		"com.samsung.android.rubin.lib.READ"
		"com.samsung.android.rubin.lib.WRITE"
		"com.samsung.android.rubin.persona.permission.READ_PERSONA_MANAGER"
		"com.samsung.android.rubin.persona.permission.WRITE_PERSONA_MANAGER"
		"com.samsung.android.rubin.profile.permission.REQUEST_KIDSMODE_INFO_RUBIN"
		"com.samsung.android.sf.permission.ACCESS_SF_GEN"
		"com.samsung.cmh.data.READ"
		"com.samsung.cmh.data.WRITE"
		"com.samsung.cmh.SKIPHEAVY"
		"com.samsung.cmh.START"
		"com.samsung.WATCH_APP_TYPE.Companion"
		"com.samsung.wmanager.ENABLE_NOTIFICATION"
		"com.sec.android.app.clockpackage.permission.READ_ALARM"
		"com.sec.android.app.sbrowser.permission.QUICKACCESS"
		"com.sec.android.app.sbrowser.permission.READ_MOST_VISITED_SITES"
		"com.sec.android.diagmonagent.permission.DIAGMON"
		"com.sec.spp.permission.TOKEN_25059dfec3f0a8ba2c46083cf1b6a800f6b25f3cc9ae91093f4bbf139a95073a08d34d5a59806e31f73d09e6c3b4a4d6f960ee22b8aa92e0ae0b4c0e2e811edf29b49aaf8d086a6e4423174619bb38c3b8fdb8cf2fe5175cf4c970d20f06ac6faf2e0526f7e6da89bd1b567cf7af0b135c930ee518e9d4f17628fac7ed20cb4d"
		"sec.permission.RADIO_BASED_LOCATION"
		"sec.permission.SAMSUNG_POSITIONING"
	)
	pm_deny com.samsung.android.rubin.app ${SAMSUNGRUBIN_PRMS[@]}

	echo -e "$INFO Disabling Samsung camera dependency"
	echo -e "$INFO Fact: if you disable Samsung Camera's dependency, FilterProvider and StickerProvider, it can crash the camera app"
	pm_disable com.samsung.android.provider.filterprovider
	pm_disable com.samsung.android.provider.stickerprovider
fi