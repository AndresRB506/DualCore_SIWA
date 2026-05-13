simSetSimulator "-vcssv" -exec "./simv" -args \
           "-cm line+cond+fsm+tgl+assert+branch+property_path -cm_name test +TESTNAME=test" \
           -uvmDebug on -simDelim
debImport "-i" "-simflow" "-dbdir" "./simv.daidir"
srcTBInvokeSim
srcHBSelect "topcore_tb.uut" -win $_nTrace1
srcHBSelect "topcore_tb.uut" -win $_nTrace1
wvCreateWindow
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave3
verdiDockWidgetMaximize -dock windowDock_nWave_3
wvZoomAll -win $_nWave3
verdiDockWidgetRestore -dock windowDock_nWave_3
srcTBRunSim
verdiDockWidgetSetCurTab -dock windowDock_InteractiveConsole_2
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
verdiDockWidgetMaximize -dock windowDock_nWave_3
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 3931781381.176999 4227978763.477089
wvZoom -win $_nWave3 3995119186.196145 4033441219.485645
verdiDockWidgetRestore -dock windowDock_nWave_3
verdiDockWidgetSetCurTab -dock windowDock_InteractiveConsole_2
debExit
