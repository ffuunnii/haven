//
// testbench.sv: Top Entity for PCIE2IB BRIDGE automatic test
// Copyright (C) 2007 CESNET
// Author(s): Tomas Malek <tomalek@liberouter.org>
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
// 3. Neither the name of the Company nor the names of its contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
//
// This software is provided ``as is'', and any express or implied
// warranties, including, but not limited to, the implied warranties of
// merchantability and fitness for a particular purpose are disclaimed.
// In no event shall the company or contributors be liable for any
// direct, indirect, incidental, special, exemplary, or consequential
// damages (including, but not limited to, procurement of substitute
// goods or services; loss of use, data, or profits; or business
// interruption) however caused and on any theory of liability, whether
// in contract, strict liability, or tort (including negligence or
// otherwise) arising in any way out of the use of this software, even
// if advised of the possibility of such damage.
//
// $Id: testbench.sv 688 2007-10-19 16:11:56Z tomalek $
//

import test_pkg::*; // Test constants and types

// ----------------------------------------------------------------------------
//                                 TESTBENCH
// ----------------------------------------------------------------------------
module testbench;

  // -- Testbench wires and registers -----------------------------------------
  logic CLK = 0;
  logic RESET;
  iIbBm64            BM   (CLK, RESET);
  iInternalBusLink   UP   (CLK, RESET);
  iInternalBusLink   DOWN (CLK, RESET);
  iPcieRx            RX   (CLK, RESET);
  iPcieTx            TX   (CLK, RESET);
  iPcieCfg           CFG  (CLK, RESET);

  //-- Clock generation -------------------------------------------------------
  always #(cClkPeriod/2) CLK = ~CLK;

  //-- Unit Under Test --------------------------------------------------------
  PCIE2IB_BRIDGE_SV UUT ( // Unit Under Test
      .CLK     (CLK),
      .RESET   (RESET),
      .RX      (RX),
      .TX      (TX),
      .CFG     (CFG),
      .BM      (BM),
      .IB_DOWN (DOWN),
      .IB_UP   (UP)); 

  //-- Test -------------------------------------------------------------------
  TEST TEST_U ( // Testing program
      .CLK     (CLK),
      .RESET   (RESET),
      .RX      (RX),
      .TX      (TX),
      .CFG     (CFG),
      .BM      (BM),
      .IB_DOWN (DOWN),
      .IB_UP   (UP));

endmodule : testbench
