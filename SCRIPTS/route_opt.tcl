# Detail route setting........................................
setNanoRouteMode -reset
setDesignMode -bottomRoutingLayer 1
setDesignMode -topRoutingLayer 9
setNanoRouteMode -drouteAutoStop true
#setNanoRouteMode -routeBottomRoutingLayer 2
#setNanoRouteMode -routeTopRoutingLayer 7
setNanoRouteMode -envNumberFailLimit 11
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode false
#setNanoRouteMode -routeAntennaCellName "ANTGD"
setNanoRouteMode -routeDeleteAntennaReroute true
setNanoRouteMode -routeSelectedNetOnly false
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeSiEffort medium
setNanoRouteMode -routeWithSiPostRouteFix false
setNanoRouteMode -routeTdrEffort 2
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -timingEngine CTE
setNanoRouteMode -routeStrictlyHonorNonDefaultRule false
setNanoRouteMode -routeWithEco false
setNanoRouteMode -drouteEndIteration 20
setNanoRouteMode -drouteMinSlackForWireOptimization -0.100
#setNanoRouteMode -routeConcurrentMinimizeViaCountEffort true
#setNanoRouteMode -routeAutoTuneOptionsForAdvancedDesign true
setNanoRouteMode -routeReserveSpaceForMultiCut true
setNanoRouteMode -routeWithViaInPin false
setNanoRouteMode -routeWithViaOnlyForStandardCellPin true
setNanoRouteMode -droutePostRouteSwapVia true
#setNanoRouteMode -drouteExpAllowNonPreferApa true
#setNanoRouteMode -droutePostRouteSpreadWire true
#setNanoRouteMode -droutePostRouteWidenWireRule NDR1
#setNanoRouteMode -routeExpUseAutoVia false
setNanoRouteMode -routeDesignRouteClockNetsFirst false
setNanoRouteMode -routeDesignFixClockNets false
#setNanoRouteMode -routeSelectedNetOnly true
#setAttribute -net "CTS* -shield_net VSS -shield_side one_side
#selectNet -shield
#routeDesign
#setNanoRouteMode -routeSelectedNetOnly false
#setPGPinUseSignalRoute GBLVDDG
#setPGPinUseSignalRoute GBLL":VSSG"

routeDesign -globalDetail -noPlacementCheck

#suspend
#return

# Saving the Route design.....................................
saveDesign -def DBS/route.enc
saveNetlist -excludeLeafCell netlist/route.v
defOut -floorPlan -netlist -routing def/route.def

# VIA Optimization............................................
setNanoRouteMode -drouteUseMultiCutViaEffort high
setNanoRouteMode -routeWithEco true
setNanoRouteMode -droutePostRouteSwapVia true
routeDesign -viaOpt

# Wire Optimization...........................................
setNanoRouteMode -droutePostRouteSpreadWire true
setNanoRouteMode -drouteMinLengthForWireSpreading 2
setNanoRouteMode -droutePostRouteSwapVia none
setNanoRouteMode -routeWithEco true
routeDesign -wireOpt

verifyGeometry -regRoutingOnly -error 1000000
routeDesign

# Extracting the Route design.................................
setExtractRCMode -engine postRoute -effortLevel medium
extractRC
rcOut -rc_corner rc_best -spef spef/rc_best.spef
rcOut -rc_corner rc_worst -spef spef/rc_worst.spef

# Checks after Routing........................................
verifyConnectivity
verify_PG_short -no_routing_blkg
verify_drc -limit 10000

# Saving the Route opt design.................................
saveDesign -def DBS/route_opt.enc
saveNetlist -excludeLeafCell netlist/route_opt.v
defOut -floorPlan -netlist -routing def/route_opt.def

# Reports after Routing.......................................
set_interactive_constraint_modes [all_constraint_modes -active]
set_propagated_clock [all_clocks]
all_analysis_views
set_analysis_view -setup func_slow_max -hold func_fast_min
timeDesign -reportOnly -expandedViews -pathReports -drvReports -slackReports -postRoute -numPaths 1000 -prefix route_opt_incr_[clock format [clock second] -format "%m-%d"] -outDir ./timingReports/
timeDesign -postRoute
timeDesign -postRoute -hold
#report_timing -from ahbmi_out_reg_3_hready/DFF/Q -to ahbmi_out[34]
#report_timing -from mcore0/a0/r_reg_pwd/DFF/Q -to mcore0/mctrl0/r_reg_ramoen_4/DFF/D
#report_timing -from mcore0/ahb0/r_reg_hslave_2/DFF/Q -to proc0/cmem0/idata0/u0/id0/A[1]
#report_timing -from proc0/iu0/wr_reg_trapping/DFF/Q -to proc0/c0/icache0/RC_CG_HIER_INST26/RC_CGIC_INST/E
#report_timing -from proc0/cmem0/dtags0/u0/id0/Q1[24] -to proc0/c0/dcache0/r_reg_holdn/DFF/D
#report_timing -from clk_en -to CGIC_INST/E
#report_timing -from proc0/cmem0/ddata0/u0/id0/Q[25] -to proc0/cmem0/ddata0/u0/id0/D[25]
#dbGet selected.instTerms.name ; getting pins name
#dbGet selected.instTerms.net.name ; getting inst name
#ecoAddRepeater -term FE_OCPC631_N_126/Y -cell gpdk045wc/DLY4X4
#ecoChangeCell -inst FE_OCPC631_N_126 -cell gpdk045wc/DLY4X4

