#!/usr/bin/perl5.10.1 

# Usage:
# script.pl vcd_file

use strict;
use warnings;

#general variables:
my $vcd_file = $ARGV[0];
my %hierarchy = ();
my $counter = 0;

#Lee el archivo de comandos y los almacena el el hash "comandos"
open (my $fh1, '<',$vcd_file) or die "No se pudo abrir el netlist '$vcd_file' $!";
while (my $row = <$fh1>){
	  chomp $row;
	   if($row =~ /.scope [^ ]+ ([^ ]+) +.end/){
	     $hierarchy{"hier_$counter"} =$1;
	     $counter++;
	   }
	   
	   if($row =~ /.upscope +.end/){
             $counter--;
	     if($counter == -1){
	       print("Error: Counter negativo\n");
	       close $fh1;
	       exit;
	     }
	     delete($hierarchy{"hier_$counter"});
	   }
	   if($row =~ /enddefinitions/){
	     close $fh1;
             exit;
	   }
	   if($row =~ /.var [^ ]+ [0-9]+ [^ ]+ (.*) +.end/){  
	     my $signal = "$1";
	     my $signal_hier = "";
	     if($counter != 0){
	       $signal_hier= $hierarchy{"hier_0"};
	     }
	     for(my $i = 1;$i <$counter;$i++){
	       $signal_hier = $signal_hier.".".$hierarchy{"hier_$i"};
	     }
	     if($signal =~ /(.+) \[([0-9]+):([0-9]+)\]/){
 	       my $signal_name = $1;
	       my $high_index = $2;
	       my $low_index = $3;
	       for(my $b = $low_index; $b <= $high_index; $b++){
	         print($signal_hier.".".$signal_name."[$b]\n");
	       }
	     }else{
               print($signal_hier.".".$signal."\n");
	     }
	   }
}
close $fh1;
