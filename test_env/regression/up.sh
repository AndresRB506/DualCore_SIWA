#!/bin/bash

clear all

#Capturando la direccion actual
dir=$(pwd)

# Se ingresa la direccion del directorio donde se encuentra el archivo de bash
cd /mnt/vol_NFS_Zener/WD_ESPEC/jmontero/
source ./bash_snps_xt018-AMS_2017

# Se le pide al usuario que ingrese el nombre del archivo que desea subir
echo "Ingrese el nombre del archivo que desea subir a github "
read nombre
echo $nombre

cd /mnt/vol_NFS_Zener/WD_ESPEC/jmontero
g++ pruebas.cpp -o pruebas
./pruebas
