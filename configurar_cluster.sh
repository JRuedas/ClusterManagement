#!/bin/bash

echo "Script Principal: Iniciando administrador de servicios" 

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
		echo "ERROR: $file no es un fichero."
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

	echo "Script Principal: Parametros de la linea $Num_LIN $IP $SERVICE $FILE_CONF_SERV" 

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
	
	# Copy configuration file to Configuration folder
	if [ ! -f $FILE_CONF_SERV ]
	then
		echo "ERROR: El fichero: $FILE_CONF_SERV no existe."
		exit 1
	fi

	cp $FILE_CONF_SERV ./Configuration
	FILE_CONF_SERV=$(basename $FILE_CONF_SERV)

	# Remove directory
	echo "Script Principal: Limpiando estado de anteriores ejecuciones. Borrando directorio ProyectoASI ..."
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP 'rm -Rf /tmp/ProyectoASI' > /dev/null 2>&1 || { 
		echo "ERROR: No se puedo borrar el directorio ProyectoASI"
		exit 1
	}
	echo "Script Principal: Directorio borrado correctamente"
	
	# Create directory 
	echo "Script Principal: Creando el directorio ProyectoASI en /tmp ..."
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP 'mkdir /tmp/ProyectoASI' > /dev/null 2>&1 || { 
		echo "ERROR: No se puedo crear el directorio ProyectoASI"
		exit 1
	}
	echo "Script Principal: Se ha creado el directorio ProyectoASI"


	# Copy configuration directory
	echo "Script Principal: Copiando directorio Configuration..."
	scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r ./Configuration root@$IP:/tmp/ProyectoASI > /dev/null 2>&1 || { 
		echo "ERROR: No se puedo copiar el directorio Configuration"
		exit 1
	}
	echo "Script Principal: Directorio Configuration copiado"


	# Copy service directory
	echo "Script Principal: Copiando directorio Service..."
	scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -r ./Service root@$IP:/tmp/ProyectoASI > /dev/null 2>&1 || { 
		echo "ERROR: No se puedo copiar el directorio Service"
		exit 1
	}
	echo "Directorio Service copiado"
	

	# Execute mandate
	echo "Script Principal: Dando permisos de ejecución..."
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP "chmod +x /tmp/ProyectoASI/Service/$SCRIPT" > /dev/null 2>&1 || { 
		echo "ERROR: No se pudo dar permisos de ejecución al script"
		exit 1
	}

	# Run script
	echo "Script Principal: Ejecutando script..."
	ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$IP "/tmp/ProyectoASI/Service/$SCRIPT /tmp/ProyectoASI/Configuration/$FILE_CONF_SERV" || { 
		echo "ERROR: No se pudo ejecutar el script con su fichero de configuración"
		exit 1
	}
	
done

echo "Script Principal: Administrador de servicios finalizado"
