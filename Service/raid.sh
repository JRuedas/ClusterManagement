#!/bin/bash

FILE_CONF=$*

#read the file conf
RAID=$(head -n 1 $FILE_CONF)
LEVEL=$(sed -n 2p $FILE_CONF)
DEVICES=$(tail -n 1 $FILE_CONF)
echo $DEVICES | wc -w > num.txt
NUM_DEVICES=$(cat num.txt)
rm num.txt

# Check number of arguments
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#Check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "El contenido del fichero de configuración es: "
		echo Raid: $RAID
		echo Level: $LEVEL
		echo Devices: $NUM_DEVICES, $DEVICES
	else
		echo "ERROR: $FILE_CONF no existe o no es un fichero"
		exit 1
	fi 
fi 

#install the tools
#apt-get update
#apt-get install mdadm
#echo "Heramientas para crear el RAID instaladas"


#create the raid
#mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2  /dev/sdb1 /dev/sdc1
mdadm --create --verbose $RAID --level=$LEVEL --raid-devices=$NUM_DEVICES  $DEVICES
