simSetSimulator "-vcssv" -exec "./salida" -args " " -uvmDebug on
debImport "-i" "-simflow" "-dbdir" "./salida.daidir"
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Stack>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "239" "113" "1440" "752"
verdiDockWidgetSetCurTab -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_top.dut_wr" -win $_nTrace1
srcSetScope "tb_top.dut_wr" -delim "." -win $_nTrace1
srcHBSelect "tb_top.dut_wr" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "tb_top.dut_wr.MISO"
srcSignalViewSelect "tb_top.dut_wr.SCS"
srcSignalViewSelect "tb_top.dut_wr.SCLK"
srcSignalViewSelect "tb_top.dut_wr.MOSI"
srcSignalViewSelect "tb_top.dut_wr.MISO"
srcHBSelect "tb_top" -win $_nTrace1
srcSetScope "tb_top" -delim "." -win $_nTrace1
srcHBSelect "tb_top" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSignalViewSelect "tb_top.clk_tb"
verdiSetActWin -dock widgetDock_<Signal_List>
srcHBSelect "tb_top.dut_if" -win $_nTrace1
srcSetScope "tb_top.dut_if" -delim "." -win $_nTrace1
srcHBSelect "tb_top.dut_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvCreateWindow
srcHBDrag -win $_nTrace1
wvDumpScope "tb_top.dut_if"
wvSetPosition -win $_nWave3 {("dut_if(wrapper_if)" 0)}
wvRenameGroup -win $_nWave3 {G1} {dut_if(wrapper_if)}
wvAddSignal -win $_nWave3 "/tb_top/dut_if/clk" "/tb_top/dut_if/reset" \
           "/tb_top/dut_if/gpio\[7:0\]" \
           "/tb_top/dut_if/full_range_level_shifter\[7:0\]" \
           "/tb_top/dut_if/IS_Val\[31:0\]" "/tb_top/dut_if/IS_Config\[31:0\]" \
           "/tb_top/dut_if/IS_Trigger\[3:0\]" "/tb_top/dut_if/maip" \
           "/tb_top/dut_if/Reg_GPIO_en\[7:0\]" \
           "/tb_top/dut_if/Reg_GPIO_int\[7:0\]" \
           "/tb_top/dut_if/Reg_GPIO_out\[7:0\]" "/tb_top/dut_if/TX_UART" \
           "/tb_top/dut_if/RX_UART"
wvSetPosition -win $_nWave3 {("dut_if(wrapper_if)" 0)}
wvSetPosition -win $_nWave3 {("dut_if(wrapper_if)" 13)}
wvSetPosition -win $_nWave3 {("dut_if(wrapper_if)" 13)}
wvSetPosition -win $_nWave3 {("G2" 0)}
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcTBRunSim
srcTBSimBreak
wvZoomAll -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoom -win $_nWave3 22580774.006623 518923556.498344
wvZoom -win $_nWave3 498790446.943628 518101796.924680
verdiSetActWin -dock widgetDock_<Inst._Tree>
verdiWindowResize -win $_Verdi_1 "394" "153" "1440" "752"
debExit
