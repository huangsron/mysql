#!/bin/bash
MyUSER="root" # USERNAME
MyPASS="dbadmin1234"        # PASSWORD
MyHOST="localhost"           # Hostname

# Linux bin paths, change this if it can not be autodetected via which command
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

# Backup Dest directory, change this if you have someother location
DEST="/tmp/sql/db_backup"
# Main directory where backup will be stored
MBD="$DEST/mysql"
# Get hostname
HOST="$(hostname)"
# Get data in dd-mm-yyyy format
NOW="$(date +'%d-%m-%Y')"
# File to store current backup file
FILE=""
# Store list of databases
DBS=""
# DO NOT BACKUP these databases
IGGY="information_schema mysql sys employees2"

[ ! -d $MBD ] && mkdir -p $MBD || :

# Only root can access it!
# $CHOWN 0.0 -R $DEST
# $CHMOD 0600 $DEST

# Get all database list first
DBS="$($MYSQL -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"
echo "backup list $DBS"

for db in $DBS; do
    skipdb=-1
    if [ "$IGGY" != "" ]; then
        for i in $IGGY; do
            [ "$db" == "$i" ] && skipdb=1 || :
        done
    fi
    if [ "$skipdb" == "-1" ]; then
        # FILE="$MBD/$db.$HOST.$NOW.gz"
        FILE="$MBD/$db.$HOST.$NOW"

        echo "backup file $FILE"
        # do all inone job in pipe,
        # connect to mysql using mysqldump for select mysql database
        # and pipe it out to gz file in backup dir :)
        # $MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db | $GZIP -9 >$FILE

        $MYSQLDUMP -u $MyUSER -h $MyHOST -p$MyPASS $db > "${FILE}.sql"
        tar zcvf "${FILE}.tgz" "${FILE}.sql"
    fi
done


# remove old backup file
# sudo touch -a -m -t 1001010101 sql/db_backup/tgs.txt
# sudo find sql/db_backup -type f -mtime +10 | sudo xargs rm -f
# touch -a -m -t 1001010101 $MBD/tgs.txt

# remove file
find $MBD -type f -mtime +10 | xargs rm -f