#!/bin/bash

echo "Servicio RAID: Iniciando servicio RAID"

#Exportar DEBIAN_FRONTEND con el valor noninteractive para forzar la instalacion de herramientas

export DEBIAN_FRONTEND=noninteractive

#Obtener los parametros del fichero de perfil de configuracion de servicio

FILE_CONF=$*

RAID=$(head -n 1 $FILE_CONF)
LEVEL=$(sed -n 2p $FILE_CONF)
DEVICES=$(tail -n 1 $FILE_CONF)
echo $DEVICES | wc -w > num.txt
NUM_DEVICES=$(cat num.txt)
rm num.txt


#Comprobar Numero de argumnetos
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	# Comprobar si es un fichero
	if [ -f $FILE_CONF ]
	then 
		echo "Servicio RAID: El contenido del fichero de configuración es: "
		echo Raid: $RAID
		echo Level: $LEVEL
		echo Devices: $NUM_DEVICES, $DEVICES
	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#Instalar herraminetas
echo "Servicio RAID: Instalando heramientas para crear el RAID..."
apt-get -y update > /dev/null 2&>1
apt-get -y install mdadm > /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio RAID: Heramientas para crear el raid instaladas"
else
    	echo "ERROR: al instalar mdadm"
	exit 1
fi


#Crear el raid
echo "Servicio RAID: Creando el RAID..."
mdadm --create -R --verbose $RAID --level=$LEVEL --raid-devices=$NUM_DEVICES  $DEVICES
if [ $? -eq 0 ]
    	then echo "Servicio RAID: El raid $RAID ha sido creado en los dispositivos $DEVICES"
else
    	echo "ERROR: Al crear el raid"
	exit 1
fi
