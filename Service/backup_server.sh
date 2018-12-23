#!/bin/bash

echo "Servicio BACKUP SV: Iniciando servicio BACKUP SERVIDOR"

FILE_CONF=$1

#Comprobar argumentos

if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "Servicio BACKUP SV: Contenido del Fichero de Configuración Perfil de servicio:"
		echo "$DIR_REMOTE"
	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 

#Obtener los parametros del fichero de perfil de configuracion de servicio

DIR_REMOTE=`head -n 1 $FILE_CONF`

#Crear Directorio de Backup

mkdir -p $DIR_REMOTE

if [ $? -ne 0 ]
then 
    echo "ERROR: Al crear Directorio almacén"
    exit 1
fi

# Comprobar si el Directorio esta vacio

if [ "$(ls -A $DIR_REMOTE)" ] 
	then 
	 echo "ERROR: no se puede usar $DIR_REMOTE como alamacén, no está vacío" 
	 exit 1
else
	 echo "Servicio BACKUP SV: Servicio Backup Servidor completado"
fi 

