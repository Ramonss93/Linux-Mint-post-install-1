#!/bin/bash

if [ `id -u` -ne 0 ]; then
    printf "The script must be run as root!\n"
    exit 1
fi

# Flush commands to bash history immediately
export PROMPT_COMMAND='history -a'

# Adds a progressbar
TEMPFILE=/etc/apt/apt.conf.d/00newconftemp
echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar
# Do not ask for continue or new configurations
echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90yes
echo 'APT::Get::force-yes "true";' >> /etc/apt/apt.conf.d/90yes
echo -e 'Dpkg::Options {\n\t"--force-confdef";\n\t"--force-confnew";\n}' > $TEMPFILE

# Keep sudo
sudo_stat=.sudo_status.txt
trap 'rm -f $sudo_stat > /dev/null 2>&1' 0
trap "exit 2" 1 2 3 15

# Default variables
DEBIAN_FRONTEND=noninteractive
export BACKGROUND_PATH="$HOME/.config/trashware.png"
export REMOTE_PATH="http://trashwarecesena.it/laboratorio/background.png"

# Keyboard shortcuts
TASKMANAGER="[/]
action='mate-system-monitor'
binding='<Primary><Alt>Delete'
name='Task Manager'"
TASKMANAGER_PATH="/tmp/customShortcut"
su -c "echo -e \"$TASKMANAGER\" > $TASKMANAGER_PATH" - trashware

keep_sudo() {
	while [ -f $sudo_stat ];
	do
		sudo -v
		sleep 5
	done &
}

# Update
upgrade_system() {
	sudo apt-get -q update && sudo apt-get -f upgrade
	# If the command fail: try to uprade and dist-upgrade
	while [[ $? > 0 ]]; do
		sudo apt-get update && sudo apt-get -f upgrade
		sudo apt-get -f install && sudo apt-get -f upgrade
	done
}

# Install basic software
dist_upgrade() {
	sudo apt-get -f dist-upgrade
	while [[ $? > 0 ]]; do
		sudo apt-get update && sudo apt-get -f upgrade
		sudo apt-get -f install && sudo apt-get -f dist-upgrade
	done
	sudo apt-get install -f curl
	sudo apt-get purge apt-xapian-index
}

# Clean system
clean() {
	sudo apt-get autoclean
	sudo apt-get clean
	echo "vm.swappiness=10" >> /etc/sysctl.conf
	echo "CONCURRENCY=makefile" >> /etc/init.d/rc
}

sudo -v
keep_sudo
upgrade_system
dist_upgrade
clean

# Download the background
su -c "curl $REMOTE_PATH > $BACKGROUND_PATH" - trashware
# Set the background (scaled)
su -c "dconf write /org/mate/desktop/background/picture-filename \"'$BACKGROUND_PATH'\"" - trashware
su -c "dconf write /org/mate/desktop/background/picture-options \"'scaled'\"" - trashware
# Set background default colors
su -c "dconf write /org/mate/desktop/background/primary-color \"'#FFFFFF'\"" - trashware
su -c "dconf write /org/mate/desktop/background/secondary-color \"'#FFFFFF'\"" - trashware
su -c "dconf load /org/mate/desktop/keybindings/custom0/ < $TASKMANAGER_PATH" - trashware
su -c "dconf write /org/mate/settings-daemon/plugins/media-keys/power \"'<Primary><Alt>q'\"" - trashware

rm -f /root/.bash_history
rm -f $TEMPFILE
rm -rf $HOME/.cache
if [ -e $sudo_stat ] then
	rm -f $sudo_stat
fi
rm -f $HOME/.bash_history
