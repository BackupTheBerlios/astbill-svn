#!/bin/bash
#
# WARNING this script is experimental
#
# BACKUP your /etc/asterisk before you run this script
#
# Use at your own RISK!
#
# AstBill
echo "-----------------------------------------"
echo "Executing AstBill Install Script."
echo "-----------------------------------------"
echo ""
echo "WARNING this script is experimental"
echo "BACKUP your /etc/asterisk before you run this script"
echo "Use at your own RISK!"
echo ""
echo "Be aware, that this setup of AstBill is not secure. If you would like to"
echo "have a secure AstBill setup, you'd better go on the manual way, and set"
echo "every option carefully. This automatically working setup gives you an"
echo "instantly working AstBill installation, but it is not meant to be used on"
echo "online servers."
echo ""
echo "Type in yes if you are sure you want to continue"

read response
if [ "X${response}" = "Xyes" ]
then
echo "Continuing... good luck!"
else
echo "Exiting"
exit 0
fi


BAKDIR="`pwd`/backup/"
DATE=`date +%s`
FILENAME="asterisk_backup_$DATE.tar.bz2"


echo "Backing up your asterisk config files to $BAKDIR$FILENAME"

if [ -d $BAKDIR ]
then
echo ""
else
mkdir $BAKDIR
fi

tar cfj $BAKDIR$FILENAME /etc/asterisk 2>&1 | grep -v "Removing leading"



mkdir -p /home/astbill/logs
mkdir -p /home/astbill/backup
mkdir -p /etc/asterisk
mkdir -p /var/lib/asterisk/agi-bin
# mkdir -p /usr/src/asterisk
mkdir -p /var/lib/asterisk/sounds/
# mkdir -p /var/lib/asterisk/mohmp3
# Used for temporary outgoing calling files.



# Apache need access to mysql.sock
# Debian              /var/run/mysqld/mysqld.sock
# Fedora and CentOS   /var/lib/mysql/mysql.sock

mkdir -p /var/run/mysqld
mkdir -p /var/lib/mysql
chmod 777 -R /var/run/mysqld
chmod 777 -R /var/lib/mysql

#cp -fr /home/astbill/astbill-0.9.0.7/cgi-bin/* /var/wwwroot/localhost/cgi-bin/

mkdir -p /var/spool/asterisk/tmp
mkdir -p /var/spool/asterisk/outgoing
chmod 777 -R /var/spool/asterisk/tmp
chmod 777 -R /var/spool/asterisk/outgoing

mkdir -p /etc/asterisk

# echo "WARNING: We are now replacing your /etc/asterisk directory :)"
# echo "This may break your old asterisk installation. TAKE BACKUP!"
# echo "Type Yes if that is ok:"
# X=`line`

# echo "wooo, hi there You answered: $X"


cp -r etc/asterisk1.2.sample/* /etc/asterisk
cp -r etc/asterisk/* /etc/asterisk
chmod 777 /etc/asterisk/*
# chmod 770 /etc/asterisk/*
# chown -R asterisk:asterisk /etc/asterisk/*

mkdir -p wwwroot/files/astar
cp -fr themes/* wwwroot/themes/
cp -fr images/* wwwroot/files/astar/
mkdir -p wwwroot/modules/astbill
cp -fr modules/astbill wwwroot/modules
mkdir -p wwwroot/ajax
cp -fr ajax/*.php wwwroot/ajax


chmod -R 777 wwwroot/files/
chmod +x scripts/backupastbill.sh

echo "Installing AstBill Sounds"
echo "-----------------------------------------"

#install AstBill sounds
cp -fr sounds/* /var/lib/asterisk/sounds


echo "Installing AstBill AGI scripts"
echo "-----------------------------------------"

cp -fr agi-bin/* /var/lib/asterisk/agi-bin/

# chown -R asterisk:asterisk /var/lib/asterisk/agi-bin/
chmod -R +x /var/lib/asterisk/agi-bin/*

echo "Remember to edit /etc/asterisk/res_mysql.conf"
echo "You have to put the right path to mysql.sock"
echo "-----------------------------------------"
