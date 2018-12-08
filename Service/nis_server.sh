#!bin/bash

FILE_CONF=$*
NIS_DOMAIN_NAME=$(cat $FILE_CONF)

# Check number of arguments
if [ $# -ne 1 ]
then
	echo "\nERROR: El número de argumentos no es válido"
	exit 1
else
	#Check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "\nEl contenido del fichero de configuración es: "
		echo $NIS_DOMAIN_NAME

	else
		echo "\nERROR: $FILE_CONF no existe o no es un fichero"
		exit 1
	fi 
fi 


#install the tools
#apt-get update
#apt-get install nis
#echo "\nHeramientas para crear el servidor NIS instaladas"

#Modified the config files

sed '1d' /etc/defaultdomain > test-file.txt
echo $NIS_DOMAIN_NAME > /etc/defaultdomain
rm test-file.txt
echo "\nEl fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain

sed 's/NISSERVER=false/NISSERVER=true/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=true/NISCLIENT=false/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "\nEl fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis

# modificar y poner dir broadcast y dir de red /etc/ypserv.securenets

sed 's/127.0.1.1$/127.0.1.1 '$NIS_DOMAIN_NAME' /g' /etc/hosts > test-file.txt
cat test-file.txt | /etc/hosts
rm test-file.txt
echo "\nEl fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
cat /etc/hosts

#Comprobar grupos y UID de usuarios para tener acceso al server /var/yp/Makefile


