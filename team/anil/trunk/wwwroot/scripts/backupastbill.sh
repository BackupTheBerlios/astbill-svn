# Simple Backup Script for AstBill-0.9.0.9
#
mkdir -p /home/astbill/backup
cd /home/astbill/backup
#
/usr/local/mysql/bin/mysqldump --opt -u astbilluser -p astbill419 astbill >/home/astbill/backup/astbillbackup.sql
#
bzip2 /home/astbill/backup/astbillbackup.sql
#

