#!/usr/bin/perl5.10.1 

# Usage:
# script.pl list_file 

use strict;
use warnings;

#general variables:
my $list_file = $ARGV[0];
my $flag = 1;

#Lee el archivo de comandos y los almacena el el hash "comandos"
open (my $fh1, '<',$list_file) or die "No se pudo abrir el list_file '$list_file' $!";
print "_stuck_at_;0 1\n";
print "_failing_signal_;";
while (my $row = <$fh1>){
	  chomp $row;
             if($flag){
               print "$row";
	       $flag = 0;
	     }else{
               print " $row";
             }
}
close $fh1;
