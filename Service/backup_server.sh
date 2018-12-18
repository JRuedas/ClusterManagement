#!/bin/bash

FILE_CONF=$1

#Get parameters from the service configuration file

DIR_REMOTE=`head -n 1 $FILE_CONF`

#check number of arguments
if [ $# -ne 1 ]
then
	echo "Service_BACKUP_S: ERRROR El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "Service_BACKUP_S: Contenido del Fichero de Configuración Perfil de servicio:"
		echo "$DIR_REMOTE"
	else
		echo "Service_BACKUP_S: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 

# Creat Directory for Backup (Root Directory)

mkdir -p $DIR_REMOTE

# Creat Directory for Backup (Exe Directory)

#mkdir -p ./$DIR_REMOTE

if [ $? -ne 0 ]
then 
    echo "Service_BACKUP_S: Error al crear Directorio almacen"
    exit 1
else 
	echo "Service_BACKUP_S: Completado correctamente"
fi
