
Linux - AWS Cloud Eng Road Map Need Shell Scripting
************************************************

1) File Backup with Datestamp and Send Mail Notification

2) Mysql DB backup Copy to AWS S3 and delete old backup

3) Mysql DB backup local and Send Mail Notification

4) Disk Usage 80% Greater check Send Mail Notification

5) Service UP or down check mail trigger and service status change

6) Memory low check Send Mail Notification

File backup and send mail
*************************
TIME=`date +%b-%d-%y`           
FILENAME=backup-$TIME.tar.gz   
SRCDIR=/imp-data                    
DESDIR=/mybackupfolder   
       
tar -cpzf $DESDIR/$FILENAME $SRCDIR 

if [ "$?" = "0" ]; then
        echo "Backup Process was Successful. A new backup file $FILENAME has been created" | mailx -s "Backup Status Successful" itsupport@gmail.com
else
         echo "Backup Process Failed. Please contact System Administrator" | mailx -s "Backup Status Failed" itsupport@gmail.com
        exit 1
fi

find /imp-data -mindepth 1 -mtime +1 -delete


Mysql DB backup Copy to AWS S3 and delete old backup
****************************************************

#!/bin/bash

FILE=DB_dump_`date +%Y%m%d`.sql

/usr/bin/mysqldump -u root -p password target_db > /backup/$FILE

/bin/gzip   /backup/$FILE

/usr/local/bin/aws s3 cp /backup/$FILE.gz s3://targetbucket/SQL/`date +%Y%m%d`/

/bin/rm -rf /backup/$FILE.gz /backup/$FILE

exit 0

Mysql DB backup local and Send Mail Notification
************************************************

#!/bin/bash

filename=live-DB-`date +%Y-%m-%d`.sql

/usr/bin/mysqldump -u root -p password target_db > /backup/$FILE

/usr/bin/zip /backup/DB/$filename.zip /backup/DB/$filename

rm -rf /backup/DB/$filename

echo "example.com Mysql-backup completed" | mail -s Mysql-Backup itsupport@gmail.com

find /backup/DB/ -mindepth 1 -mtime +3 -delete

Disk Usage 80% Greater check Send Mail Notification
***************************************************

#!/bin/bash
CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
THRESHOLD=80

if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    mail -s 'Disk Space Alert' itsupport@gmail.com 
Your root partition remaining free space is critically low on AOL appserver. Used: $CURRENT%
EOF
fi





Service UP or down check mail trigger
*************************************

#!/bin/bash
UP=$(/etc/init.d/apache2 status | grep running | grep -v not | wc -l);
if [ "$UP" -ne 1 ];
then
        echo "webserver is down on AOL.";
        sudo service apache2 start | mail -s "webserver is down on AOL." itsupport@gmail.com 
else
        echo "All is well.";
fi
Shell Script to Check Server Memory
************************************

#!/bin/bash 
subject="Server Memory Status Alert"
To="server.monitor@example.com"

free=$(free -mt | grep Total | awk '{print $4}')

if [[ "$free" -le 100  ]]; then
        echo -e "Warning, server memory is running low!\n\nFree memory: $free MB" | mail -s "$subject" $To
fi
exit 0
