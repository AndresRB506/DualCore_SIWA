## Testbench del módulo TOP TEC RISCV con SPI y UART

En esta carpeta se encuentra el testbench del TOP TEC RISCV con SPI y UART. Los archivos que se encuentran son:

* IS25WP032D.v : Esta es la descripción de la memoria IS25WP032D, que se utilizará como fuente de instrucciones. Esta inicializada por el archivo aux/mem_model.txt
* Makefile: Este archivo posee las instrucciones de ejecucución del testbench. 
* Testbench files : En este repositorio se encuentran los archivos  Status.sv, synopsys_tools.sh y topcore_tb.sv con los cuales se realiza la verificación. 
* memory.py : Script en Python que realiza el mapeo del programa de instrucciones al archivo .txt necesario por IS25WP032D.v para inicializar la memoria.
* instructions : Archivo con las instrucciones a ejecutar.

### Instrucciones de uso
1. Se debe ejecutar el bash del archivo synopsys_tools.sh
```sh
       source synopsys_tools.sh
```
2. Se copia en el archivo *instructions* las instrucciones para la prueba.
3. Se ejecuta la siguiente instruccion para ejecutar la prueba.
```sh
       source comandos
```

