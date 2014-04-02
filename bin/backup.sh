#!/bin/sh

DATUM=$(date +"%Y-%m-%d")
ZEIT=$(date +"%H-%M-%S")
SOURCE=$HOME
DEST=/media/backup/denice-19

if mount -l| grep -q /media/backup
then
	/bin/mkdir -p $DEST/$DATUM/$ZEIT 
	/usr/bin/ionice -c 3 /usr/bin/rsync -aPq --exclude-from $HOME/.rsync-exclude --link-dest=$DEST/latest $SOURCE $DEST/$DATUM/$ZEIT
	rm $DEST/latest
	ln -s $DEST/$DATUM/$ZEIT $DEST/latest
else
	echo "Backup-Platte nicht gemountet! ENDE."
fi

