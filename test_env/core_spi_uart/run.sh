#!/bin/sh

file="tests.txt"
opt1="Pre-Synthesis Simulation"
opt2="Post-Synthesis Simulation"
opt3="Logic Physical Simulation"
opt4="Quit"
options=("$opt1" "$opt2" "$opt3" "$opt4")
warning_msg="Do not close this tab"
one_time="0"
declare -i one_time
echo "Welcome!"
echo "This Script will iniciate the simulation of all tests indicated inside test.txt."
echo ""
#welcome_msg="To configure the simulations, please check 'comandos' file."
PS3="Please choose what type of logic simulation you want to run: "
select opt in "${options[@]}"
do
	case "$REPLY" in
		1 )
			echo "Starting Pre-Synthesis Simulations..."
			echo "Do not close this tab"
			rm Summary.txt > /dev/null 2>&1
			echo "Success/Fail Summary Report for Pre-Synthesis Simulations" >> Summary.txt
			echo "         Test Name             | Status" >> Summary.txt
			echo " " >> Summary.txt
			wc -l < $file > "temporal_file.txt"
			lines_q=$(head -n 1 "temporal_file.txt")
			count=0
			declare -i count
			echo "Progress: $((count*100/lines_q))%"
			while read line; do
				echo -ne "\e[1A"
				echo "Progress: $((count*100/lines_q))%"
				if [[ "$one_time" == "0" ]]; then
					python memory.py Test_Files/Assembly_Code/all_tests/$line.o.txt > /dev/null 2>&1
					vcs -ova_cov -cm line+cond+fsm+tgl+assert+branch+property_path -cm_report unencrypted_hierarchies+svpackages+noinitial -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 +incdir+../../TEC_RISCV/TOP +incdir+../../TEC_RISCV/SPI +incdir+../../TEC_RISCV/UART -CFLAGS -DVCS top_core_spi_uart.sv > /dev/null 2>&1
					if [ ! -f simv ]; then
						report=" $line"
						while [[ ${#report} -lt 31 ]]; do
							report="$report "
						done
						report="$report| FAIL (Compilation Error)"
						echo "$report" >> Summary.txt
					fi
					./simv -cm line+cond+fsm+tgl+assert+branch+property_path -cm_name $line +TESTNAME=$line +SUMMARY > /dev/null 2>&1
					#echo "$line"
					one_time="1"
				else
					python memory.py Test_Files/Assembly_Code/all_tests/$line.o.txt > /dev/null 2>&1
					if [ ! -f simv ]; then
						report=" $line"
						while [[ ${#report} -lt 31 ]]; do
							report="$report "
						done
						report="$report| FAIL (Compilation Error)"
						echo "$report" >> Summary.txt
					fi
					./simv -cm line+cond+fsm+tgl+assert+branch+property_path -cm_name $line +TESTNAME=$line +SUMMARY > /dev/null 2>&1
					#echo "$line"
				fi
				((count=count+1))
			done < "$file"
			echo -ne "\e[1A"
			echo "Progress: $((count*100/lines_q))%"
			mv Summary.txt Summary_Pre-Synthesis.txt
			rm simv > /dev/null 2>&1
			rm -r simv.daidir/ > /dev/null 2>&1
			rm "temporal_file.txt"
			echo "Simulations have ended succesfully!"
			echo "Check the generated reports."
			break
			;;
		2 )
			echo "Not implemented yet...."
			break
			;;
		3 )
			echo "Starting Post-Synthesis Physical Simulations..."
			echo "Do not close this tab"
			rm Summary.txt > /dev/null 2>&1
			echo "Success/Fail Summary Report for Post-Synthesis Physical Simulations" >> Summary.txt
			echo "         Test Name             | Status" >> Summary.txt
			echo " " >> Summary.txt
			wc -l < $file > "temporal_file.txt"
			lines_q=$(head -n 1 "temporal_file.txt")
			count=0
			declare -i count
			echo "Progress: $((count*100/lines_q))%"
			while read line; do
				echo -ne "\e[1A"
				echo "Progress: $((count*100/lines_q))%"
				if [[ "$one_time" == "0" ]]; then
					python memory.py Test_Files/Assembly_Code/all_tests/$line.o.txt > /dev/null 2>&1
					vcs -ova_cov -cm line+cond+fsm+tgl+assert+branch+property_path -cm_report unencrypted_hierarchies+svpackages+noinitial -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 +incdir+../../TEC_RISCV/TOP +incdir+../../TEC_RISCV/SPI +incdir+../../TEC_RISCV/UART -sdf typ:Test_Top.uut:../../TEC_RISCV/TOP/Tec_Riscv_pads_phy_no_pg.sdf +sdfverbose +neg_tchk top_core_spi_uart_phy.sv > /dev/null 2>&1
					if [ ! -f simv ]; then
						report=" $line"
						while [[ ${#report} -lt 31 ]]; do
							report="$report "
						done
						report="$report| FAIL (Compilation Error)"
						echo "$report" >> Summary.txt
					fi
					./simv -cm line+cond+fsm+tgl+assert+branch+property_path -cm_name $line +TESTNAME=$line +SUMMARY > /dev/null 2>&1
					#echo "$line"
					one_time="1"
				else
					python memory.py Test_Files/Assembly_Code/all_tests/$line.o.txt > /dev/null 2>&1
					if [ ! -f simv ]; then
						report=" $line"
						while [[ ${#report} -lt 31 ]]; do
							report="$report "
						done
						report="$report| FAIL (Compilation Error)"
						echo "$report" >> Summary.txt
					fi
					./simv -cm line+cond+fsm+tgl+assert+branch+property_path -cm_name $line +TESTNAME=$line +SUMMARY > /dev/null 2>&1
					#echo "$line"
				fi
				((count=count+1))
			done < "$file"
			echo -ne "\e[1A"
			echo "Progress: $((count*100/lines_q))%"
			mv Summary.txt Summary_Physical.txt
			rm simv > /dev/null 2>&1
			rm -r simv.daidir/ > /dev/null 2>&1
			rm "temporal_file.txt"
			echo "Simulations have ended succesfully!"
			echo "Check the generated reports."
			break
			;;
		4 )
			echo "Process Canceled..."
			break
			;;
		*)
			echo "Invalid input $REPLY"
			;;
	esac
done

echo "This program has ended."
