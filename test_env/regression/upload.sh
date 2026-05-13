#!/bin/bash

clear all

# Captura la localizacion actual del directorio en la variable dir
dir=$(pwd)

# Corre las pruebas de funcionamiento
cd /home/juan/Documentos/cron
./pruebas

# Se verifica si se pasaron las pruebas
for line in $(cat file.txt);

do

var=1

if [ $line -eq $var ]; then
        cd $dir
        git add .
        git commit -m "committing new changes!"
        git push origin master
        echo ""
        echo "git repo updated"
else
        echo "Fallo las pruebas"
fi;

done
