#!/usr/bin/perl -w

use strict;
use warnings;

foreach (@ARGV){
    print "file: $_\n";
#--------------------------------------------------------------------------------------------------
#----------------------------------Abrir el file---------------------------------------------------
#--------------------------------------------------------------------------------------------------
# Estas instruccion abren el file
open(FILE, "</mnt/vol_NFS_Zener/WD_ESPEC/esolera/Verigicacion_micro/Verificacion_RISCV_TEC/pruebas_ensamblador/$_") || die "File not found";
my @lines = <FILE>;
close(FILE);

#--------------------------------------------------------------------------------------------------
#----------------------------------Cosntantes programa---------------------------------------------
#--------------------------------------------------------------------------------------------------
#comp:OPCODE del jal y del branch
#complete1: Usada para completar el bit de signo para hacer la conversión 2'
#newlines: Donde se guardan las nuevas líneas del código
my $jal= "1101111";
my $branch="1100011";
my $complete1 = "00000000000000000000";
my $complete2 = "000000000000";
my @newlines;
my $out;

#--------------------------------------------------------------------------------------------------
#--------------------------------Recorrido del texto-----------------------------------------------
#--------------------------------------------------------------------------------------------------
#$a:contiene la linea del texto
#Con cnomp le quito el \n
foreach $a (@lines) {
  chomp($a);
#---------------------------------------------------------------------------------------------------
#---------------------------------Lectura del opcode------------------------------------------------
#---------------------------------------------------------------------------------------------------
#Instruccion1:Convierte en notacion binaria la instruccion
#Instruccion2:Extrae lo 7 bits superiores para ver el opcode
  my $bin = sprintf( "%032b", hex ($a));
  my $data = substr($bin, -7);

#---------------------------------------------------------------------------------------------------
#---------------------------------Detección intrucción jal------------------------------------------------
#---------------------------------------------------------------------------------------------------
#El inmediato en esta instruccion esta desordenado por lo cual primero se ordena
#t20:coloca el bit 20 del inmediato(signo)
#$t19a12:coloca los bit 19 al 12 del inmediato
#$t11:coloca el bit 11 del inmediato
#$t10a1:coloca el resto de los 10 bits restantes.
#$zero: Este inmediato no tiene el bit zero pues asume que es 0
#t19a0:Concantena todos los bits para recontruir el inmediato sin el bit de signo
#t20ext:Es el bit de signo con los 0 extendidos para formar un dato transformable a decimal
#int y int2 tienen los valores en decimal para ejecutar la resta con 4 y la conversión de complemento 2'
#$decy$sal: Dec contiene el decimal del nuevo inmediato, sal contiene este valor en binario para reordenarlo
#newimn:sal es de 22 bit en esta variable se almacena los 21 bits que se necesitan
#los tN son nuevamente para guardar los bits correspondientes del nuevo numero
#$newdata:contiene el neuvo inmediato en binario concatenado en el orden que necesita la Instruccion , más unos 1111 al inicio para
#la conversion en hexadecimal.
#$int4,$hex3:hacen una conversion del nuevo dato a hexadecimal
#Se guardan en $a los 3 primeros hexadecimales y se concatenan al nuevo inmediato.
#al final se guarda todo en $_ que es la variable que escribe el arreglo que crea el txt.
  if ($jal eq $data) {
    my $t20 = substr($bin, 0, 1);
    my $t19a12 = substr($bin,12 , 8);
    my $t11 = substr($bin,11 , 1);
    my $t10a1 = substr($bin,1 , 10);
    my $zero = "0";
    my $t19a0 = $t19a12 . $t11 . $t10a1 . $zero ;
    my $int = unpack("N", pack("B32", substr("0" x 32 . $t19a0 , -32)));
    my $t20ext = $t20 . $complete1;
    my $int2 = unpack("N", pack("B32", substr("0" x 32 . $t20ext , -32)));
    my $dec = $int - $int2-4;
    my $sal = sprintf "%032b",$dec;
    my $newinm=substr($sal, -21);
    $t20=substr($newinm, 0, 1);
    $t19a12=substr($newinm, 1, 8);
    $t11=substr($newinm, 9, 1);
    $t10a1=substr($newinm, 10, 10);
    my $newdata = '1111'. $t20 . $t10a1 . $t11 . $t19a12;
    my $int4 = unpack("N", pack("B32", substr("0" x 32 . $newdata, -32)));
    my $hex3 = sprintf("%x", $int4 );
    $hex3=substr($hex3, -5);
    $a=substr($a, -3);
    $a=$hex3.$a;
    $out = "$a\n";
  }
  else{
    if($branch eq $data){
      my $t12_branch = substr($bin, 0, 1);
      my $t11_branch = substr($bin, 24, 1);
      my $t10_a_5_branch = substr($bin, 1, 6);
      my $t4_a_1_branch = substr($bin, 20, 4);
      my $zero = "0";
      my $low_bin_inmediate = $t11_branch . $t10_a_5_branch . $t4_a_1_branch . $zero;
      my $up_bin_inmediate = $t12_branch . $complete2;
      my $int_branch_low = unpack("N", pack("B32", substr("0" x 32 . $low_bin_inmediate , -32)));
      my $up_int_inmediate = unpack("N", pack("B32", substr("0" x 32 . $up_bin_inmediate , -32)));
      my $branch_dec = $int_branch_low - $up_int_inmediate-4;
      my $sal_branches = sprintf "%032b",$branch_dec;
      my $new_branch_inm = substr($sal_branches, -13);
      $t12_branch = substr($new_branch_inm, 0, 1);
      $t11_branch = substr($new_branch_inm, 1, 1);
      $t10_a_5_branch = substr($new_branch_inm, 2, 6);
      $t4_a_1_branch = substr($new_branch_inm, 8, 4);
      my $newintruction_med = "1111" . $t12_branch . $t10_a_5_branch . substr($bin, 7, 5);
      my $newintruction_low = "1111". substr($bin, 12, 8) . $t4_a_1_branch . $t11_branch . substr($bin, 25, 7);
      my $branch_int4 = unpack("N", pack("B32", substr("0" x 32 . $newintruction_med, -32)));
      my $branch_hex3 = sprintf("%x", $branch_int4 );
      $newintruction_med = substr($branch_hex3, -3);
      $branch_int4 = unpack("N", pack("B32", substr("0" x 32 . $newintruction_low, -32)));
      $branch_hex3 = sprintf("%x", $branch_int4 );
      $newintruction_low = substr($branch_hex3, -5);
      my $newintruction = $newintruction_med . $newintruction_low;
      $out = "$newintruction\n";
    }
    else{
    $out = "$a\n";
    }
  }
  push(@newlines,$out);
}
#---------------------------------------------------------------------------------------------------
#--------------------------------Archivo salida-----------------------------------------------------
#---------------------------------------------------------------------------------------------------
#Se abre el archivo que se va escribir
open(FILE, ">/media/esolera/ExtraDrive1/TEC/Asistencia/Verificacion/Verificacion_RISCV_TEC/pruebas_ensamblador/hex_files/Aritmeticas/$_") || die "File not found";
print FILE @newlines;
close(FILE);
}
