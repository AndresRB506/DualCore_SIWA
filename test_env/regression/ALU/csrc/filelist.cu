CU_MOD_OBJS =  \
objs/zr7M1_d.o objs/tmda9_d.o objs/hEeZs_d.o objs/uM9F1_d.o objs/amcQw_d.o  \
objs/MAbZJ_d.o amcQwB.o objs/y3yDu_d.o objs/reYIK_d.o objs/Mk7In_d.o  \
objs/EyNJN_d.o objs/Eiy7n_d.o 

CU_MOD_C_OBJS =  \


$(CU_MOD_C_OBJS): %.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \


CU_LVL_OBJS = \
SIM_l.o 

CU_OBJS = $(CU_MOD_OBJS) $(CU_MOD_C_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

