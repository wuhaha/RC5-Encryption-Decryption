LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- we will use CONV_INTEGER
USE WORK.rc5_pkg.ALL;

ENTITY decryption IS
PORT
(
clr : IN STD_LOGIC; -- Asynchronous reset
clk : IN STD_LOGIC; -- Clock signal

din : IN STD_LOGIC_VECTOR(63 DOWNTO 0); -- 64-bit input
di_vld	: IN	STD_LOGIC;  -- input is valid

dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0); -- 64-bit output
do_rdy	: OUT	STD_LOGIC;   -- output is ready

skey : in s_array
);
END decryption;

ARCHITECTURE decryption OF decryption IS
SIGNAL i_cnt : STD_LOGIC_VECTOR(3 DOWNTO 0); -- round counter
SIGNAL a_rot : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ab_xor : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_pre	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL a_reg : STD_LOGIC_VECTOR(31 DOWNTO 0); -- register A
SIGNAL b_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ba_xor : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_pre	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL b_reg : STD_LOGIC_VECTOR(31 DOWNTO 0); -- register B

-- define a type for round keys

TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
--CONSTANT skey : rom:=rom'(X"9BBBD8C8", X"1A37F7FB", X"46F8E8C5",
  --    X"460C6085", X"70F83B8A", X"284B8303", X"513E1454", X"F621ED22",
    --  X"3125065D", X"11A83A5D", X"D427686B", X"713AD82D", X"4B792F99",
      --X"2799A4DD", X"A7901C49", X"DEDE871A", X"36C03196", X"A7EFC249",
      --X"61A78BB8", X"3B0A1D2B", X"4DBFCA76", X"AE162167", X"30D76B0A",
      --X"43192304", X"F6CC1431", X"65046380");
	  
TYPE  StateType IS (ST_IDLE,      --do nothing
                    ST_PRE_ROUND, -- pre-round op is performed 
                    ST_ROUND_OP,  -- round op is performed
				                  --remains in this state for 12 clock cycles
                    ST_READY      -- valid result; for one clock cycle 
                             );
SIGNAL  state   :   StateType;

BEGIN
 

b_rot <= b_reg - skey(CONV_INTEGER(i_cnt & '1'));
WITH a_reg(4 DOWNTO 0) SELECT
ba_xor<= b_rot(0) & b_rot(31 DOWNTO 1) WHEN "00001",
        b_rot(1 DOWNTO 0) & b_rot(31 DOWNTO 2) WHEN "00010",
        b_rot(2 DOWNTO 0) & b_rot(31 DOWNTO 3) WHEN "00011",
        b_rot(3 DOWNTO 0) & b_rot(31 DOWNTO 4) WHEN "00100",
        b_rot(4 DOWNTO 0) & b_rot(31 DOWNTO 5) WHEN "00101",
        b_rot(5 DOWNTO 0) & b_rot(31 DOWNTO 6) WHEN "00110",
        b_rot(6 DOWNTO 0) & b_rot(31 DOWNTO 7) WHEN "00111",
        b_rot(7 DOWNTO 0) & b_rot(31 DOWNTO 8) WHEN "01000",
        b_rot(8 DOWNTO 0) & b_rot(31 DOWNTO 9) WHEN "01001",
        b_rot(9 DOWNTO 0) & b_rot(31 DOWNTO 10) WHEN "01010",
        b_rot(10 DOWNTO 0) & b_rot(31 DOWNTO 11) WHEN "01011",
        b_rot(11 DOWNTO 0) & b_rot(31 DOWNTO 12) WHEN "01100",
        b_rot(12 DOWNTO 0) & b_rot(31 DOWNTO 13) WHEN "01101",
        b_rot(13 DOWNTO 0) & b_rot(31 DOWNTO 14) WHEN "01110",
        b_rot(14 DOWNTO 0) & b_rot(31 DOWNTO 15) WHEN "01111",
        b_rot(15 DOWNTO 0) & b_rot(31 DOWNTO 16) WHEN "10000",
        b_rot(16 DOWNTO 0) & b_rot(31 DOWNTO 17) WHEN "10001",
        b_rot(17 DOWNTO 0) & b_rot(31 DOWNTO 18) WHEN "10010",
        b_rot(18 DOWNTO 0) & b_rot(31 DOWNTO 19) WHEN "10011",
        b_rot(19 DOWNTO 0) & b_rot(31 DOWNTO 20) WHEN "10100",
        b_rot(20 DOWNTO 0) & b_rot(31 DOWNTO 21) WHEN "10101",
        b_rot(21 DOWNTO 0) & b_rot(31 DOWNTO 22) WHEN "10110",
        b_rot(22 DOWNTO 0) & b_rot(31 DOWNTO 23) WHEN "10111",
        b_rot(23 DOWNTO 0) & b_rot(31 DOWNTO 24) WHEN "11000",
        b_rot(24 DOWNTO 0) & b_rot(31 DOWNTO 25) WHEN "11001",
        b_rot(25 DOWNTO 0) & b_rot(31 DOWNTO 26) WHEN "11010",
        b_rot(26 DOWNTO 0) & b_rot(31 DOWNTO 27) WHEN "11011",
        b_rot(27 DOWNTO 0) & b_rot(31 DOWNTO 28) WHEN "11100",
        b_rot(28 DOWNTO 0) & b_rot(31 DOWNTO 29) WHEN "11101",
        b_rot(29 DOWNTO 0) & b_rot(31 DOWNTO 30) WHEN "11110",
        b_rot(30 DOWNTO 0) & b_rot(31) WHEN "11111",
        b_rot WHEN OTHERS;
		b_pre <= din(31 DOWNTO 0);  
        b<=ba_xor XOR a_reg;

-- A=((A XOR B)<<<B) + S[2×i];
a_rot <= a_reg - skey(CONV_INTEGER(i_cnt & '0'));
WITH b(4 DOWNTO 0) SELECT
ab_xor<= a_rot(0) & a_rot(31 DOWNTO 1) WHEN "00001",
        a_rot(1 DOWNTO 0) & a_rot(31 DOWNTO 2) WHEN "00010",
        a_rot(2 DOWNTO 0) & a_rot(31 DOWNTO 3) WHEN "00011",
        a_rot(3 DOWNTO 0) & a_rot(31 DOWNTO 4) WHEN "00100",
        a_rot(4 DOWNTO 0) & a_rot(31 DOWNTO 5) WHEN "00101",
        a_rot(5 DOWNTO 0) & a_rot(31 DOWNTO 6) WHEN "00110",
        a_rot(6 DOWNTO 0) & a_rot(31 DOWNTO 7) WHEN "00111",
        a_rot(7 DOWNTO 0) & a_rot(31 DOWNTO 8) WHEN "01000",
        a_rot(8 DOWNTO 0) & a_rot(31 DOWNTO 9) WHEN "01001",
        a_rot(9 DOWNTO 0) & a_rot(31 DOWNTO 10) WHEN "01010",
        a_rot(10 DOWNTO 0) & a_rot(31 DOWNTO 11) WHEN "01011",
        a_rot(11 DOWNTO 0) & a_rot(31 DOWNTO 12) WHEN "01100",
        a_rot(12 DOWNTO 0) & a_rot(31 DOWNTO 13) WHEN "01101",
        a_rot(13 DOWNTO 0) & a_rot(31 DOWNTO 14) WHEN "01110",
        a_rot(14 DOWNTO 0) & a_rot(31 DOWNTO 15) WHEN "01111",
        a_rot(15 DOWNTO 0) & a_rot(31 DOWNTO 16) WHEN "10000",
        a_rot(16 DOWNTO 0) & a_rot(31 DOWNTO 17) WHEN "10001",
        a_rot(17 DOWNTO 0) & a_rot(31 DOWNTO 18) WHEN "10010",
        a_rot(18 DOWNTO 0) & a_rot(31 DOWNTO 19) WHEN "10011",
        a_rot(19 DOWNTO 0) & a_rot(31 DOWNTO 20) WHEN "10100",
        a_rot(20 DOWNTO 0) & a_rot(31 DOWNTO 21) WHEN "10101",
        a_rot(21 DOWNTO 0) & a_rot(31 DOWNTO 22) WHEN "10110",
        a_rot(22 DOWNTO 0) & a_rot(31 DOWNTO 23) WHEN "10111",
        a_rot(23 DOWNTO 0) & a_rot(31 DOWNTO 24) WHEN "11000",
        a_rot(24 DOWNTO 0) & a_rot(31 DOWNTO 25) WHEN "11001",
        a_rot(25 DOWNTO 0) & a_rot(31 DOWNTO 26) WHEN "11010",
        a_rot(26 DOWNTO 0) & a_rot(31 DOWNTO 27) WHEN "11011",
        a_rot(27 DOWNTO 0) & a_rot(31 DOWNTO 28) WHEN "11100",
        a_rot(28 DOWNTO 0) & a_rot(31 DOWNTO 29) WHEN "11101",
        a_rot(29 DOWNTO 0) & a_rot(31 DOWNTO 30) WHEN "11110",
        a_rot(30 DOWNTO 0) & a_rot(31) WHEN "11111",
        a_rot WHEN OTHERS;
		a_pre<=din(63 DOWNTO 32); 
a<=ab_xor XOR b;

-- A register
PROCESS(din,clr, clk) BEGIN
IF(clr='0') THEN a_reg<=(OTHERS=>'0');
ELSIF(clk'EVENT AND clk='1') THEN IF(state=ST_PRE_ROUND) THEN a_reg<=a_pre;
      		                      ELSIF(state=ST_ROUND_OP) THEN a_reg<=a;   
                                  END IF;
END IF;
END PROCESS;

-- B register
PROCESS(din,clr, clk) BEGIN 
IF(clr='0') THEN b_reg<=(OTHERS=>'0');
ELSIF(clk'EVENT AND clk='1') THEN IF(state=ST_PRE_ROUND) THEN b_reg<=b_pre;
           	                         ELSIF(state=ST_ROUND_OP) THEN b_reg<=b;
	                                  END IF;
END IF;
END PROCESS;
-- round counter
PROCESS(clr, clk) BEGIN
IF(clr='0') THEN i_cnt<="1100";
ELSIF(clk'EVENT AND clk='1') 
THEN IF(state=ST_ROUND_OP) THEN  
                           IF(i_cnt="0001") THEN i_cnt<="1100";
                           ELSE i_cnt<=i_cnt-'1';
                           END IF;
     END IF;
END IF;
END PROCESS;

PROCESS(clr, clk)
BEGIN
   IF(clr='0') THEN state<=ST_IDLE;
   ELSIF(clk'EVENT AND clk='1') THEN
          CASE state IS
          WHEN ST_IDLE=>  IF(di_vld='1') THEN state<=ST_PRE_ROUND;  END IF;
          WHEN ST_PRE_ROUND=> state<=ST_ROUND_OP;
          WHEN ST_ROUND_OP=> IF(i_cnt="0001") THEN state<=ST_READY;  END IF;
          WHEN ST_READY=> state<=ST_READY;
          END CASE;
    END IF;
END PROCESS;



WITH state SELECT
     do_rdy<=	'1' WHEN ST_READY,	
	         	'0' WHEN OTHERS;
				
WITH state SELECT
     doUt<=	(a_reg-skey(0)) & (b_reg-skey(1)) WHEN ST_READY,	
	         (a_reg-skey(0)) & (b_reg-skey(1)) WHEN ST_IDLE,
			 a_reg & b_reg WHEN ST_PRE_ROUND,
			 a_reg & b_reg WHEN ST_ROUND_OP;
				
END decryption;