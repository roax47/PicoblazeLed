----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:11:38 06/15/2019 
-- Design Name: 
-- Module Name:    PicoLed - Behavioral 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PicoLed is
    Port ( clk_i : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           led7_an_o : out  STD_LOGIC_VECTOR (3 downto 0);
           led7_seg_o : out  STD_LOGIC_VECTOR (7 downto 0);
           button_i : in  STD_LOGIC_VECTOR (3 downto 0));
end PicoLed;

architecture Behavioral of PicoLed is

		
	component kcpsm3 is
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;

	 component rom is
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
	 
	 component display is
    Port ( 			clk_i : in  STD_LOGIC;
						rst_i : in  STD_LOGIC;
					 digit_i : in  STD_LOGIC_VECTOR (31 downto 0);
				  led7_an_o : out  STD_LOGIC_VECTOR (3 downto 0);
				 led7_seg_o : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	
	component clk_divider is
    Port ( 			clk_i : in  STD_LOGIC;
						rst_i : in  STD_LOGIC;
					 clk_div : out  STD_LOGIC);
	end component;

	
	signal clk_div : std_logic;
	
	
	signal instruction_x : std_logic_vector(17 downto 0);
	signal address_x : std_logic_vector(9 downto 0);
	signal port_id : std_logic_vector (7 downto 0);
	signal pico_output : std_logic_vector(7 downto 0);
	signal pico_input : std_logic_vector(7 downto 0);
	signal write_strobe : std_logic;
	signal read_strobe : std_logic;
	signal interrupt : std_logic := '0';
	signal interrupt_ack : std_logic;
	signal input : std_logic_vector (7 downto 0);
	signal rst_pico : std_logic := '0';
	shared variable btn_pressed : std_logic := '0';
	shared variable dig_index : Integer := 0;
	type state is (edit, browsing);
	signal logic_state : state := edit;
	type Digits is array (0 to 15) of std_logic_vector(6 downto 0);
	signal dig : Digits:=	
			(	"0000001",
				"1001111",
				"0010010",
				"0000110",
				"1001100",
				"0100100",
				"0100000",
				"0001111",
				"0000000",
				"0000100",
				"0001000",
				"1100000",
				"0110001",
				"1000010",
				"0110000",
				"0111000"
			);
	signal digit : std_logic_vector (31 downto 0):="00000011000000110000001100000011";
	signal digit_2 : std_logic_vector (31 downto 0):="00000011000000110000001100000011";
	signal button_counter : Integer := 0;
	signal btn_selected : Integer := 0;
	signal pico_out_tmp: std_logic_vector(6 downto 0) := "0000001";
	shared variable pico_out_tmp_tmp: std_logic_vector(6 downto 0) := "0000001";
	shared variable index_tmp : Integer := 1;
	signal counter_disp: Integer := 0;
	constant N: Integer := 500;
	shared variable shifted : std_logic := '0';
	shared variable btn_3_cntr : Integer := 0;
	signal im_shiftin : std_logic := '0';
begin


	Divider: clk_divider port map (clk_i, rst_i, clk_div);	
	PicoBlaze: kcpsm3 port map (address_x, instruction_x, port_id, write_strobe, pico_output, read_strobe,
					pico_input, interrupt, interrupt_ack, rst_pico, clk_div);
	Memory: rom port map (address_x, instruction_x, clk_div);	
	Disp: display port map (clk_div, rst_i, digit, led7_an_o, led7_seg_o); 
	
	process (clk_div, rst_i) is
		variable vibration: Integer:=300;	
	begin
	
		if rst_i = '1' then		
			pico_input <= X"00"; 
			rst_pico <= '1';
			digit(31 downto 25) <= dig(0);
			digit(23 downto 17) <= dig(0);
			digit(15 downto 9) <= dig(0);
			digit(7 downto 1) <= dig(0);
		
		elsif rising_edge(clk_div) then

			if button_i(0) = '1' or button_i(1) = '1' or button_i(2) = '1' or button_i(3) = '1' then
				btn_pressed := '1';
				 case button_i is
					when "1000" => btn_selected <= 4;
					when "0100" => btn_selected <= 3;
					when "0010" => btn_selected <= 2;
					when "0001" => btn_selected <= 1;
					when others => btn_selected <= 0;
			  end case;
			else
				btn_pressed := '0';
				
			end if;
			

			
			if button_counter < vibration then
				button_counter <= button_counter + 1;
			end if;

			if button_i(2) = '1' and btn_3_cntr < vibration*4 then
				btn_3_cntr := btn_3_cntr + 1;
			elsif button_i(2) = '0' then
				btn_3_cntr := 0;
			end if;
			
			rst_pico <= '0';

			if logic_state = browsing then
			--mozemy tylko wejsc w stan edycji
				if btn_3_cntr >= vibration*4 then
					logic_state <= edit;
					btn_3_cntr := 0;
				end if;
				
			end if;


			if logic_state = edit then
				if btn_3_cntr >= vibration*4 then
					logic_state <= browsing;
					btn_3_cntr := 0;
				end if;
			
				if interrupt = '1' and interrupt_ack = '1' then
					interrupt <= '0';
				end if;
				if button_counter = vibration then
					if button_i(0) = '1'  then
						input <= X"01";
						interrupt <= '1';
						button_counter <= 0;
					elsif button_i(1) = '1'  then
						input <= X"02";
						interrupt <= '1';
						button_counter <= 0;
					elsif button_i(2) = '1'  then
						--if button_counter < vibration * 5 then
	--						digit(8*(dig_index+1)-1 downto 8*(dig_index)+1) <= pico_out_tmp;
							input <= X"03";
							dig_index := dig_index - 1;
							if dig_index = -1 then
								dig_index := 3;
							end if;
							interrupt <= '1';
							button_counter <= 0;
--							pico_out_tmp <= digit(8*(dig_index+1)-1 downto 8*(dig_index)+1);
							im_shiftin <= '1';
						--else
						--	logic_state <= browsing;
						--	button_counter <= 0;
						--end if;
						
					elsif button_i(3) = '1' then
						input <= X"04";
						--digit(7 downto 1) <= dig(dig_index);
--						digit(8*(dig_index+1)-1 downto 8*(dig_index)+1) <= pico_out_tmp;
						dig_index := dig_index + 1;
						if dig_index = 4 then
							dig_index := 0;
						end if;
						button_counter <= 0;
						interrupt <= '1';
--						pico_out_tmp <= digit(8*(dig_index+1)-1 downto 8*(dig_index)+1);
						im_shiftin <= '1';
					end if;
					
				end if;
			end if;
			
					
			if write_strobe = '1' then
				if port_id = "00001011" then  --B
					--digit(8*(dig_index+1)-1 downto 8*(dig_index)+1) <= dig(conv_integer(pico_output));
					digit_2(8*(dig_index+1)-1 downto 8*(dig_index)+1) <= dig(conv_integer(pico_output));
				end if;
			end if;

			if logic_state = edit then
				if counter_disp < N/2 then
					digit <= digit_2;
				else
					digit(8*(dig_index+1)-1 downto 8*(dig_index)+1) <= "1111111";
				end if;
--				if im_shiftin = '1' then
--					digit(8*(index_tmp+1)-1 downto 8*(index_tmp)+1) <= pico_out_tmp_tmp;
--					im_shiftin <= '0';
--				end if;
					
				
			else
				digit <= digit_2;
			end if;
		
			if port_id = "00001010" then --A
				pico_input <= input;
			end if;
		
			if(counter_disp < N) then
				counter_disp <= counter_disp + 1;
			else
				counter_disp <= 0;				
			end if;
		
		end if;
	
	end process;


end Behavioral;



