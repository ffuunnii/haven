-- fls_cu_fsm.vhd: FrameLink Splitter Control Unit FSM architecture
-- Copyright (C) 2006 CESNET
-- Author(s): Martin Kosek <kosek@liberouter.org>
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
--                            Entity declaration
-- ----------------------------------------------------------------------------
entity FLS_CU_FSM is
   port(
      CLK            : in std_logic;
      RESET          : in std_logic;

      -- input signals
      EOF            : in  std_logic;
      QUEUE_RDY      : in  std_logic;

      -- output signals
      SET_VALID      : out std_logic;
      CLR_VALID      : out std_logic;
      CLR_READY      : out std_logic;
      NEXT_QUEUE     : out std_logic
   );
end entity FLS_CU_FSM;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture full of FLS_CU_FSM is

   -- ------------------ Types declaration ------------------------------------
   type t_state is ( CHOOSE_QUEUE, BUSY );
   
   -- ------------------ Signals declaration ----------------------------------
   signal present_state, next_state : t_state;

begin


   -- ------------------ Sync logic -------------------------------------------
   sync_logic  : process( RESET, CLK)
   begin
      if (RESET = '1') then
         present_state <= CHOOSE_QUEUE;
      elsif (CLK'event AND CLK = '1') then
         present_state <= next_state;
      end if;
   end process sync_logic;
   
   -- ------------------ Next state logic -------------------------------------
   next_state_logic : process(present_state, EOF, QUEUE_RDY)
   begin
   case (present_state) is
   
      -- ---------------------------------------------
      when CHOOSE_QUEUE =>
         if (QUEUE_RDY = '1') then
            next_state <= BUSY;
         else
            next_state <= CHOOSE_QUEUE;
         end if;

      -- ---------------------------------------------
      when BUSY =>
         if (EOF = '1' and QUEUE_RDY = '0') then
            next_state <= CHOOSE_QUEUE;
         else
            next_state <= BUSY;
         end if;

      end case;
   end process next_state_logic;

   -- ------------------ Output logic -----------------------------------------
   output_logic: process( present_state, QUEUE_RDY, EOF )
   begin
   
      -- ---------------------------------------------
      -- Initial values
      SET_VALID      <= '0';
      CLR_VALID      <= '0';
      CLR_READY      <= '0';
      NEXT_QUEUE     <= '0';

      case (present_state) is
      
      -- ---------------------------------------------
      when CHOOSE_QUEUE =>
         SET_VALID      <= QUEUE_RDY;
         NEXT_QUEUE     <= QUEUE_RDY;
         CLR_READY      <= QUEUE_RDY;

      -- ---------------------------------------------
      when BUSY =>
         NEXT_QUEUE     <= EOF and QUEUE_RDY;
         CLR_VALID      <= EOF and (not QUEUE_RDY);
   
      end case;
   end process output_logic;

end architecture full;
