#!/bin/bash
# File of the service mount 

#Get parameters from the service configuration file

File_Conf_Serv=$1
Name_Dev=`head -n 1 $File_Conf_Serv`
Mount_Point=`tail -n 1 $File_Conf_Serv`

echo "Nombre del dispositivo: $Name_Dev"
echo "Punto de montaje: $Mount_Point"

# Check if device exist

isMounted=`ls -l /dev/sd* | grep -o $Name_Dev` 
echo "valor del dispositivo: $isMounted"
 
if [ -z "$isMounted" ] 
then
	echo "Service_MOUNT: Error de montado, el dispositivo $Name_Dev no existe o no se puede montar"
fi


# Check mount point 

if [ -z "$Mount_Point" ] 
then
	echo "Service_MOUNT: Error de montado, falta de punto de montaje"
fi

# Creat a directory with intermediate

mkdir -p ./$Mount_Point > /dev/null

# Check configuration on fstab and mount

grep -o "$Name_Dev" /etc/fstab > /dev/null 

if [ $? -ne 0 ]
then 
    echo "El dispositivo no esta en fstab" 
    echo "$Name_Dev $Mount_Point auto auto 0 0" >> /etc/fstab 
fi
 
if [ $? -ne 0 ]
then 
	echo "Service_MOUNT: El dispositivo $Name_Dev copiado en /etc/fstab"
fi

# mount all file systems mentioned in fstab

#mount -a > /dev/null

#echo "Service_MOUNT: Servicio Montaje completado correctamente"




