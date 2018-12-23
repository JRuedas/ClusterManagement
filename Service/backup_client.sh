#!/bin/bash

echo "Servicio BACKUP CL: Iniciando servicio BACKUP CLIENTE"

#Exportar DEBIAN_FRONTEND con el valor noninteractive para forzar la instalacion de herramientas

export DEBIAN_FRONTEND=noninteractive

#Obtener los parametros del fichero de perfil de configuracion de servicio

FILE_CONF=$1

DIR_LOC=`head -n 1 $FILE_CONF`
IP=`sed -n 2p $FILE_CONF`  
DIR_REM=`sed -n 3p $FILE_CONF` 
TIME=`sed -n 4p $FILE_CONF`

#Comprobar Numero de argumentos
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#Comprobar si es un fichero
	if [ ! -f $FILE_CONF ]
	then
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 

echo "Servicio BACKUP CL: Directorio a copiar $DIR_LOC"
echo "Servicio BACKUP CL: Dirección Ip del Servidor de Backup $IP"
echo "Servicio BACKUP CL: Directorio Remoto $DIR_REM"
echo "Servicio BACKUP CL: Periocidad $TIME"

# Comprobar la existencia del Directorio Local 

if [ ! -d $DIR_LOC ]
then 
	echo "ERROR: El directorio local pasado como argumento no es un directorio"
	exit 1
fi

# Comprobar conexion con la maquina Servidor 

ping -c3 $IP > /dev/null 2>&1 || { 
		echo "ERROR: Dirección IP: $IP no encontrada"
		exit 1
	}
echo "Servicio BACKUP CL: Conexión correcta con el servidor de backup $IP"

# Comprobar la existencia del Directorio Remoto

echo "Servicio BACKUP CL: Comprobando la existencia del directorio Remoto..."
ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP "test -d $DIR_REM" > /dev/null 2>&1 || { 
		echo "ERROR: No existe el directorio remoto de almacenamiento en el Servidor de Backup"
		exit 1
	}

echo "Servicio BACKUP CL: Existe el Directorio Remoto de almacenamiento"


# Instalar herramientas

echo "Servicio BACKUP CL: Instalando herramienta de backup Rsync..."

apt-get install rsync > /dev/null 2>&1 || { 
		echo "ERROR: no se han podido instalar la herramineta rysinc"
		exit 1
	}
echo "Servicio BACKUP CL: Herramienta Rsync instalada correctamente"

# Crear el Demonio

isCreated=`cat /etc/crontab |  grep -o "$DIR_LOC root@$IP:$DIR_REM"`


if [ -z "$isCreated" ]
then 
    echo "Servicio BACKUP CL: Demonio no existe"
    # Demonio rsync con OPTIONS: -a = -rlptgoD (recursive, links, permissions, times, groups, owner, diveces)  
    #                            -z = zip
    echo "* */$TIME * * * root rsync -az $DIR_LOC root@$IP:$DIR_REM" >> /etc/crontab
    echo "Servicio BACKUP CL: Demonio creado correctamente"
else
    echo "Servicio BACKUP CL: Demonio ya existe"
fi

echo "Servicio BACKUP CL: Servicio Backup cliente completado"
