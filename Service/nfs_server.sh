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
	then echo "Servicio NFS servidor: $FILE_CONF es un fichero"

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
apt-get -y install nfs-kernel-server > /dev/null
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
	# Comprueba que el directorio exista
	if [ ! -d $line ]
	then
		echo "ERROR: El directorio $line no existe"
		exit 1
	fi
	# Comprueba que el fichero de configuración no tenga líneas en blanco
	if [ $line -lt 1 ]
	then 
		echo "ERROR: El fichero de configuración esta vacio"
		exit 1
	fi
	# Modifica /etc/exports para que el cambio sea persistente
	#/home 10.0.2.0/24(rw,sync,no_subtree_check)
	if cat /etc/exports | grep --quiet "^$line *(rw,sync)"; then
		continue
	else
		echo "$line *(rw,sync)" >> /etc/exports	
	fi
done

echo "Servicio NFS servidor: El fichero /etc/exports ha sido modificado, su contenido ahora es:"
cat /etc/exports


# Reiniciar servicio
echo "Servicio NFS servidor: Reiniciando servidor NFS..."
/etc/init.d/nfs-kernel-server restart
if [ $? -eq 0 ]
    	then echo "Servicio NFS servidor: Servidor NFS reiniciado"
else
    	echo "ERROR: No se pudo reiniciar el servidor"
	exit 1
fi

