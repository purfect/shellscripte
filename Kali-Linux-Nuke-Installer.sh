#!/bin/bash
#
# Baut Selbstzerstörung (Nuke) in Kali-Linux ein
# 
# mehr Infos unter: https://www.kali.org/tutorials/nuke-kali-linux-luks/
#
# Author: rasputin
VERSION=0.1

LUKS_HEADER_BACKUP="luksheader.back"
LUKS_HEADER_BACKUP_ENC="luksheader.back.enc"

function print_good(){
	echo -e "\x1B[01;32m[*]\x1B[0m $1"
}
function print_error(){
	echo -e "\x1B[01;31m[!]\x1B[0m $1"
}
function show_intro(){
	echo ""
	echo "#################################"
	echo "#				#"
	echo "# 	NUKE Installer		#"
	echo "#				#"
	echo "#	   written by		#"
	echo "#	~>| Rasputin |<~	#"
	echo "#				#"
	echo "#################################"
	echo ""
}
show_intro
if [[ $EUID -ne 0 ]]
then
	print_error "Keine Root-Rechte !"
	exit 1
else
	All_Slots=$(cryptsetup luksDump /dev/sda5 | grep Slot | wc -l)
	Free_Slots=$(cryptsetup luksDump /dev/sda5 | grep DIS | wc -l)
	print_good "LUKS-Slots insgesamt: $All_Slots"
	print_good "Freie LUKS-Slots: $Free_Slots"
	if [ "$Free_Slots" > 1 ]
	then
		Slots_before_inst="$Free_Slots"
		print_good "NUKE wird installiert"
		cryptsetup luksAddNuke /dev/sda5
		if [ "$Slots_before_inst" > "$Free_Slots" ]
		then
			print_good "Nuke erfolgreich installiert"
			print_good "Backup vom LUKS-Header wird erstellt"
			cryptsetup luksHeaderBackup --header-backup-file $LUKS_HEADER_BACKUP /dev/sda5
			if [ -f "$LUKS_HEADER_BACKUP" ]
			then
				print_good "Backup vom LUKS-HEADER in \"$LUKS_HEADER_BACKUP\" gespeichert"
				print_good "Backup vom LUKS-HEADER wird verschluesselt"
				openssl enc -aes-256-cbc -salt -in $LUKS_HEADER_BACKUP -out $LUKS_HEADER_BACKUP_ENC
				if [ -f "$LUKS_HEADER_BACKUP" ]
				then
					print_good "Verschluesseltes Backup des LUKS-HEADER in \"$LUKS_HEADER_BACKUP_ENC\" gespeichert"
					print_error "Backup (\"$LUKS_HEADER_BACKUP_ENC\") bitte seperat aufbewahren ! (z.B. USB-Stick)"
				else
					print_error "LUKS-HEADER konnte nicht verschluesselt werden"
					exit 1
				fi
			else
				print_error "Es konnte kein Backup erstellt werden"
				exit 1
			fi 
			
		else	
			print_error "Nuke konnte nicht installiert werden"
		fi
	else
		echo "NO"
	fi
fi
