#!/bin/bash

# Comprobación número de argumentos

if [ $# -ne 1 ]
then 
	echo "Uso: El número de argumnetos no es válido"
	exit 1
fi 


F_CONF=$1

F_C_FORMAT=`grep -E -v '^(#|$)' $1`

 echo $F_C_FORMAT

exit 0