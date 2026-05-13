gui_set_pref_value -category {coveragesetting} -key {geninfodumping} -value 1
gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier simv.vdb -testdir  {simv.vdb} -test { simv/+TESTNAME= simv/CSRRC simv/CSRRCI simv/CSRRS simv/CSRRSI simv/CSRRW simv/CSRRWI simv/Escritura_Registros_AUIPC simv/Escritura_Registros_Add simv/Escritura_Registros_LUI simv/Interrupt_UART_Bottom simv/Interrupt_UART_sb simv/Interrupt_UART_sh simv/Interrupt_UART_sw simv/Store_load_byte simv/add simv/addi simv/and simv/andi simv/branches simv/jump simv/lbu simv/lhu simv/mep_app simv/nop simv/or simv/ori simv/sh_lh simv/sll simv/slli simv/slt simv/slti simv/sltiu simv/sltu simv/sra simv/srai simv/srl simv/srli simv/sub simv/sw_lw simv/xor simv/xori } -merge MergedTest -db_max_tests 10 -fsm transition
