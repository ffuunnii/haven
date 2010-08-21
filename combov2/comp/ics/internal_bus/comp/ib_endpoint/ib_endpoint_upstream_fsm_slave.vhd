--
-- ib_endpoint_upstream_fsm_slave.vhd: Upstream FSM Slave Mode
-- Copyright (C) 2006 CESNET
-- Author(s): Petr Kobiersky <xkobie00@stud.fit.vutbr.cz>
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
-- TODO:
--
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.ib_pkg.all; -- Internal Bus package

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity IB_ENDPOINT_UPSTREAM_FSM_SLAVE is
   port (
   -- Common Interface
   CLK                : in std_logic;  -- Clk
   RESET              : in std_logic;  -- Reset
   -- HDR_GEN Interface
   RD_COMPL_REQ       : in  std_logic;
   RD_COMPL_ACK       : out std_logic;

   -- Control            
   GET_SECOND_HDR     : out std_logic; -- Get second header
   
   -- Align buffer Interface
   RD_SRC_RDY         : in  std_logic;  -- Align buffer src_rdy
   RD_DST_RDY         : out std_logic;  -- Align buffer dst_rdy
   RD_EOF             : in  std_logic;  -- Align buffer eof 

   -- Multipexor Interface
   MUX_SEL            : out std_logic; -- Select HEADER/DATA

   -- Upstream Interface
   SOP                : out std_logic; -- Start of Packet (Start of transaction)
   EOP                : out std_logic; -- Ent of Packet (End of Transaction)
   SRC_RDY            : out std_logic; -- Source Ready
   DST_RDY            : in  std_logic  -- Destination Ready
   );
end entity IB_ENDPOINT_UPSTREAM_FSM_SLAVE;

  
-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture IB_ENDPOINT_UPSTREAM_FSM_SLAVE_ARCH of IB_ENDPOINT_UPSTREAM_FSM_SLAVE is

   -- Control FSM declaration
   type   t_states is (st_idle, st_read_wait, st_rd_hdr, st_data);
   signal present_state, next_state : t_states;

begin


-- UPSTREAM FSM -----------------------------------------------------------
-- next state clk logic
clk_d: process(CLK, RESET)
  begin
    if RESET = '1' then
      present_state <= st_idle;
    elsif (CLK='1' and CLK'event) then
      present_state <= next_state;
    end if;
  end process;

-- TODO : Priorita na RD a WR

-- next state logic
state_trans: process(present_state, RD_COMPL_REQ, DST_RDY, RD_EOF, RD_SRC_RDY)
  begin
    case present_state is

      -- ST_IDLE
      when st_idle =>
         -- Header Valid
         if (RD_COMPL_REQ = '1') then
            next_state <= st_read_wait;
         else
            next_state <= st_idle;
         end if;
      
      -- Wait for readed data
      when st_read_wait =>
         if (DST_RDY = '1' and RD_SRC_RDY = '1') then
            next_state <= st_rd_hdr;
         else
            next_state <= st_read_wait;
         end if;

      -- ST_RD_HDR
      when st_rd_hdr =>
         if (DST_RDY = '1') then
            next_state <= st_data;
         else
            next_state <= st_rd_hdr;
         end if;
         
      -- ST_DATA
      when st_data =>
         -- When Last data readed
         if (DST_RDY = '1' and RD_EOF = '1') then
           next_state <= st_idle;
         else
           next_state <= st_data;
         end if;
         
      end case;
  end process;

-- output logic
output_logic: process(present_state, RD_COMPL_REQ, DST_RDY, RD_EOF, RD_SRC_RDY)
  begin
   MUX_SEL            <= '0'; -- Select HEADER/DATA
   RD_DST_RDY         <= '0'; -- RD_DST_RDY
   SOP                <= '0'; -- Start of Packet (Start of transaction)
   EOP                <= '0'; -- Ent of Packet (End of Transaction)
   SRC_RDY            <= '0'; -- Source Ready
   GET_SECOND_HDR     <= '0';
   RD_COMPL_ACK       <= '0';
  
   case present_state is

      -- ST_IDLE
      when st_idle =>
         RD_DST_RDY <= '0';
         if (RD_COMPL_REQ = '1') then
            RD_COMPL_ACK  <= '1';
         end if;

      when st_read_wait =>
         if (DST_RDY = '1' and RD_SRC_RDY = '1') then
            SOP               <= '1';
            SRC_RDY           <= '1';
         end if;

      -- ST_RD_HDR
      when st_rd_hdr =>
         GET_SECOND_HDR    <= '1';
         SRC_RDY           <= DST_RDY;
               
      -- ST_DATA
      when st_data =>
         RD_DST_RDY        <= DST_RDY;
         EOP               <= RD_EOF;
         SRC_RDY           <= RD_SRC_RDY;
         MUX_SEL           <= '1';
      end case;
  end process;

end architecture IB_ENDPOINT_UPSTREAM_FSM_SLAVE_ARCH;
