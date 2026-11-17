# In Vivado Tcl Console, source this file from any working directory.
# The .xpr is created under vivado/PackRight/PackRight.xpr beside this script.
set script_dir [file dirname [file normalize [info script]]]
set project_name PackRight
set project_dir [file join $script_dir vivado $project_name]

create_project $project_name $project_dir -part xc7s50-csga324-1 -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

foreach source_file [glob -nocomplain [file join $script_dir rtl *.sv]] {
    add_files $source_file
}
add_files -fileset constrs_1 [file join $script_dir constraints boolean_packright.xdc]
add_files -fileset sim_1 [file join $script_dir sim tb_packright_logic.sv]
add_files -fileset sim_1 [file join $script_dir sim tb_hx711_reader.sv]

set_property top packright_top [get_filesets sources_1]
set_property top tb_packright_logic [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "PackRight project created: [file join $project_dir PackRight.xpr]"
puts "The RFID reader and OLED display drivers are not implemented in this starter."
