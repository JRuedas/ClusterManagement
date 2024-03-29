#!/bin/bash

# Comprobamos si el numero de parametros es correcto y el fichero de configuracion existe

if [ $# -ne 1 ]; then
	echo "ERROR: Numero de parametros incorrecto"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "ERROR: El fichero especificado no existe"
	exit 1
fi

prevIFS=$IFS
IFS=$'\n'

echo "Servicio LVM: Leyendo fichero de configuración del servicio"

#Contador de lineas y contador de volumenes

linecount=0
volcount=0
for line in $(cat $1); do

	# Saltar lineas que sean comentarios

	if [[ $line == *"#"* ]]; then
		continue
	fi

	# Asignar los diferentes valores dependiendo de la linea del fichero

	if [ $linecount = 0 ]; then
		NAME=$line
	elif [ $linecount = 1 ]; then
		DEVICES=$line
	elif [ $linecount > 1 ]; then
		IFS=' '

	       	read -r -a array <<< "$line"
		VOL_NAME[$volcount]=${array[0]}
		VOL_SIZE[$volcount]=${array[1]}

		IFS=$'\n'
		let volcount+=1
	fi
	let linecount+=1
done

# Comprobacion numero de lineas de fichero incorrecto

if [ $volcount -eq 0 ]; then
	echo "ERROR: Numero de lineas de fichero incorrectas"
	exit 1
fi

# Preparamos el entorno para la instalacion

export DEBIAN_FRONTEND=noninteractive

echo "Servicio LVM: Actualizando paquetes e instalando servicio LVM version 2"
apt-get -y update > /dev/null 2&>1
apt-get -y install lvm2 --no-install-recommends > /dev/null

# Comprobacion si la instalacion se hizo correctamente 

if [ $? -ne 0 ]; then
	echo "ERROR: El paquete no se pudo instalar"
	exit 1
fi

echo "Servicio LVM: Servicio LVM version 2 instalado correctamente"

# Inicializamos los volumenes fisicos forzandolos por si existiesen y de forma no interactiva

IFS=' '
echo "Servicio LVM: Inicializando los volumenes fisicos"
pvcreate $DEVICES > /dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: Fallo la inicializacion de los volumenes fisicos"
	exit 1
fi

# Creamos un grupo de volumenes forzandolo por si existiesen y de forma no interactiva

echo "Servicio LVM: Creando grupo de volumenes"
vgcreate $NAME $DEVICES > /dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: Fallo la creacion del grupo de volumenes"
	exit 1
fi

# Calculamos el tamaño total de los volumenes

counter=0
TOTAL_SIZE=0
until [ $counter -ge $volcount ]; do
	let TOTAL_SIZE=$(( $TOTAL_SIZE + ${VOL_SIZE[$counter]::-1} ))
	let counter+=1
     done

# Obtenemos el tamaño del grupo de volumenes y lo parseamos para trabajar con el

IFS=','
read -r -a array <<< "$(vgs --noheadings -o vg_size --units g)"
GROUP_SIZE="$(sed 's/^[[:space:]]*//' <<< "${array[0]}")"

# Comprobacion si entra en tamaño de grupo

if [ $TOTAL_SIZE -gt $GROUP_SIZE ]; then
	echo "ERROR: El tamaño del grupo es demasiado pequeño"
	exit 1
fi

echo "Servicio LVM: Creando volumenes logicos dentro del grupo"

counter=0
until [ $counter -ge $volcount ]; do
	lvcreate --name ${VOL_NAME[$counter]} --size ${VOL_SIZE[$counter]} $NAME > /dev/null
	
	if [ $? -ne 0 ]; then
		echo "ERROR: Fallo la creacion del volumen" ${VOL_NAME[$counter]}
		exit 1
	fi

	let counter+=1
     done
     
IFS=$prevIFS

echo "Servicio LVM: Servicio LVM completado"
