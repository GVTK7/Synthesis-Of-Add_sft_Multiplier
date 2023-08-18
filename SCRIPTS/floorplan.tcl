

init_design
checkDesign -netlist

#floorplan dimensions declaring
floorPlan -s {65 65 10 10 10 10} -coreMarginsBy io -noSnapToGrid



globalNetConnect VDD -pin VDD -type pgpin -verbose -netlistOverride
globalNetConnect VSS -pin VSS -type pgpin -verbose -netlistOverride

addRing -type core_rings -center 1 -follow core -layer {top M3 bottom M3 right M1 left M1} -width 1 -spacing 2 -offset 0.5 -nets {VDD VSS}

addStripe -nets {VDD VSS} -layer Metal6 -direction vertical -start_from right -width 0.5 -spacing 1 -set_to_set_distance 11 -switch_layer_over_obs 1

setSrouteMode -viaConnectToShape stripe
sroute -nets {VDD VSS} -connect {blockPin corePin padRing floatingStripe} -blockPinTarget nearestTarget -corePinTarget {stripe ring ringpin blockpin blockpin} -floatingStripeTarget {blockring padring ring stripe ringpin blockpin followpin } -layerChangeRange {Metal1(1) Metal6(6)} -crossoverViaLayerRange {Metal1(1) Metal6(6)} -allowLayerChange 1 -blockPin useLef



# Placemet..............
#setPlaceMode -placeIoPins true

#place_opt_design



# Checks after power planing..................................
verify_drc
verifyConnectivity
verifyConnectivity

# Saving the power planned file.....................
saveFPlan DBS/powerplan.fp
saveDesign DBS/powerplan.enc


# preCTS reports..................................
timeDesign -preCTS
report_timing 
optDesign -preCTS
