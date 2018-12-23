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
		echo "Servicio NIS cliente: El contenido del fichero de configuración es: "
		cat $FILE_CONF
		NIS_DOMAIN=$(head --lines 1 $FILE_CONF)
		NIS_SERVER=$(tail --lines 1 $FILE_CONF)

	else
		echo "ERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


# Establecer modo no interactivo
export DEBIAN_FRONTEND=noninteractive


# Instalación de las herramientas
echo "Servicio NIS cliente: Instalando heramientas para crear el cliente NIS..."
apt-get -y update > /dev/null 2&>1
apt-get install nis 
if [ $? -eq 0 ]
    then echo "Servicio NIS cliente: Heramientas para crear el cliente NIS instaladas"
else
    echo "ERROR: No se pudo instalar NIS"
    exit 1
fi


# Modificar /etc/default/nis para establecer el rol de cliente
echo "Servicio NIS cliente: Modificando fichero /etc/default/nis para establecer el rol de cliente... " 
sed 's/NISSERVER=.*/NISSERVER=false/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=true/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "Servicio NIS cliente: El fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


# Modificar /etc/yp.conf para localizar los servidores
echo "Servicio NIS cliente: Modificando fichero /etc/yp.conf para localización de servidores... " 
sed "s/# ypserver ypserver.network.com/$NIS_SERVER $NIS_SERVER/g" /etc/yp.conf > test-file.txt
cat test-file.txt > /etc/yp.conf
echo "Servicio NIS cliente: El fichero /etc/yp.conf ha sido modificado, su contenido ahora es: " 
rm test-file.txt
cat /etc/yp.conf

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

