#!/bin/bash

# Check number of arguments

FILE_CONF=$*

if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#Check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "El contenido del fichero de configuración es: "
		cat $FILE_CONF
	else
		echo "ERROR: $FILE_CONF no existe"
		exit 1
	fi 
fi 

FILE_CONF_CLEAN=`grep -E -v '^(#|$)' $FILE_CONF`

sed '1 d' FILE_CONF_CLEAN > raid
RAID=cat raid
#	LEVEL_RAID=
#	DEVICES= 


#install de tools
apt-get update
apt-get install mdadm
echo "Heramientas para crear el RAID instaladas"


#read the file conf



#create the raid
#mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2  /dev/sdb1 /dev/sdc1