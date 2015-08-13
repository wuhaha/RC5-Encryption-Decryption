library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.rc5_pkg.ALL;

entity outputProcessor is
port (
	clock : in std_logic;
	halfSel : in std_logic_vector(1 downto 0);
	input : in std_logic_vector (63 downto 0);
	currentValue : out std_logic_vector(0 to 6);
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic
	);
end outputProcessor;

architecture outputProcessor of outputProcessor is

	component digitConverter is
	port (
		digitIn : in std_logic_vector(0 to 3);
		digitOut : out std_logic_vector(0 to 6)
		);
	end component digitConverter;
	
	-- internal signals
	signal selectedDigit : std_logic_vector (0 to 3);
	signal currentHalf : std_logic_vector (15 downto 0);
	
begin

	converter: digitConverter port map (digitIn => selectedDigit, digitOut => currentValue);
	
	-- dot is always off (for now)
	dot <= '1';
	
	-- select requested 16-bit from 64-bit input
	process (halfSel, input)
	begin
			case halfSel is
				when "00" => currentHalf <= input (15 downto 0);
				when "01" => currentHalf <= input (31 downto 16);
				when "10" => currentHalf <= input (47 downto 32);
				when others => currentHalf <= input (63 downto 48);
			end case;
	end process;
	
	
	-- switch to next digit depending on constant rate
	process (clock)
		constant switchRate : integer := 100000;
		variable counter : integer := switchRate;
		variable nextDigit : integer := 0;
		
	begin		
		-- check for switch
		if (clock'event and clock = '1') then
			if (counter /= switchRate) then
				counter := counter + 1;
			
			else
				-- reset counter and switch digit
				counter := 0;
				
				if (nextDigit = 0) then
					-- light up digit 0
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '0'; -- enable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (3 downto 0);
				--end if;
							
				elsif (nextDigit = 1) then
					-- light up digit 1
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '0'; -- enable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (7 downto 4);
				--end if;
					
				elsif (nextDigit = 2) then
					-- light up digit 2
					digit3en <= '1'; -- disable digit 3 (MS digit)
					digit2en <= '0'; -- enable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (11 downto 8);
				--end if;
					
				else
					-- light up digit 3
					digit3en <= '0'; -- enable digit 3 (MS digit)
					digit2en <= '1'; -- disable digit 2
					digit1en <= '1'; -- disable digit 1
					digit0en <= '1'; -- disable digit 0 (LS digit)
					
					selectedDigit <= currentHalf (15 downto 12);
				end if;
				
				
				if (nextDigit = 3) then
					nextDigit := 0;
				else
					nextDigit := nextDigit + 1;
				end if;
				
			end if;
		end if;
		
	end process;

end outputProcessor;