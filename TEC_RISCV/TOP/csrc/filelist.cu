PIC_LD=ld

ARCHIVE_OBJS=
ARCHIVE_OBJS += _27453_archive_1.so
_27453_archive_1.so : archive.0/_27453_archive_1.a
	@$(AR) -s $<
	@$(PIC_LD) -shared  -o .//../simv.daidir//_27453_archive_1.so --whole-archive $< --no-whole-archive
	@rm -f $@
	@ln -sf .//../simv.daidir//_27453_archive_1.so $@






%.o: %.c
	$(CC_CG) $(CFLAGS_CG) -c -o $@ $<
CU_UDP_OBJS = \
objs/udps/Dagb4.o objs/udps/Nbvs5.o objs/udps/ztgRb.o objs/udps/sGwIS.o objs/udps/kEncY.o  \
objs/udps/iw2t3.o 

CU_LVL_OBJS = \
SIM_l.o 

MAIN_OBJS = \
objs/a/amcQw_d.o 

CU_OBJS = $(MAIN_OBJS) $(ARCHIVE_OBJS) $(CU_UDP_OBJS) $(CU_LVL_OBJS)

