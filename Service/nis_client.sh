#!/bin/bash

FILE_CONF=$*

# Comprueba el número de argumentos
if [ $# -ne 1 ]
then
	echo "ERROR: El número de argumentos no es válido"
	exit 1
else
	# Comprueba que el argumento es un fichero
	if [ -f $FILE_CONF ]
	then 
		echo "Servicio NIS cliente: $FILE_CONF es un fichero"
		NIS_DOMAIN=$(head --lines 1 $FILE_CONF)
		if [ -z  "$NIS_DOMAIN" ]
    			then echo "ERROR: El fichero de configuración debe incluir el dominio del servidor NIS"
    			exit 1
		fi
		NIS_SERVER=$(sed -n 2p $FILE_CONF)
		if [ -z  "$NIS_SERVER" ]
    			then echo "ERROR: El fichero de configuración debe incluir la dirección del servidor NIS"
    			exit 1
		fi

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#Comprueba que la IP del servidor es correcta
ping -c 1 $NIS_SERVER &> /dev/null
if [ $? -eq 0 ]
    then echo "Servicio NIS cliente: La dirección $NIS_SERVER es válida"
else
    echo "ERROR: La dirección $NIS_SERVER es incorrecta"
    exit 1
fi


# Establecer modo no interactivo
export DEBIAN_FRONTEND=noninteractive


# Instalación de las herramientas
echo "Servicio NIS cliente: Instalando heramientas para crear el cliente NIS..."
apt-get -y update > /dev/null 2&>1
apt-get install nis &> /dev/null 
if [ $? -eq 0 ]
    then echo "Servicio NIS cliente: Heramientas para crear el cliente NIS instaladas"
else
    echo "ERROR: No se pudo instalar NIS"
    exit 1
fi


# Modifica /etc/hosts para establecer el dominio del servidor
#echo "Servicio NIS servidor: Modificando fichero /etc/hosts para poner servidor NIS como host... " 
#sed "s/^127\.0\.1\.1.*/127.0.1.1\t$NIS_DOMAIN_NAME/g" /etc/hosts > test-file.txt
#cat test-file.txt > /etc/hosts
#rm test-file.txt

#echo "Servicio NIS servidor: El fichero /etc/hosts ha sido modificado, su contenido ahora es: " 
#cat /etc/hosts


# Modifica /etc/defaultdomain para establecer el dominio del servidor
echo "Servicio NIS servidor: Modificando fichero /etc/defaultdomain para poner nombre de dominio NIS... " 
echo $NIS_DOMAIN > /etc/defaultdomain
echo "Servicio NIS servidor: El fichero /etc/defaultdomain ha sido modificado, su contenido ahora es: " 
cat /etc/defaultdomain


# Modificar /etc/yp.conf para localizar los servidores
echo "Servicio NIS cliente: Modificando fichero /etc/yp.conf para localización de servidores... " 
echo "domain $NIS_DOMAIN server $NIS_SERVER" >> /etc/yp.conf
echo "ypserver $NIS_SERVER" >> /etc/yp.conf
echo "Servicio NIS cliente: El fichero /etc/yp.conf ha sido modificado, su contenido ahora es: " 
cat /etc/yp.conf


# Modificar /etc/default/nis para establecer el rol de cliente
echo "Servicio NIS cliente: Modificando fichero /etc/default/nis para establecer el rol de cliente... " 
sed 's/NISSERVER=.*/NISSERVER=false/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=true/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "Servicio NIS cliente: El fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


# Modificar /etc/nsswitch.conf para establecer que info usará NIS
echo "Servicio NIS cliente: Modificando fichero /etc/nsswitch.conf para establecer que información se usa en NIS... " 
sed '/^passwd:         compat$/ s/passwd:         compat/passwd:         compat nis/g' /etc/nsswitch.conf > test-file.txt
sed '/^group:          compat$/ s/group:          compat/group:          compat nis/g' test-file.txt > test-file2.txt
sed '/^shadow:         compat$/ s/shadow:         compat/shadow:         compat nis/g' test-file2.txt > test-file3.txt
sed '/^hosts:          files dns$/ s/hosts:          files dns/hosts:          files dns nis/g' test-file3.txt > /etc/nsswitch.conf
rm test-file.txt
rm test-file2.txt
rm test-file3.txt
echo "Servicio NIS cliente: El fichero /etc/nsswitch.conf ha sido modificado, su contenido ahora es: " 
cat /etc/nsswitch.conf


# Reinicio del servicio
/etc/init.d/nis restart 
if [ $? -eq 0 ]
    	then echo "Servicio NIS cliente: Servicio reiniciado"
else
    	echo "ERROR: No se pudo reiniciar el servicio"
	exit 1
fi
