#!bin/bash

FILE_CONF=$*

#check number of arguments
if [ $# -ne 1 ]
then
	echo "\nERROR: El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "\nEl contenido del fichero de configuración es: "
		cat $FILE_CONF

	else
		echo "\nERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#set the non interactive mode
export DEBIAN_FRONTEND=noninteractive


#install the tools
echo "\nInstalando heramientas para crear el servidor NFS..."
#apt-get update
#apt-get install nfs-kernel-server
if [ $? -eq 0 ]
    	then echo "\nHeramientas para crear el servidor NFS instaladas"
else
    	echo "\nError al instalar NFS"
	exit 1
fi


#obtain the number of devices in the file
while IFS=' ' read -r IP REMOTE_DIR MOUNT; do
	echo "IP=$IP REMOTE=$REMOTE_DIR MOUNT=$MOUNT#"

	#modifed /etc/fstab
	#10.0.2.15:/home /home nfs defaults
	echo "\nModificando fichero /etc/fstab... "
	grep --quiet "$IP:$REMOTE_DIR $MOUNT nfs defaults$" /etc/fstab
	if [ $? -eq 1 ] ; then
		echo "$IP:$REMOTE_DIR $MOUNT nfs defaults" >> /etc/fstab	
	fi

	#mount -t nfs servidor:dir_exportado punto_de_montaje
	echo -e "\nCreando punto de montaje remoto... " 
	#mount --types nfs $IP:$REMOTE_DIR $MOUNT
	if [ $? -eq 0 ]
    		then echo -e "\nPunto de montaje $IP:$REMOTE_DIR $MOUNT creado" 
	else
    		echo "\nError al crear el punto de montaje: $IP:$REMOTE_DIR $MOUNT "
	fi

done < $FILE_CONF

cat /etc/fstab

