dm::openLibraryManager
gi::executeAction menuPreShow -in [gi::getWindows 2]
gi::executeAction menuPreShow -in [gi::getWindows 2]
dm::showAddLibrary -parent 2
gi::executeAction menuPreShow -in [gi::getWindows 2]
dm::showNewCell -parent 2
gi::setActiveDialog [gi::getDialogs {dmNewCell} -parent [gi::getWindows 2]]
db::setAttr geometry -of [gi::getDialogs {dmNewCell} -parent [gi::getWindows 2]] -value 448x227+725+362
db::setAttr geometry -of [gi::getFrames 1] -value 1040x824+623+133
db::setAttr geometry -of [gi::getFrames 1] -value 1040x824+622+133
gi::closeWindows [gi::getDialogs {dmNewCell} -parent [gi::getWindows 2]]
dm::showNewLibrary -parent 2
gi::setActiveDialog [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
db::setAttr geometry -of [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]] -value 458x467+903+260
gi::setField {libName} -value {Prueba} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::pressButton {libDirBrowse} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::pressButton {libDirBrowse} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::setField {libDir} -value {..} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::setField {libTypeIcc} -value {true} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
db::setAttr geometry -of [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]] -value 458x423+903+260
gi::pressButton {iccTechFileBrowse} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::setField {libTypeFileSys} -value {true} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
db::setAttr geometry -of [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]] -value 458x467+903+260
gi::setField {techTypeFile} -value {true} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::pressButton {techFileBrowse} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::closeWindows [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
dm::showNewLibrary -parent 2
gi::setActiveDialog [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
db::setAttr geometry -of [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]] -value 458x467+901+234
gi::setField {techTypeDefault} -value {true} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::setField {libName} -value {Prueba} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::pressButton {ok} -in [gi::getDialogs {dmNewLibrary} -parent [gi::getWindows 2]]
gi::setCurrentIndex {libs} -index {Prueba} -in [gi::getWindows 2]
gi::setItemSelection {libs} -index {Prueba} -in [gi::getWindows 2]
gi::setCurrentIndex {cellCategories} -index {Uncategorized} -in [gi::getWindows 2]
gi::setItemSelection {cellCategories} -index {Uncategorized} -in [gi::getWindows 2]
gi::executeAction menuPreShow -in [gi::getWindows 2]
gi::executeAction menuPreShow -in [gi::getWindows 2]
gi::executeAction menuPreShow -in [gi::getWindows 2]
gi::executeAction menuPreShow -in [gi::getWindows 2]
gi::executeAction giCloseWindow -in [gi::getWindows 2]
gi::setActiveWindow 1
gi::setActiveWindow 1 -raise true
sa::showConsole -session [sa::createSession]
gi::setCurrentIndex {outputsTable} -index {0,0} -in [gi::getWindows 3]
gi::executeAction giCloseWindow -in [gi::getWindows 3]
gi::setActiveWindow 1
gi::setActiveWindow 1 -raise true
db::showImportStream
gi::setActiveDialog [gi::getDialogs {dbImportStream}]
db::setAttr geometry -of [gi::getDialogs {dbImportStream}] -value 610x567+645+217
gi::pressButton {runDirectoryBrowse} -in [gi::getDialogs {dbImportStream}]
gi::pressButton {fileNameBrowse} -in [gi::getDialogs {dbImportStream}]
db::setAttr geometry -of [gi::getFrames 1] -value 1040x824+982+325
gi::setField {topCellName} -value {top_riscv_tec_pads} -in [gi::getDialogs {dbImportStream}]
gi::pressButton {libDirBrowse} -in [gi::getDialogs {dbImportStream}]
gi::setField {libName} -value {Prueba} -in [gi::getDialogs {dbImportStream}]
gi::pressButton {ok} -in [gi::getDialogs {dbImportStream}]
db::showImportStream
gi::setActiveDialog [gi::getDialogs {dbImportStream}]
db::setAttr geometry -of [gi::getDialogs {dbImportStream}] -value 610x567+645+217
gi::setActiveTab {tabWidget} -tabName {mapFiles} -in [gi::getDialogs {dbImportStream}]
gi::setActiveTab {tabWidget} -tabName {main} -in [gi::getDialogs {dbImportStream}]
db::setAttr geometry -of [gi::getFrames 1] -value 1040x824+643+293
exit
