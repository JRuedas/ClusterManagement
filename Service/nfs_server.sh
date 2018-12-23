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
		echo "Servicio NFS servidor: El contenido del fichero de configuración es: "
		cat $FILE_CONF

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


# Establecer el modo no interactivo
export DEBIAN_FRONTEND=noninteractive


# Instalar las herramientas
echo "Servicio NFS servidor: Instalando heramientas para crear el servidor NFS..."
apt-get -y update > /dev/null 2&>1
apt-get -y install nfs-common > /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio NFS servidor: Heramientas para crear el servidor NFS instaladas"
else
    	echo "ERROR: no se pudo instalar NFS"
	exit 1
fi


# Obtener el número de direcorios en el fichero
echo "Servicio NFS servidor: Modificando fichero /etc/exports para insertar los directorios a exportar... "
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

echo "Servicio NFS servidor: El fichero /etc/exports ha sido modificado, su contenido ahora es:"
cat /etc/exports


# Exportar directorios
echo "Servicio NFS servidor: Exportando directorios... "
exportfs
if [ $? -eq 0 ]
    	then echo "Servicio NFS servidor: Directorios exportados"
else
    	echo "ERROR: No se pudo exportar los directorios"
	exit 1
fi


# Arrancar servicio
echo "Servicio NFS servidor: Arrancando servidor NFS..."
service nfs start
if [ $? -eq 0 ]
    	then echo "Servicio NFS servidor: Servidor NFS arrancado"
else
    	echo "ERROR: No se pudo arrancar el servidor"
	exit 1
fi

