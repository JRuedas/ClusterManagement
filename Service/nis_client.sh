#!bin/bash


#install the tools
#apt-get update
#apt-get install nis
#echo "\nHeramientas para crear el servidor NIS instaladas"

#Modified config files

sed 's/NISSERVER=$/NISSERVER=false/g' /etc/default/nis > test-file.txt
sed 's/NISCLIENT=$/NISCLIENT=true/g' test-file.txt > /etc/default/nis
rm test-file.txt
echo "\nEl fichero /etc/default/nis ha sido modificado, su contenido ahora es: " 
cat /etc/default/nis

sed -i '$a ypserver ip-servidor-nis' /etc/yp.conf
cat /etc/yp.conf