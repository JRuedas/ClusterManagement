#!bin/bash

FILE_CONF=$*
NIS_DOMAIN=$(head --lines 1 $FILE_CONF)
NIS_SERVER=$(tail --lines 1 $FILE_CONF)

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
		cat $FILE_CONF

	else
		echo "\nERROR: $FILE_CONF no es un fichero"
		exit 1
	fi 
fi 


#set the non interactive mode
export DEBIAN_FRONTEND=noninteractive


#install the tools
echo "\nInstalando heramientas para crear el cliente NIS..."
apt-get update
apt-get install nis
if [ $? -eq 0 ]
    then echo "\nHeramientas para crear el cliente NIS instaladas"
else
    echo "\nError al instalar NIS"
fi


#modified /etc/default/nis to set the client role
echo "\nModificando fichero /etc/default/nis para establecer el rol de cliente... " 
sed 's/NISSERVER=.*/NISSERVER=false/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=.*/NISCLIENT=true/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "\nEl fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis


#modified /etc/yp.conf to localize the servers
echo "\nModificando fichero /etc/yp.conf para localización de servidores... " 
sed "/ypserver ip-servidor-nis/ s/ypserver ip-servidor-nis/$NIS_DOMAIN $NIS_SERVER/g" /etc/yp.conf > test-file.txt
cat test-file.txt > /etc/yp.conf
echo "\nEl fichero /etc/yp.conf ha sido modificado, su contenido ahora es: " 
cat /etc/yp.conf


#modified /etc/nsswitch.conf to set what info is to use NIS
echo "\nModificando fichero /etc/nsswitch.conf para establecer que información se usa en NIS... " 
sed '/^passwd:         compat$/ s/passwd:         compat/passwd:         compat nis/g' /etc/nsswitch.conf > test-file.txt
sed '/^group:          compat$/ s/group:          compat/group:          compat nis/g' test-file.txt > test-file2.txt
sed '/^shadow:         compat$/ s/shadow:         compat/shadow:         compat nis/g' test-file2.txt > test-file3.txt
sed '/^hosts:          files dns$/ s/hosts:          files dns/hosts:          files dns nis/g' test-file3.txt > /etc/nsswitch.conf
rm test-file.txt
rm test-file2.txt
rm test-file3.txt
echo "\nEl fichero /etc/nsswitch.conf ha sido modificado, su contenido ahora es: " 
cat /etc/nsswitch.conf

#start service





