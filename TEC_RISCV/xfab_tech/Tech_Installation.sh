#!/usr/bin/env bash

###################################################################################################
## Title:		Tech_Installation.sh							 
## Description:		Script de descompresión de archivos .zip o .tar.gz para instalar de forma
## 			automatica los archivos de la tecnologia de integracion XFAB de 180nm	 
## Dependencies: 	Ninguna. 								 
## Project:		Microcontrolador RISCV							 
## Author:		Reinaldo Castro Gonzalez						 
## Institution:		Instituto Tecnologico de Costa Rica. DCILab				 
## Date:		12 de Febrero de 2018							 
## Notes:		Se anaden funcionalidades como pedir la ruta de archivos fuente, busqueda
##			recursiva, manejo de excepciones, soportar archivos con extension tar.gz 					 
## Version:		2.0									 
## Revision:		05/03/2018								 
###################################################################################################

# Variables de ruta

# Pedir al usuario la direccion del directorio fuente para buscar los archivos a instalar 
echo 'Introduzca la direccion absoluta al directorio fuente de los instalables:'
read DIR_A; # Directorio Fuente. Leer el dato del teclado y guardarlo en la variable de usuario DIR_A 
DIR_B="/mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams"; # Directorio Destino.

# Se verifica si los directorios existen; es decir, que las variables contengan rutas validas.
if [ ! -d $DIR_A ]; then
	echo "El directorio fuente es invalido";
	exit;
elif [ ! -d $DIR_B ]; then
	echo "El directorio destino es invalido";
	exit;
else
	
	# Se crea un arreglo para guardar los elementos contenidos en el directorio fuente.
	list=("$(find $DIR_A -name '*.tar.gz')") || list=("$(find $DIR_A -name '*.zip')");
	array=($list);

	# Se verifica si hay archivos para extraer o instalar. Caso contrario se termina el proceso.
	if [ {${array[*]} = 0 ]; then
		echo "No hay archivos para descomprimir/instalar"
		exit;
	else
		# Bucle para indexar el arreglo y descomprimir los archivos en la ruta especificada.
		for index in ${array[*]};	
			do
				if [ ${index: -4} == ".zip" ]; then
					sudo unzip $index -d $DIR_B;
				elif [ ${index: -7} == ".tar.gz" ]; then
					sudo tar -xzf $index --directory $DIR_B;	
				else
					echo "El archivo $index tiene una extension no soportada";
				fi
			done
	fi
fi	
#EOF
