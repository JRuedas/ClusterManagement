#!/bin/bash

prevIFS=$IF
IFS=$'\n'

echo "Actualizando paquetes e instalando servicio LVM version 2"
#apt-get update && apt-get install lvm2 -qq --force-yes > /dev/null

echo "Leyendo fichero de configuración del servicio"

linecount=0
volcount=0
for line in $(cat $1); do

	# Skip comments if any
	if [[ $line == *"#"* ]]; then
		continue
	fi

	if [ $linecount = 0 ]; then
		NAME=$line
		echo "Nombre: " $NAME
	elif [ $linecount = 1 ]; then
		DEVICES=$line
		echo "Devices: " $DEVICES
	elif [ $linecount > 1 ]; then
		IFS=' '
	       	read -r -a array <<< "$line"
		VOL_NAME[$volcount]=${array[0]}
		VOL_SIZE[$volcount]=${array[1]}
		echo "Vol name" $volcount ${VOL_NAME[$volcount]}
	        echo "Vol size"	$volcount ${VOL_SIZE[$volcount]} 
		IFS=$'\n'
		let volcount+=1
	fi
	let linecount+=1
done

echo "Inicializando los volumenes fisicos"
pvcreate $DEVICES > /dev/null

echo "Creando grupo de volumenes"
vgcreate $NAME $DEVICES > /dev/null

echo "Creando volumenes logicos dentro del grupo"

counter=0
until [ $counter -ge $volcount ]; do
	lvcreate --name $VOL_NAME[$counter] --size $VOL_SIZE[$counter] $NAME > /dev/null
	let counter+=1
     done
     
IFS=$prevIFS

echo "Servicio configurado"
