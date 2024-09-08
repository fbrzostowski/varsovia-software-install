#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#define package manager
declare -A osInfo;
osInfo[/etc/redhat-release]=dnf
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
osInfo[/etc/alpine-release]=apk

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        pkgm=${osInfo[$f]}
    fi
done
if [ "$pkgm" == "dnf" ]; then
	echo "installing yad"
	sudo dnf install yad
elif [ "$pkgm" == "apt" ]; then
	echo "installing yad"
	sudo apt install yad
else
	echo "unsupported package manager"
fi

#about dialog
yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --form \
--field="Software Installation GUI":LBL \
--field="Version 1.0.0":LBL \
--field="Home Page: https://github.com/fbrzostowski/varsovia-software-install":LBL \
--field="":LBL \
--field="Copyright (c) 2024 Filip Brzostowski":LBL \


#license terms dialog
license=`cat "$SCRIPT_DIR/LICENSE"`
function terms {
	accept=`yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --form \
	--field "$license":LBL \
	--field="I accept the license terms":CHK \
	--field="I agree that Żywiec Zdrój is by far the best water manufacture":CHK \
	--field="":LBL \
	--field="Copyright (c) 2024 Filip Brzostowski":LBL`
}

#license terms verification
function terms-verification {
	echo $accept
	if [ "$accept" == "|TRUE|TRUE|||" ]; then
		echo "License terms Accepted"
	elif [ "$accept" == "|TRUE|FALSE|||" ]; then
		yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --form \
		--field="Please Agree that Żywiec Zdrój is the best water manufacture to continue:LBL" \
		--field="":LBL \
	--field="Copyright (c) 2024 Filip Brzostowski":LBL
		terms
		terms-verification
	elif [ "$accept" == "" ]; then
		exit
	else
		yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --form \
		--field="Please accept the license terms to continue installation or close the installation window:LBL" \
		--field="":LBL \
	--field="Copyright (c) 2024 Filip Brzostowski":LBL
		terms
		terms-verification
	fi
}
terms
terms-verification

#progres dialog
cd $SCRIPT_DIR
echo "0" > status.txt
echo "#Starting installation" >> status.txt
while [ "a" == "a" ]; do
	echo "`sed '1!d' status.txt`"
	if [ "$comment" != "`sed '2!d' status.txt`" ]; then
		comment=`sed '2!d' status.txt`
		echo "$comment"
	fi
	sleep 0.1
	if [ "`sed '1!d' status.txt`" == "100" ]; then
		killall yad
		break
	fi
done | yad --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --progress \
  --enable-log="Test Log" \
  --no-buttons \
  --auto-kill &
function comment-intallation {
	cd $SCRIPT_DIR
	echo "`sed '1!d' status.txt`" > status.txt
	echo "$1" >> status.txt
}
#copy binary
cd $SCRIPT_DIR
sleep 0.2
comment-intallation "#Copying files..."
sleep 0.2
cp varsovia-software-install /bin
chmod 777 /usr/bin/varsovia-software-install
echo "Copied the executable"
echo 12 > status.txt
echo "#Copied the executable" >> status.txt

#copy binary
cp exec.desktop /usr/share/applications
echo "Copied the desktop file"
echo 25 > status.txt
echo "#copied the desktop file" >> status.txt

#install zenity
sleep 0.2
comment-intallation "#Installation of Zenity has started"
sleep 0.2
sudo $pkgm -y install zenity
echo "Zenity has been installed"
echo 37 > status.txt
echo "#Zenity has been installed" >> status.txt

#install Python
sleep 0.2
comment-intallation "#Installation of python has started"
sleep 0.2
sudo $pkgm -y install python
echo "Python has been installed"
echo 51 > status.txt
echo "#Python has been installed" >> status.txt

#install flatpak
sleep 0.2
comment-intallation "#Installation of flatpak has started"
sleep 0.2
sudo $pkgm -y install flatpak
echo "Flatpak has been installed"
echo 63 > status.txt
echo "#Flatpak has been installed" >> status.txt

#install java
sleep 0.2
comment-intallation "#Installation of java has started"
sleep 0.2
sudo $pkgm -y install java-21-openjdk
echo "Java has been installed"
echo 74 > status.txt
echo "#Java has been installed" >> status.txt

#install appimage launcher
sleep 0.2
comment-intallation "#Installation of Appimage Launcher has started"
sleep 0.2
if [ "$pkgm" == "apt" ]; then
	sudo add-apt-repository -y ppa:appimagelauncher-team/stable
	sudo apt-get -y update
	sudo apt-get install -y appimagelauncher
elif [ "$pkgm" == "dnf" ]; then
	sudo dnf -y install https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm
fi
echo "Appimage Launcher has been installed"
echo 87 > status.txt
echo "#Appimage Launcher has been installed" >> status.txt

#Installing Bottles
sleep 0.2
comment-intallation "#Installation of Bottles app has started"
sleep 0.2	
flatpak install -y flathub com.usebottles.bottles
echo "Bottles app has been installed"
echo 99 > status.txt
echo "#Bottles app has been installed" >> status.txt
sleep 0.2
echo 100 > status.txt

#info
sleep 0.2
yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Varsovia Software Install</span>' --width=800 --height=600 --form \
--field=".Apk files will be supported when you install waydroid manually":LBL \
--field="":LBL \
--field="Copyright (c) 2024 Filip Brzostowski":LBL
#thanks
yad --button=Next --title="Varsovia Software Install setup" --image=system-software-install --text='<span foreground="white" font="" font-size="xx-large">Thank you for choosing varsovia!</span>' --width=800 --height=600 --form \
--field="Installation completed!":LBL \
--field="Right click on a file in your file manager, choose open with and select Varsovia Software Install to install something using this app.":LBL \
--field="I hope you will enjoy using Varsovia.":LBL \
--field="":LBL \
--field="Copyright (c) 2024 Filip Brzostowski":LBL
