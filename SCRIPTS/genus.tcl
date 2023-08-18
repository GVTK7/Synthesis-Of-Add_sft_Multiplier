
set_db init_lib_search_path /home/user03/Desktop/Cadence/stlc_mul/LIBS/lib/min/
set_db init_hdl_search_path /home/user03/Desktop/Cadence/stlc_mul/DATA/


read_libs fast.lib

read_hdl {MATRIX_MUL_SYSTOLIC.v  Memory.v RingShiftRegister.v No_of_Dlys.v  Delay_module.v Pe_network.v   row_pe.v  pe.v  DFlipFlop.v Array_MUL_Sign.v Array_MUL_USign.v Add_Sub_Nbit.v Full_Adder.v  Half_Adder.v OR_2in.v}

elaborate 

#check_design -unresolved


read_sdc /home/user03/Desktop/Cadence/stlc_mul/DATA/constraints.sdc


							#synthesis


#here record all modules commands are to check the flattening /ungrouped modules of original rtl codded heirchary modules,
#record_all_modules      -out_file initial_module_list_elab

#set_attribute syn_generic_effort medium
set_db syn_generic_effort medium
syn_generic
#record_all_modules      -out_file initial_module_list_generic


#set_attribute syn_map_effort medium
set_db syn_map_effort medium
syn_map
#record_all_modules      -out_file initial_module_list_map



#set_attribute syn_opt_effort medium
set_db syn_opt_effort medium
syn_opt

#commands to check the flattening
#check_flattened_modules -load_file initial_module_list_generic -out_file out_opt_v_generic
#check_flattened_modules -load_file initial_module_list_elab    -out_file out_opt_v_elab




synthesize -to_mapped -effort medium

write_hdl > Sys_Multiplier_netlist.v
write_sdc > Sys_Multiplier_constraints.sdc
#write_sdf > Multiplier_delay.sdf
#write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge > delays.sdf



report_units
report_units > design_units
report_gates
report_gates > design_gates
report_power
report_power > design_power
report_timing
report_timing > design_timing
report_qor
report_qor > design_qor
check_design
gui_show
