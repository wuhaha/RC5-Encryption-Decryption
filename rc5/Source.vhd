library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.rc5_pkg.ALL;

entity source is
port (
   clr : IN STD_LOGIC; -- Asynchronous reset
   clk : IN STD_LOGIC; -- Clock signal

	sel : in std_logic;
	output : out std_logic_vector(127 downto 0)
	);
end source;

architecture source of source is

	
	type ROM is array (0 to 1) of std_logic_vector(127 downto 0);
	
	
	constant testData : ROM := ROM '(
	X"11765029117650291176502911765029", X"00000000000000000000000000000000"
	);

begin

	
	PROCESS(clr, clk)
BEGIN
   IF(clr='0') THEN output <=testData(1) ;
   ELSIF(clk'EVENT AND clk='1') THEN
       case sel is
			when '0' => output <= testData(0);
			when '1' => output <= testData(1);
			when others => output <= testData(0);
		end case;   
    END IF;
END PROCESS;
	
end source;
