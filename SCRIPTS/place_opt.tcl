# Setting before placement...............................
reset_path_group -all
resetPathGroupOptions
set inp [all_inputs -no_clocks]
set outp [all_outputs]
set mems [all_registers -macros]
set icgs [filter_collection [all_registers] "is_integrated_clock_gating_cell == true"]
set regs [remove_from_collection [all_registers -edge_triggered] $icgs]
set allregs [all_registers]
group_path -name In2Reg -from $inp -to $allregs
group_path -name Reg2Out -from $allregs -to $outp
group_path -name In2Out -from $inp -to $outp
group_path -name Reg2Reg -from $regs -to $regs
group_path -name Reg2Mem -from $regs -to $mems
group_path -name Mem2Reg -from $mems -to $regs
group_path -name Reg2ClkGate -from $allregs -to $icgs
setPathGroupOptions Reg2Mem -effortlevel high -weight 10 -late -targetSlack 0
setPathGroupOptions Reg2Reg -effortlevel high -weight 10 -late -targetslack 0
setPathGroupOptions Reg2ClkGate -effortlevel high -weight 10 -late -targetSlack 0
setPathGroupOptions In2Reg -effortlevel high -weight 5 -late -targetSlack 0
setPathGroupOptions Reg2Out -effortLevel high -weight 5 -late -targetSlack 0
setPathGroupOptions Mem2Reg -effortLevel high -weight 5 -late -targetSlack 0
setPathGroupOptions In2Out -effortLevel high -weight 5 -late -targetSlack 0

# Placement Switches......................................
setPlaceMode -place_global_max_density 0.90
setPlaceMode -place_global_uniform_density true
#setPlaceMode -placeIoPins true
setPlaceMode -place_global_place_io_pins true
setPlaceMode -place_design_floorplan_mode false
setPlaceMode -place_global_reorder_scan true
setPlaceMode -place_global_timing_effort medium
setPlaceMode -place_global_clock_gate_aware true
setPlaceMode -place_design_refine_place true
setPlaceMode -place_detail_check_route true
setPlaceMode -place_global_cong_effort high
setPlaceMode -place_detail_honor_inst_pad true
setPlaceMode -place_detail_pad_fixed_insts true
setPlaceMode -place_global_ignore_scan true

setScanReorderMode -scanEffort high -allowSwapping true
setOptMode -holdTargetSlack 0.02
setOptMode -setupTargetSlack 0.05
set_interactive_constraint_modes [all_constraint_modes -active]
set_max_transition 0.600 [dbGet top.name]
set_max_fanout 32 [dbGet top.name]
setOptMode -fixFanoutLoad true
setOptMode -powerEffort none

# IO buffer insertions....................................
remove_assigns -buffering -buffer BUFX8
attachIOBuffer -excludeClockNet -status Fixed -in BUFX12 -out BUFX12

# Tie cells insertions....................................
#setTieHiLoMode -reset
#setTieHiLoMode -createHierPort false -honorDontTouch false -maxDistance 50 -maxFanout 20 -prefix TIEHL -reportHierPort false
#addTieHiLo -cell TIEHI -createHierPort false -prefix PreCTS_TIEH -reportHierPort false
#addTieHiLo -cell TIELO -createHierPort false -prefix PreCTS_TIEL -reportHierPort false
#selectInstByCellName TIE*
#llength [dbGet selected.name]
#deselectInstByCellName TIEHI
setUsefulSkewMode -maxAllowedDelay 0.110
setOptMode -usefulSkew true
setOptMode -usefulSkewPreCTS true
setAnalysisMode -checkType setup -cppr both
setAnalysisMode -analysisType onChipVariation

# Placement of standard cells.............................
setAnalysisMode -analysisType onChipVariation -cppr both
set_dont_use [get_lib_cells */*XL] true
set_dont_use [get_lib_cells */*X1] true
set_clock_uncertainty -setup 0.300 [all_clocks]
set_analysis_view -setup func_slow_max -hold func_fast_min








place_opt_design 
checkPlace
reportDesignUtil

# Checks after placement..................................
timeDesign -preCTS -slackReports -drvReports > preCTS/timing.rpt
reportCongestion -overflow -hotSpot > preCTS/congestion.rpt
report_power > preCTS/power.rpt
reportGateCount > preCTS/gateCount.rpt
timeDesign -reportOnly -expandedViews -pathReports -drvReports -slackReports -preCTS -numPaths 1000 -prefix place_opt_incr_[clock format [clock second] -format "%m-%d"] -outDir ./timingReports/

# Saving the design.......................................
#checkPlace leon.checkPlace
saveDesign -def DBS/prects.enc
