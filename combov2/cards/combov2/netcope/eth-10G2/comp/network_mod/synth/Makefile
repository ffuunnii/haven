# Makefile: Makefile to compile Network Module
# Copyright (C) 2009 CESNET
# Author: Viktor Pus <pus@liberouter.org>
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
# $Id: Makefile 14970 2010-08-11 07:28:31Z pus $
#


# makefile to synthesize component

# This makefile can produce these two modules:
MODULE_RXTX=network_mod_10g2
MODULE_RXTX64=network_mod_10g2_64
MODULE_RX=network_mod_10g2_rx

FIRMWARE_BASE=../../../../../../..

.PHONY: all doc precision

MAIN=Makefile.main

# Default: XST
xst: $(MODULE_RX).ngc $(MODULE_RXTX).ngc $(MODULE_RXTX64).ngc

precision: $(MODULE_RX).edf $(MODULE_RXTX).edf $(MODULE_RXTX64).edf

%.ngc: FORCE
	$(MAKE) -f $(MAIN) $@ SYNTH=xst PRE_XST_SYNTH="export XIL_XST_NOCMDCHECK=1"

%.edf: FORCE
	$(MAKE) -f $(MAIN) $@ SYNTH=precision SYNTHFLAGS="-shell -file" SYNTHFILES=Precision.tcl

FORCE:

clean:
	$(MAKE) -f $(MAIN) $@

doc:
	$(MAKE) -f $(MAIN) vhdocl
