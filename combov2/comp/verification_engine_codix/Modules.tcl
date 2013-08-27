# Modules.tcl: Local include Modules tcl script
# Author: Ondrej Lengal <ilengal@fit.vutbr.cz>
#
# $Id$
#

# Set paths
set COMP_BASE              "$ENTITY_BASE/.."
set FIRMWARE_BASE          "$COMP_BASE/.."
set FL_BASE                "$COMP_BASE/fl_tools"

set FL_ADDER_BASE          "$FL_BASE/edit/netcope_adder"
set VER_CORE_BASE          "$COMP_BASE/verification_core_codix"
set FL_RAND_GEN_BASE       "$COMP_BASE/hw_ver/fl_rand_gen"
set FL_COM_UNIT_BASE       "$COMP_BASE/hw_ver/fl_command_unit"
set FL_SCOREBOARD_BASE     "$COMP_BASE/hw_ver/fl_hw_scoreboard"
set FL_FILTER_BASE         "$COMP_BASE/hw_ver/fl_filter"
set FL_WATCH_BASE          "$COMP_BASE/fl_tools/debug/watch"

# Source files
set MOD "$MOD $ENTITY_BASE/verification_engine_ent.vhd"

# Components
set COMPONENTS [list \
   [ list "FL_ADDER"           $FL_ADDER_BASE         "FULL"] \
]

##############################################################################
# The CODIX architecture contains:
#
#   * program driver
#   * DUT (Codix)
#   * memory monitor
#   * halt monitor
#   * portout monitor
#   * fl binder
##############################################################################
if { $ARCHGRP == "CODIX" } {

  # Source the HAVEN package
  set PACKAGES "$PACKAGES $FIRMWARE_BASE/pkg/haven_const.vhd"

  # verification core codix + netcope adder
  set MOD "$MOD $ENTITY_BASE/verification_engine_core.vhd"

   set COMPONENTS [concat $COMPONENTS [list \
     [ list "VER_CORE"             $VER_CORE_BASE        "FULL"] \
   ]]
}