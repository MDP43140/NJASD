#!/usr/bin/env bash
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

pm_deny(){
	adb shell pm revoke $@
}
pm_disable(){
	adb shell am force-stop $@
	adb shell pm clear $@
	adb shell pm disable $@
}
ao_deny(){
	adb shell appops set $@ deny
}
ao_deny2(){
	PACKAGE_APPOPS["$1"]=( $2 )

	for APP_OPS in ${!PACKAGE_APPOPS[$APP_NAME][@]};do
		echo adb shell appops set $1 ${PACKAGE_APPOPS[$APP_OPS]} deny
	done
}

echo -e $INFO Restricting Various apps Ability to run in bg, and at any time...
ao_deny simplehat.clicker RUN_IN_BACKGROUND
ao_deny org.zwanoo.android.speedtest RUN_IN_BACKGROUND
ao_deny com.samsung.android.game.gamehome RUN_IN_BACKGROUND
ao_deny com.samsung.android.game.gos RUN_IN_BACKGROUND
ao_deny com.sec.android.app.camera RUN_IN_BACKGROUND
ao_deny com.PoxelStudios.DudeTheftAuto RUN_IN_BACKGROUND
ao_deny com.apps.MyXL RUN_IN_BACKGROUND
ao_deny ua.com.streamsoft.pingtools RUN_IN_BACKGROUND
ao_deny com.samsung.android.stickercenter RUN_IN_BACKGROUND
ao_deny com.samsung.android.themestore RUN_IN_BACKGROUND
ao_deny com.sec.android.app.camera RUN_IN_BACKGROUND
ao_deny net.apex_designs.payback2 RUN_IN_BACKGROUND
ao_deny net.apex_designs.payback2 RUN_ANY_IN_BACKGROUND
ao_deny com.estrongs.android.pop RUN_ANY_IN_BACKGROUND
ao_deny simplehat.clicker RUN_ANY_IN_BACKGROUND
ao_deny org.zwanoo.android.speedtest RUN_ANY_IN_BACKGROUND
ao_deny com.samsung.android.game.gamehome RUN_ANY_IN_BACKGROUND
ao_deny com.samsung.android.game.gos RUN_ANY_IN_BACKGROUND
ao_deny com.sec.android.app.camera RUN_ANY_IN_BACKGROUND
ao_deny com.PoxelStudios.DudeTheftAuto RUN_ANY_IN_BACKGROUND
ao_deny com.apps.MyXL RUN_ANY_IN_BACKGROUND
ao_deny ua.com.streamsoft.pingtools RUN_ANY_IN_BACKGROUND
ao_deny com.samsung.android.stickercenter RUN_ANY_IN_BACKGROUND
ao_deny com.samsung.android.themestore RUN_ANY_IN_BACKGROUND
ao_deny com.sec.android.app.camera RUN_ANY_IN_BACKGROUND
ao_deny jp.snowlife01.android.optimization RUN_ANY_IN_BACKGROUND
ao_deny com.feelingtouch.zf3d RUN_IN_BACKGROUND
ao_deny com.feelingtouch.zf3d RUN_ANY_IN_BACKGROUND
ao_deny com.eights.pool.ball.night RUN_ANY_IN_BACKGROUND

echo -e $INFO Restricting Various apps to Ability to run after boot...
echo -e $WARN Expect this to fail on certain devices, its ok to ignore it.
ao_deny simplehat.clicker BOOT_COMPLETED
ao_deny org.zwanoo.android.speedtest BOOT_COMPLETED
ao_deny com.samsung.android.game.gamehome BOOT_COMPLETED
ao_deny com.samsung.android.game.gos BOOT_COMPLETED
ao_deny com.sec.android.app.camera BOOT_COMPLETED
ao_deny com.PoxelStudios.DudeTheftAuto BOOT_COMPLETED
ao_deny com.apps.MyXL BOOT_COMPLETED
ao_deny ua.com.streamsoft.pingtools BOOT_COMPLETED
ao_deny com.samsung.android.stickercenter BOOT_COMPLETED
ao_deny com.samsung.android.themestore BOOT_COMPLETED
ao_deny com.sec.android.app.camera BOOT_COMPLETED deny

#warn:some apps will crash if START_FOREGROUND is denied
#none yet....

#other bloats with more nonsense ops
echo -e $INFO Restricting Samsungapps Ability to track and run in bg...
ao_deny com.sec.android.app.samsungapps SYSTEM_ALERT_WINDOW
ao_deny com.sec.android.app.samsungapps WAKE_LOCK
ao_deny com.sec.android.app.samsungapps START_FOREGROUND
ao_deny com.sec.android.app.samsungapps RUN_IN_BACKGROUND
ao_deny com.sec.android.app.samsungapps RUN_ANY_IN_BACKGROUND deny

echo -e $INFO Restricting Various apps Unnecesary Permission...
ao_deny jp.snowlife01.android.optimization WAKE_LOCK deny
ao_deny jp.snowlife01.android.optimization TOAST_WINDOW deny
ao_deny net.apex_designs.payback2 SYSTEM_ALERT_WINDOW
ao_deny com.dumplingsandwich.portraitsketch TOAST_WINDOW

#This. Is. Ridicilous, Level of Tracking...
echo -e $INFO Restricting Facebook Ability to track through AppOps...
ao_deny com.facebook.katana BOOT_COMPLETED
ao_deny com.facebook.katana CALL_PHONE
ao_deny com.facebook.katana CAMERA
ao_deny com.facebook.katana COARSE_LOCATION
ao_deny com.facebook.katana FINE_LOCATION
ao_deny com.facebook.katana GET_ACCOUNTS
ao_deny com.facebook.katana GET_USAGE_STATS
ao_deny com.facebook.katana MONITOR_HIGH_POWER_LOCATION
ao_deny com.facebook.katana MONITOR_LOCATION
ao_deny com.facebook.katana READ_CALENDAR
ao_deny com.facebook.katana READ_CONTACTS
ao_deny com.facebook.katana READ_EXTERNAL_STORAGE
ao_deny com.facebook.katana READ_PHONE_NUMBERS
ao_deny com.facebook.katana READ_PHONE_STATE
ao_deny com.facebook.katana RECORD_AUDIO
ao_deny com.facebook.katana REQUEST_DELETE_PACKAGES
ao_deny com.facebook.katana RUN_ANY_IN_BACKGROUND
ao_deny com.facebook.katana RUN_IN_BACKGROUND
ao_deny com.facebook.katana SYSTEM_ALERT_WINDOW
ao_deny com.facebook.katana TOAST_WINDOW
ao_deny com.facebook.katana VIBRATE
ao_deny com.facebook.katana WAKE_LOCK
ao_deny com.facebook.katana WIFI_SCAN
ao_deny com.facebook.katana WRITE_CALENDAR
ao_deny com.facebook.katana WRITE_CLIPBOARD
ao_deny com.facebook.katana WRITE_CONTACTS
ao_deny com.facebook.katana WRITE_EXTERNAL_STORAGE

echo -e $INFO Restricting FB Messenger Ability to track through AppOps...
ao_deny com.facebook.mlite GET_USAGE_STATS
ao_deny com.facebook.mlite RUN_IN_BACKGROUND
ao_deny com.facebook.mlite RUN_ANY_IN_BACKGROUND
ao_deny com.facebook.mlite START_FOREGROUND
ao_deny com.facebook.mlite WAKE_LOCK deny

echo -e $INFO Restricting UC Browser Ability to track...
ao_deny com.UCMobile.intl AUDIO_MEDIA_VOLUME
ao_deny com.UCMobile.intl CHANGE_WIFI_STATE
ao_deny com.UCMobile.intl COARSE_LOCATION
ao_deny com.UCMobile.intl FINE_LOCATION
ao_deny com.UCMobile.intl LEGACY_STORAGE
ao_deny com.UCMobile.intl MONITOR_LOCATION
ao_deny com.UCMobile.intl READ_CLIPBOARD
ao_deny com.UCMobile.intl READ_DEVICE_IDENTIFIERS
ao_deny com.UCMobile.intl READ_EXTERNAL_STORAGE
ao_deny com.UCMobile.intl SYSTEM_ALERT_WINDOW
ao_deny com.UCMobile.intl TOAST_WINDOW
ao_deny com.UCMobile.intl VIBRATE
ao_deny com.UCMobile.intl WAKE_LOCK
ao_deny com.UCMobile.intl WIFI_SCAN
ao_deny com.UCMobile.intl WRITE_CLIPBOARD
ao_deny com.UCMobile.intl WRITE_EXTERNAL_STORAGE
ao_deny com.UCMobile.intl WRITE_SETTINGS deny

echo -e $INFO Restricting Various apps Ability to track...
ao_deny com.dts.freefireth RUN_ANY_IN_BACKGROUND
ao_deny com.tencent.ig RUN_ANY_IN_BACKGROUND
ao_deny com.eights.pool.ball.night WRITE_EXTERNAL_STORAGE deny

ao_deny com.android.calculator READ_CLIPBOARD
ao_deny com.android.calculator RUN_ANY_IN_BACKGROUND deny

ao_deny com.andromo.dev445584.app545102 WAKE_LOCK
ao_deny com.andromo.dev445584.app545102 TOAST_WINDOW
ao_deny com.andromo.dev445584.app545102 READ_EXTERNAL_STORAGE
ao_deny com.andromo.dev445584.app545102 WRITE_EXTERNAL_STORAGE
ao_deny com.andromo.dev445584.app545102 RUN_ANY_IN_BACKGROUND
ao_deny com.andromo.dev445584.app545102 START_FOREGROUND deny

echo -e "$INFO Restricting Facebook Ability to track by denying ALL (hidden) permission using PM..."
echo -e $WARN Expect this to fail a lot, its ok to ignore it, but you might be less-protected.
pm_deny com.facebook.katana com.android.vending.BILLING
pm_deny com.facebook.katana android.permission.BLUETOOTH
pm_deny com.facebook.katana android.permission.BLUETOOTH_ADMIN
pm_deny com.facebook.katana android.permission.CALL_PHONE
pm_deny com.facebook.katana android.permission.ACCESS_COARSE_LOCATION
pm_deny com.facebook.katana android.permission.WAKE_LOCK
pm_deny com.facebook.katana android.permission.VIBRATE
pm_deny com.facebook.katana android.permission.READ_CONTACTS
pm_deny com.facebook.katana android.permission.WRITE_CONTACTS
pm_deny com.facebook.katana android.permission.GET_ACCOUNTS
pm_deny com.facebook.katana android.permission.MANAGE_ACCOUNTS
pm_deny com.facebook.katana android.permission.AUTHENTICATE_ACCOUNTS
pm_deny com.facebook.katana android.permission.READ_SYNC_SETTINGS
pm_deny com.facebook.katana android.permission.WRITE_SYNC_SETTINGS
pm_deny com.facebook.katana android.permission.ACCESS_FINE_LOCATION
pm_deny com.facebook.katana android.permission.ACCESS_NETWORK_STATE
pm_deny com.facebook.katana android.permission.BROADCAST_STICKY
pm_deny com.facebook.katana com.facebook.katana.provider.ACCESS
pm_deny com.facebook.katana com.facebook.orca.provider.ACCESS
pm_deny com.facebook.katana com.facebook.services.identity.FEO2
pm_deny com.facebook.katana com.facebook.mlite.provider.ACCESS
pm_deny com.facebook.katana com.facebook.pages.app.provider.ACCESS
pm_deny com.facebook.katana com.facebook.appmanager.UNPROTECTED_API_ACCESS
pm_deny com.facebook.katana android.permission.DOWNLOAD_WITHOUT_NOTIFICATION
pm_deny com.facebook.katana android.permission.NFC
pm_deny com.facebook.katana android.permission.CAMERA
pm_deny com.facebook.katana android.permission.RECORD_AUDIO
pm_deny com.facebook.katana android.permission.WRITE_EXTERNAL_STORAGE
pm_deny com.facebook.katana com.facebook.permission.prod.FB_APP_COMMUNICATION
pm_deny com.facebook.katana android.permission.READ_PHONE_NUMBERS
pm_deny com.facebook.katana android.permission.READ_PHONE_STATE
pm_deny com.facebook.katana android.permission.READ_CALENDAR
pm_deny com.facebook.katana android.permission.WRITE_CALENDAR
pm_deny com.facebook.katana android.permission.MODIFY_AUDIO_SETTINGS
pm_deny com.facebook.katana android.permission.READ_PROFILE
pm_deny com.facebook.katana android.permission.CHANGE_NETWORK_STATE
pm_deny com.facebook.katana android.permission.CHANGE_WIFI_STATE
pm_deny com.facebook.katana android.permission.SYSTEM_ALERT_WINDOW
pm_deny com.facebook.katana com.google.android.providers.gsf.permission.READ_GSERVICES
pm_deny com.facebook.katana android.permission.RECEIVE_BOOT_COMPLETED
pm_deny com.facebook.katana android.permission.GET_TASKS
pm_deny com.facebook.katana android.permission.USE_BIOMETRIC
pm_deny com.facebook.katana android.permission.USE_FINGERPRINT
pm_deny com.facebook.katana android.permission.FOREGROUND_SERVICE
pm_deny com.facebook.katana android.permission.INTERNET
pm_deny com.facebook.katana com.google.android.c2dm.permission.RECEIVE
pm_deny com.facebook.katana android.permission.READ_EXTERNAL_STORAGE
pm_deny com.facebook.katana android.permission.ACCESS_BACKGROUND_LOCATION
pm_deny com.facebook.katana com.facebook.katana.permission.CROSS_PROCESS_BROADCAST_MANAGER
pm_deny com.facebook.katana android.permission.BATTERY_STATS
pm_deny com.facebook.katana android.permission.ACCESS_WIFI_STATE
pm_deny com.facebook.katana com.android.launcher.permission.INSTALL_SHORTCUT
pm_deny com.facebook.katana com.facebook.receiver.permission.ACCESS
pm_deny com.facebook.katana com.sec.android.provider.badge.permission.READ
pm_deny com.facebook.katana com.sec.android.provider.badge.permission.WRITE
pm_deny com.facebook.katana com.htc.launcher.permission.READ_SETTINGS
pm_deny com.facebook.katana com.htc.launcher.permission.UPDATE_SHORTCUT
pm_deny com.facebook.katana com.sonyericsson.home.permission.BROADCAST_BADGE
pm_deny com.facebook.katana com.sonymobile.home.permission.PROVIDER_INSERT_BADGE
pm_deny com.facebook.katana com.facebook.katana.permission.RECEIVE_ADM_MESSAGE
pm_deny com.facebook.katana com.amazon.device.messaging.permission.RECEIVE
pm_deny com.facebook.katana com.nokia.pushnotifications.permission.RECEIVE
pm_deny com.facebook.katana com.facebook.katana.permission.CREATE_SHORTCUT
pm_deny com.facebook.katana android.permission.USE_FULL_SCREEN_INTENT

echo -e "$INFO Restricting \"Galaxy Store\" ability to track users by denying ALL (hidden) permission using PM..."
echo -e "$WARN Expect this to fail a lot, its ok to ignore it."
pm_deny com.sec.android.app.samsungapps android.permission.ACCESS_NETWORK_STATE
pm_deny com.sec.android.app.samsungapps android.permission.ACCESS_WIFI_STATE
pm_deny com.sec.android.app.samsungapps android.permission.BLUETOOTH
pm_deny com.sec.android.app.samsungapps android.permission.BLUETOOTH_ADMIN
pm_deny com.sec.android.app.samsungapps android.permission.CHANGE_COMPONENT_ENABLED_STATE
pm_deny com.sec.android.app.samsungapps android.permission.CHANGE_NETWORK_STATE
pm_deny com.sec.android.app.samsungapps android.permission.CHANGE_WIFI_STATE
pm_deny com.sec.android.app.samsungapps android.permission.DELETE_PACKAGES
pm_deny com.sec.android.app.samsungapps android.permission.FOREGROUND_SERVICE
pm_deny com.sec.android.app.samsungapps android.permission.GET_ACCOUNTS
pm_deny com.sec.android.app.samsungapps android.permission.GET_ACCOUNTS_PRIVILEGED
pm_deny com.sec.android.app.samsungapps android.permission.GET_PACKAGE_SIZE
pm_deny com.sec.android.app.samsungapps android.permission.GET_TASKS
pm_deny com.sec.android.app.samsungapps android.permission.INSTALL_PACKAGES
pm_deny com.sec.android.app.samsungapps android.permission.INTERACT_ACROSS_USERS
pm_deny com.sec.android.app.samsungapps android.permission.INTERNET
pm_deny com.sec.android.app.samsungapps android.permission.NFC
pm_deny com.sec.android.app.samsungapps android.permission.PACKAGE_USAGE_STATS
pm_deny com.sec.android.app.samsungapps android.permission.QUERY_ALL_PACKAGES
pm_deny com.sec.android.app.samsungapps android.permission.READ_EXTERNAL_STORAGE
pm_deny com.sec.android.app.samsungapps android.permission.READ_PHONE_STATE
pm_deny com.sec.android.app.samsungapps android.permission.READ_PRIVILEGED_PHONE_STATE
pm_deny com.sec.android.app.samsungapps android.permission.READ_SEARCH_INDEXABLES
pm_deny com.sec.android.app.samsungapps android.permission.RECEIVE_BOOT_COMPLETED
pm_deny com.sec.android.app.samsungapps android.permission.REQUEST_INSTALL_PACKAGES
pm_deny com.sec.android.app.samsungapps android.permission.SET_PROCESS_LIMIT
pm_deny com.sec.android.app.samsungapps android.permission.START_ACTIVITIES_FROM_BACKGROUND
pm_deny com.sec.android.app.samsungapps android.permission.SUBSTITUTE_SHARE_TARGET_APP_NAME_AND_ICON
pm_deny com.sec.android.app.samsungapps android.permission.SYSTEM_ALERT_WINDOW
pm_deny com.sec.android.app.samsungapps android.permission.UPDATE_APP_OPS_STATS
pm_deny com.sec.android.app.samsungapps android.permission.VIBRATE
pm_deny com.sec.android.app.samsungapps android.permission.WAKE_LOCK
pm_deny com.sec.android.app.samsungapps android.permission.WIFI_LOCK
pm_deny com.sec.android.app.samsungapps android.permission.WRITE_APN_SETTINGS
pm_deny com.sec.android.app.samsungapps android.permission.WRITE_EXTERNAL_STORAGE
pm_deny com.sec.android.app.samsungapps android.permission.WRITE_INTERNAL_STORAGE
pm_deny com.sec.android.app.samsungapps android.permission.WRITE_SECURE_SETTINGS
pm_deny com.sec.android.app.samsungapps android.permission.WRITE_SETTINGS
pm_deny com.sec.android.app.samsungapps com.android.launcher.permission.INSTALL_SHORTCUT
pm_deny com.sec.android.app.samsungapps com.android.launcher.permission.UNINSTALL_SHORTCUT
pm_deny com.sec.android.app.samsungapps com.asus.msa.SupplementaryDID.ACCESS
pm_deny com.sec.android.app.samsungapps com.google.android.c2dm.permission.RECEIVE
pm_deny com.sec.android.app.samsungapps com.google.android.gms.permission.AD_ID
pm_deny com.sec.android.app.samsungapps com.msc.openprovider.OpenContentProvider.READ_CONTENT
pm_deny com.sec.android.app.samsungapps com.netflix.partner
pm_deny com.sec.android.app.samsungapps com.samsung.android.app.cocktailbarservice.permission.ENABLE_EDGE_PANEL
pm_deny com.sec.android.app.samsungapps com.samsung.android.app.spage.permission.READ_CARD_DATA
pm_deny com.sec.android.app.samsungapps com.samsung.android.app.spage.permission.WRITE_CARD_DATA
pm_deny com.sec.android.app.samsungapps com.samsung.android.bixby.agent.permission.READ_PUBLIC_SETTINGS
pm_deny com.sec.android.app.samsungapps com.samsung.android.game.gamehome.accesspermission.REQUEST_REWARDS
pm_deny com.sec.android.app.samsungapps com.samsung.android.game.gametools.permission.READ_KT_PLAY_GAMES
pm_deny com.sec.android.app.samsungapps com.samsung.android.gearplugin.permission.ACCESS_GEAR_PLUGIN
pm_deny com.sec.android.app.samsungapps com.samsung.android.iap.permission.BILLING
pm_deny com.sec.android.app.samsungapps com.samsung.android.launcher.permission.READ_SETTINGS
pm_deny com.sec.android.app.samsungapps com.samsung.android.mas.setting.ContentProvider.READ_VALUE
pm_deny com.sec.android.app.samsungapps com.samsung.android.permission.installApp
pm_deny com.sec.android.app.samsungapps com.samsung.android.rubin.app.ui.permission.LAUNCH_RUBIN_SETTING
pm_deny com.sec.android.app.samsungapps com.samsung.android.rubin.context.permission.READ_CONTEXT_MANAGER
pm_deny com.sec.android.app.samsungapps com.samsung.android.rubin.persona.permission.READ_PERSONA_MANAGER
pm_deny com.sec.android.app.samsungapps com.samsung.android.samsungaccount.permission.PROFILE_PROVIDER
pm_deny com.sec.android.app.samsungapps com.samsung.android.security.permission.SAMSUNG_KEYSTORE_PERMISSION
pm_deny com.sec.android.app.samsungapps com.samsung.android.stickercenter.permission.sticker.READ
pm_deny com.sec.android.app.samsungapps com.samsung.android.stickercenter.service.ACCESS
pm_deny com.sec.android.app.samsungapps com.samsung.kidshome.broadcast.DEFAULT_HOME_CHANGE_PERMISSION
pm_deny com.sec.android.app.samsungapps com.samsung.sea.retailagent.permission.RETAILMODE
pm_deny com.sec.android.app.samsungapps com.sec.android.app.clockpackage.permission.ACCESS_CELEB_VOICE
pm_deny com.sec.android.app.samsungapps com.sec.android.app.clockpackage.permission.READ_CELEB_VOICE
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.ACCOUNT_ACTIVITY
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.BILLING_ACTIVITY
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.CONTENT_ACTIVITY
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.COUNTRYSERACHEX_SERVICE
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.GENERNAL_ACTIVITY
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.HUN_EVENT
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.PURCHASE_PROTECTION_SERVICE
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.accesspermission.UPDATE_EXISTS
pm_deny com.sec.android.app.samsungapps com.sec.android.app.samsungapps.permission.DDI
pm_deny com.sec.android.app.samsungapps com.sec.android.fota.permission.PUSH
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.badge.permission.READ
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.badge.permission.WRITE
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.samsungapps.permission.READ
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.samsungapps.permission.WRITE
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.una.astore.permission.READ
pm_deny com.sec.android.app.samsungapps com.sec.android.provider.una.astore.permission.WRITE
pm_deny com.sec.android.app.samsungapps com.sec.android.wallet.permission
pm_deny com.sec.android.app.samsungapps com.sec.spp.permission.TOKEN_2e584d01f317fdee32cc8e855153d01df2a62f8194c5c4e621bf45bcc3807f066f637c5329f12f95158279f36aae6250df4a72e8d51fc6e578e248fcf11e8339654d20216c79a9d36fed33741d7190e77939da234b8157e48c3cdde7bc93bffdba1de18b6415d62b81b8d2dd41756f099ecb13fc4d975077a6d8cde99df4405b
pm_deny com.sec.android.app.samsungapps com.sec.spp.push.permission.ACCESS_SPP_SERVER
pm_deny com.sec.android.app.samsungapps freemme.permission.msa
pm_deny com.sec.android.app.samsungapps sstream.app.StoryProvider.WRITE.PERMISSION

echo -e "$INFO Restricting Samsung's \"Customization Service\" Ability to track by denying ALL (hidden) permission using PM..."
echo -e $WARN Expect this to fail a lot, its ok to ignore it.
pm_deny com.samsung.android.rubin.app android.permission.ACCESS_BACKGROUND_LOCATION
pm_deny com.samsung.android.rubin.app android.permission.ACCESS_COARSE_LOCATION
pm_deny com.samsung.android.rubin.app android.permission.ACCESS_FINE_LOCATION
pm_deny com.samsung.android.rubin.app android.permission.ACCESS_NETWORK_STATE
pm_deny com.samsung.android.rubin.app android.permission.ACCESS_WIFI_STATE
pm_deny com.samsung.android.rubin.app android.permission.ACTIVITY_RECOGNITION
pm_deny com.samsung.android.rubin.app android.permission.BLUETOOTH
pm_deny com.samsung.android.rubin.app android.permission.BLUETOOTH_ADMIN
pm_deny com.samsung.android.rubin.app android.permission.CHANGE_WIFI_STATE
pm_deny com.samsung.android.rubin.app android.permission.GET_ACCOUNTS
pm_deny com.samsung.android.rubin.app android.permission.INTERNET
pm_deny com.samsung.android.rubin.app android.permission.MEDIA_CONTENT_CONTROL
pm_deny com.samsung.android.rubin.app android.permission.PACKAGE_USAGE_STATS
pm_deny com.samsung.android.rubin.app android.permission.PROCESS_OUTGOING_CALLS
pm_deny com.samsung.android.rubin.app android.permission.READ_CALENDAR
pm_deny com.samsung.android.rubin.app android.permission.READ_CALL_LOG
pm_deny com.samsung.android.rubin.app android.permission.READ_CONTACTS
pm_deny com.samsung.android.rubin.app android.permission.READ_EXTERNAL_STORAGE
pm_deny com.samsung.android.rubin.app android.permission.READ_PRIVILEGED_PHONE_STATE
pm_deny com.samsung.android.rubin.app android.permission.READ_SMS
pm_deny com.samsung.android.rubin.app android.permission.REAL_GET_TASKS
pm_deny com.samsung.android.rubin.app android.permission.RECEIVE_BOOT_COMPLETED
pm_deny com.samsung.android.rubin.app android.permission.SET_ACTIVITY_WATCHER
pm_deny com.samsung.android.rubin.app android.permission.SYSTEM_ALERT_WINDOW
pm_deny com.samsung.android.rubin.app android.permission.WAKE_LOCK
pm_deny com.samsung.android.rubin.app android.permission.WRITE_EXTERNAL_STORAGE
pm_deny com.samsung.android.rubin.app com.android.browser.permission.READ_HISTORY_BOOKMARKS
pm_deny com.samsung.android.rubin.app com.google.android.c2dm.permission.RECEIVE
pm_deny com.samsung.android.rubin.app com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE
pm_deny com.samsung.android.rubin.app com.msc.openprovider.OpenContentProvider.READ_CONTENT
pm_deny com.samsung.android.rubin.app com.samsung.accessory.permission.ACCESSORY_FRAMEWORK
pm_deny com.samsung.android.rubin.app com.samsung.android.bixby.agent.permission.READ_LANGUAGE
pm_deny com.samsung.android.rubin.app com.samsung.android.bixby.bridge.provision.integrated.READ_PERMISSION
pm_deny com.samsung.android.rubin.app com.samsung.android.cf.permission.ACCESS_CF_GEN
pm_deny com.samsung.android.rubin.app com.samsung.android.gearoplugin.provider.Settings.READ
pm_deny com.samsung.android.rubin.app com.samsung.android.hostmanager.permission.ACCESS_WEARABLE_STATE
pm_deny com.samsung.android.rubin.app com.samsung.android.hostmanager.permission.CONTROL_WEARABLE_STATUS
pm_deny com.samsung.android.rubin.app com.samsung.android.launcher.permission.READ_SETTINGS
pm_deny com.samsung.android.rubin.app com.samsung.android.mas.setting.ContentProvider.READ_VALUE
pm_deny com.samsung.android.rubin.app com.samsung.android.mobileservice.profile.READ
pm_deny com.samsung.android.rubin.app com.samsung.android.oneconnect.permission.READ_CLOUD_LOCATION_PROVIDER
pm_deny com.samsung.android.rubin.app com.samsung.android.providers.context.permission.WRITE_USE_APP_FEATURE_SURVEY
pm_deny com.samsung.android.rubin.app com.samsung.android.providers.media.CMH
pm_deny com.samsung.android.rubin.app com.samsung.android.providers.media.READ
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.app.ui.permission.LAUNCH_RUBIN_SETTING
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.context.permission.READ_CONTEXT_MANAGER
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.context.permission.READ_PERSONA_MANAGER
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.context.permission.WRITE_CONTEXT_MANAGER
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.debugmode.ACCESS_DEBUG_MODE
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.inferenceengine.datalogging.LOG_WRITE
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.lib.READ
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.lib.WRITE
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.persona.permission.READ_PERSONA_MANAGER
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.persona.permission.WRITE_PERSONA_MANAGER
pm_deny com.samsung.android.rubin.app com.samsung.android.rubin.profile.permission.REQUEST_KIDSMODE_INFO_RUBIN
pm_deny com.samsung.android.rubin.app com.samsung.android.sf.permission.ACCESS_SF_GEN
pm_deny com.samsung.android.rubin.app com.samsung.cmh.data.READ
pm_deny com.samsung.android.rubin.app com.samsung.cmh.data.WRITE
pm_deny com.samsung.android.rubin.app com.samsung.cmh.SKIPHEAVY
pm_deny com.samsung.android.rubin.app com.samsung.cmh.START
pm_deny com.samsung.android.rubin.app com.samsung.WATCH_APP_TYPE.Companion
pm_deny com.samsung.android.rubin.app com.samsung.wmanager.ENABLE_NOTIFICATION
pm_deny com.samsung.android.rubin.app com.sec.android.app.clockpackage.permission.READ_ALARM
pm_deny com.samsung.android.rubin.app com.sec.android.app.sbrowser.permission.QUICKACCESS
pm_deny com.samsung.android.rubin.app com.sec.android.app.sbrowser.permission.READ_MOST_VISITED_SITES
pm_deny com.samsung.android.rubin.app com.sec.android.diagmonagent.permission.DIAGMON
pm_deny com.samsung.android.rubin.app com.sec.spp.permission.TOKEN_25059dfec3f0a8ba2c46083cf1b6a800f6b25f3cc9ae91093f4bbf139a95073a08d34d5a59806e31f73d09e6c3b4a4d6f960ee22b8aa92e0ae0b4c0e2e811edf29b49aaf8d086a6e4423174619bb38c3b8fdb8cf2fe5175cf4c970d20f06ac6faf2e0526f7e6da89bd1b567cf7af0b135c930ee518e9d4f17628fac7ed20cb4d
pm_deny com.samsung.android.rubin.app sec.permission.RADIO_BASED_LOCATION
pm_deny com.samsung.android.rubin.app sec.permission.SAMSUNG_POSITIONING

echo -e "$INFO Disabling Samsung camera dependency"
echo -e "$INFO Fact: if you disable Samsung Camera's dependency, FilterProvider and StickerProvider, it can crash the camera app"
pm_disable com.samsung.android.provider.filterprovider
pm_disable com.samsung.android.provider.stickerprovider


















REM(){
# bash version (dont hope will run on android lmffaooooooo)
deny_perm2(){
	for ((i=0;i<${#app_ops[@]};++i));do
		echo appops set $1 ${app_ops[$i]} deny
	done
}
apps_RunInBg=(
	"simplehat.clicker"
	"org.zwanoo.android.speedtest"
	"com.samsung.android.game.gamehome"
	"com.samsung.android.game.gos"
	"com.sec.android.app.camera"
	"com.PoxelStudios.DudeTheftAuto"
	"com.apps.MyXL"
	"ua.com.streamsoft.pingtools"
	"com.samsung.android.stickercenter"
	"com.samsung.android.themestore"
	"com.sec.android.app.camera"
	"com.dumplingsandwich.portraitsketch"
)
apps_RunAInBg=(
	"simplehat.clicker"
	"org.zwanoo.android.speedtest"
	"com.samsung.android.game.gamehome"
	"com.samsung.android.game.gos"
	"com.sec.android.app.camera"
	"com.PoxelStudios.DudeTheftAuto"
	"com.apps.MyXL"
	"ua.com.streamsoft.pingtools"
	"com.samsung.android.stickercenter"
	"com.samsung.android.themestore"
	"com.sec.android.app.camera"
	"jp.snowlife01.android.optimization"
	"com.dumplingsandwich.portraitsketch"
)
apps_BootCompleted=(
	"simplehat.clicker"
	"org.zwanoo.android.speedtest"
	"com.samsung.android.game.gamehome"
	"com.samsung.android.game.gos"
	"com.sec.android.app.camera"
	"com.PoxelStudios.DudeTheftAuto"
	"com.apps.MyXL"
	"ua.com.streamsoft.pingtools"
	"com.samsung.android.stickercenter"
	"com.samsung.android.themestore"
	"com.sec.android.app.camera"
)

for i in ${!apps_RunInBg[@]};      do appops set ${apps_RunInBg[$i]}       RUN_IN_BACKGROUND     deny;done
for i in ${!apps_RunAInBg[@]};     do appops set ${apps_RunAInBg[$i]}      RUN_ANY_IN_BACKGROUND deny;done
for i in ${!apps_BootCompleted[@]};do appops set ${apps_BootCompleted[$i]} BOOT_COMPLETED        deny;done

#Facebook app permissions (21 ops)
app_ops=(
	"RUN_IN_BACKGROUND" 		 # Allow running in background (so facebook can spy on you).
	"RUN_ANY_IN_BACKGROUND"  # Allow running in background at any time (so facebook can spy on you. requires newer Android API).
	"BOOT_COMPLETED"				 # Allow running after boot completed (to enable facebook to empower every tracking nonsense dodoo).
	"COARSE_LOCATION"				 # Allow Accessing coarse location (to give you 'relevant' nonsense).
	"FINE_LOCATION"					 # Allow Accessing fine location (to give you 'relevant' nonsense).
	"RECORD_AUDIO"					 # Allow using mic (so facebook can listen to anything whereever they wished for).
	"CAMERA"								 # Allow using camera (facebook will use this to capture your nudes ;p, which is eww).
	"CALL_PHONE"						 # Allow phone calling.
	"WRITE_CALENDAR"				 # Allow modifying calendar (to mess with your calendar).
	"READ_CALENDAR"					 # Allow read calendar events (to track your rotutinities).
	"WRITE_CONTACTS"				 # Allow modifying contact infos.
	"READ_CONTACTS"					 # Allow reading contact info (to track your relations with others).
	"READ_PHONE_STATE"			 # Allow tracking your phone crap
	"READ_EXTERNAL_STORAGE"	 # Allow reading external storage (facebook will read every single files, and uploads it automatically if its image file, which invades privacy so bad)
	"WRITE_EXTERNAL_STORAGE" # Allow modifying contact info (facebook will write your friend contact there, soo annonying...).
	"GET_ACCOUNTS"					 # Allow getting account info (to track what other apps you using, and steal its id and sell to advertisers)
	"READ_PHONE_NUMBERS"		 # Allow reading phone numbers  (to track user, give ads, and match facebook friends)
	"READ_CONTACTS"					 # Allow reading contacts (same as above)
	"WAKE_LOCK"							 # Prevent phone from sleeping (so facebook can keep their users "engaged" with their stupid advertising tracking nonsense)
	"GET_USAGE_STATS"				 # Allow accessing usage statictics (to track user behaviour)
	"READ_CLIPBOARD"				 # Allow reading clipboard (to steal a clipboard)
)
deny_perm2 com.facebook.katana



}


















