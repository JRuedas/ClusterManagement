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
apt-get -y install nfs-common > /dev/null
if [ $? -eq 0 ]
    	then echo "Heramientas para crear el servidor NFS instaladas"
else
    	echo "Error al instalar NFS"
	exit 1
fi


#obtain the number of devices in the file
echo "Modificando fichero /etc/exports para poner nombre de dominio NIS... "
for line in $(cat $FILE_CONF)
do
	#modifed /etc/exports  
	#/home 10.0.2.0/24(rw,sync,no_subtree_check)
	if cat /etc/exports | grep --quiet "^$line 0.0.0.0/0(rw,sync)"; then
		continue
	else
		echo "$line 0.0.0.0/0(rw,sync)" >> /etc/exports	
	fi
done

echo "El fichero /etc/exports ha sido modificado, su contenido ahora es:"
cat /etc/exports


#export files
echo "Exportando directorios... "
exportfs
if [ $? -eq 0 ]
    	then echo "Directorios exportados"
else
    	echo "Error al exportar los directorios"
	exit 1
fi


#start service
echo "Arrancando servidor NFS..."
service nfs start
if [ $? -eq 0 ]
    	then echo "Servidor NFS arrancado"
else
    	echo "Error al arrancar el servidor"
	exit 1
fi

