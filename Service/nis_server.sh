#!bin/bash

FILE_CONF=$*
NIS_DOMAIN_NAME=$(cat $FILE_CONF)

# Check number of arguments
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#Check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "El contenido del fichero de configuración es: "
		echo $NIS_DOMAIN_NAME

	else
		echo "ERROR: $FILE_CONF no existe o no es un fichero"
		exit 1
	fi 
fi 


#install the tools
#apt-get update
#apt-get install nis
#echo "Heramientas para crear el RAID instaladas"

#Modified the config files

sed '1d' /etc/defaultdomain > test-file.txt
echo $NIS_DOMAIN_NAME > /etc/defaultdomain
rm test-file.txt
echo "El fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain

sed 's/NISSERVER=false/NISSERVER=true/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=true/NISCLIENT=false/g' test-file.txt > test-file-final.txt
rm /etc/default/nis
rm test-file.txt
mv test-file-final.txt /etc/default/nis

echo "El fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis