#!bin/bash

FILE_CONF=$*

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
		cat $FILE_CONF

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#set the non interactive mode
export DEBIAN_FRONTEND=noninteractive


#install the tools
echo "Instalando heramientas para crear el servidor NFS..."
apt-get -y update > /dev/null 2&>1
apt-get -y install nfs-kernel-server > /dev/null
if [ $? -eq 0 ]
    	then echo "Heramientas para crear el servidor NFS instaladas"
else
    	echo "Error al instalar NFS"
	exit 1
fi


#obtain the number of devices in the file
while IFS=' ' read -r IP REMOTE_DIR MOUNT; do
	echo "IP=$IP REMOTE=$REMOTE_DIR MOUNT=$MOUNT#"

	#modifed /etc/fstab
	#10.0.2.15:/home /home nfs defaults
	echo "Modificando fichero /etc/fstab... "
	grep --quiet "$IP:$REMOTE_DIR $MOUNT nfs defaults$" /etc/fstab
	if [ $? -eq 1 ] ; then
		echo "$IP:$REMOTE_DIR $MOUNT nfs defaults" >> /etc/fstab	
	fi

	#mount -t nfs servidor:dir_exportado punto_de_montaje
	echo -e "Creando punto de montaje remoto... " 
	#mount --types nfs $IP:$REMOTE_DIR $MOUNT
	if [ $? -eq 0 ]
    		then echo -e "Punto de montaje $IP:$REMOTE_DIR $MOUNT creado" 
	else
    		echo "Error al crear el punto de montaje: $IP:$REMOTE_DIR $MOUNT "
	fi

done < $FILE_CONF

cat /etc/fstab

