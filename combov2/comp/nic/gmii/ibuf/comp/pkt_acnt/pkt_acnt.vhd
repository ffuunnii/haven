--
-- pkt_acnt.vhd: Asynchronous counter with one increasing port and one
-- decreasing port for control of reading packets from buffer
-- Copyright (C) 2006 CESNET
-- Author(s): Martin Mikusek <martin.mikusek@liberouter.org>
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- library containing log2 function
use work.math_pack.all;

-- auxilarity function needed to compute address width
--use WORK.bmem_func.all;
use WORK.cnt_types.all;

-- pragma translate_off
library UNISIM;
use UNISIM.vcomponents.all;
-- pragma translate_on
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity pkt_acnt is
    generic(
      -- ITEMS = Numer of items
      -- !!!!!!!!!!! Must be (2^n)-1, n>=2 !!!!!!!!!!!!!!!!!!!!!!
      ITEMS        : integer;
      STATUS_WIDTH : integer
   );
   port (
      RESET       : in  std_logic;

      -- Write interface
      CLK_WR      : in  std_logic;
      INC         : in  std_logic;
      FULL        : out std_logic;
      STATUS      : out std_logic_vector(STATUS_WIDTH-1 downto 0);

      -- Read interface
      CLK_RD      : in  std_logic;
      DEC         : in  std_logic;
      EMPTY       : out std_logic
   );
end pkt_acnt;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of pkt_acnt is

   -- Number of address bits
   constant FADDR            : integer := LOG2(ITEMS)-1;

   -- FIFO part signals
   signal cnt_read_addr      : std_logic_vector(FADDR downto 0);
   signal read_addrgray      : std_logic_vector(FADDR downto 0);
   signal read_nextgray      : std_logic_vector(FADDR downto 0);
   signal read_lastgray      : std_logic_vector(FADDR downto 0);

   signal cnt_write_addr     : std_logic_vector(FADDR downto 0);
   signal write_addrgray     : std_logic_vector(FADDR downto 0);
   signal write_nextgray     : std_logic_vector(FADDR downto 0);

   signal reg_status         : std_logic_vector(FADDR downto 0);
   signal read_truegray      : std_logic_vector(FADDR downto 0);
   signal reg_read_truegray  : std_logic_vector(FADDR downto 0);
   signal read_bin           : std_logic_vector(FADDR downto 0);
   signal reg_cnt_write_addr : std_logic_vector(FADDR downto 0);


   signal read_allow         : std_logic;
   signal write_allow        : std_logic;
   signal empty_allow        : std_logic;
   signal full_allow         : std_logic;

   signal ecomp              : std_logic_vector(FADDR downto 0);
   signal fcomp              : std_logic_vector(FADDR downto 0);
   signal emuxcyo            : std_logic_vector(FADDR+1 downto 0);
   signal fmuxcyo            : std_logic_vector(FADDR+1 downto 0);
   signal emptyg             : std_logic;
   signal fullg              : std_logic;
   signal regasync_full      : std_logic;
--    signal reg_full_fall    : std_logic;
   signal regasync_empty     : std_logic;
--    signal reg_empty_fall   : std_logic;

   signal gnd                : std_logic;
   signal pwr                : std_logic;

component MUXCY_L
   port (
      DI:  in std_logic;
      CI:  in std_logic;
      S:   in std_logic;
      LO: out std_logic);
end component;

begin

   gnd      <= '0';
   pwr      <= '1';

-- ------------------------------------------------------------------------
--                       Control Part
-- ------------------------------------------------------------------------
--  allow flags generation

read_allow <= (DEC and not regasync_empty);
write_allow <= (INC and not regasync_full);

full_allow <= (regasync_full or INC);
empty_allow <= (regasync_empty or DEC);


---------------------------------------------------------------
--  empty and full flag generation

-- rising edge
process (CLK_RD, RESET)
begin
   if (RESET = '1') then
      regasync_empty <= '1';
   elsif (CLK_RD'event and CLK_RD = '1') then
      if (empty_allow = '1') then
         regasync_empty <= emptyg;
      end if;
   end if;
end process;

-- rising edge
process (CLK_WR, RESET)
begin
   if (RESET = '1') then
      regasync_full <= '1';
   elsif (CLK_WR'event and CLK_WR = '1') then
      if (full_allow = '1') then
         regasync_full <= fullg;
      end if;
   end if;
end process;

----------------------------------------------------------------
--              Read Address Genearation
----------------------------------------------------------------

cnt_read_addr_u : entity work.cnt
generic map(
   WIDTH => FADDR+1,
   DIR   => up,
   CLEAR => false
)
port map(
   RESET => RESET,
   CLK   => CLK_RD,
   DO    => cnt_read_addr,
   CLR   => '0',
   CE    => read_allow
);

read_nextgray_p: process (CLK_RD, RESET)
begin
   if (RESET = '1') then
      read_nextgray <= conv_std_logic_vector(2**(FADDR), FADDR+1);
   elsif (CLK_RD'event and CLK_RD = '1') then
      if (read_allow = '1') then
         -- binary to gray convertor
         read_nextgray(FADDR) <= cnt_read_addr(FADDR);
         for i in FADDR-1 downto 0 loop
            read_nextgray(i) <= cnt_read_addr(i+1) xor cnt_read_addr(i);
         end loop;
      end if;
   end if;
end process;

read_addrgray_p: process (CLK_RD, RESET)
begin
   if (RESET = '1') then
      read_addrgray <= conv_std_logic_vector(2**(FADDR)+1, FADDR+1);
   elsif (CLK_RD'event and CLK_RD = '1') then
      if (read_allow = '1') then
         read_addrgray <= read_nextgray;
      end if;
   end if;
end process;

proc6: process (CLK_RD, RESET)
begin
   if (RESET = '1') then
      read_lastgray <= conv_std_logic_vector(2**(FADDR)+3, FADDR+1);
   elsif (CLK_RD'event and CLK_RD = '1') then
      if (read_allow = '1') then
         read_lastgray <= read_addrgray;
      end if;
   end if;
end process proc6;

----------------------------------------------------------------
--             Write Address Genearation
----------------------------------------------------------------

cnt_write_addr_u : entity work.cnt
generic map(
   WIDTH => FADDR+1,
   DIR   => up,
   CLEAR => false
)
port map(
   RESET => RESET,
   CLK   => CLK_WR,
   DO    => cnt_write_addr,
   CLR   => '0',
   CE    => write_allow
);

write_nextgray_p: process (CLK_WR, RESET)
begin
   if (RESET = '1') then
      write_nextgray <= conv_std_logic_vector(2**(FADDR), FADDR+1);
   elsif (CLK_WR'event and CLK_WR = '1') then
      if (write_allow = '1') then
         -- binary to gray convertor
         write_nextgray(FADDR) <= cnt_write_addr(FADDR);
         for i in FADDR-1 downto 0 loop
            write_nextgray(i) <= cnt_write_addr(i+1) xor cnt_write_addr(i);
         end loop;
      end if;
   end if;
end process;

write_addrgray_p: process (CLK_WR, RESET)
begin
   if (RESET = '1') then
      write_addrgray <= conv_std_logic_vector(2**(FADDR)+1, FADDR+1);
   elsif (CLK_WR'event and CLK_WR = '1') then
      if (write_allow = '1') then
         write_addrgray <= write_nextgray;
      end if;
   end if;
end process;

----------------------------------------------------------------
--                     Fast carry logic
----------------------------------------------------------------

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ECOMP_GEN : for i in 0 to FADDR generate
   ecomp(i) <= (not (write_addrgray(i) xor read_addrgray(i)) and regasync_empty) or
               (not (write_addrgray(i) xor read_nextgray(i)) and not regasync_empty);
end generate;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
emuxcyo(0)  <= pwr;
emptyg      <= emuxcyo(FADDR+1);

EMUXCY_GEN : for i in 0 to FADDR generate
   emuxcyX: MUXCY_L
   port map (
      DI => gnd,
      CI => emuxcyo(i),
      S  => ecomp(i),
      LO => emuxcyo(i+1)
   );
end generate;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FCOMP_GEN : for i in 0 to FADDR generate
   fcomp(i) <= (not (read_lastgray(i) xor write_addrgray(i)) and regasync_full) or
               (not (read_lastgray(i) xor write_nextgray(i)) and not regasync_full);
end generate;

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fmuxcyo(0)  <= pwr;
fullg       <= fmuxcyo(FADDR+1);

FMUXCY_GEN : for i in 0 to FADDR generate
   fmuxcyX: MUXCY_L
   port map (
      DI => gnd,
      CI => fmuxcyo(i),
      S  => fcomp(i),
      LO => fmuxcyo(i+1)
   );
end generate;


----------------------------------------------------------------
--             Status Genearation
----------------------------------------------------------------
-- graycode read address generation
read_truegray_p: process (CLK_RD, RESET)
begin
   if (RESET='1') then
      read_truegray <= (others=>'0');
   elsif (CLK_RD'event and CLK_RD='1') then
      ----------------------------------------------------
      read_truegray(FADDR) <= cnt_read_addr(FADDR);
      read_truegray_gen : for i in FADDR-1 downto 0 loop
         read_truegray(i) <= cnt_read_addr(i+1) xor cnt_read_addr(i);
      end loop;
   end if;
end process;

-- synchronization with CLK_WR
reg_read_truegray_p: process (CLK_WR, RESET)
begin
   if (RESET='1') then
      reg_read_truegray <= (others=>'0');
   elsif (CLK_WR'event and CLK_WR='1') then
      reg_read_truegray <= read_truegray;
   end if;
end process;

-- transformation to binary format
read_bin(FADDR) <= reg_read_truegray(FADDR);
read_bin_gen : for i in FADDR-1 downto 0 generate
   read_bin(i) <= read_bin(i+1) xor reg_read_truegray(i);
end generate;

-- registering of cnt_write_addr
reg_cnt_write_addr_p: process (CLK_WR, RESET)
begin
   if (RESET='1') then
      reg_cnt_write_addr <= (others=>'0');
   elsif (CLK_WR'event and CLK_WR='1') then
      reg_cnt_write_addr <= cnt_write_addr;
   end if;
end process;

-- status computing
reg_status_p: process (CLK_WR, RESET)
begin
   if (RESET='1') then
      reg_status <= (others=>'0');
   elsif (CLK_WR'event and CLK_WR='1') then
      if (regasync_full='0') then
         reg_status <= (reg_cnt_write_addr - read_bin);
      end if;
   end if;
end process;

----------------------------------------------------------------
--                   Interface Mapping
----------------------------------------------------------------
FULL   <= regasync_full;
EMPTY  <= regasync_empty;
STATUS <= reg_status(FADDR downto FADDR-STATUS_WIDTH+1); -- we use only few MSB bits

end behavioral;
-- ----------------------------------------------------------------------------

