
all:	sim gen convert clean
SHELL = /bin/bash
MS="-s"

##########################################################################
#
# DUT Sources
#
##########################################################################
DUT_SRC_DIR=../../../source/ac97/rtl
_TARGETS_=	$(DUT_SRC_DIR)/ac97_defines.v                  \
		$(DUT_SRC_DIR)/ac97_top.v                      \
		$(DUT_SRC_DIR)/ac97_sout.v                     \
		$(DUT_SRC_DIR)/ac97_sin.v                      \
		$(DUT_SRC_DIR)/ac97_soc.v                      \
		$(DUT_SRC_DIR)/ac97_out_fifo.v                 \
		$(DUT_SRC_DIR)/ac97_in_fifo.v                  \
		$(DUT_SRC_DIR)/ac97_wb_if.v                    \
		$(DUT_SRC_DIR)/ac97_rf.v                       \
		$(DUT_SRC_DIR)/ac97_prc.v                      \
		$(DUT_SRC_DIR)/ac97_fifo_ctrl.v                \
		$(DUT_SRC_DIR)/ac97_cra.v                      \
		$(DUT_SRC_DIR)/ac97_dma_if.v                   \
		$(DUT_SRC_DIR)/ac97_dma_req.v                  \
		$(DUT_SRC_DIR)/ac97_int.v                      \
		$(DUT_SRC_DIR)/ac97_rst.v 

##########################################################################
#
# Test Bench Sources
#
##########################################################################
TB_SRC_DIR=../../../source/ac97/testbench
_TB_=		$(TB_SRC_DIR)/ac97_codec_sout.v		\
		$(TB_SRC_DIR)/ac97_codec_sin.v		\
		$(TB_SRC_DIR)/ac97_codec_top.v		\
		$(TB_SRC_DIR)/wb_model_defines.v	\
		$(TB_SRC_DIR)/wb_mast_model.v		\
		$(TB_SRC_DIR)/test_bench_top.v		\
		

##########################################################################
#
# Misc Variables
#
##########################################################################
TECH_SRC_DIR=/mnt/vol_NFS_Zener/tools/synopsys/pdks/xt018-ams/xt018/\
	diglibs/D_CELLS_LL/v2_0/verilog/v2_0_0/
#INCDIR=-y $TECH_SRC_DIR +libext+.v+.V; Util para simulaciones post sintesis
LOGF=-l vcs.log
FILE=./vcdplus.vpd

##########################################################################
#
# Make Targets
#
##########################################################################

sim:
	vcs -full64 -debug_access+all +v2k +vcs+vcdpluson +systemverilogext+sv \
	 $(_TARGETS_) $(_TB_) $(LOGF) 

gen:
	./simv > simulation.log

convert:
	mv vcdplus.vpd ac97.vpd
	vpd2vcd -full64 ac97.vpd ac97.vcd
	vcd2saif -64 -input ac97.vcd -output ac97.saif

clean:
	rm -rf	./csrc ./DVEfiles ./simv.daidir		\
		./opendatabase.log ./simv ./ucli.key	\
		./swave_compile_done ./ac97.vcd		\

##########################################################################

