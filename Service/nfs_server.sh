#!bin/bash

FILE_CONF=$*

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
		cat $FILE_CONF

	else
		echo "\nERROR: $FILE_CONF no existe o no es un fichero"
		exit 1
	fi 
fi 


#install the tools
#apt-get update
#apt-get install nfs-kernel-server
if [ $? -eq 0 ]
    then echo "\nHeramientas para crear el servidor NFS instaladas"
else
    echo "\nError al instalar NFS"
fi

#modified /etc/idmapd.conf

#sed '/^# Domain = .*/ s/^# Domain = .*/# Domain = newDomain/g' /etc/idmapd.conf
#duda si debe hacerse

#modifed /etc/exports 

c=0
for line in $(cat $FILE_CONF)
do
	eval "var$c=$line";
	c=$((c+1));
done

echo $var0

ifconfig > file-test.txt

sed --silent '/inet addr:/{p;}' file-test.txt > file-test2.txt
IP=$(cat file-test2.txt | cut -d " " -f2)
echo "$IP"

rm file-test.txt file-test2.txt

#sed "/^$/ s/^$/$var0 /g" /etc/exports 

#servidor:dir_exportado punto_de_monatje nfs defaults
#/home 10.0.2.0/24(rw,sync,no_subtree_check)



