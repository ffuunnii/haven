/*
 * testbench.sv: Top Entity for TX DMA Controller automatic test
 * Copyright (C) 2008 CESNET
 * Author(s): Marek Santa <xsanta06@stud.fit.vutbr.cz>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the Company nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * This software is provided ``as is'', and any express or implied
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose are disclaimed.
 * In no event shall the company or contributors be liable for any
 * direct, indirect, incidental, special, exemplary, or consequential
 * damages (including, but not limited to, procurement of substitute
 * goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether
 * in contract, strict liability, or tort (including negligence or
 * otherwise) arising in any way out of the use of this software, even
 * if advised of the possibility of such damage.
 *
 * $Id: testbench.sv 8583 2009-06-01 14:33:57Z xsimko03 $
 *
 * TODO:
 *
 */
 

// ----------------------------------------------------------------------------
//                                 TESTBENCH
// ----------------------------------------------------------------------------
import test_pkg::*; // Test constants

module testbench;

  // -- Testbench wires and interfaces ----------------------------------------
  logic            CLK   = 0;
  logic            RESET;
  iMi32                                 SW   (CLK, RESET);
  iInternalBus                          IB   (CLK, RESET);
  iDmaCtrl   #(CTRL_DMA_DATA_WIDTH)     MISC   [BUFFER_FLOWS] (CLK, RESET);
  iDmaCtrl   #(CTRL_DMA_DATA_WIDTH)     DESC   [BUFFER_FLOWS] (CLK, RESET);
  iDmaCtrl   #(CTRL_DMA_DATA_WIDTH)     DMA    [BUFFER_FLOWS] (CLK, RESET);
  iFrameLinkRx #(RXDWIDTH, RXDREMWIDTH) FL     [BUFFER_FLOWS] (CLK, RESET);
    
  //-- Clock generation -------------------------------------------------------
  always #(CLK_PERIOD/2) CLK = ~CLK;


  //-- Design Under Test ------------------------------------------------------
  DUT DUT_U   (.CLK     (CLK),
               .RESET   (RESET),
               .SW      (SW),
               .IB      (IB),
               .MISC    (MISC),
               .DESC    (DESC),
               .DMA     (DMA),
               .FL      (FL)
              );


  //-- Test -------------------------------------------------------------------
  TEST TEST_U (.CLK     (CLK),
               .RESET   (RESET),
               .SW      (SW),
               .IB      (IB),
               .MISC    (MISC),
               .DESC    (DESC),
               .DMA     (DMA),
               .FL      (FL)
              );

endmodule : testbench
