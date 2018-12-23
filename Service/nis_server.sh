#!/bin/bash

FILE_CONF=$*
NIS_DOMAIN_NAME=$(cat $FILE_CONF)


# Comprobación del número de argumentos
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	# Comprobar que el argumento es un fichero
	if [ -f $FILE_CONF ]
	then 
		echo "Servicio NIS servidor: El contenido del fichero de configuración es: "
		echo $NIS_DOMAIN_NAME

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


# Establecer modo no interactivo
export DEBIAN_FRONTEND=noninteractive


# Instalación de las herramientas
echo "Servicio NIS servidor: Instalando heramientas para crear el servidor NIS..."
apt-get -y update > /dev/null 2&>1
apt-get -y install nis > /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio NIS servidor: Heramientas para crear el servidor NIS instaladas"
else
    	echo "ERROR: No se pudo instalar NIS"
	exit 1
fi


# Modifica /etc/defaultdomain para establecer el dominio del servidor
echo "Servicio NIS servidor: Modificando fichero /etc/defaultdomain para poner nombre de dominio NIS... " 
echo $NIS_DOMAIN_NAME > /etc/defaultdomain
echo "Servicio NIS servidor: El fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain


# Modifica /etc/default/nis para establcer el rol de servidor (master)
echo "Servicio NIS servidor: Modificando fichero /etc/default/nis para establecer servidor como master... " 
sed 's/NISSERVER=.*/NISSERVER=master/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=false/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "Servicio NIS servidor: El fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


# Modifica /etc/ypserv.securenets para estbalecer la interfaz a la que se da acceso a las máquinas
# Permite acceso a todos
echo "Servicio NIS servidor: El fichero /etc/ypserv.securenets no ha sido modificado, por defecto da acceso a todos, su contenido es: " 
cat /etc/ypserv.securenets


# Arranca servicio
echo "Servicio NIS servidor: Arrancando servidor NIS..."
service nis start
if [ $? -eq 0 ]
    	then echo "Servicio NIS servidor: Servidor NIS arrancado"
else
    	echo "ERROR: No se pudo arrancar el servidor NIS"
	exit 1
fi


IP=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')

# Modifica /etc/hosts para establecer el dominio del servidor
echo "Servicio NIS servidor: Modificando fichero /etc/hosts para poner servidor NIS como host... " 
sed "s/^127\.0\.1\.1.*/127.0.1.1\t$NIS_DOMAIN_NAME/g" /etc/hosts > test-file.txt
cat test-file.txt > /etc/hosts
rm test-file.txt

echo "Servicio NIS servidor: El fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
cat /etc/hosts


# Modifica /var/yp/Makefile para establecer la contraseña y el grupo en el repositorio
echo "Servicio NIS servidor: Modificando fichero /var/yp/Makefile para que contraseñas esten en repositorio... " 
sed 's/^MERGE_PASSWD=.*/MERGE_PASSWD=true/g' /var/yp/Makefile > test-file.txt
sed 's/^MERGE_GROUP=.*/MERGE_GROUP=true/g' test-file.txt > test-file2.txt

echo "Servicio NIS servidor: El fichero /var/yp/Makefile ha sido modificado, su contenido ahora es: " 
cat test-file2.txt > /var/yp/Makefile
rm test-file.txt test-file2.txt
sed --quiet '/MERGE_PASSWD=/p' /var/yp/Makefile
sed --quiet '/MERGE_GROUP=/p' /var/yp/Makefile


# Actualiza la base de datos de NIS 
echo "Servicio NIS servidor: Volcando información de configuración al repositorio..."
EOF 2> /dev/null | /usr/lib/yp/ypinit -m &> /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio NIS servidor: Información de configuración volcada a repositorio"
else
    	echo "ERROR: No se pudo volcar la información al repositorio"
	exit 1
fi


# Reinicia el servicio
echo "Servicio NIS servidor: Reiniciando el servicio NIS..."
/etc/init.d/nis restart &> /dev/null
if [ $? -eq 0 ]
    	then echo "Servicio NIS servidor: Servicio reiniciado"
else
    	echo "ERROR: No se pudo reiniciar el servicio"
	exit 1
fi




