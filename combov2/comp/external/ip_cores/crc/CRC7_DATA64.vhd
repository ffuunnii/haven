
-- ########################################################################
-- CRC Engine RTL Design 
-- Copyright (C) www.ElectronicDesignworks.com 
-- Source code generated by ElectronicDesignworks IP Generator (CRC).
-- Documentation can be downloaded from www.ElectronicDesignworks.com 
-- ******************************** 
--            License     
-- ******************************** 
-- This source file may be used and distributed freely provided that this
-- copyright notice, list of conditions and the following disclaimer is
-- not removed from the file.                    
-- Any derivative work should contain this copyright notice and associated disclaimer.                    
-- This source code file is provided "AS IS" AND WITHOUT ANY WARRANTY, 
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
-- PARTICULAR PURPOSE.
-- ********************************
--           Specification 
-- ********************************
-- File Name       : CRC7_DATA64.vhd    
-- Description     : CRC Engine ENTITY 
-- Clock           : Positive Edge 
-- Reset           : Active High
-- First Serial    : MSB 
-- Data Bus Width  : 64 bits 
-- Polynomial      : (0 3 7)                   
-- Date            : 15-Jul-2010  
-- Version         : 1.0        
-- ########################################################################
                    
LIBRARY IEEE ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY crc_gen7_64 IS 
   PORT(           
           clock      : IN  STD_LOGIC; 
           reset      : IN  STD_LOGIC; 
           soc        : IN  STD_LOGIC; 
           data       : IN  STD_LOGIC_VECTOR(63 DOWNTO 0); 
           data_valid : IN  STD_LOGIC; 
           eoc        : IN  STD_LOGIC; 
           crc        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
           crc_valid  : OUT STD_LOGIC 
       );
END crc_gen7_64; 

ARCHITECTURE behave OF crc_gen7_64 IS 

 SIGNAL crc_r          : STD_LOGIC_VECTOR(6 DOWNTO 0);
 SIGNAL crc_c          : STD_LOGIC_VECTOR(6 DOWNTO 0);
 SIGNAL crc_i          : STD_LOGIC_VECTOR(6 DOWNTO 0);
 SIGNAL crc_const      : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";

BEGIN 

	      
crc_i    <= crc_const when soc = '1' else
            crc_r;

crc_c(0) <= data(0) XOR data(4) XOR data(7) XOR data(14) XOR data(21) XOR data(44) XOR data(37) XOR data(62) XOR crc_i(5) XOR data(49) XOR data(30) XOR data(15) XOR data(55) XOR data(60) XOR crc_i(3) XOR data(42) XOR data(23) XOR data(50) XOR data(31) XOR data(8) XOR data(18) XOR data(48) XOR data(53) XOR data(34) XOR data(35) XOR data(12) XOR data(52) XOR data(39) XOR data(16) XOR data(43) XOR data(20) XOR data(47) XOR data(24); 
crc_c(1) <= data(1) XOR data(5) XOR data(8) XOR data(15) XOR data(22) XOR data(45) XOR data(38) XOR data(63) XOR crc_i(6) XOR data(50) XOR data(31) XOR data(16) XOR data(56) XOR data(61) XOR crc_i(4) XOR data(43) XOR data(24) XOR data(51) XOR data(32) XOR data(9) XOR data(19) XOR data(49) XOR data(54) XOR data(35) XOR data(36) XOR data(13) XOR data(53) XOR data(40) XOR data(17) XOR data(44) XOR data(21) XOR data(48) XOR data(25); 
crc_c(2) <= data(2) XOR data(6) XOR data(9) XOR data(16) XOR data(23) XOR data(46) XOR data(39) XOR data(51) XOR data(32) XOR data(17) XOR data(57) XOR crc_i(0) XOR data(62) XOR crc_i(5) XOR data(44) XOR data(25) XOR data(52) XOR data(33) XOR data(10) XOR data(20) XOR data(50) XOR data(55) XOR data(36) XOR data(37) XOR data(14) XOR data(54) XOR data(41) XOR data(18) XOR data(45) XOR data(22) XOR data(49) XOR data(26); 
crc_c(3) <= data(0) XOR data(3) XOR data(10) XOR data(17) XOR data(40) XOR data(33) XOR data(58) XOR crc_i(1) XOR data(63) XOR crc_i(6) XOR data(45) XOR data(26) XOR data(11) XOR data(51) XOR data(56) XOR data(38) XOR data(19) XOR data(46) XOR data(27) XOR data(4) XOR data(14) XOR data(44) XOR data(62) XOR crc_i(5) XOR data(49) XOR data(30) XOR data(60) XOR crc_i(3) XOR data(31) XOR data(8) XOR data(48) XOR data(35) XOR data(12) XOR data(39) XOR data(16) XOR data(43) XOR data(20); 
crc_c(4) <= data(1) XOR data(4) XOR data(11) XOR data(18) XOR data(41) XOR data(34) XOR data(59) XOR crc_i(2) XOR data(46) XOR data(27) XOR data(12) XOR data(52) XOR data(57) XOR crc_i(0) XOR data(39) XOR data(20) XOR data(47) XOR data(28) XOR data(5) XOR data(15) XOR data(45) XOR data(63) XOR crc_i(6) XOR data(50) XOR data(31) XOR data(61) XOR crc_i(4) XOR data(32) XOR data(9) XOR data(49) XOR data(36) XOR data(13) XOR data(40) XOR data(17) XOR data(44) XOR data(21); 
crc_c(5) <= data(2) XOR data(5) XOR data(12) XOR data(19) XOR data(42) XOR data(35) XOR data(60) XOR crc_i(3) XOR data(47) XOR data(28) XOR data(13) XOR data(53) XOR data(58) XOR crc_i(1) XOR data(40) XOR data(21) XOR data(48) XOR data(29) XOR data(6) XOR data(16) XOR data(46) XOR data(51) XOR data(32) XOR data(62) XOR crc_i(5) XOR data(33) XOR data(10) XOR data(50) XOR data(37) XOR data(14) XOR data(41) XOR data(18) XOR data(45) XOR data(22); 
crc_c(6) <= data(3) XOR data(6) XOR data(13) XOR data(20) XOR data(43) XOR data(36) XOR data(61) XOR crc_i(4) XOR data(48) XOR data(29) XOR data(14) XOR data(54) XOR data(59) XOR crc_i(2) XOR data(41) XOR data(22) XOR data(49) XOR data(30) XOR data(7) XOR data(17) XOR data(47) XOR data(52) XOR data(33) XOR data(63) XOR crc_i(6) XOR data(34) XOR data(11) XOR data(51) XOR data(38) XOR data(15) XOR data(42) XOR data(19) XOR data(46) XOR data(23); 


crc_gen_process : PROCESS(clock, reset) 
BEGIN                                    
 IF(reset = '1') THEN  
    crc_r <= "0000000" ;
 ELSIF( clock 'EVENT AND clock = '1') THEN 
    IF(data_valid = '1') THEN 
         crc_r <= crc_c; 
    END IF; 
 END IF;    
END PROCESS crc_gen_process;      
    

crc_valid_gen : PROCESS(clock, reset) 
BEGIN                                    
 If(reset = '1') THEN 
     crc_valid <= '0'; 
 ELSIF( clock 'EVENT AND clock = '1') THEN 
    IF(data_valid = '1' AND eoc = '1') THEN 
        crc_valid <= '1'; 
    ELSE 
        crc_valid <= '0'; 
    END IF; 
 END IF;    
END PROCESS crc_valid_gen; 

crc <= crc_r;

END behave;
                      





 


