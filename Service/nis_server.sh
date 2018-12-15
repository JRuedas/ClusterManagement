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
apt-get update
apt-get install nis
if [ $? -eq 0 ]
    then echo "\nHeramientas para crear el servidor NIS instaladas"
else
    echo "\nError al instalar NIS"
fi

echo $NIS_DOMAIN_NAME > /etc/defaultdomain
echo "\nEl fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain

sed 's/NISSERVER=.*/NISSERVER=master/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=false/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "\nEl fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis

# modificar y poner dir broadcast y dir de red /etc/ypserv.securenets
cat /etc/ypserv.securenets
echo "\n"

sed "/127.0.1.1/ s/127.0.1.1 .*/127.0.1.1 $NIS_DOMAIN_NAME/g" /etc/hosts > test-file.txt
cat test-file.txt > /etc/hosts
rm test-file.txt
echo "\nEl fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
cat /etc/hosts


sed 's/^MERGE_PASSWD=.*/MERGE_PASSWD=true/g' /var/yp/Makefile > test-file.txt
sed 's/^MERGE_GROUP=.*/MERGE_GROUP=true/g' test-file.txt > test-file2.txt
echo "\nEl fichero /var/yp/Makefile ha sido modificado, su contenido ahora es: " 
sed -n '/MERGE_PASSWD=/p' test-file2.txt
sed -n '/MERGE_GROUP=/p' test-file2.txt


# cambiar el nombre del servidor nis
sed "s/.*/$NIS_DOMAIN_NAME/g" /var/yp/ypservers > test-file.txt
cat test-file.txt > /var/yp/ypservers
rm test-file.txt
echo "\nEl fichero /var/yp/ypservers ha sido modificado, su contenido ahora es: "
cat /var/yp/ypservers

/usr/lib/yp/ypinit -m 
if [ $? -eq 0 ]
    then echo "\nInformación de configuración volcada a repositorio"
else
    echo "\nError al volcar la información al repositorio"
fi
 
make -C /var/yp
if [ $? -eq 0 ]
    then echo "\nRepositorio actualizado"
else
    echo "\nError al actualizar repositorio"
fi

#duda como sustituir hostname en actualizacion de fichero



