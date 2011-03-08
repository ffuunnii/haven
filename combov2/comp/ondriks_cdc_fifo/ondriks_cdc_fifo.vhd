-- ondriks_cdc_fifo.vhd: Clock-Domain Crossing FIFO for Virtex-5
-- Author(s): Ondrej Lengal <lengal@liberouter.org>
--
-- $Id$
--

library ieee;
use ieee.std_logic_1164.all;

-- ==========================================================================
--                              ENTITY DECLARATION
-- ==========================================================================
entity ONDRIKS_CDC_FIFO is
   generic
   (
      -- data width
      DATA_WIDTH       : integer
   );
   port
   (
      -- asynchronous reset
      RESET            :  in std_logic;

      -- write interface
      WR_CLK           :  in std_logic;
      WR_DATA          :  in std_logic_vector(DATA_WIDTH-1 downto 0);
      WR_WRITE         :  in std_logic;
      WR_FULL          : out std_logic;
      WR_ALMOST_FULL   : out std_logic;

      -- read interface
      RD_CLK           :  in std_logic;
      RD_DATA          : out std_logic_vector(DATA_WIDTH-1 downto 0);
      RD_READ          :  in std_logic;
      RD_EMPTY         : out std_logic;
      RD_ALMOST_EMPTY  : out std_logic
   );
end entity;


-- ==========================================================================
--                           ARCHITECTURE DESCRIPTION
-- ==========================================================================
architecture arch of ONDRIKS_CDC_FIFO is

-- ==========================================================================
--                                    COMPONENTS
-- ==========================================================================

component asfifo_lut_1
	port (
	rst: IN std_logic;
	wr_clk: IN std_logic;
	rd_clk: IN std_logic;
	din: IN std_logic_VECTOR(0 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(0 downto 0);
	full: OUT std_logic;
	empty: OUT std_logic;
	prog_full: OUT std_logic;
	prog_empty: OUT std_logic);
end component;

component asfifo_lut_71
	port (
	rst: IN std_logic;
	wr_clk: IN std_logic;
	rd_clk: IN std_logic;
	din: IN std_logic_VECTOR(70 downto 0);
	wr_en: IN std_logic;
	rd_en: IN std_logic;
	dout: OUT std_logic_VECTOR(70 downto 0);
	full: OUT std_logic;
	empty: OUT std_logic;
	prog_full: OUT std_logic;
	prog_empty: OUT std_logic);
end component;


-- ==========================================================================
--                                      TYPES
-- ==========================================================================

-- ==========================================================================
--                                    CONSTANTS
-- ==========================================================================

-- ==========================================================================
--                                     SIGNALS
-- ==========================================================================

begin

   -- -----------------------------------------------------------------------
   --                              Assertions
   -- -----------------------------------------------------------------------
   assert ((DATA_WIDTH = 1) OR (DATA_WIDTH = 71))
      report "Invalid data width"
      severity failure;

gen_asfifo_1:
   if (DATA_WIDTH = 1) generate

      fifo_1 : asfifo_lut_1
		port map (
			rst => RESET,
			wr_clk => WR_CLK,
			rd_clk => RD_CLK,
			din => WR_DATA,
			wr_en => WR_WRITE,
			rd_en => RD_READ,
			dout => RD_DATA,
			full => WR_FULL,
			empty => RD_EMPTY,
			prog_full => WR_ALMOST_FULL,
			prog_empty => RD_ALMOST_EMPTY);
   end generate;

gen_asfifo_71:
   if (DATA_WIDTH = 71) generate

      fifo_71 : asfifo_lut_71
		port map (
			rst => RESET,
			wr_clk => WR_CLK,
			rd_clk => RD_CLK,
			din => WR_DATA,
			wr_en => WR_WRITE,
			rd_en => RD_READ,
			dout => RD_DATA,
			full => WR_FULL,
			empty => RD_EMPTY,
			prog_full => WR_ALMOST_FULL,
			prog_empty => RD_ALMOST_EMPTY);
   end generate;

end architecture;