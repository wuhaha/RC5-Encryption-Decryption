library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.rc5_pkg.ALL;

entity rc5 is
port (
	clock : in std_logic;
	clear : in std_logic;
	
	dir : in std_logic;
	halfSel : in std_logic_vector(1 downto 0);
	inputSel : in std_logic;
	
	din_vld_en : in std_logic;
	din_vld_de : in std_logic;
	
	dout_rdy_en : out std_logic;
	dout_rdy_de : out std_logic;
	key_vld : in std_logic;
	
	currentValue : out std_logic_vector(0 to 6);
	digit3en, digit2en, digit1en, digit0en, dot : out std_logic;
	
	dout : out std_logic_vector(63 downto 0)
	);
end rc5;

architecture rc5 of rc5 is

	-- components
	component source is
	port (
	   clr	: IN	STD_LOGIC;
	   clk	: IN	STD_LOGIC;
	
		sel : in std_logic;
		output : out std_logic_vector(127 downto 0)
		);
	end component source;
	
   component encryption is
   port (  clr	: IN	STD_LOGIC;
	       clk	: IN	STD_LOGIC;
			 
	       din	: IN	STD_LOGIC_VECTOR(63 DOWNTO 0);
	       di_vld	: IN	STD_LOGIC;  -- input is valid
			 
	       dout	: OUT	STD_LOGIC_VECTOR(63 DOWNTO 0);
	       do_rdy	: OUT	STD_LOGIC;   -- output is ready
			 
			 skey : in s_array
		 );
   end component encryption;
   
   component decryption is
   port (  clr : IN STD_LOGIC; -- Asynchronous reset
           clk : IN STD_LOGIC; -- Clock signal
			  
           din : IN STD_LOGIC_VECTOR(63 DOWNTO 0); -- 64-bit input
           di_vld	: IN	STD_LOGIC;  -- input is valid
			  
           dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0); -- 64-bit output
           do_rdy	: OUT	STD_LOGIC;   -- output is ready
			  
			  skey : in s_array
		 );
   end component decryption;	
	
	component outputProcessor is
	port (
		clock : in std_logic;
	    halfSel : in std_logic_vector(1 downto 0);
		input : in std_logic_vector (63 downto 0);
		currentValue : out std_logic_vector(0 to 6);
		digit3en, digit2en, digit1en, digit0en, dot : out std_logic
		);
	end component outputProcessor;
	
	component key_gen is
	
	port(	
	   key: 	in std_logic_vector(127 downto 0);
		key_vld: in std_logic;
		skey: 	out s_array;
		clr:	in std_logic;
		key_rdy_o:out std_logic;
		clk: 	in std_logic
		);
	
	end component key_gen;
		
	
	
	-- internal signals
   	signal dinValue : std_logic_vector(63 downto 0);
	signal en_op, de_op : std_logic_vector(63 downto 0);
	signal doutValue : std_logic_vector(63 downto 0);
	signal skey : s_array;
	--signal din_vld_en : std_logic;
	--signal din_vld_de : std_logic;
	signal en_vld : std_logic;
	signal de_vld : std_logic;
	signal key_rdy_o : std_logic;
	signal key : std_logic_vector(127 downto 0);
	
	
begin

dinValue <=x"1176502912345678";

PROCESS(clock)
BEGIN
   IF(clock'EVENT AND clock='1') THEN
         en_vld <=din_vld_en and key_rdy_o;
         de_vld <=din_vld_de and key_rdy_o;   
    END IF;
END PROCESS;



    sourceOfData: 	source port map (clr => clear, clk=>clock,sel => inputSel, output => key);
	
	en:	encryption port map (clr => clear, clk=>clock,din=>dinValue,
									 di_vld=>en_vld, dout=>en_op, do_rdy=>dout_rdy_en,skey => skey);
   
    de:	decryption port map (clr=>clear, clk=>clock,  din=>en_op, 
										    di_vld=>de_vld, dout=>de_op, do_rdy=>dout_rdy_de,skey=>skey); 
    key_generation: key_gen port map(key=>key,key_vld=>key_vld,skey => skey,clr=>clear,key_rdy_o=>key_rdy_o,clk=>clock);											 
                              
	
	displayDriver:	outputProcessor port map (clock => clock, halfSel => halfSel, input => doutValue,
										currentValue => currentValue, digit3en => digit3en,
										digit2en => digit2en, digit1en => digit1en,
										digit0en => digit0en, dot => dot);

   with dir select
      doutValue <=  en_op when '0',
                    de_op when others;
	
	dout <=doutValue;
end rc5;
