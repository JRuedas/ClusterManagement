#!bin/bash

FILE_CONF=$*
NIS_DOMAIN_NAME=$(cat $FILE_CONF)


#check number of arguments
if [ $# -ne 1 ]
then
	echo "\nERROR: El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "\nEl contenido del fichero de configuración es: "
		echo $NIS_DOMAIN_NAME

	else
		echo "\nERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#install the tools
echo "\nInstalando heramientas para crear el servidor NIS..."
apt-get update
apt-get install nis >> /dev/null
if [ $? -eq 0 ]
    then echo "\nHeramientas para crear el servidor NIS instaladas"
else
    echo "\nError al instalar NIS"
fi


#modified /etc/defaultdomain to set the domain server
echo "\nModificando fichero /etc/defaultdomain para poner nombre de dominio NIS... " 
echo $NIS_DOMAIN_NAME > /etc/defaultdomain
echo "\nEl fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain

#modified /etc/default/nis to set the role server
echo "\nModificando fichero /etc/default/nis para establecer servidor como master... " 
sed 's/NISSERVER=.*/NISSERVER=master/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=false/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "\nEl fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


#modified /etc/ypserv.securenets to establish the interface for the machines have access
#now give access to everybody, change to network interface
echo "\nEl fichero /etc/ypserv.securenets ha sido modificado, su contenido ahora es: " 
cat /etc/ypserv.securenets
echo "\n"


#modified /etc/hosts to set the domain server
echo "\nModificando fichero /etc/hosts para poner servidor NIS como host... " 
sed "/127.0.1.1/ s/127.0.1.1 .*/127.0.1.1 $NIS_DOMAIN_NAME/g" /etc/hosts > test-file.txt
cat test-file.txt > /etc/hosts
rm test-file.txt
echo "\nEl fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
cat /etc/hosts


#modified /var/yp/Makefile to set the passw and group in the repository
echo "\nModificando fichero /var/yp/Makefile para que contraseñas esten en repositorio... " 
sed 's/^MERGE_PASSWD=.*/MERGE_PASSWD=true/g' /var/yp/Makefile > test-file.txt
sed 's/^MERGE_GROUP=.*/MERGE_GROUP=true/g' test-file.txt > test-file2.txt
echo "\nEl fichero /var/yp/Makefile ha sido modificado, su contenido ahora es: " 
cat test-file2.txt > /var/yp/Makefile
rm test-file.txt test-file2.txt
sed -n '/MERGE_PASSWD=/p' /var/yp/Makefile
sed -n '/MERGE_GROUP=/p' /var/yp/Makefile


#modified the name of the domain server
echo "\nModificando fichero /var/yp/ypservers para volcar la información de configuración al repositorio... " 
sed "s/.*/$NIS_DOMAIN_NAME/g" /var/yp/ypservers > test-file.txt
cat test-file.txt > /var/yp/ypservers
rm test-file.txt
echo "\nEl fichero /var/yp/ypservers ha sido modificado, su contenido ahora es: "
cat /var/yp/ypservers


#set the configuration info to the repository
/usr/lib/yp/ypinit -m > /dev/null
if [ $? -eq 0 ]
    then echo "\nInformación de configuración volcada a repositorio"
else
    echo "\nError al volcar la información al repositorio"
fi


