# Create project
prj_create -name "shokolade_oder_night" -impl "impl_1" -dev iCE40UP5K-SG48I -performance "High-Performance_1.2V" -synthesis "synplify"

# Add hdl sources
prj_add_source "../hdl_src/clock_handler.vhd"
prj_add_source "../hdl_src/led_handler.vhd"
prj_add_source "../hdl_src/top_level.vhd"
prj_set_impl_opt -impl "impl_1" {top} {top}

# Add constraint sources
prj_add_source "../constraint_src/constraint.pdc"

# Add programming configuration source
prj_add_source "../lattice_src/programmer_configuration.xcf"

# Set strategy
prj_import_strategy -name "main_strategy" -file "../lattice_src/strategy.sty"
prj_set_strategy "main_strategy"

# Save
prj_save

# Create bitstream
prj_run Synthesis -impl impl_1
prj_run Map -impl impl_1
prj_run PAR -impl impl_1
prj_run Export -impl impl_1

# Save
prj_save