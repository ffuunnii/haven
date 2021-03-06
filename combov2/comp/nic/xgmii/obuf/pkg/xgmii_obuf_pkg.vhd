-- xgmii_obuf_pkg.vhd: XGMII OBUF Package
-- Copyright (C) 2008 CESNET
-- Author(s): Libor Polcak <polcak_l@liberouter.org>
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
-- $$
--
-- TODO:
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- ----------------------------------------------------------------------------
--                       XGMII OBUF Package
-- ----------------------------------------------------------------------------
package xgmii_obuf_pkg is

   -- OBUF commands
   constant OBUFCMD_STROBE_COUNTERS : std_logic_vector(7 downto 0) := X"01";
   constant OBUFCMD_RESET_COUNTERS  : std_logic_vector(7 downto 0) := X"02";

   -- Footer format
   constant C_FRAME_VLD_POS         : integer := 0;
   constant C_RPLC_SRC_MAC_POS      : integer := 1;
   constant C_FTR_MAX_BIT           : integer := C_RPLC_SRC_MAC_POS;

end xgmii_obuf_pkg;


-- ----------------------------------------------------------------------------
--                        XGMII OBUF Package
-- ----------------------------------------------------------------------------
package body xgmii_obuf_pkg is

end xgmii_obuf_pkg;

