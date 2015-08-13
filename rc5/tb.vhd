--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:53:03 12/09/2014
-- Design Name:   
-- Module Name:   C:/Users/me/Documents/EL6463/Hw/Hw7/tb.vhd
-- Project Name:  Hw7
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rc5
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.rc5_pkg.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rc5
    PORT(
         clock : IN  std_logic;
         clear : IN  std_logic;
         dir : IN  std_logic;
         halfSel : IN  std_logic_vector(1 downto 0);
         inputSel : IN  std_logic;
         din_vld_en : IN  std_logic;
         din_vld_de : IN  std_logic;
         dout_rdy_en : OUT  std_logic;
         dout_rdy_de : OUT  std_logic;
         key_vld : IN  std_logic;
         currentValue : OUT  std_logic_vector(0 to 6);
         digit3en : OUT  std_logic;
         digit2en : OUT  std_logic;
         digit1en : OUT  std_logic;
         digit0en : OUT  std_logic;
         dot : OUT  std_logic;
         dout : OUT  std_logic_vector(63 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal clear : std_logic := '0';
   signal dir : std_logic := '0';
   signal halfSel : std_logic_vector(1 downto 0) := (others => '0');
   signal inputSel : std_logic := '0';
   signal din_vld_en : std_logic := '0';
   signal din_vld_de : std_logic := '0';
   signal key_vld : std_logic := '0';

 	--Outputs
   signal dout_rdy_en : std_logic;
   signal dout_rdy_de : std_logic;
   signal currentValue : std_logic_vector(0 to 6);
   signal digit3en : std_logic;
   signal digit2en : std_logic;
   signal digit1en : std_logic;
   signal digit0en : std_logic;
   signal dot : std_logic;
   signal dout : std_logic_vector(63 downto 0);

   -- Clock period definitions
   constant clock_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rc5 PORT MAP (
          clock => clock,
          clear => clear,
          dir => dir,
          halfSel => halfSel,
          inputSel => inputSel,
          din_vld_en => din_vld_en,
          din_vld_de => din_vld_de,
          dout_rdy_en => dout_rdy_en,
          dout_rdy_de => dout_rdy_de,
          key_vld => key_vld,
          currentValue => currentValue,
          digit3en => digit3en,
          digit2en => digit2en,
          digit1en => digit1en,
          digit0en => digit0en,
          dot => dot,
          dout => dout
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      clear <= '0';
      wait for 100 ns;	
		clear <= '1';
		wait for clock_period*200;
	end process;


   readcmd: process

        -- This process loops through a file and reads one line
        -- at a time, parsing the line to get the values and
        -- expected result.

     file cmdfile: TEXT;       -- Define the file 'handle'
     variable L: Line;         -- Define the line buffer
     variable good: boolean; --status of the read operation

     variable CI, CO: std_logic;
     variable A,B: std_logic_vector(31 downto 0); 
     variable S: std_logic_vector(31 downto 0); 

    begin

        -- Open the command file...

     FILE_OPEN(cmdfile,"rc5_test.DAT",READ_MODE);

     loop

         if endfile(cmdfile) then  -- Check EOF
             assert false
                 report "End of file encountered; exiting."
                 severity NOTE;
             exit;
         end if;

         readline(cmdfile,L);           -- Read the line
         next when L'length = 0;  -- Skip empty lines
         read(L,CI,good);     -- Read the A argument as hex value
         assert good
             report "Text I/O read error"
             severity ERROR;


                     hread(L,A,good);     -- Read the A argument as hex value
         assert good
             report "Text I/O read error"
             severity ERROR;

         hread(L,B,good);     -- Read the B argument
         assert good
             report "Text I/O read error"
             severity ERROR;

         hread(L,S,good);     -- Read the Sum expected resulted
         assert good
             report "Text I/O read error"
             severity ERROR;

        read(L,CO,good);     -- Read the CO expected resulted
         assert good
             report "Text I/O read error"
             severity ERROR;

        cin <= CI;
         x <= A;
         y <= B;

        wait for clock_period;

         assert (sum = S)
             report "Check failed!"
                 severity ERROR;

         assert (cout = CO)
             report "Check failed!"
                 severity ERROR;
     end loop;

   wait;
end process;

END;
