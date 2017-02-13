#!/bin/bash

#
# Post-install script for Linux Mint 18 PC installed by Trashware Cesena
# 
# All the OS configuration changes must be system-wide where possible.
# Otherwise note it in the comments.
#

# Require running the script as root user

if [ `id -u` -ne 0 ]; then
    printf "The script must be run as root user!\n"
    exit 1
fi

#
# Configuring apt-get
#

# Enable apt-get progressbar
echo 'Dpkg::Progress-Fancy "1";' |  tee -a /etc/apt/apt.conf.d/99progressbar

# Do not ask for continue or new configurations
echo -e 'APT::Get::Assume-Yes "true";\nAPT::Get::force-yes "true";'  |  tee -a /etc/apt/apt.conf.d/90yes
TEMPFILE=/etc/apt/apt.conf.d/00newconftemp
echo -e 'Dpkg::Options {\n\t"--force-confdef";\n\t"--force-confnew";\n}' |  tee -a $TEMPFILE
rm -f $TEMPFILE;

# TODO: autmatically chose "Y" for this kind of prompts:
#File di configurazione "/etc/compizconfig/config"
# ==> Modificato (dall'utente o da uno script) dopo l'installazione.
# ==> Il distributore del pacchetto ha fornito una versione aggiornata.
#   Come procedere? Le opzioni sono:
#    Y o I   : installa la versione del responsabile del pacchetto
#    N od O  : mantiene la versione attualmente installata
#      D     : mostra le differenze tra le versioni
#      Z     : avvia una shell per esaminare la situazione
# L'azione predefinita consiste nel mantenere la versione attuale.
#*** config (Y/I/N/O/D/Z) [predefinito=N] ?

# Update the system
apt-get -q update &&  apt-get -f upgrade
while [[ $? > 0 ]]; do
	apt-get update &&  apt-get -f upgrade
	apt-get -f install &&  apt-get -f upgrade
done

# Clean apt-get
apt-get autoclean
apt-get clean

# Some usefull OS settings
echo "vm.swappiness=10" |  tee -a /etc/sysctl.conf
sed -i 's/CONCURRENCY=none/CONCURRENCY=makefile/g' /etc/init.d/rc

#
# User experience customizations
#

# Set the default background
#GSCHEMAS_PATH=/usr/share/glib-2.0/schemas
#BACKGROUND_NAME="trashware_logo.png"
#BACKGROUNDS_OS_FOLDER="/usr/share/backgrounds/"
#GSCHEMA_BACKGROUND_OVERRIDE_FILENAME=mint-artwork-mate.gschema.override
# curl -o $BACKGROUNDS_OS_FOLDER/$BACKGROUND_NAME http://labs.trashwarecesena.it/images/$BACKGROUND_NAME
# cp $GSCHEMA_BACKGROUND_OVERRIDE_FILENAME $GSCHEMAS_PATH
#echo "picture-filename='$BACKGROUNDS_OS_FOLDER'" |  tee -a $GSCHEMAS_PATH/$GSCHEMA_BACKGROUND_OVERRIDE_FILENAME
# glib-compile-schemas $GSCHEMAS_PATH


# TODO: set lighter default greeter for lightdm

# TODO: remove firefox mint customizations

# TODO: set simplet desktop panels confiuration (e.g.: without terminal icon near menu icon)

# TODO: Set keyboard shortcuts
# create a /usr/share/glib-2.0/schemas/org.gnome.desktop.wm.keybindings.gschema.override file with the mate-system-monitor Ctrl+Alt+Canc keybinding

# Removing meta packages, wich are useless after installation and prevent removing some software
apt-get remove -y mint-meta-core mint-meta-mate

# Remove Linux Mint welcome screen
apt-get remove -y mintwelcome

#
# Cleaning up cache, histories, temps, ...
#

rm -rf $HOME/.cache
rm -f $HOME/.bash_history
apt-get autoremove
