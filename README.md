## NJASD (Not Just Another System Debloater)
Set up your Android device in your own way!

## Features:
- Remove bloat (ofcourse it is because why not right? :D. root/delete,no root/uninstall,android below 8/disable).
- Install your preferred app (put your apk in "Install_Apps" folder).
- Install FOSS alternative apps (TODO).
- Deny packages permission and opreations (if you use "important" apps that you wont remove but worrying about privacy, or important system apps that cant be removed or will cause issues).
- Wreck tracking XML properties (root-only, Experimental!! use at your own risk)
- Disable bloat (instead of removing it).
- Cache cleaning (well... this cleans wayy more than it should, so i only recommend to use it after you backup, or if its your first custom rom setup with bunch of apps installed. TODO)

## Why i make this?
Because:
- no one created the all-in-one script that does more than debloat (should have more clear reason).
- I HATEE OEMS AND CARRIERS PUTTING ALOT OF BLOAT SHIIT
Notably Samsung (including alot of samsung's own software beside google, microsoft apps, facebook apps [with EXCLUSIVE tracking])
and Xiaomi (i dont have xiaomi phones, but i heard that they are putting alot of bloat, and tracking you so hard to give you ads, eww...)

these bloatwares are running in background, Invading our privacy by collecting data.
and sending ads (mostly through notification), eating my quota, Storage, CPU Cycle, RAM, and Battery Life.

## How to run the script?
- Clone this repo to your local storage (`git clone https://github.com/mdp43140/NJASD.git` or just download the zip, link not available yet for now)
- if you clone it by downloading the zip, extract it.
- Open your terminal and change your directory to path where you dropped NJASD.
- make sure you have adb (android-tools) installed.
- and just run `./njasd-linux.sh`


## Requirement:
Computer
- Linux (no windows here sorry lol, windows lacks required tools, and need to use PowerShell, which is a very" complicated commands).
- Bash 5 (idk about this one).
- ADB (very required tools)
	- Ubuntu/Debian: apt install android-sdk-platform-tools
Phone
- Developer options ON (tap "Build number" 7x in About section in your phone settings), and USB Debugging enabled.
- OEM Unlock (optional).
	- Root (optional).
- Some Android tools.
	- am (Application Manager, to force-stop apps, etc...)
	- appops (Application Opreation manager)
	- bu (Backup Utility, not required for now, for backup features, idk how this even works lol)
	- pm (Package Manager, core utility to uninstall, manage permission, query installed packages, etc...)
- Some Linux tools
	- awk
	- sed (Stream Editor, generic Linux tools)
- shell (on the target Android phone) must be able to:
	- run scripts in internal storage (adb shell sh /sdcard/wreckthatbloat.sh).
	- had some bash features (functions(){}, files/{andFolders,queried,like}/this, etc...).

## Note (might be outdated):
- Important For Oppo/ColorOS users: You need to enable "Disable Permission Monitoring" in the Developer Options or appops won't work.
- Bloat removal will remove these related apps:
	- Facebook
	- LinkedIn
	- Samsung
	- Microsoft
- Make Sure that the file structure on your PC Working directory looks like this:
 ./njasd (NJASD base directory, where all required files would be here)
	/njasd_linux.sh (the main script)
	/Bloatware_List.txt (the bloatware lists)
	/Install_Apps (put your apks that is going to be installed in here, optional, no spaces or will fail)

### btw i have updated this readme in a while, so some things here might be wrong...
