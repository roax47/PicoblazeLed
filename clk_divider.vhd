----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:29:27 06/15/2010 
-- Design Name: 
-- Module Name:    clk_div - Behavioral 
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

entity clk_divider is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           clk_div : out  STD_LOGIC);
end clk_divider;

architecture Behavioral of clk_divider is
	signal clk_new : std_logic := '0';
	signal counter : integer := 0;
begin
	clk_div <= clk_new;
	
	process (clk_i, rst_i) is
	begin
		if rst_i = '1' then
			counter <= 0;
		elsif rising_edge(clk_i) then
			counter <= counter + 1;
			if counter = 25000 then --25000
				if clk_new = '1' then 
					clk_new <= '0';
				else 
					clk_new <= '1';
				end if;
				counter <= 0;
			end if;
		end if;
	end process;

end Behavioral;

