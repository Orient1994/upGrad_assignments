#!/bin/bash


#======== if we have multile users and S3 bukcet we can use below approch instaed of hardcoded value of user_name and S3 bucket======
#echo "Please Enter your Username:- "
#read my_name
#echo "Please provide the S3 bucket name"
#read S3_bucket
#====================================================================================================================================
my_name="rahulgs"
S3_bucket="upgrad-rahulgs"

#Update all packages details
sudo apt update -y

# check if apache2 package is installed or not 

INSTALLATION_STATUS=`dpkg --get-selections | grep apache |grep -v deinstall|grep install|wc -l`

if [ ${INSTALLATION_STATUS} -ge 1 ]
then 
	echo  "Apache Packgae is  already installed "

else
	echo "Started installing apache2 Package "
	apt-get install apache2
fi

## check Apache Status 

APACHE2_SERVICE_STATUS=`ps -eaf |grep -i apache2 |wc -l`
if [ ${APACHE2_SERVICE_STATUS} -ge 1 ]
then
	echo  "Apache service is up and Running fine"
else
	echo  "Apache service is not running on server"
	systemctl restart apache2
fi
## Checking status of APaches Service


NEXT_BOOT_STATUS=`systemctl is-enabled apache2`

if [ ${NEXT_BOOT_STATUS} == "enabled" ]
then
        echo  "Service is currently configured to start on the next boot up"
else
        echo  "Enabling Apache2 service for next boot up"
        systemctl enable apache2

fi

APACHE2_SERVICE_STATUS=`systemctl is-active apache2`
if [ ${APACHE2_SERVICE_STATUS} == "active" ]
then
        echo "Apache services up and  running fine"
else
        echo "Starting Apache service"
         systemctl restart apache2
fi




##Creating tar file for all log files related to apache2 service
echo  "Archiving Apache2 log files "
timestamp=$(date '+%d%m%Y-%H%M%S')

tar -cvf ${my_name}-httpd-logs-${timestamp}.tar --absolute-names /var/log/apache2/*.log 
mv  ${my_name}-httpd-logs-${timestamp}.tar /tmp

##Uploading file inot S3 bucket
echo  "Uploading file into S3 bucket"
aws  s3   cp /tmp/${my_name}-httpd-logs-${timestamp}.tar  s3://${S3_bucket}/${my_name}-httpd-logs-${timestamp}.tar

#
