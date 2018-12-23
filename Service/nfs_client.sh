#!/bin/bash

FILE_CONF=$*


# Comprobar el número de argumentos
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	# Comprobar que el argumento sea un fichero
	if [ -f $FILE_CONF ]
	then 
		echo "Servicio NFS cliente: El contenido del fichero de configuración es: "
		cat $FILE_CONF

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


# Establecer el modo no interactivo
export DEBIAN_FRONTEND=noninteractive


# Instalar las herramientas
echo "Servicio NFS cliente: Instalando heramientas para crear el cliente NFS..."
apt-get -y update > /dev/null 2&>1
apt-get -y install nfs-kernel-server > /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio NFS cliente: Heramientas para crear el servidor NFS instaladas"
else
    	echo "ERROR: No se pudo instalar NFS"
	exit 1
fi


# Obtener el número de directorios 
while IFS=' ' read -r IP REMOTE_DIR MOUNT; do
	echo "IP=$IP REMOTE=$REMOTE_DIR MOUNT=$MOUNT#"

	# Modificar /etc/fstab para añadir los directorios
	#10.0.2.15:/home /home nfs defaults
	echo "Servicio NFS cliente: Modificando fichero /etc/fstab... "
	grep --quiet "$IP:$REMOTE_DIR $MOUNT nfs defaults$" /etc/fstab
	if [ $? -eq 1 ] ; then
		echo "$IP:$REMOTE_DIR $MOUNT nfs defaults" >> /etc/fstab	
	fi

	#mount -t nfs servidor:dir_exportado punto_de_montaje
	echo -e "Servicio NFS cliente: Creando punto de montaje remoto... " 
	#mount --types nfs $IP:$REMOTE_DIR $MOUNT
	if [ $? -eq 0 ]
    		then echo -e "Servicio NFS cliente: Punto de montaje $IP:$REMOTE_DIR $MOUNT creado" 
	else
    		echo "ERROR: No se pudo crear el punto de montaje: $IP:$REMOTE_DIR $MOUNT "
	fi

done < $FILE_CONF

cat /etc/fstab

