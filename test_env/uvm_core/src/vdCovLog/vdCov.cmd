verdiWindowResize -win $_vdCoverage_1 "0" "26" "1920" "1016"
gui_set_pref_value -category {coveragesetting} -key {geninfodumping} -value 1
gui_exclusion -set_force true
gui_assert_mode -mode flat
gui_class_mode -mode hier
gui_excl_mgr_flat_list -on  0
gui_covdetail_select -id  CovDetail.1   -name   Line
verdiWindowWorkMode -win $_vdCoverage_1 -coverageAnalysis
gui_open_cov  -hier salida.vdb -testdir  {salida.vdb} -test { salida/test } -merge MergedTest -db_max_tests 10 -fsm transition
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.central_control
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.central_control
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc1   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc1  tb_top.dut_wr.uut.TOP.pc0   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc0  tb_top.dut_wr.uut.TOP.central_control   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file.Reg_csr
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Bus
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Bus
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.central_control  tb_top.dut_wr.uut.TOP.pc1   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc1   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_BS
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_BS
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_CSK
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_CSK
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_BS
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU.inst_BS
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_BS
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_BS
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_BS
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_BS
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_CSK
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu.inst_CSK
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.central_control
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.central_control
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} fifo_flops
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} fifo_flops
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} fifo_ltch
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} fifo_ltch
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} ALU
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.mem   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.mem  tb_top.dut_wr.uut   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut  tb_top.dut_wr.uut.SPI   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.SPI  tb_top.dut_wr.uut.TOP   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP  tb_top.dut_wr.uut.TOP.Alu   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.SPI
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.SPI
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.SPI
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.SPI
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.UART
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.UART
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Alu
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Alu  tb_top.dut_wr.uut.TOP.Deco   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Deco  tb_top.dut_wr.uut.TOP.Memoria_8K   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Memoria_8K  tb_top.dut_wr.uut.TOP.Memory_controller   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Memory_controller  tb_top.dut_wr.uut.TOP.Reg_file   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Memory_controller
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Reg_file  tb_top.dut_wr.uut.TOP   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP  tb_top.dut_wr.uut.SPI   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.SPI  tb_top.dut_wr.uut.TOP.pc1   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc1  tb_top.dut_wr.uut.TOP.pc0   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.pc0  tb_top.dut_wr.uut.TOP.Reg_file   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Reg_file  tb_top.dut_wr.uut.TOP.central_control   }
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.central_control  tb_top.dut_wr.uut.TOP.Reg_file   }
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file
gui_list_expand -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file.Reg_integer
gui_list_collapse -id  CoverageTable.1   -list {covtblInstancesList} tb_top.dut_wr.uut.TOP.Reg_file.Reg_integer
gui_list_select -id CoverageTable.1 -list covtblInstancesList { tb_top.dut_wr.uut.TOP.Reg_file   }
