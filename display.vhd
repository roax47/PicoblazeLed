----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:08:44 03/11/2019 
-- Design Name: 
-- Module Name:    led_mod - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		digit_i: in std_logic_vector(31 downto 0);
		led7_an_o: out std_logic_vector( 3 downto 0);
		led7_seg_o: out std_logic_vector( 7 downto 0)
		);
end display;

architecture Behavioral of display is

signal active: integer := 0;

begin

    with active select
    led7_an_o <= "0111" when 0,
                 "1011" when 1,
                 "1101" when 2,
                 "1110" when 3,
                 "1111" when others;

	with active select
	led7_seg_o <= digit_i(31 downto 24) when 0,
					 digit_i(23 downto 16) when 1,
						 digit_i(15 downto 8) when 2,
						 digit_i(7 downto 0) when 3,
						 "11111111" when others;
						 
    process(clk_i,rst_i) 	
	 begin
		  if(rst_i = '1') then
			  active<=4;
        elsif rising_edge(clk_i)  then		
					if(active = 3 or active = 4) then
						 active<= 0;
					else
						active <= active + 1;
					end if;
        end if;
    end process;
	 
end Behavioral;