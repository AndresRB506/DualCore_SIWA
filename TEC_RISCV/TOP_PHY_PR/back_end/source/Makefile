
all:	sim gen convert clean
SHELL = /bin/bash
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR= /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/ALU_register/back_end/source
_TARGETS_=	$(DUT_SRC_DIR)/ top.v                  
		  
		                    
	

##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR= /mnt/vol_NFS_Zener/WD_ESPEC/moviedo/ALU_register/back_end/source
_TB_=		$(TB_SRC_DIR)/ test_top.sv		

		

##########################################################################
#
# Misc Variables
#
##########################################################################
TECH_SRC_DIR=/mnt/vol_NFS_Zener/tools/synopsys/pdks/xt018-ams/xt018/diglibs/D_CELLS_LL/v2_0/verilog/v2_0_0/
#INCDIR=-y $(TECH_SRC_DIR) +libext+.v+.V; #Util para simulaciones post sintesis
LALA=$(TECH_SRC_DIR)/D_CELLS_LL.v \
		$(TECH_SRC_DIR)/VLG_PRIMITIVES.v
LOGF=-l vcs.log
FILE=./vcdplus.vpdma

##########################################################################
#
# Make Targets
#
##########################################################################

sim:
	echo $(INCDIR)
	vcs -full64 -timescale=1ns/1ps -debug_access+all +v2k +vcs+vcdpluson +systemverilogext+sv \
	 $(_TARGETS_) $(_TB_) $(LALA) $(LOGF)

gen:
	./simv > simulation.log

convert:
	mv vcdplus.vpd top.vpd
	vpd2vcd -full64 top.vpd top.vcd
	vcd2saif -64 -input top.vcd -output top.saif

clean:
	rm -rf	./csrc ./DVEfiles ./simv.daidir		\
		./opendatabase.log ./simv ./ucli.key	\
		./swave_compile_done ./top.vcd		\

##########################################################################

