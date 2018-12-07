#!/bin/bash
# File of the service mount 

#Get parameters from the service configuration file

File_Conf_Serv=$1
Name_Dev=`head -n 1 $File_Conf_Serv`
Mount_Point=`tail -n 2 $File_Conf_Serv`

echo "Nombre del dispositivo: $Name_Dev"
echo "Punto de montaje: $Mount_Point"

# Check if device exist

isMounted=`df | grep -o $Name_Dev` 

if [ -z "$Name_Dev"] 
then
	echo "Service_MOUNT: Error de montado, el dispositivo $Name_Dev no existe o no se puede montar"
fi

echo "Valor de dispositivo $isMounted"

# Creat a directory with intermediate

mkdir -p $Mount_Point > /dev/null


