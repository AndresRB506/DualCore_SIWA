CU_MOD_OBJS =  \
objs/VC4mS_d.o objs/CVIdu_d.o objs/iVz5Y_d.o objs/hkcup_d.o objs/trjvP_d.o  \
objs/J8u50_d.o objs/UIEu2_d.o objs/aZBi0_d.o objs/hSZxw_d.o objs/FPiqB_d.o  \
objs/tSaKw_d.o objs/ZR4r6_d.o objs/qdMtn_d.o objs/t5uqz_d.o objs/PSfyd_d.o  \
objs/hQbYt_d.o objs/WLN4t_d.o objs/atLs2_d.o objs/pCYkB_d.o objs/E3ED6_d.o  \
objs/N4Bik_d.o objs/amcQw_d.o objs/NCyeQ_d.o objs/cgAbS_d.o objs/j5gQi_d.o  \
objs/maQnz_d.o objs/jdG3K_d.o objs/u2IL7_d.o objs/iJpid_d.o objs/pGJY8_d.o  \
objs/MAbZJ_d.o objs/k0NrH_d.o objs/h8nEf_d.o objs/ftg4g_d.o objs/Guucm_d.o  \
objs/zUIsQ_d.o objs/ex7vW_d.o objs/yI6HV_d.o objs/cgVPB_d.o objs/FBWFc_d.o  \
objs/DCgbR_d.o objs/kjczG_d.o objs/eh30K_d.o objs/uqp68_d.o objs/ai8Aa_d.o  \
amcQwB.o objs/UUmPf_d.o objs/z8Sfv_d.o objs/LUjI7_d.o objs/reYIK_d.o  \
objs/jJa1f_d.o objs/GDATE_d.o objs/VEx0J_d.o objs/bSefM_d.o objs/EyNJN_d.o  \
objs/g9v9W_d.o objs/Eiy7n_d.o objs/ZQjeY_d.o objs/bvImI_d.o 

CU_MOD_C_OBJS =  \


$(CU_MOD_C_OBJS): %.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

CU_OBJS = $(CU_MOD_OBJS) $(CU_MOD_C_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

PRE_LDFLAGS += -Wl,--whole-archive
STRIPFLAGS += -Wl,--no-whole-archive
