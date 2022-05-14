#!/system/bin/sh
# Preparation
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

echo -e "$INFO You can run this on your phone terminal (/system/bin/sh /sdcard/njasd/WrenchTrackers/WrenchTrackers.sh)"
echo -e "$INFO just make sure to read the requirement on README.md file"

# Config
BASE_DIR_PHONE="/sdcard/njasd"
WRENCHTRACKER_DIR_PHONE="$BASE_DIR_PHONE/WrenchTrackers"

# Security mechanism to prevent overwriting wrong files (especially with su permission)
HOME="$WRENCHTRACKER_DIR_PHONE"
cd $HOME

# Helper functions
addXmlProp(){ #FileName,DataType,Name
	#but theres a problem, we cant just put it at the end... we need to put it in right place bruh (before </map>, or even might be worse...)
	#echo '<'$2' name="'$3'"></'$2'>' >> $1
}
modifyXmlValue(){ #Name,Value1,Value2,FileName. Modifies xml name value metadata
	su -c sed -i -E "s/name=\"$1\" value=\"$2\"/name=\"$1\" value=\"$3\"/g" $4
}
modifyInnerXmlValue(){ #Name,DataType,Value1,Value2,FileName. Modifies xml child metadata properties
	if [ "$1" = "" ];then
		su -c sed -i -E "s/>$3<\/$2>/>$4<\/$2>/g" $5
	else
		su -c sed -i -E "s/<$2 name=\"$1\">$3<\/$2>/<$2 name=\"$1\">$4<\/$2>/g" $5
	fi
}
removeTrackingUUID(){ #FileName,Name,UUIDType. Replace tracking UUIDs with zero (TODO: or random gibberish)
	local UUIDFormatDots
	local UUIDFormatZero
	case $3 in
		facebook_evadeAttempt_uuid)
			UUIDFormatDots="..........-....-....-....-............"
		;;
		22noStrip)
			UUIDFormatDots="......................"
		;;
		40noStrip)
			UUIDFormatDots="........................................"
		;;
		32noStrip)
			UUIDFormatDots="................................"
		;;
		64noStrip)
			UUIDFormatDots="................................................................"
		;;
		32strip|*) # default
			UUIDFormatDots="........-....-....-....-............"
		;;
	esac
	UUIDFormatZero="$(echo $UUIDFormatDots | sed 's/\./0/g')"
	modifyInnerXmlValue $2 string "$UUIDFormatDots" "$UUIDFormatZero" $1
}
# NO 69 allowed thanks! get outta here, fucking unluck porny shit!
replaceFile(){ #from,to. WIP
	su -c cat "$WRENCHTRACKER_DIR_PHONE/$1.xml" > $2
}
removeDuplicate(){
 #su -c awk '!(c[$0]++)' $1 > $1.new
 #cat "$1.new" | su -c tee $1 > /dev/null
}
# Wrencher
# Why \\\\\\\\ instead of just \ ?
# you dont know dood, adb+su asks 8 of em! hell even more than that if you need more than 1 \s!!!
for i in /data/data/*/shared_prefs/_HANSEL_FILTERS_SP.xml;do
	echo -e "$INFO Wrenching $i... (Hansel)"
 #bruh hansel is too much on obfuscation here... sussy wussy if u ask me ofcourse since this also ON MY SIM COMPANION APP THAT I USE!!
 #i hate annonying unfixable ampersand bug on stupid simple shell
 #modifyInnerXmlValue 'app_version' string '\{.+\}' '\{&quot;id&quot;:&quot;app_version&quot;,&quot;value&quot;:&quot;0&quot;,&quot;type&quot;:&quot;string&quot;\}<\/string>/g' $i
 #modifyInnerXmlValue 'device_model' string '\{.+\}' '\{&quot;id&quot;:&quot;device_model&quot;,&quot;value&quot;:&quot;generic&quot;,&quot;type&quot;:&quot;string&quot;\}<\/string>' $i
 #modifyInnerXmlValue 'device_manufacturer' string '\{.+\}' '\{&quot;id&quot;:&quot;device_manufacturer&quot;,&quot;value&quot;:&quot;generic&quot;,&quot;type&quot;:&quot;string&quot;\}<\/string>' $i
 #modifyInnerXmlValue '#\$user_id' string '\{.+\}' '\{&quot;id&quot;:&quot;#$user_id&quot;,&quot;value&quot;:&quot;0000000000&quot;,&quot;type&quot;:&quot;string&quot;\}<\/string>' $i
 #modifyInnerXmlValue 'os_version' string '\{.+\}' '\{&quot;id&quot;:&quot;os_version&quot;,&quot;value&quot;:&quot;-1&quot;,&quot;type&quot;:&quot;string&quot;\}<\/string>' $i
done
for i in /data/data/*/shared_prefs/_HANSEL_TRACKER_SP.xml;do
	echo -e "$INFO Wrenching $i... (Hansel)"
	modifyInnerXmlValue 'BRANCH_TRACKER_TIMESTAMP' long '\d+' '0' $i
done
for i in /data/data/*/shared_prefs/adjust_preferences.xml;do
	echo -e "$INFO Wrenching $i... (Adjust)"
	replaceFile adjust_preferences "$i"
done
for i in /data/data/*/shared_prefs/com.applovin.sdk.1.xml;do
	echo -e "$INFO Wrenching $i... (AppLovin.Ads)"
	modifyInnerXmlValue '' string 'https?:\/\/.+' 'http:\/\/127.0.0.1' $i
	modifyXmlValue "is_verbose_logging" true false "$i"
done
for i in /data/data/*/shared_prefs/com.applovin.sdk.impl.postbackQueue.domain.xml;do
	echo -e "$INFO Wrenching $i... (AppLovin.Tracking)"
 #Shame on AppLovin for their ridicilous tracking (this giant 'sanitized' mess below will replace all possible tracking vector with fake data instead)
	modifyInnerXmlValue "" string '\{.+\}' '\{\&quot;uniqueId\&quot;:\&quot;00000000-0000-0000-0000-000000000000\&quot;,\&quot;communicatorRequestId\&quot;:\&quot;\&quot;,\&quot;targetUrl\&quot;:\&quot;http:\\\/\\\/127.0.0.1\&quot;,\&quot;backupUrl\&quot;:\&quot;http:\\\/\\\/127.0.0.1\&quot;,\&quot;isEncodingEnabled\&quot;:true,\&quot;attemptNumber\&quot;:999,\&quot;parameters\&quot;:\{\&quot;orientation_lock\&quot;:\&quot;unknown\&quot;,\&quot;lm\&quot;:\&quot;false\&quot;,\&quot;api_level\&quot;:\&quot;0\&quot;,\&quot;tv\&quot;:\&quot;false\&quot;,\&quot;tds\&quot;:\&quot;0\&quot;,\&quot;app_version\&quot;:\&quot;0\&quot;,\&quot;is_tablet\&quot;:\&quot;false\&quot;,\&quot;adns\&quot;:\&quot;0\&quot;,\&quot;aida\&quot;:\&quot;true\&quot;,\&quot;lmt\&quot;:\&quot;0\&quot;,\&quot;applovin_random_token\&quot;:\&quot;00000000-0000-0000-0000-000000000000\&quot;,\&quot;api_did\&quot;:\&quot;\&quot;,\&quot;tz_offset\&quot;:\&quot;0.0\&quot;,\&quot;ia\&quot;:\&quot;0\&quot;,\&quot;model\&quot;:\&quot;generic\&quot;,\&quot;brand\&quot;:\&quot;generic\&quot;,\&quot;hardware\&quot;:\&quot;generic\&quot;,\&quot;server_installed_at\&quot;:\&quot;\&quot;,\&quot;rat\&quot;:\&quot;0\&quot;,\&quot;af\&quot;:\&quot;0\&quot;,\&quot;bt_ms\&quot;:\&quot;0\&quot;,\&quot;test_ads\&quot;:\&quot;0\&quot;,\&quot;brand_name\&quot;:\&quot;generic\&quot;,\&quot;dnt\&quot;:\&quot;true\&quot;,\&quot;adr\&quot;:\&quot;0\&quot;,\&quot;revision\&quot;:\&quot;generic\&quot;,\&quot;mute_switch\&quot;:\&quot;0\&quot;,\&quot;volume\&quot;:\&quot;0\&quot;,\&quot;country_code\&quot;:\&quot;XX\&quot;,\&quot;adnsd\&quot;:\&quot;0\&quot;,\&quot;vs\&quot;:\&quot;false\&quot;,\&quot;current_retry_attempt\&quot;:\&quot;0\&quot;,\&quot;plugin_version\&quot;:\&quot;0\&quot;,\&quot;screen_size_in\&quot;:\&quot;0\&quot;,\&quot;fm\&quot;:\&quot;0\&quot;,\&quot;fs\&quot;:\&quot;0\&quot;,\&quot;postback_ts\&quot;:\&quot;0\&quot;,\&quot;platform\&quot;:\&quot;linux\&quot;,\&quot;sb\&quot;:\&quot;0\&quot;,\&quot;sc\&quot;:\&quot;\&quot;,\&quot;installer_name\&quot;:\&quot;null\&quot;,\&quot;sim\&quot;:\&quot;0\&quot;,\&quot;kb\&quot;:\&quot;en_US\&quot;,\&quot;sdk_version\&quot;:\&quot;0.0.0\&quot;,\&quot;event\&quot;:\&quot;null\&quot;,\&quot;xdpi\&quot;:\&quot;0\&quot;,\&quot;sc3\&quot;:\&quot;\&quot;,\&quot;debug\&quot;:\&quot;false\&quot;,\&quot;sc2\&quot;:\&quot;\&quot;,\&quot;os\&quot;:\&quot;0\&quot;,\&quot;lpm\&quot;:\&quot;0\&quot;,\&quot;compass_random_token\&quot;:\&quot;00000000-0000-0000-0000-000000000000\&quot;,\&quot;carrier\&quot;:\&quot;null\&quot;,\&quot;gy\&quot;:\&quot;false\&quot;,\&quot;tg\&quot;:\&quot;0\&quot;,\&quot;package_name\&quot;:\&quot;null\&quot;,\&quot;tm\&quot;:\&quot;0\&quot;,\&quot;mediation_provider\&quot;:\&quot;null\&quot;,\&quot;ydpi\&quot;:\&quot;0\&quot;,\&quot;ts\&quot;:\&quot;0\&quot;,\&quot;font\&quot;:\&quot;0.0\&quot;\},\&quot;httpHeaders\&quot;:\{\},\&quot;requestBody\&quot;:\{\&quot;applovin_sdk_super_properties\&quot;:\{\}\}\}' $i
 #Remove dupes created by command above.
 #not recommended for now... (file permission might be reset, which suck on Android. altough after testing, it didn't happen)
	removeDuplicate $i
done
for i in /data/data/*/shared_prefs/com.applovin.sdk.preferences.*.xml;do #
	echo -e "$WARN $i (TODO)"
done
for i in /data/data/*/shared_prefs/com.applovin.sdk.shared.xml;do
	echo -e "$INFO Wrenching $i... (AppLovin.Ads)"
	removeTrackingUUID "$i" com.applovin.sdk.applovin_random_token
	removeTrackingUUID "$i" com.applovin.sdk.compass_random_token
done
for i in /data/data/*/shared_prefs/com.crashlytics.prefs.xml;do
	echo -e "$INFO Wrenching $i... (Google.Crashlytics)"
	removeTrackingUUID "$i" crashlytics.advertising.id
	removeTrackingUUID "$i" crashlytics.installation.id
done
for i in /data/data/*/shared_prefs/com.crashlytics.sdk.android:answers:settings.xml;do
	echo -e "$INFO Wrenching $i... (Google.Crashlytics)"
	modifyXmlValue "analytics_launched" true false "$i"
done
for i in /data/data/*/shared_prefs/com.dynatrace.android.dtxPref.xml;do
	echo -e "$INFO Wrenching $i... (DynaTrace.DataBroker)"
	modifyXmlValue "DTXDataCollectionLevel" '.+' 'NONE' "$i"
	modifyXmlValue "DTXNewVisitorSent" true false "$i"
	modifyXmlValue "DTXOptInCrashes" true false "$i"
done
for i in /data/data/*/shared_prefs/com.google.android.gms.measurement.prefs.xml;do
	echo -e "$INFO Wrenching $i... (Google.AppMeasurement)"
	modifyXmlValue "last_upload" '\d+' 0 "$i"
	modifyXmlValue "first_open_time" '\d+' 0 "$i"
	modifyXmlValue "deferred_analytics_collection" false true "$i"
	modifyXmlValue "use_service" true false "$i"
	modifyXmlValue "health_monitor:start" '\d+' 0 "$i"
	modifyXmlValue "health_monitor:count" '\d+' 0 "$i"
	removeTrackingUUID "$i" app_instance_id '32nostrip'
done
for i in /data/data/*/shared_prefs/com.google.android.gms.appid.xml;do
	echo -e "$INFO Wrenching $i... (Google.measurement.AppID)"
	replaceFile blank "$i"
done
for i in /data/data/*/shared_prefs/com.google.firebase.crashlytics.xml;do
	echo -e "$INFO Wrenching $i... (Google.Firebase.Crashlytics)"
	removeTrackingUUID "$i" firebase.installation.id '22noStrip'
	removeTrackingUUID "$i" crashlytics.installation.id '40noStrip'
done
for i in /data/data/*/shared_prefs/com.facebook.sdk.appEventPreferences.xml;do
	echo -e "$INFO Wrenching $i... (Facebook.Tracking_Profiling)"
	modifyXmlValue "kitsBitmmask" '\d+' -1 "$i"
	modifyXmlValue "is_referrer_updated" true false "$i"
	removeTrackingUUID "$i" 'PCKGCHKSUM;.+' '32noStrip'
	removeTrackingUUID "$i" anonymousAppDeviceGUID facebook_evadeAttempt_uuid
done
for i in /data/data/*/shared_prefs/com.facebook.sdk.attributionTracking.xml;do
	echo -e "$INFO Wrenching $i... (Facebook.Tracking_Profiling)"
	removeTrackingUUID "$i" anonymousAppDeviceGUID facebook_evadeAttempt_uuid
done
for i in /data/data/*/shared_prefs/com.facebook.sdk.USER_SETTINGS.xml;do
	echo -e "$INFO Wrenching $i... (Facebook.Tracking_Profiling)"
	modifyXmlValue "com.facebook.sdk.USER_SETTINGS_BITMASK" '\d+' -1 "$i"
done
for i in /data/data/*/shared_prefs/com.fyber.unity.ads.OfferWallUnityActivity.xml;do
	echo -e "$INFO Wrenching $i... (Fyber.Advertising)"
 #Give a BIG FUCK to Fyber for stealing all of our quota for ads
	modifyXmlValue "precaching.enabled" true false "$i"
	modifyInnerXmlValue "app.id.key" string '\d+' 0 "$i"
	removeTrackingUUID "$i" user.id.key '40noStrip'
	removeTrackingUUID "$i" security.token.key
done
for i in /data/data/*/shared_prefs/com.medallia.*.xml;do #
	echo -e "$INFO Wrenching $i... (Medallia.Survey_Tracking_Profiling)"
	modifyInnerXmlValue "LAST_SDK_VERSION" string '\d+' 0.0.0 "$i"
	modifyInnerXmlValue "LOCAL_CONFIGURATION_TIMESTAMP" long '\d+' -1 "$i"
	modifyInnerXmlValue "API_TOKEN" string '.+' '' "$i"
	modifyInnerXmlValue "LAST_OS_VERSION" string '\d+' -1 "$i"
	modifyInnerXmlValue "LENNY" string '.+' '' "$i"
done
for i in /data/data/*/shared_prefs/com.google.firebase.*.xml;do #
	echo -e "$WARN $i (TODO)"
done
for i in /data/data/*/shared_prefs/FBAdPrefs.xml;do
	echo -e "$INFO Wrenching $i... (Facebook.Advertising)"
	modifyXmlValue "AppMinSdkVersion" '\d+' 9999 "$i"
 #name="AFP;{whatver version here to prevent sed from working properly but we outsmarted them}">{random 32 long tracking uid}</string>
	removeTrackingUUID "$i" nil '32nostrip'
done
for i in /data/data/*/shared_prefs/FirebaseAppHeartBeat.xml;do
	echo -e "$INFO Wrenching $i... (Google.Firebase)"
	modifyXmlValue "fire-global" '\d+' 0 "$i"
	modifyXmlValue "fire-iid" '\d+' 0 "$i"
	modifyXmlValue "fire-installations-id" '\d+' 0 "$i"
done
for i in /data/data/*/shared_prefs/fiverocks.xml;do
	echo -e "$INFO Wrenching $i... (FiveRocks.DataBroker)"
	removeTrackingUUID "$i" idfa
	modifyXmlValue 'fql' '\d+' 0 $i
	modifyXmlValue 'ss' '\d+' 0 $i
	modifyXmlValue 'std' '\d+' 0 $i
	modifyXmlValue 'slt' '\d+' 0 $i
	modifyXmlValue 'sld' '\d+' 0 $i
	modifyXmlValue 'it' '\d+' 0 $i
	modifyXmlValue 'fq' '\d+' 0 $i
	modifyXmlValue 'gcm.onServer' true false $i
	modifyXmlValue 'idfa.optout' false true $i
done
for i in /data/data/*/shared_prefs/FyberPreferences.xml;do
	echo -e "$INFO Wrenching $i... (Fyber.Tracking)"
	removeTrackingUUID "$i" STATE_GENERATED_USERID_KEY '40noStrip'
done
for i in /data/data/*/shared_prefs/fyber*.xml;do #
	echo -e "$WARN $i (TODO)"
done
for i in /data/data/*/shared_prefs/tjcPrefrences.xml;do
	echo -e "$INFO Wrenching $i... (TapJoy.Tracking)"
	removeTrackingUUID "$i" tapjoyAnalyticsId
	removeTrackingUUID "$i" tapjoyInstallId '64noStrip'
done
for i in /data/data/*/shared_prefs/TwitterAdvertisingInfoPreferences.xml;do
	echo -e "$INFO Wrenching $i... (Twitter.AdTracking)"
	modifyXmlValue "limit_ad_tracking_enabled" false true "$i"
	removeTrackingUUID "$i" advertising_id
done
#*some editing magic* $cache > $cache.new
#cat $cache.new > cache
#su -c "sed -i 's/OPT_IN=true/OPT_IN=false/g' $ANYTHING 2>/dev/null"

# Temporary dir cleanup (Finishing)
rm -rf "$WRENCHTRACKER_DIR_PHONE"