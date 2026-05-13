#!/bin/bash

cd /home/juan/Documentos/cron
./nombre

#for line in $(cat nombre.txt); do echo "$line" ; done

while IFS=' ' read -r line || [[ -n "$line" ]]; do printf "%s\n" "$line"; done < nombre.txt
echo $line
git add "$line"
git commit -m "upload pato"
git push origin master
