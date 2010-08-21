-- dma_2x64b_rx_const.vhd: User constants for 2x64b RX DMA Module
-- Copyright (C) 2008 CESNET
-- Author(s):  Pavol Korcek <korcek@liberouter.org>
--             Martin Kosek <kosek@liberouter.org>
--             Jan Vozenilek <xvozen00@stud.fit.vutbr.cz>
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. Neither the name of the Company nor the names of its contributors
--    may be used to endorse or promote products derived from this
--    software without specific prior written permission.
--
-- This software is provided ``as is'', and any express or implied
-- warranties, including, but not limited to, the implied warranties of
-- merchantability and fitness for a particular purpose are disclaimed.
-- In no event shall the company or contributors be liable for any
-- direct, indirect, incidental, special, exemplary, or consequential
-- damages (including, but not limited to, procurement of substitute
-- goods or services; loss of use, data, or profits; or business
-- interruption) however caused and on any theory of liability, whether
-- in contract, strict liability, or tort (including negligence or
-- otherwise) arising in any way out of the use of this software, even
-- if advised of the possibility of such damage.
--
-- $Id$
--

library IEEE;
use IEEE.std_logic_1164.all;

package dma_mod_nx64b_rx_const is

   -- ------------------ Constants declaration --------------------------------
   
      -- --------------- Internal Bus Endpoint --------------------------------
      constant IB_LIMIT                :  std_logic_vector(31 downto 0) := X"01000000";
      constant IB_INPUT_BUFFER_SIZE    :  integer := 0;
      constant IB_OUTPUT_BUFFER_SIZE   :  integer := 0;
      constant IB_READ_REORDER_BUFFER  :  boolean := true;
      -- enable strict version
      constant IB_STRICT_EN            :  boolean := false;   
      
      -- --------------- Local Bus Endpoint -----------------------------------
      constant LB_BASE_ADDR            :  std_logic_vector(31 downto 0) := X"00000800";
      constant LB_LIMIT                :  std_logic_vector(31 downto 0) := X"00000800";
      constant LB_FREQUENCY            :  integer := 100;
      constant LB_BUFFER_EN            :  boolean := false;

      -- RXTX BUFFERs ------------------------------------------------------------
      constant RXTX_BLOCK_SIZE         : integer := 512;  -- 64b words
      -- Total size (bytes) for one iterface in RX/TX buffer. 
      constant RXTX_IFC_TOTAL_SIZE     : integer := 16384;
--      constant RXTX_IFC_TOTAL_SIZE     : integer := 32768;
      -- DMA Controller generics
      constant RXTX_MEM_PAGE_SIZE      : integer := 4096;
      constant RXTX_OPT_DESC_BLOCK_SIZE : integer := 16;
      constant RXTX_INT_TIMEOUT        : integer := 10;
      constant RXTX_BUFFER_ADDR        : std_logic_vector(31 downto 0) := X"02000000";
      constant RXTX_BUFFER_SIZE        : integer := RXTX_BLOCK_SIZE*8;  -- bytes
      constant RXTX_DESC_BASE_ADDR     : std_logic_vector(31 downto 0) := X"02200000";
      -- ------------------------------------------------------------------------- 
end dma_mod_nx64b_rx_const;

package body dma_mod_nx64b_rx_const is
end dma_mod_nx64b_rx_const;

