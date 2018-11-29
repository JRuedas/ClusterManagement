#!/bin/bash

# Comprobación número de argumentos

if [ $# -ne 1 ]
then 
	echo "Uso: El número de argumnetos no es válido"
	exit 1
fi 

F_CONF=$1
F_C_FORMAT=`grep -E -v '^(#|$)' $F_CONF`

Num_LIN=1 
IFS=$'\n' 

# 1  
#for servicio in $F_C_FORMAT; do
#	#Hacemos que el espacio separe las variables
#	IFS=$' '
#	echo $Num_LIN $servicio   # Sacamos Nº linea, máquina, servicio, fichero de conf serv 
#	let Num_LIN+=1
#done

# 2
for service in $F_C_FORMAT 
do
	IFS=$' '
    IP=`echo $service | cut -d " " -f1` 
    SERVICE=`echo $service | cut -d " " -f2` 
 	FILE_CONF_SERV=`echo $service | cut -d " " -f3`

    echo $Num_LIN $IP $SERVICE $FILE_CONF_SERV 
    # funcion $Num_LIN $IP $SERVICE $FILE_CONF_SERV
    let Num_LIN+=1
done
 

exit 0