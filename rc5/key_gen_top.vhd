-- Description
-- SW7 select which half of the output to display.  0 shows 16MSB and 1 shows 16 LSB
-- SW6 and SW5 choose between 4 stored values for inputs
--  00 - X"01234567", 
--  01 - X"89ABCDEF",  
--	 10 - X"387210A3", 
--  11 - X"B2C9E018" 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

USE WORK.rc5_pkg.ALL;

entity rc5Top is
port (
	
	clk: in std_logic;
	clr:IN STD_LOGIC;
	halfSel: in std_logic;
	key_rdy_o:out std_logic;
	inputSel : in std_logic_vector(1 downto 0);
	vec_sel:in std_logic_vector(4 downto 0);
	key_vld:in std_logic;
	
	
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic;
	currentValue : out std_logic_vector(0 to 6)
	);
end rc5Top;

architecture rc5Top of rc5Top is

	-- components
	component source is
	port (
		sel : in std_logic_vector(1 downto 0);
		output : out std_logic_vector(127 downto 0) 
		);
	end component source;
	
	component rc5 is
	 port(	
	   key: 	in std_logic_vector(127 downto 0);
		key_vld: in std_logic;
		skey: 	out s_array;
		clr:	in std_logic;
		key_rdy_o:out std_logic;
		clk: 	in std_logic
		);

	end component rc5;
	
	
	component outputProcessor is
	port (
	clock: in std_logic;
	halfSel: in std_logic;
	vec_sel:in std_logic_vector(4 downto 0);
	input : in s_array;
	currentValue : out std_logic_vector(0 to 6);
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic
	);
	end component outputProcessor;
		
	
	
--	-- internal signals

	signal key_in:std_logic_vector(127 downto 0);
	signal skey_out:s_array;
	--signal key_out:work.rc5_pkg.ROM;

	
begin

	sourceOfData: 	source port map (sel => inputSel, output => key_in); 
	
   key_gen: rc5 port map(key=>key_in, key_vld=>key_vld,skey=>skey_out,clr=>clr,clk=>clk,key_rdy_o=>key_rdy_o);
	

	
	
	displayDriver:	outputProcessor port map (clock => clk, halfSel => halfSel,vec_sel=>vec_sel, input => skey_out,
										currentValue => currentValue, digit3en => digit3en,
										digit2en => digit2en, digit1en => digit1en,
										digit0en => digit0en, dot => dot);



					  
end rc5Top;
