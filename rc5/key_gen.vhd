--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--PACKAGE rc5_pkg IS
--type s_array is array (0 to 25) of std_logic_vector(31 downto 0);
--TYPE  L_ARRAY IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (31 DOWNTO 0);

--END rc5_pkg;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

USE WORK.rc5_pkg.ALL;


LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	WORK.RC5_PKG.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity key_gen is
	port(	
	   key: 	in std_logic_vector(127 downto 0);
		key_vld: in std_logic;
		skey: 	out s_array;
		clr:	in std_logic;
		key_rdy_o:out std_logic;
		clk: 	in std_logic
		);

end entity;

architecture key_gen of key_gen is


--signal sout:work.rc5_pkg.ROM;

signal r_cnt : std_logic_vector (6 downto 0);
signal i_cnt: std_logic_vector(4 downto 0);
signal j_cnt: std_logic_vector(1 downto 0);
SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); -- register A
SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0); -- register b
SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL temp: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_circ: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_circ: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal s:work.rc5_pkg.s_array;
signal l :work.rc5_pkg.L_ARRAY;
signal key_rdy:std_logic;
--signal skeyi:std_logic_vector(31 downto 0);
    

--TYPE s_array IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
--signal s : s_array; 
--
--TYPE  L_ARRAY IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
--signal l : l_array;


TYPE     StateType IS (ST_IDLE, ST_KEY_IN, ST_KEY_EXP, ST_READY);
SIGNAL	state : StateType;

begin
--A = S[i] = (S[i] + A + B) <<< 3;

a <= s(conv_integer(i_cnt)) + a_reg + b_reg;
a_circ <= a(28 downto 0) & a(31 downto 29);


--B = L[j] = (L[j] + A + B) <<< (A + B);
b <= l(conv_integer(j_cnt)) + a_circ + b_reg;
temp <= a_circ + b_reg;

with temp(4 downto 0) select
b_circ<=b(30 DOWNTO 0) & b(31) WHEN "00001",			--LEFT ROTATE BY 1
        b(29 DOWNTO 0) & b(31 DOWNTO 30) WHEN "00010",	--LEFT ROTATE BY 2
	b(28 DOWNTO 0) & b(31 DOWNTO 29) WHEN "00011",	--LEFT ROTATE BY 3
	b(27 DOWNTO 0) & b(31 DOWNTO 28) WHEN "00100",	--LEFT ROTATE BY 4
	b(26 DOWNTO 0) & b(31 DOWNTO 27) WHEN "00101",	--LEFT ROTATE BY 5
	b(25 DOWNTO 0) & b(31 DOWNTO 26) WHEN "00110",	--LEFT ROTATE BY 6
	b(24 DOWNTO 0) & b(31 DOWNTO 25) WHEN "00111",	--LEFT ROTATE BY 7
	b(23 DOWNTO 0) & b(31 DOWNTO 24) WHEN "01000",	--LEFT ROTATE BY 8
	b(22 DOWNTO 0) & b(31 DOWNTO 23) WHEN "01001",	--LEFT ROTATE BY 9
	b(21 DOWNTO 0) & b(31 DOWNTO 22) WHEN "01010",	--LEFT ROTATE BY 10
	b(20 DOWNTO 0) & b(31 DOWNTO 21) WHEN "01011",	--LEFT ROTATE BY 11
	b(19 DOWNTO 0) & b(31 DOWNTO 20) WHEN "01100",	--LEFT ROTATE BY 12
	b(18 DOWNTO 0) & b(31 DOWNTO 19) WHEN "01101",	--LEFT ROTATE BY 13
	b(17 DOWNTO 0) & b(31 DOWNTO 18) WHEN "01110",	--LEFT ROTATE BY 14
	b(16 DOWNTO 0) & b(31 DOWNTO 17) WHEN "01111",	--LEFT ROTATE BY 15
	b(15 DOWNTO 0) & b(31 DOWNTO 16) WHEN "10000",	--LEFT ROTATE BY 16
	b(14 DOWNTO 0) & b(31 DOWNTO 15) WHEN "10001",	--LEFT ROTATE BY 17
	b(13 DOWNTO 0) & b(31 DOWNTO 14) WHEN "10010",	--LEFT ROTATE BY 18
	b(12 DOWNTO 0) & b(31 DOWNTO 13) WHEN "10011",	--LEFT ROTATE BY 19
	b(11 DOWNTO 0) & b(31 DOWNTO 12) WHEN "10100",	--LEFT ROTATE BY 20
	b(10 DOWNTO 0) & b(31 DOWNTO 11) WHEN "10101",	--LEFT ROTATE BY 21
	b(9 DOWNTO 0) & b(31 DOWNTO 10) WHEN "10110",	        --LEFT ROTATE BY 22
	b(8 DOWNTO 0) & b(31 DOWNTO 9) WHEN "10111",          --LEFT ROTATE BY 23
	b(7 DOWNTO 0) & b(31 DOWNTO 8) WHEN "11000",  	--LEFT ROTATE BY 24
	b(6 DOWNTO 0) & b(31 DOWNTO 7) WHEN "11001",  	--LEFT ROTATE BY 25
	b(5 DOWNTO 0) & b(31 DOWNTO 6) WHEN "11010",  	--LEFT ROTATE BY 26
	b(4 DOWNTO 0) & b(31 DOWNTO 5) WHEN "11011",  	--LEFT ROTATE BY 27
	b(3 DOWNTO 0) & b(31 DOWNTO 4) WHEN "11100",  	--LEFT ROTATE BY 28
	b(2 DOWNTO 0) & b(31 DOWNTO 3) WHEN "11101",  	--LEFT ROTATE BY 29
	b(1 DOWNTO 0) & b(31 DOWNTO 2) WHEN "11110",	        --LEFT ROTATE BY 30
	b(0) & b(31 DOWNTO 1) WHEN "11111",	 	      	--LEFT ROTATE BY 31
	b WHEN OTHERS;	
	
	

---state
PROCESS(clr, clk)	  
     BEGIN
       IF(clr='0') THEN
           state<=ST_IDLE;
       ELSIF(clk'EVENT AND clk='1') THEN
           CASE state IS
              WHEN ST_IDLE=>
                  	IF(key_vld='1') THEN  state<=ST_KEY_IN;   END IF;
              WHEN ST_KEY_IN=> 
		state<=ST_KEY_EXP;  
              WHEN ST_KEY_EXP=> 
		IF(r_cnt="1001101") THEN   state<=ST_READY;  END IF;
					when st_ready=>state<=st_ready;
          END CASE;
        END IF;
  END PROCESS;            



--a_reg
process(clr, clk,state)
begin
	if(clr = '0' or state=ST_KEY_IN) then
		a_reg <= (others => '0');
	elsif (clk'event and clk ='1') then
		if (state = st_key_exp) then
			a_reg <= a_circ;
		end if;
	end if;
end process;
--b_reg
process(clr, clk,state)
begin
	if(clr = '0' or state=ST_KEY_IN) then
		b_reg <= (others => '0');
	elsif (clk'event and clk ='1') then
		if (state = st_key_exp) then
			b_reg <= b_circ;
		end if;
	end if;
end process;

--counters
--i_cnt
PROCESS(clr, clk,state)
 BEGIN
    IF(clr = '0' or state=ST_KEY_IN) THEN  i_cnt<="00000";
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=ST_KEY_EXP) THEN
         IF(i_cnt="11001") THEN   i_cnt<="00000";
         ELSE   i_cnt<=i_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
--j_cnt
PROCESS(clr, clk)
 BEGIN
    IF(clr = '0' or state=ST_KEY_IN) THEN  j_cnt<="00";
    ELSIF(clk'EVENT AND clk='1') THEN
       IF(state=st_key_exp) THEN
         IF(j_cnt="11") THEN   j_cnt<="00";
         ELSE   j_cnt<=j_cnt+1;
         END IF;
       END IF;
    END IF;
 END PROCESS;
 ---r_cnt
  process (clr,clk,state)  --counter
     begin
         if(clr = '0' or state=ST_KEY_IN) then r_cnt<="0000000";
         elsif(clk'EVENT AND clk='1') THEN
             IF(state=ST_KEY_EXP)THEN
                 IF(r_cnt="1001101") then r_cnt<="0000000";
                 ELSE r_cnt<=r_cnt+1;
             end if;
         end if;
     end if;
 end process;  
 
 --array s
process(clr, clk,state)
begin
	if (clr = '0' or state=ST_KEY_IN) then
		s(0) <= X"b7e15163"; s(1) <= X"5618cb1c";s(2) <= X"f45044d5";
		s(3) <= X"9287be8e";s(4) <= X"30bf3847";s(5) <= X"cef6b200";
		s(6) <= X"6d2e2bb9";s(7) <= X"0b65a572";s(8) <= X"a99d1f2b";
		s(9) <= X"47d498e4";s(10) <= X"e60c129d";s(11) <= X"84438c56";
		s(12) <= X"227b060f";s(13) <= X"c0b27fc8";s(14) <= X"5ee9f981";
		s(15) <= X"fd21733a";s(16) <= X"9b58ecf3";s(17) <= X"399066ac";
		s(18) <= X"d7c7e065";s(19) <= X"75ff5a1e";s(20) <= X"1436d3d7";
		s(21) <= X"b26e4d90";s(22) <= X"50a5c749";s(23) <= X"eedd4102";
		s(24) <= X"8d14babb";s(25) <= X"2b4c3474";
	elsif (clk'event and clk = '1') then
		if (state = st_key_exp) then
			 s(conv_integer(i_cnt)) <= a_circ;

		end if;
	end if;
end process;



--l array
process(clr, clk)
begin
    if(clr = '0') then
	   l(0) <= (others=>'0');
	   l(1) <= (others=>'0');
	   l(2) <= (others=>'0');
	   l(3) <= (others=>'0');
	elsif (clk'event and clk = '1') then
		if(state = ST_KEY_IN) then
			l(0) <= key(31 downto 0);
			l(1) <= key(63 downto 32);
			l(2) <= key(95 downto 64);
			l(3) <= key(127 downto 96);
		elsif(state = st_key_exp) then
			l(conv_integer(j_cnt)) <= b_circ;

		end if;
	end if;
end process;

key_rdy_o<=key_rdy;


with state select
key_rdy<= '1' when ST_READY,
			 '0' when others;
			
			
process(state)
begin
if(state=st_ready) then
skey <= s;
end if;
end process;


end key_gen;


