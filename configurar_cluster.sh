#!/bin/bash

# Check number of arguments

if [ $# -ne 1 ]
then 
	echo "ERROR: El número de argumentos no es válido"
	exit 1
fi 

# Check files  

file_service="mount.sh raid.sh lvm.sh nis_server.sh nis_client.sh nfs_server.sh nfs_client.sh backup_client.sh backup_server.sh"

for file in $file_service; do
	if [ ! -f "./Service/$file" ]
	then
		echo "ERROR: Fichero $file no disponible."
		exit 1
	fi
done


F_CONF=$1
F_C_FORMAT=`grep -E -v '^(#|$)' $F_CONF`

Num_LIN=1 
IFS=$'\n' 


for service in $F_C_FORMAT 
do
	IFS=$' '
	IP=`echo $service | cut -d " " -f1` 
	SERVICE=`echo $service | cut -d " " -f2` 
	FILE_CONF_SERV=`echo $service | cut -d " " -f3`

	echo "Parametros de la linea: $Num_LIN $IP $SERVICE $FILE_CONF_SERV" 
   
	let Num_LIN+=1

	case $SERVICE in
		mount )
			SCRIPT=mount.sh
			;;
		raid )
			SCRIPT=raid.sh
			;;
		lvm )
			SCRIPT=lvm.sh
			;;
		nis_server )
			SCRIPT=nis_server.sh
			;;
		nis_client )
			SCRIPT=nis_client.sh
			;;
		nfs_server )
			SCRIPT=nfs_server.sh
			;;
		nfs_client )
			SCRIPT=nfs_client.sh
			;;
		backup_server )
			SCRIPT=backup_server.sh
			;;
		backup_client )
			SCRIPT=backup_client.sh
			;;
		*)
			echo "ERROR: Tratamiento del servicio $SERVICE"
			exit 1
			;;
	esac

	ssh root@$IP 'mkdir ~/ProyectoASI/' > /dev/null 2>&1 || { 
		echo "ERROR: Creación carpeta del proyecto"
		exit 1
	}

	scp ./Configuration/$FILE_CONF_SERV root@$IP:~/ProyectoASI/$FILE_CONF_SERV > /dev/null 2>&1
	scp $SCRIPT root@$2:~/ProyectoASI/servicio > /dev/null 2>&1
	scp ./Service/$SCRIPT root@$MAQUINA:~/$SCRIPT > /dev/null 2>&1

	ssh root@$MAQUINA "chmod +x ~/ProyectoASI/$SCRIPT" > /dev/null 2>&1
	ssh root@$MAQUINA "~/ProyectoASI/$SCRIPT ~/ProyectoASI/$FILE_CONF_SERV" 2>&1

	ssh root@$MAQUINA 'rm -r ~/ProyectoASI/' > /dev/null 2>&1


done
exit 0