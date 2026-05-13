#!/bin/bash

cd /home/juan/Documentos/cron
./pruebas

for line in $(cat file.txt);

do

var=1

if [ $line -eq $var ]; then
        cd /home/juan/Documentos/cron
        git add -A
        git commit -m "committing new configuration changes!"
        git push origin master
        echo ""
        echo "git repo updated"
else
        echo "Fallo las pruebas"
fi;

done
