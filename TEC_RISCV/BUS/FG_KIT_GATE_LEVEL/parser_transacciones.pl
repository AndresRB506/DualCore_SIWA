#!/usr/bin/perl5.10.1 

# Usage:
# netlistgen.pl comandos netlist_base.cir

use strict;
use warnings;

#general variables:
my $archivo_para_analizar = $ARGV[0];
my $status =  0;
my $time_send = 0;
my $time_rcvd = 0;
my $bus = 0;
my $source_ID = 0;
my $receiver_ID = 0;
my $delay_clk_cycles = 0;
my $msg_payload = 0;
my $msg_trgt = 0;
my %transacciones = ();
my $firma = 0;
my $contador_transacciones_completas = 0; 

#Lee el archivo de comandos y los almacena el el hash "comandos"
open (my $fh1, '<',$archivo_comandos) or die "No se pudo abrir el netlist '$archivo_comandos' $!";
print "Leyendo archivo de comandos\n";
while (my $row = <$fh1>){
	  chomp $row;
	  if($row =~ /[01],[0-9]+,[0-9]+,[0-9]+,[0-9]+,[0-9]+,[0-9]+,[0-9abcdef]+,[0-9]+/){
	     my @campos = split /,/,$row;
             my $status =  $campos[0];
             my $time_send = $campos[1];
             my $time_rcvd = $campos[2];
             my $bus = $campos[3];
             my $source_ID = $campos[4];
             my $receiver_ID = $campos[5];
             my $delay_clk_cycles = $campos[6];
             my $msg_payload = $campos[7];
             my $msg_trgt = $campos[8];
	     if($status){
	       $contador_tarnsacciones_completas++;
	     }else{
	       if($time_send == 0){
		 if($time_rcvd != 0){
		   
		 }else{
		 }
	       }else{

	       }
	     }
  	     print "El nemonico \"$lista_linea_comandos[0]\" sera substutuido por:\n$lista_linea_comandos[1]\n";
	   }
}
close $fh1;

#Lee el archivo del netlist Base y lo almacena en la variable "model_netlist"
open (my $fh2, '<',$netlist_base) or die "No se pudo abrir el netlist '$netlist_base' $!";

while (my $row = <$fh2>){
	  chomp $row;
	    $model_netlist = "${model_netlist}\n${row}";
}
close $fh2;
print "El netlist fue leido correctamente\n";

#Para cada una de las combinaciones posibles de las variables a cambiar se genera un netlist.
my %netlist_in_use;
$netlist_in_use{$netlist_base} = $model_netlist;
my %temporal_list_of_netlist;

foreach my $nemo (keys %comandos){

  foreach my $nemo_val (split / /,$comandos{$nemo}){
    foreach my $netlist_inst (keys %netlist_in_use){
      my $temporal_netlist = $netlist_in_use{$netlist_inst}; 
      $temporal_netlist =~ s/$nemo/$nemo_val/g;
      $temporal_list_of_netlist{"${netlist_inst}_${nemo}_${nemo_val}"}=$temporal_netlist;
    }  
  }
  %netlist_in_use = %temporal_list_of_netlist;
    foreach my $key (keys %temporal_list_of_netlist){
      delete $temporal_list_of_netlist{$key};
    }
}

#open (my $fh3, '>', "RESULTADOS/sourceme.txt") or die "No se pudo abrir el archivo 'RESULTADOS/sourceme.txt' $!";

  foreach my $netlist_inst (keys %netlist_in_use){
    open (my $fh2, '>', "RESULTADOS/$netlist_inst") or die "No se pudo abrir el archivo 'RESULTADOS/$netlist_inst' $!";
      print $fh2 "$netlist_in_use{$netlist_inst}";
    close $fh2;
    print "Generado:${netlist_inst}\n";
#      print $fh3 "eldo -i ${netlist_inst}  > ${netlist_inst}_log;\n";
#      print $fh3 "echo \"${netlist_inst}\" >> Done_simulations.txt;\n";
  }
#  close $fh3;

