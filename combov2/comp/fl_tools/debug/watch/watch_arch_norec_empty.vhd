-- watch_arch_norec_empty.vhd: Empty FL_WATCH_NOREC architecture
-- Copyright (C) 2006 CESNET
-- Author(s): Viktor Pus <pus@liberouter.org>
--	      Jan Stourac <xstour03@stud.fit.vutbr.cz>
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

-- library containing log2 and min functions
use work.math_pack.all;

-- ----------------------------------------------------------------------------
--                               Architecture
-- ----------------------------------------------------------------------------
architecture empty of FL_WATCH_NOREC is

   signal gnd_vect : std_logic_vector(6*INTERFACES+2*32+4+4-1 downto 0);

begin

   -- inputs grounded
   gnd_vect <= CLK
             & RESET
             & SOF_N
             & EOF_N
             & SOP_N
             & EOP_N
             & DST_RDY_N
             & SRC_RDY_N
             & MI_DWR
             & MI_ADDR
             & MI_RD
             & MI_WR
             & MI_BE;

   -- outputs inactive
   FRAME_ERR <= (others => '0');
   MI_DRD    <= (others => 'X');
   MI_ARDY   <= '0';
   MI_DRDY   <= '0';

end architecture empty;
