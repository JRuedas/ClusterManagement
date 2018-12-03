#!/bin/bash
# File of the service mount 

linea=0
for comand in $(cat $1); do
	if [ $linea = 0 ]
	then
		#Nombre Dispositivo
		NOMBRE_DEL_DISPOSITIVO=$comand
	elif [ $linea = 1 ]
	then
		#Punto de Montaje
		PUNTO_DE_MONTAJE=$comand
	fi
	let linea+=1
done


echo "Nombre del dispositivo: $NOMBRE_DEL_DISPOSITIVO"
echo "Punto de montaje: $PUNTO_DE_MONTAJE"

File_Conf_Serv=$1
Name_Dev=`head -n 1 $File_Conf_Serv`
Mount_Point=`tail -n 2 $File_Conf_Serv`

echo "Nombre del dispositivo: $Name_Dev"
echo "Punto de montaje: $Mount_Point"

if [ "$PUNTO_DE_MONTAJE" = "$Mount_Point" ]
then 
	echo "Son iguales"
else
	echo "No sonn iguales"
fi


