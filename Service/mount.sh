#!/bin/bash
# File of the service mount 

#Get parameters from the service configuration file

File_Conf_Serv=$1
Name_Dev=`head -n 1 $File_Conf_Serv`
Mount_Point=`tail -n 2 $File_Conf_Serv`

echo "Nombre del dispositivo: $Name_Dev"
echo "Punto de montaje: $Mount_Point"

# Check if device exist

isMounted=`df | grep -o "$Name_Dev"` 

if [ -z "$isMounted" ] 
then
	echo "Service_MOUNT: Error de montado, el dispositivo $Name_Dev no existe o no se puede montar"
fi

echo "Valor de dispositivo $isMounted"

# Check mount point 

if [ -z "$Mount_Point" ] 
then
	echo "Service_MOUNT: Error de montado, falta de punto de montaje"
fi

# Creat a directory with intermediate

mkdir -p $Mount_Point > /dev/null

# Check configuration on fstab and mount

grep -q "$Name_Dev" /etc/fstab 

if [ $? -ne 0 ]
then 
 	echo "$Name_Dev[\t]$Mount_Point[\t]auto[\t]auto[\t]0[\t]0" >> /etc/fstab 
 elif [ $? -ne 0 ]
 	then
 		echo "Service_MOUNT: Error no se ha podido configurar /etc/fstab"
else 
	echo "Service_MOUNT: El dispositivo $Name_Dev ya se encuentra en /etc/fstab"
fi

# mount all file systems mentioned in fstab

mount -a > /dev/null

echo "Service_MOUNT: Servicio Montaje completado correctamente"




