# Makefile: Makefile to compile SFPRO design
# Copyright (C) 2006 CESNET
# Author: Tomas Martinek <martinek@liberouter.org>
# 		  Jan Korenek <korenek@liberouter.org>
# 		  Jiri Tobola <tobola@liberouter.org>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name of the Company nor the names of its contributors
#    may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# This software is provided ``as is'', and any express or implied
# warranties, including, but not limited to, the implied warranties of
# merchantability and fitness for a particular purpose are disclaimed.
# In no event shall the company or contributors be liable for any
# direct, indirect, incidental, special, exemplary, or consequential
# damages (including, but not limited to, procurement of substitute
# goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether
# in contract, strict liability, or tort (including negligence or
# otherwise) arising in any way out of the use of this software, even
# if advised of the possibility of such damage.
#
# $Id: Makefile 14 2007-07-31 06:44:05Z kosek $
#

# Synthesis tool: precision or spectrum or synplify
SYNTHESIS ?= precision
#SYNTHESIS ?= xst

# Base directory
VHDL_DESIGN = ../../../../..

# UCF
FPGAUCF = ent_sfpro.ucf 
ifeq ($(SYNTHESIS),xst)
	ADDUCF = fpga_xst.ucf
else
	ADDUCF = fpga_precision.ucf
endif

# Architecture + entity
SRC = sfpro_top.vhd
TOP = 


ifeq ($(SYNTHESIS),precision)
	#- Precision Synthesizer ---
	SYNTH = precision
	SYNTHFLAGS = -shell -file
	SYNTHFILES = Precision.tcl
else
	ifeq ($(SYNTHESIS),synplify)
		#- Synplify Synthesizer ----
		SYNTH = synplify_pro
		SYNTHFLAGS = -batch
		SYNTHFILES = Synplify.tcl
	else
		ifeq ($(SYNTHESIS),xst)
			SYNTH = xst
			SYNTHFLAGS = -ifn
			SYNTHFILES = XST.xst
		else
			#- Leonardo Synthesizer ----
			SYNTHFLAGS = -file=Leonardo.tcl
			VERSYNTHFLAGS = -file=Leonardo.ver.tcl
		endif
	endif
endif

#NGDBuild,MAP,PAR flags
#NGDBUILDFLAGS = -aul
MAPFLAGS = -timing -ol high
#PARFLAGS = -w -ol high

# Simulation specification
SIMF = 
SIMT = 

all: $(SRC:.vhd=.mcs)
	@echo "$(SRC:.vhd=.mcs) has been successfully built"

# Translation specification
include $(VHDL_DESIGN)/base/Makefile.fpga.inc

