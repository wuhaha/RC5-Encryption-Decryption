library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity digitConverter is
port (
	digitIn : in std_logic_vector(0 to 3);
	digitOut : out std_logic_vector(0 to 6)
	);
end digitConverter;

architecture digitConverter of digitConverter is

	
	type ROM is array (0 to 15) of std_logic_vector (0 to 6);
	
	
	constant conversionTable : ROM := ROM '(
	"0000001",	-- 0
	"1001111",	-- 1
	"0010010",	-- 2
	"0000110",	-- 3
	"1001100",	-- 4
	"0100100",	-- 5
	"0100000",	-- 6
	"0001111",	-- 7
	"0000000",	-- 8
	"0000100",	-- 9
	"0001000",	-- A
	"1100000",	-- B
	"0110001",	-- C
	"1000010",	-- D
	"0110000",	-- E
	"0111000"	-- F
	);

begin	
	process (digitIn)
				
	begin
		digitOut <= conversionTable(conv_integer(digitIn));
	end process;

end digitConverter;
