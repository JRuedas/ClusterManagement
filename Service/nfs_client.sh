#!bin/bash

FILE_CONF=$*

# Check number of arguments
if [ $# -ne 1 ]
then
	echo "\nERROR: El número de argumentos no es válido"
	exit 1
else
	#Check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "\nEl contenido del fichero de configuración es: "
		cat $FILE_CONF

	else
		echo "\nERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#install the tools
echo "\nInstalando heramientas para crear el servidor NFS..."
#apt-get update
#apt-get install nfs-kernel-server
if [ $? -eq 0 ]
    then echo "\nHeramientas para crear el servidor NFS instaladas"
else
    echo "\nError al instalar NFS"
fi

#obtain netmask
MASK=$(/sbin/ifconfig eth0 | awk '/Mask:/{ print $4;}' | sed 's/Mask://g')

#obtain the number of devices in the file
for line in $(cat $FILE_CONF)
do
	echo "$line";
	IP=`echo $line | cut -d " " -f1` 
	REMOTE_DIR=`echo $line | cut -d " " -f2` 
	MOUNT=`echo $line | cut -d " " -f3`
	#mount -t nfs servidor:dir_exportado punto_de_montaje
	echo "\nCreando punto de montaje remoto... " 
	mount -t nfs $MASK:$REMOTE_DIR $MOUNT

	#modifed /etc/fstab
	#10.0.2.15:/home /home nfs defaults
	echo "\nModificando fichero /etc/fstab... " 
	sed "s/ ./$MASK:$REMOTE_DIR $MOUNT nfs defaults/g" /etc/exports > test-file.txt
	cat test-file.txt
done
