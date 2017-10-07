#!/bin/bash

###[ Config ]###
VERSION="0.1"
SWAPFILENAME="swapfile"
DIRECTORY="/"
SIZE=1          #Size in GB
################

get_swapfilenumber() {
        RESULT=$(swapon -s | grep -c $SWAPFILENAME)
        RESULT=$(( RESULT + 1 ))
        echo $RESULT
}



if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
else
        NEWSIZE=$(( SIZE * 1024 * 1024))
        NUMBER=$(get_swapfilenumber)
        NEWFILENAME=$DIRECTORY$SWAPFILENAME$NUMBER
        echo "Anlegen von $NEWFILENAME"
        dd if=/dev/zero of="$NEWFILENAME" bs=1024 count="$NEWSIZE" status=none
        echo "Anpassen der Rechte"
        chown root:root "$NEWFILENAME"
        chmod 0600 "$NEWFILENAME"
        echo "Aktiviere Swap..."
        mkswap "$NEWFILENAME" > /dev/null
        swapon "$NEWFILENAME"
	echo "Bearbeite /etc/fstab"
	if [ -f /etc/fstab ]; then 
		echo "$NEWFILENAME none swap sw 0 0" >> /etc/fstab
	else
		echo "fstab wurde nicht gefunden"
	fi
	swapon -s


fi
