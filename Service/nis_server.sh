#!bin/bash

FILE_CONF=$*
NIS_DOMAIN_NAME=$(cat $FILE_CONF)


#check number of arguments
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	#check if the param is a file
	if [ -f $FILE_CONF ]
	then 
		echo "El contenido del fichero de configuración es: "
		echo $NIS_DOMAIN_NAME

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#set the non interactive mode
export DEBIAN_FRONTEND=noninteractive


#install the tools
echo "Instalando heramientas para crear el servidor NIS..."
apt-get -y update > /dev/null 2&>1
apt-get -y install nis > /dev/null
if [ $? -eq 0 ]
    	then echo "Heramientas para crear el servidor NIS instaladas"
else
    	echo "Error al instalar NIS"
	exit 1
fi


#modified /etc/defaultdomain to set the domain server
echo "Modificando fichero /etc/defaultdomain para poner nombre de dominio NIS... " 
echo $NIS_DOMAIN_NAME > /etc/defaultdomain
echo "El fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain


#modified /etc/default/nis to set the role server
echo "Modificando fichero /etc/default/nis para establecer servidor como master... " 
sed 's/NISSERVER=.*/NISSERVER=master/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=false/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "El fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


#modified /etc/ypserv.securenets to establish the interface for the machines have access
#now give access to everybody, change to network interface
echo "El fichero /etc/ypserv.securenets no ha sido modificado para poder dar acceso a toda la interfaz, su contenido es: " 
cat /etc/ypserv.securenets
echo "\n"


#start service
echo "Arrancando servidor NIS..."
#service nis start
if [ $? -eq 0 ]
    	then echo "\nServidor NIS arrancado"
else
    	echo "\nError al arrancar el servidor NIS"
	exit 1
fi


IP=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')

#modified /etc/hosts to set the domain server
echo "Modificando fichero /etc/hosts para poner servidor NIS como host... " 
sed 's/<regex>/text/gd'
sed "s/^127\.0\.1\.1.*/127.0.1.1\t$NIS_DOMAIN_NAME/g" /etc/hosts > test-file.txt
cat test-file.txt > /etc/hosts
rm test-file.txt
echo "El fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
cat /etc/hosts


#modified /var/yp/Makefile to set the passw and group in the repository
echo "Modificando fichero /var/yp/Makefile para que contraseñas esten en repositorio... " 
sed 's/^MERGE_PASSWD=.*/MERGE_PASSWD=true/g' /var/yp/Makefile > test-file.txt
sed 's/^MERGE_GROUP=.*/MERGE_GROUP=true/g' test-file.txt > test-file2.txt
echo "El fichero /var/yp/Makefile ha sido modificado, su contenido ahora es: " 
cat test-file2.txt > /var/yp/Makefile
rm test-file.txt test-file2.txt
sed --quiet '/MERGE_PASSWD=/p' /var/yp/Makefile
sed --quiet '/MERGE_GROUP=/p' /var/yp/Makefile


#update NIS database
echo "Volcando información de configuración al repositorio..."
#/usr/lib/yp/ypinit -m > /dev/null
if [ $? -eq 0 ]
    	then echo "Información de configuración volcada a repositorio"
else
    	echo "Error al volcar la información al repositorio"
	exit 1
fi


