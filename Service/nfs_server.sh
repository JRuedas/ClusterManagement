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


#obtain IP address and MASK of the NFS server
IP=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
MASK=$(/sbin/ifconfig eth0 | awk '/Mask:/{ print $4;}' | sed 's/Mask://g')


#obtain the number of devices in the file
for line in $(cat $FILE_CONF)
do
	echo "$line";
	cut
	#modifed /etc/exports 
	echo "\nModificando fichero /etc/exports  para poner nombre de dominio NIS... " 
	#/home 10.0.2.0/24(rw,sync,no_subtree_check)	
	sed "s/ ./$line $MASK(rw,sync)/g" /etc/exports > test-file.txt
	cat test-file.txt
	exportfs
done
rm test-file.txt

#start service
echo "\nArrancando servidor NFS..."
#service nfs start










