-- rx_dma_ctrl_opt_buf_wrapper.vhd: Optimized RX DMA controller and RX buffer
--                                  wrapper
-- Copyright (C) 2007 CESNET
-- Author(s): Ondrej Lengal <xlenga00@stud.fit.vutbr.cz>
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- package with log2 function
use work.math_pack.all;

-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity rx_dma_ctrl_opt_buf_wrapper is
generic (
  -- ============= RX BUFFER generics ================
  -- data width of the RX buffer
  BUFFER_DATA_WIDTH       : integer := 64;
  -- available space in the RX buffer for each flow
  BUFFER_BLOCK_SIZE       : integer := 512;
  -- total size of the RX buffer for on flow is BUFFER_DATA_WIDTH * BUFFER_BLOCK_SIZE [bit]
  
  -- number of flows (i.e. FrameLinks) leaving the RX buffer
  BUFFER_FLOWS            : integer := 2;
  -- total size [bytes] for one flow (interface)
  BUFFER_TOTAL_FLOW_SIZE  : integer := 16384;

  -- ============ RX CTRL OPT generics ===============
  
  -- base address of the RX buffer (to be used in DMA requests as local address)
  CTRL_BUFFER_ADDR        : integer := 0;
  -- the width of the DMA request interface
  CTRL_DMA_DATA_WIDTH     : integer := 16
);
port (
  -- common interface
  CLK         : in  std_logic;
  RESET       : in  std_logic;

  -- misc signals
  INTERRUPT   : out std_logic_vector(BUFFER_FLOWS-1 downto 0);  -- interrupt request

  -- descriptor FIFO interface
  DESC_READ   : out std_logic_vector(BUFFER_FLOWS-1 downto 0);
  DESC_DO     : in  std_logic_vector(BUFFER_FLOWS*CTRL_DMA_DATA_WIDTH-1 downto 0);
  DESC_EMPTY  : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  DESC_ENABLE : out std_logic_vector(BUFFER_FLOWS-1 downto 0);  -- "controller is enabled" signal

  -- memory interface
  SW_DWR      : in  std_logic_vector(31 downto 0);
  SW_ADDR     : in  std_logic_vector(31 downto 0);
  SW_RD       : in  std_logic;
  SW_WR       : in  std_logic;
  SW_BE       : in  std_logic_vector(3 downto 0);
  SW_DRD      : out std_logic_vector(31 downto 0);
  SW_ARDY     : out std_logic;
  SW_DRDY     : out std_logic;

  -- DMA Interface
  DMA_ADDR    : in  std_logic_vector(BUFFER_FLOWS*log2(128/CTRL_DMA_DATA_WIDTH)-1 downto 0);
  DMA_DOUT    : out std_logic_vector(BUFFER_FLOWS*CTRL_DMA_DATA_WIDTH-1 downto 0);
  DMA_REQ     : out std_logic_vector(BUFFER_FLOWS-1 downto 0);
  DMA_ACK     : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  DMA_DONE    : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  DMA_TAG     : in  std_logic_vector(BUFFER_FLOWS*16-1 downto 0);

  -- Read interface (InternalBus)
  RD_ADDR       : in  std_logic_vector(31 downto 0);
  RD_BE         : in  std_logic_vector(7 downto 0);
  RD_REQ        : in  std_logic;
  RD_ARDY       : out std_logic;

  RD_DATA       : out std_logic_vector(BUFFER_DATA_WIDTH-1 downto 0);
  RD_SRC_RDY    : out std_logic;
  RD_DST_RDY    : in  std_logic;

  -- Write interface (FrameLinks)
  RX_DATA       : in  std_logic_vector(BUFFER_DATA_WIDTH-1 downto 0);
  RX_SOP_N      : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  RX_EOP_N      : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  RX_SOF_N      : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  RX_EOF_N      : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  RX_REM        : in  std_logic_vector(
      (log2((BUFFER_DATA_WIDTH/BUFFER_FLOWS)/8)*BUFFER_FLOWS)-1 downto 0);
  RX_SRC_RDY_N  : in  std_logic_vector(BUFFER_FLOWS-1 downto 0);
  RX_DST_RDY_N  : out std_logic_vector(BUFFER_FLOWS-1 downto 0)
);
end entity rx_dma_ctrl_opt_buf_wrapper;

-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture full of rx_dma_ctrl_opt_buf_wrapper is

  -- interface between RX DMA controllers and RX buffer
  signal rx_buf_newlen      : std_logic_vector(BUFFER_FLOWS*16-1 downto 0);
  signal rx_buf_newlen_dv   : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal rx_buf_newlen_rdy  : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal rx_buf_rellen      : std_logic_vector(BUFFER_FLOWS*16-1 downto 0);
  signal rx_buf_rellen_dv   : std_logic_vector(BUFFER_FLOWS-1 downto 0);

  -- memory interface demultiplexer and or signals
  signal mi32_wr_demux_out  : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal mi32_rd_demux_out  : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal mi32_ardy_or_in    : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal mi32_drdy_or_in    : std_logic_vector(BUFFER_FLOWS-1 downto 0);
  signal mi32_drd_mux_in   : std_logic_vector(BUFFER_FLOWS*32-1 downto 0);
  signal mi32_drd_mux_out  : std_logic_vector(31 downto 0);

  -- internal bus write address and write request
  signal ib_addr            : std_logic_vector(31 downto 0);
  signal ib_rd_req          : std_logic;

  -- helpful signal: correct address on internal bus
  signal ib_correct_addr    : std_logic_vector(31 downto 0);
  signal interrupt_tmp      : std_logic_vector(2*BUFFER_FLOWS-1 downto 0);

begin

   -- InternalBus address
   ib_addr(19 downto 0)  <= RD_ADDR(19 downto 0);
   ib_addr(31 downto 20) <= (others => '0');

   -- the address that should be on the InternalBus to target the TX buffer
   ib_correct_addr <= conv_std_logic_vector(CTRL_BUFFER_ADDR, 32);

   -- multiplexer that switches internal bus write requests
   ib_rd_req <= RD_REQ when (RD_ADDR(31 downto 20) = ib_correct_addr(31 downto 20))
                else '0';

   SW_DRD <= mi32_drd_mux_out;


ONE_FLOW: if (BUFFER_FLOWS = 1) generate
   mi32_wr_demux_out(0) <= SW_WR;
   mi32_rd_demux_out(0) <= SW_RD;
   mi32_drd_mux_out <= mi32_drd_mux_in;
end generate;

MORE_FLOWS: if (BUFFER_FLOWS > 1) generate
   -- MI32 DRD multiplexer
   mi32_drd_muxp: process(SW_ADDR, mi32_drd_mux_in)
   begin
      mi32_drd_mux_out <= (others => '0');

      for i in 0 to BUFFER_FLOWS-1 loop
         if(conv_std_logic_vector(i, log2(BUFFER_FLOWS)) = SW_ADDR((5+log2(BUFFER_FLOWS)) downto 6)) then
            mi32_drd_mux_out <= mi32_drd_mux_in(32*(i+1)-1 downto 32*i);
         end if;
      end loop;
   end process;

   -- MI32 WR signal demultiplexer
   mi32_wr_demuxp: process(SW_ADDR, SW_WR)
   begin
      mi32_wr_demux_out <= (others => '0');

      for i in 0 to BUFFER_FLOWS-1 loop
         if(conv_std_logic_vector(i, log2(BUFFER_FLOWS)) = SW_ADDR((5+log2(BUFFER_FLOWS)) downto 6)) then
            mi32_wr_demux_out(i) <= SW_WR;
         end if;
      end loop;
   end process;

   -- MI32 RD signal demultiplexer
   mi32_rd_demuxp: process(SW_ADDR, SW_RD)
   begin
      mi32_rd_demux_out <= (others => '0');

      for i in 0 to BUFFER_FLOWS-1 loop
         if(conv_std_logic_vector(i, log2(BUFFER_FLOWS)) = SW_ADDR((5+log2(BUFFER_FLOWS)) downto 6)) then
            mi32_rd_demux_out(i) <= SW_RD;
         end if;
      end loop;
   end process;
end generate;

   -- MI32 ARDY signal OR
   mi32_ardy_orp: process(mi32_ardy_or_in)
   begin
      SW_ARDY <= '0';

      for i in 0 to BUFFER_FLOWS-1 loop
         if(mi32_ardy_or_in(i) = '1') then
            SW_ARDY <= '1';
         end if;
      end loop;
   end process;
   
   -- MI32 DRDY signal OR
   mi32_drdy_orp: process(mi32_drdy_or_in)
   begin
      SW_DRDY <= '0';

      for i in 0 to BUFFER_FLOWS-1 loop
         if(mi32_drdy_or_in(i) = '1') then
            SW_DRDY <= '1';
         end if;
      end loop;
   end process;

  -- generate RX controllers
  GEN_RX_DMA_CTRL_OPT : for i in 0 to BUFFER_FLOWS-1 generate

     INTERRUPT(i) <= interrupt_tmp(2*i+1) or interrupt_tmp(2*i);

    RX_DMA_CTRL_OPT_I : entity work.rx_dma_ctrl_opt
    generic map(
       BUFFER_ADDR       => CTRL_BUFFER_ADDR + conv_std_logic_vector(i * 16#2000#, 32),
       BUFFER_SIZE       => BUFFER_DATA_WIDTH*BUFFER_BLOCK_SIZE/8,
       DMA_DATA_WIDTH    => CTRL_DMA_DATA_WIDTH,
       DMA_TAG_ID        => conv_std_logic_vector(2*i, 8)
    )
    port map(
       -- Common interface
       CLK         => CLK,
       RESET       => RESET,
       INTERRUPT   => interrupt_tmp(2*i+1 downto 2*i),
    
       -- TX buffer interface
       BUF_NEWLEN     => rx_buf_newlen((i+1)*16-1 downto i*16),
       BUF_NEWLEN_DV  => rx_buf_newlen_dv(i),
       BUF_NEWLEN_RDY => rx_buf_newlen_rdy(i),
       BUF_RELLEN     => rx_buf_rellen((i+1)*16-1 downto i*16),
       BUF_RELLEN_DV  => rx_buf_rellen_dv(i),
       
       -- Descriptor FIFO interface
       DESC_READ   => DESC_READ(i),
       DESC_DO     => DESC_DO((i+1)*CTRL_DMA_DATA_WIDTH-1 downto
                              i*CTRL_DMA_DATA_WIDTH),
       DESC_EMPTY  => DESC_EMPTY(i),
       ENABLE      => DESC_ENABLE(i),

       -- Memory interface
       SW_DWR      => SW_DWR,
       SW_ADDR     => SW_ADDR(5 downto 0),
       SW_RD       => mi32_rd_demux_out(i),
       SW_WR       => mi32_wr_demux_out(i),
       SW_BE       => SW_BE(3 downto 0),
       SW_DRD      => mi32_drd_mux_in((i+1)*32-1 downto i*32),
       SW_ARDY     => mi32_ardy_or_in(i),
       SW_DRDY     => mi32_drdy_or_in(i),

       -- DMA Interface
       DMA_ADDR   => DMA_ADDR((i+1)*log2(128/CTRL_DMA_DATA_WIDTH)-1 downto
                              i*log2(128/CTRL_DMA_DATA_WIDTH)),
       DMA_DOUT   => DMA_DOUT((i+1)*CTRL_DMA_DATA_WIDTH-1 downto
                              i*CTRL_DMA_DATA_WIDTH),
       DMA_REQ    => DMA_REQ(i),
       DMA_ACK    => DMA_ACK(i),
       DMA_DONE   => DMA_DONE(i),
       DMA_TAG    => DMA_TAG((i+1)*16-1 downto i*16)
    );
  end generate;

  RX_BUFFER_I : entity work.sw_rxbuf_top
  generic map(
     DATA_WIDTH       => BUFFER_DATA_WIDTH,
     BLOCK_SIZE       => BUFFER_BLOCK_SIZE,
     FLOWS            => BUFFER_FLOWS,
     TOTAL_FLOW_SIZE  => BUFFER_TOTAL_FLOW_SIZE
  )
  port map(
     -- Common interface
     CLK              => CLK,
     RESET            => RESET,

     -- Write interface (InternalBus)
     RD_ADDR          => ib_addr,
     RD_BE            => RD_BE,
     RD_REQ           => ib_rd_req,
     RD_ARDY          => RD_ARDY,
     
     RD_DATA          => RD_DATA,
     RD_SRC_RDY       => RD_SRC_RDY,
     RD_DST_RDY       => RD_DST_RDY,

     -- RX controller interface
     RX_NEWLEN        => rx_buf_newlen,
     RX_NEWLEN_DV     => rx_buf_newlen_dv,
     RX_NEWLEN_RDY    => rx_buf_newlen_rdy,
     RX_RELLEN        => rx_buf_rellen,
     RX_RELLEN_DV     => rx_buf_rellen_dv,
    
     -- Read interface (FrameLinks)
     RX_DATA          => RX_DATA,
     RX_SOF_N         => RX_SOF_N,
     RX_SOP_N         => RX_SOP_N,
     RX_EOP_N         => RX_EOP_N,
     RX_EOF_N         => RX_EOF_N,
     RX_REM           => RX_REM,
     RX_SRC_RDY_N     => RX_SRC_RDY_N,
     RX_DST_RDY_N     => RX_DST_RDY_N
  );

end architecture full;
