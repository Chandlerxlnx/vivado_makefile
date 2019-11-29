# Header {{{ 
# (c) Copyright 2014 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES. 
################################################################################
#
# Vendor         : Xilinx
#
# Revision       : $Revision: #6 $
# Date           : $DateTime: 2015/04/28 14:00:18 $
# Last Author    : $Author: jwest $
#
################################################################################
# Description :
#
# The IP delivered with the project, vivado_ip_delivered, only contains the XCI
# files. This file builds the IP into a vivado_ip_built_${board} directory.
#
# This file requires that the $part variable has already been set, so it is
# sourced from the upper level build script. It is automatically run if the
# vivado_ip_built_${board} directory does not exist.
#############################################################################}}}
proc build_vivado_ip {{board U200} {part xcu200-fsgd2104-2-e} {jobs 10}} {
    set cwd [pwd]
    puts "Building IP at $cwd"
    
    create_project -force managed_ip_project ./vivado_ip_built_${board}/managed_ip_project -part $part -ip
    set_property simulator_language Verilog [current_project]
    
    # Copy Delivered IP to ./vivado_ip_built_${board}
    #set xci_files [glob vivado_ip_delivered/*.xci]
    set xci_files [glob hard_ip/*.xci]
    
    foreach xci_file  ${xci_files} {
        set ip_name  [string trim [file tail ${xci_file}] ".xci"]
        add_files -force -copy_to ./vivado_ip_built_${board} ./${xci_file}
        upgrade_ip [get_ips  ${ip_name} ]
        generate_target all [get_ips ${ip_name}]
        create_ip_run  [get_ips ${ip_name}]
    }
    
    
    #create the board file if it exist
    foreach bd_tcl [glob mb_system/*.tcl] {
      if [file exist $bd_tcl] {
        source  $bd_tcl
        generate_target all [get_files  *.bd]
        create_ip_run [get_files -of_objects [get_fileset sources_1] [get_files *.bd]] 
        puts "**************************************\n"
        #export_simulation -of_objects [get_files [get_bd_files *]] \
            -directory vivado_ip_built_${board}/ip_user_files/sim_scripts \
            -ip_user_files_dir vivado_ip_built_U200/ip_user_files \
            -ipstatic_source_dir vivado_ip_built_U200/ip_user_files/ipstatic \
            -use_ip_compiled_libs -force -quiet
      }
    }
        puts "22222**************************************\n"
    #wait_on_run [get_runs]

    # Generate IP
    launch_runs [get_runs *_synth_1] -jobs ${jobs} -quiet
    
        puts "33333**************************************\n"
    foreach synth_run [get_runs *_synth_1] {
        wait_on_run [get_runs $synth_run]
    }
    
    puts "Done Building IP at $cwd"
    close_project;
}
