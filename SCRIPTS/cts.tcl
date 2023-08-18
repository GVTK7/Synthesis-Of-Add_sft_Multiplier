# Creating NDR rules.......................................
add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -spacing {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -name 2w2s
#add_ndr -width {Metal1 0.12 Metal2 0.14 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.14 Metal9 0.14 } -spacing {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -name 2w1s
#add_ndr -width {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -spacing {Metal1 0.06 Metal2 0.07 Metal3 0.07 Metal4 0.07 Metal5 0.07 Metal6 0.07 Metal7 0.07 Metal8 0.07 Metal9 0.07 } -name 1w1s
create_route_type -name clktop -non_default_rule 2w2s -bottom_preferred_layer Metal5 -top_preferred_layer Metal6
#create_route_type -name clktrunk -non_default_rule 2w1s -bottom_preferred_layer M2 -top_preferred_layer M7
#create_route_type -name clkleaf -non_default_rule 1w1s -bottom_preferred_layer M2 -top_preferred_layer M7

# Pre CTS settings.........................................
set_clock_uncertainty -setup 0.250 [all_clocks]
set_clock_uncertainty -hold 0.125 [all_clocks]
set_ccopt_property target_max_trans -net_type top 0.6
#set_ccopt_property target_max_trans -net_type trunk 0.6
#set_ccopt_property target_max_trans -net_type leaf 0.6
set_ccopt_property target_skew 0.11
set_ccopt_property route_type clktop -net_type top
#set_ccopt_property route_type clktrunk -net_type trunk
#set_ccopt_property route_type clkleaf -net_type leaf 
set_ccopt_property buffer_cells {CLKBUFX4 CLKBUFX8 CLKBUFX12 CLKBUFX16}
set_ccopt_property inverter_cells {CLKINVX8 CLKINVX12}
set_ccopt_property use_inverters false
set_ccopt_property clock_gating_cells TLATNTSCA*
set_ccopt_property max_fanout 32
set_ccopt_property auto_limit_insertion_delay_factor 1
set_ccopt_property update_io_latency false
setCTSMode -routeNonDefaultRule 2w2s
deleteAllCellPad
specifyCellPad CLKBUFX* -left 6 -right 6 -top 1 -bottom 1
specifyCellPad TLATNTSCA* -left 6 -right 6 -top 1 -bottom 1

# NanoRoute setting.........................................
setNanoRouteMode -routeStrictlyHonorNonDefaultRule 2w2s
setNanoRouteMode -routeBottomRoutingLayer 2
setNanoRouteMode -routeTopRoutingLayer 7
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -droutePostRouteSwapVia multiCut
setNanoRouteMode -drouteUseMultiCutViaEffort high

# Creating clock tree......................................
create_ccopt_clock_tree_spec -file DBS/ccopt.spec
source -echo DBS/ccopt.spec

# Turn on multi delay-corner in ccopt.......................
set_ccopt_property -skew_group * -delay_corner * -late -target_skew 0.110
set_ccopt_property -skew_group * -delay_corner * -early -target_skew 0.110
set_ccopt_property -clock_tree * -delay_corner * -late -target_max_trans auto
set_ccopt_property -clock_tree * -delay_corner * -early -target_max_trans auto
#set_ccopt_property -target_max_trans -net_type leaf -clock_tree* 50ps
#set_ccopt_property -target_max_trans -net_type trunk -clock_tree* 50ps
set_ccopt_property -skip_reducing_clock_tree_power_1 true
set_ccopt_property -skip_reducing_clock_tree_power_2 true
set_ccopt_property -skip_reducing_clock_tree_power_3 true
set_ccopt_property -skip_reducing_clock_tree_power_4 true

ccopt_design -cts -expandedViews

# Reports after CTS........................................
timeDesign -reportOnly -expandedViews -pathReports -drvReports -slackReports -postCTS -numPaths 1000 -prefix cts_opt_incr_[clock format [clock second] -format "%m-%d"] -outDir ./timingReports/
report_clock_timing -type skew > ./report/clock_timing_skew_Jclock_[clock format [clock second] -format "%m%d"].rpt
report_clock_timing -type latency > ./report/clock_timing_latency_[clock format [clock second] -format "%m%d"].rpt
report_clock_timing -type summary > ./report/clock_timing_summary_[clock format [clock second] -format "%m%d"].rpt
report_ccopt_clock_trees -file ./report/ccopt_clock_trees_[clock format [clock second] -format "%m%d"].ctsrpt
report_ccopt_skew_groups -file ./report/ccopt_skew_groups_[clock format [clock second] -format "%m%d"].ctsrpt
report_ccopt_clock_tree_structure -file ./report/ccopt_clock_structure_[clock format [clock second] -format "%m%d"].ctsrpt
report_power -cell_type all -outfile ./report/ccopt_power_[clock format [clock second] -format "%m%d"].rpt
timeDesign -hold -postCTS > ./report/clock_timing_hold_[clock format [clock second] -format "%m%d"].rpt

# Saving the CTS design....................................
saveDesign -def DBS/cts.enc

# CTS optimization.........................................
set_interactive_constraint_modes [all_constraint_modes -active]
set_propagated_clock [all_clocks]
all_analysis_views
setPathGroupOptions Reg2Mem -effortlevel high -weight 10 -late -targetSlack 0
setPathGroupOptions Reg2Reg -effortlevel high -weight 10 -late -targetslack 0
setPathGroupOptions Reg2ClkGate -effortlevel high -weight 10 -late -targetSlack 0
setPathGroupOptions In2Reg -effortlevel high -weight 5 -late -targetSlack 0
setPathGroupOptions Reg2Out -effortLevel high -weight 5 -late -targetSlack 0
setPathGroupOptions Mem2Reg -effortLevel high -weight 5 -late -targetSlack 0
setPathGroupOptions In2Out -effortLevel high -weight 5 -late -targetSlack 0
set_analysis_view -setup func_slow_max -hold func_fast_min
optDesign -postCTS -expandedViews -prefix postcts_opt -outDir timingReports 
optDesign -postCTS -hold -expandedViews -prefix postcts_hold_opt -outDir timingReports
#changeClockStatus -all -fixedNetWires

# Saving the CTS design....................................
saveDesign -def DBS/cts_opt.enc

