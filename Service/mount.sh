#!/bin/bash
 
echo "Servicio MOUNT: Iniciando servicio MOUNT"

# Comprobamos si el numero de parámetros es correcto y el fichero de configuracion existe

if [ $# -ne 1 ]; then
	echo "ERROR: Numero de parametros incorrecto"
	exit 1
fi

if [ ! -f $1 ]; then
	echo "ERROR: El fichero especificado no existe"
	exit 1
fi

#Obtener los parametros del fichero de perfil de configuracion de servicio

File_Conf_Serv=$1
Name_Dev=`head -n 1 $File_Conf_Serv`
Mount_Point=`sed -n 2p $File_Conf_Serv`  


echo "Servicio MOUNT: Nombre del dispositivo: $Name_Dev"
echo "Servicio MOUNT: Punto de montaje: $Mount_Point"

# Comprobar que el dispositivo existe

isMounted=`ls -l /dev/sd* | grep -o $Name_Dev` 
 
if [ -z "$isMounted" ] 
then
    echo "ERROR: El dispositivo $Name_Dev no existe o no se puede montar"
    exit 1
fi

# Comprobar Punto de Montaje

if [ -z "$Mount_Point" ] 
then
	echo "ERROR: Falta de punto de montaje"
	exit 1
fi

# Crear un direcctorio con intermediarios (Opciones: -p, --parents)

mkdir -p $Mount_Point > /dev/null

# Comprobar existencia del montaje en /etc/fstab

grep -o "$Name_Dev" /etc/fstab > /dev/null 

if [ $? -ne 0 ]
then 
    echo "Servicio MOUNT: El dispositivo no está en fstab" 
    echo "$Name_Dev $Mount_Point auto auto 0 0" >> /etc/fstab 
else 
    echo "Servicio MOUNT: El dispositivo $Name_Dev ya está en /etc/fstab"
fi
 
if [ $? -eq 0 ]
then 
    echo "Servicio MOUNT: El dispositivo $Name_Dev adjuntado a /etc/fstab"
fi

# Montar todos los ficheros de sistema mencionados en fstab

mount -a > /dev/null

if [ $? -eq 0 ]
then
	echo "Servicio MOUNT: Dispositivo $Name_Dev montado correctamente en $Mount_Point"
    echo "Servicio MOUNT: Servicio Montaje completado"    
else 
    echo "ERROR: Error al finalizar montaje"
    exit 1
fi 
