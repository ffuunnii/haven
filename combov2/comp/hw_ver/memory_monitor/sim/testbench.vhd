--  ---------------------------------------------------------
--  Hardware accelerated Functional Verification of Processor
--  ---------------------------------------------------------

--  \file   testbench.vhd
--  \date   10-04-2013
--  \brief  Testbench for memory monitor

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
--use work.fl_sim_oper.all;
--use work.fl_bfm_pkg.all;
--use work.fl_bfm_rdy_pkg.all;
--use work.math_pack.all;


entity testbench is
end entity testbench;

architecture behavioral of testbench is

   -- constants
   constant IN_DATA_WIDTH        : integer := 32;
   constant OUT_DATA_WIDTH       : integer := 64;

   constant clkper               : time := 10 ns; 
   constant reset_time           : time := 100 ns;

   -- signals
   signal clk                    : std_logic;
   signal reset                  : std_logic;

   signal dbg_mode_mem : std_logic;
   signal HALT         : std_logic;
   signal Q0           : std_logic_vector(IN_DATA_WIDTH-1 downto 0);
   signal Q1           : std_logic_vector(IN_DATA_WIDTH-1 downto 0);
   signal RA0          : std_logic_vector(18 downto 0);
   signal RA1          : std_logic_vector(18 downto 0);
   signal RE0          : std_logic;
   signal RE1          : std_logic;
   signal RSC0         : std_logic_vector(2 downto 0);
   signal RSC1         : std_logic_vector(2 downto 0);
   signal RSI0         : std_logic_vector(1 downto 0);
   signal RSI1         : std_logic_vector(1 downto 0);
   signal TX_DATA      : std_logic_vector(OUT_DATA_WIDTH-1 downto 0);
   signal TX_REM       : std_logic_vector(2 downto 0);
   signal TX_SRC_RDY_N : std_logic;
   signal TX_DST_RDY_N : std_logic;
   signal TX_SOP_N     : std_logic;
   signal TX_EOP_N     : std_logic;
   signal TX_SOF_N     : std_logic;
   signal TX_EOF_N     : std_logic;

-- ----------------------------------------------------------------------------
--                      Architecture body
-- ----------------------------------------------------------------------------
begin

   uut: entity work.MEMORY_MONITOR
      generic map (
         IN_DATA_WIDTH     => IN_DATA_WIDTH,
         OUT_DATA_WIDTH    => OUT_DATA_WIDTH
      )
      port map (
         CLK          => clk,
         RESET        => reset,

         -- inputs
         Q0           => Q0,
         Q1           => Q1,
         TX_DST_RDY_N => TX_DST_RDY_N,
         HALT         => HALT,

         -- outputs
         dbg_mode_mem => dbg_mode_mem,
         RA0          => RA0,
         RA1          => RA1,
         RE0          => RE0,
         RE1          => RE1,
         RSC0         => RSC0,
         RSC1         => RSC1,
         RSI0         => RSI0,
         RSI1         => RSI1,
         TX_DATA      => TX_DATA,
         TX_REM       => TX_REM,
         TX_SRC_RDY_N => TX_SRC_RDY_N,
         TX_SOP_N     => TX_SOP_N,
         TX_EOP_N     => TX_EOP_N,
         TX_SOF_N     => TX_SOF_N,
         TX_EOF_N     => TX_EOF_N

      );

   -- CLK generator
   clkgen: process
   begin
      clk <= '1';
      wait for clkper/2;
      clk <= '0';
      wait for clkper/2;
   end process;
   
   resetgen: process
   begin
      reset <= '1';
      wait for reset_time;
      reset <= '0';
      wait;
   end process;

   tb: process

   begin

      wait for reset_time; 
      wait until rising_edge(clk);

      HALT         <= '1';
      TX_DST_RDY_N <= '0';

      Q0           <= X"22222222";
      Q1           <= X"11111111";


  end process tb; 
   
end architecture behavioral;
