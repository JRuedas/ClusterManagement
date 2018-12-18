#!/bin/bash

#Get parameters from the service configuration file

FILE_CONF=$1

DIR_LOC=`head -n 1 $FILE_CONF`
IP=`sed -n 2p $FILE_CONF`  
DIR_REM=`sed -n 3p $FILE_CONF` 
TIME=`tail -n 1 $FILE_CONF`

echo "Service_BACKUP_C: Directorio a copiar $DIR_LOC"
echo "Service_BACKUP_C: Dirección Ip del Servidor de Backup $IP"
echo "Service_BACKUP_C: Directorio Remoto $DIR_REM"
echo "Service_BACKUP_C: Periocidad $TIME"


