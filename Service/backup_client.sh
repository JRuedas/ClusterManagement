#!/bin/bash

# Export DEBIAN_FRONTEND with value noninteractive to force the install of tools

export DEBIAN_FRONTEND=noninteractive

#Get parameters from the service configuration file

FILE_CONF=$1

DIR_LOC=`head -n 1 $FILE_CONF`
IP=`sed -n 2p $FILE_CONF`  
DIR_REM=`sed -n 3p $FILE_CONF` 
TIME=`tail -n 1 $FILE_CONF`

if [ $# -ne 1 ]
then
	echo "Service_BACKUP_C: ERROR El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ ! -f $FILE_CONF ]
	then
		echo "Service_BACKUP_C: ERROR,  $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 

echo "Service_BACKUP_C: Directorio a copiar $DIR_LOC"
echo "Service_BACKUP_C: Dirección Ip del Servidor de Backup $IP"
echo "Service_BACKUP_C: Directorio Remoto $DIR_REM"
echo "Service_BACKUP_C: Periocidad $TIME"

# Check Local Directory

if [ ! -d $DIR_LOC ]
then 
	echo "Service_BACKUP_C: ERROR, El directorio Local pasado como argumento no es un directorio"
	exit 1
fi



# Check IP of Backup Server

ping -c3 $IP > /dev/null 2>&1 || { 
		echo "Service_BACKUP_C: ERROR, Dirección IP: $IP no encontrada"
		exit 1
	}
echo "Service_BACKUP_C: Conexión correcta con el servidor de backup $IP"

# Check Remote Directory

echo "Service_BACKUP_C: Comprobando la existencia del directorio Remoto..."
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP "test -d $DIR_REM" > /dev/null 2>&1 || { 
		echo "Service_BACKUP_C: ERROR, No existe el directorio remoto de almacenamiento en el Servidor de Backup"
		exit 1
	}

echo "Service_BACKUP_C: Existe el Directorio Remoto de almacenamiento"


# install the tools
# update tools 

#apt-get update > /dev/null 2>&1 || { 
#		echo "Service_BACKUP_C: ERROR, no se han podido actualizar los repositorios de instalación"
#		exit 1
#	}


echo "Service_BACKUP_C: Instalando herramienta de backup Rysinc..."

apt-get install rsync > /dev/null 2>&1 || { 
		echo "Service_BACKUP_C: ERROR, no se han podido instalar la herramineta rysinc"
		exit 1
	}
echo "Service_BACKUP_C: Herramienta Rysinc instalada correctamente"

# Creat Demon 

isCreated=`cat /etc/crontab |  grep -o "$DIR_LOC root@$IP:$DIR_REM"`

#echo "Valor de retorno: $?"

if [ -z "$isCreated" ]
then 
    echo "Service_BACKUP_C: Demonio no existe"
    # Demon rsync with OPTIONS: -a = -rlptgoD (recursive, links, permissions, times, groups, owner, diveces)  
    #                           -z = zip
    echo "* */$TIME * * * root rsync -az $DIR_LOC root@$IP:$DIR_REM" >> /etc/crontab
    echo "Service_BACKUP_C: Demonio creado correctamente"
else
    echo "Service_BACKUP_C: Demonio ya existe"
fi

echo "Service_BACKUP_C: Servicio Backup cliente completado"
