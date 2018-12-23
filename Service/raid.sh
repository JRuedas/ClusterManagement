#!/bin/bash

export DEBIAN_FRONTEND=noninteractive


#read the file conf
FILE_CONF=$*

RAID=$(head -n 1 $FILE_CONF)
LEVEL=$(sed -n 2p $FILE_CONF)
DEVICES=$(tail -n 1 $FILE_CONF)
echo $DEVICES | wc -w > num.txt
NUM_DEVICES=$(cat num.txt)
rm num.txt


#check number of arguments
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "El contenido del fichero de configuración es: "
		echo Raid: $RAID
		echo Level: $LEVEL
		echo Devices: $NUM_DEVICES, $DEVICES
	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#install the tools
echo "Instalando heramientas para crear el RAID..."
apt-get -y update > /dev/null 2&>1
apt-get -y install mdadm > /dev/null
if [ $? -eq 0 ]
    	then echo "Heramientas para crear el raid instaladas"
else
    	echo "Error al instalar mdadm"
	exit 1
fi


#create the raid
echo "Creando el RAID..."
#mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2  /dev/sdb1 /dev/sdc1
mdadm --create -R --verbose $RAID --level=$LEVEL --raid-devices=$NUM_DEVICES  $DEVICES
if [ $? -eq 0 ]
    	then echo "El raid $RAID ha sido creado en los dispositivos $DEVICES"
else
    	echo "Error al crear el raid"
	exit 1
fi
