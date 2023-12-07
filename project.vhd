library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;

entity ALU is 
	port(a,b: in std_logic_vector(31 downto 0);
	opcode: in std_logic_vector(5 downto 0);
	result: out std_logic_vector(31 downto 0));
end entity ALU;
	
architecture num1 of ALU is
begin
	process(a,b,opcode)
	variable i : integer;
	begin
		i := conv_integer(a+b)/2;
		case (opcode) is
			when "000110" => result <= a + b;
			when "001000" => result <= a - b;
			when "001010" => if (a < x"0000_0000") then 
								 result <=  -a;
							else result <= a;
							end if;							
			when "001100" => result <= -a;
			when "001110" => if (a > b) then result <= a;
							else result <= b;
							end if;
			when "001011" => if (a > b) then result <= b;
							else result <= a;
							end if;
			when "001101" => result <= conv_std_logic_vector(i,32);
			when "001111" => result <= not a;
			when "000010" => result <= a or b;
			when "000011" => result <= a and b;
			when "001001" => result <= a xor b;
			when others => null;
			end case;
	end process; 
	
end architecture num1;
----------------------------------------------- -----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity reg is
	port(add1,add2,add3: in std_logic_vector(4 downto 0);--add1, add2 => read operation. add3 => write operation
	enable,clk: in std_logic;
	input: in std_logic_vector(31 downto 0);
	out1,out2: out std_logic_vector(31 downto 0));
end entity reg;

architecture num1 of reg is

type ram_type is array(31 downto 0) of std_logic_vector(31 downto 0);  

signal ram_data: ram_type:= ( -- initializing register data

0 => std_logic_vector(to_signed(0,32)),
1 => std_logic_vector(to_signed(5986,32)),
2 => std_logic_vector(to_signed(12250,32)),
3 => std_logic_vector(to_signed(482,32)),
4 => std_logic_vector(to_signed(14246,32)),
5 => std_logic_vector(to_signed(5124,32)),
6 => std_logic_vector(to_signed(1848,32)),
7 => std_logic_vector(to_signed(5260,32)),
	
8 => std_logic_vector(to_signed(16170,32)),
9 => std_logic_vector(to_signed(4766,32)),
10 => std_logic_vector(to_signed(4298,32)),
11 => std_logic_vector(to_signed(610,32)),
12 => std_logic_vector(to_signed(1510,32)),
13 => std_logic_vector(to_signed(9794,32)),
14 => std_logic_vector(to_signed(7456,32)),
15 => std_logic_vector(to_signed(5580,32)),
	
16 => std_logic_vector(to_signed(9300,32)),
17 => std_logic_vector(to_signed(12314,32)),
18 => std_logic_vector(to_signed(12806,32)), 
19 => std_logic_vector(to_signed(10478,32)),
20 => std_logic_vector(to_signed(11556,32)),
21 => std_logic_vector(to_signed(6778,32)),
22 => std_logic_vector(to_signed(8430,32)),
23 => std_logic_vector(to_signed(5700,32)),

24 => std_logic_vector(to_signed(13422,32)),
25 => std_logic_vector(to_signed(11224,32)),
26 => std_logic_vector(to_signed(1990,32)),
27 => std_logic_vector(to_signed(922,32)),
28 => std_logic_vector(to_signed(6020,32)),
29 => std_logic_vector(to_signed(15768,32)),
30 => std_logic_vector(to_signed(5624,32)),
31 => std_logic_vector(to_signed(0,32)));

begin
	process is
	variable flag: integer:=0; -- flag = 0 for read, flag = 1 for write
	begin
		if(clk'event and clk = '1' ) then
			wait for 1 ns; -- to make sure that the opcode is ready (valid opcode => enable = )
			if(enable = '1') then
				if(flag = 0) then
					out1 <= ram_data(conv_integer(add1));
					out2 <= ram_data(conv_integer((add2)));
					flag := 1; -- to write in the next rising_edge
				elsif (flag = 1) then
					ram_data(conv_integer(add3)) <= input;
					flag := 0; -- to read in the next rising_edge
				end if;
			end if;
		end if;
		wait on clk;
	end process;
end architecture num1;
----------------------------------------------- -----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg32 is -- "reg32" do the excution of a machine instruction into opcode,add1,add2 and addDest
	port(mach_ins: in std_logic_vector(31 downto 0);
	clk: in std_logic;
	add1,add2,addDest: out std_logic_vector(4 downto 0);
	opcode: out std_logic_vector(5 downto 0));
end entity reg32;

architecture num1 of reg32 is
begin	
	process
	begin
		wait until (clk'event and clk = '1'); -- wait for rising edge to decode a new mach_ins 
				opcode <= mach_ins(5 downto 0);
				add1 <= mach_ins(10 downto 6);
				add2 <= mach_ins(15 downto 11);
				addDest <= mach_ins(20 downto 16);			
		wait on mach_ins;
	end process;
end architecture num1;
----------------------------------------------- -----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity cpu is
	port (mach_ins:in std_logic_vector(31 downto 0);
	clk: in std_logic;
	result: out std_logic_vector(31 downto 0));
end entity cpu;

architecture num1 of cpu is 

signal opcode: std_logic_vector(5 downto 0);
signal add1,add2,addDest: std_logic_vector(4 downto 0);
signal out1,out2,result_sig: std_logic_vector(31 downto 0);
signal enable: std_logic; 

begin  
	process(opcode)
	begin
		enable <= '0';			
		if (opcode = "000110" or opcode = "001000" or opcode = "001010" or opcode = "001100" -- valid opcodes  
		 or opcode = "001110" or opcode = "001011"	or opcode = "001101" or opcode = "001111" 
		 or opcode = "000010" or opcode = "000011" or opcode = "001001") then
			enable <= '1';
		end if;
	end process;

	result <= result_sig;
	ins_decode: entity work.reg32(num1) port map(mach_ins,clk,add1,add2,addDest,opcode);
	reg:    	entity work.reg(num1) 	port map(add1,add2,addDest,enable,clk,result_sig,out1,out2);
	alu: 		entity work.alu(num1) 	port map(out1,out2,opcode,result_sig);
	
end architecture num1;	
----------------------------------------------- -----------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testBeanch is
end entity testBeanch;

architecture myProg of testBeanch is

signal mach_ins: std_logic_vector(31 downto 0);
signal	clk: std_logic := '0';
signal	result: std_logic_vector(31 downto 0);

begin
	system: entity work.cpu(num1) port map (mach_ins,clk,result);
	clk <= not clk after 10 ns;	-- clk period = 20 ns, so mach_ins needs at least 40 ns to be excuted properly
	mach_ins <= b"00000000000_00000_00001_00000_001110", b"00000000000_00000_00010_00000_001110" after 40 ns,--"unused bits_dest address_second address_first address_opcode" 
				b"00000000000_00000_00011_00000_001110" after 80 ns, b"00000000000_00000_00100_00000_001110" after 120 ns,
				b"00000000000_00000_00101_00000_001110" after 160 ns, b"00000000000_00000_00110_00000_001110" after 200 ns,
				
				b"00000000000_00000_00111_00000_001110" after 240 ns, b"00000000000_00000_01000_00000_001110" after 280 ns,
				b"00000000000_00000_01001_00000_001110" after 320 ns, b"00000000000_00000_01010_00000_001110" after 360 ns,
				b"00000000000_00000_01011_00000_001110" after 400 ns, b"00000000000_00000_01100_00000_001110" after 440 ns,
				
				b"00000000000_00000_01101_00000_001110" after 480 ns, b"00000000000_00000_01110_00000_001110" after 520 ns,
				b"00000000000_00000_01111_00000_001110" after 560 ns, b"00000000000_00000_10000_00000_001110" after 600 ns,
				b"00000000000_00000_10001_00000_001110" after 640 ns, b"00000000000_00000_10010_00000_001110" after 680 ns,
				
				b"00000000000_00000_10011_00000_001110" after 720 ns, b"00000000000_00000_10100_00000_001110" after 760 ns,
				b"00000000000_00000_10101_00000_001110" after 800 ns, b"00000000000_00000_10110_00000_001110" after 840 ns,
				b"00000000000_00000_10111_00000_001110" after 880 ns, b"00000000000_00000_11000_00000_001110" after 920 ns,
				
				b"00000000000_00000_11001_00000_001110" after 960 ns, b"00000000000_00000_11010_00000_001110" after 1000 ns,
				b"00000000000_00000_11011_00000_001110" after 1040 ns, b"00000000000_00000_11100_00000_001110" after 1080 ns,
				b"00000000000_00000_11101_00000_001110" after 1120 ns, b"00000000000_00000_11110_00000_001110" after 1160 ns; --the values at addresses "31" and "0" are always zero.
					
	process 
	begin
		wait for 1200 ns;-- wait for the program to finish
		assert(result = std_logic_vector(to_signed(16170,32))) -- max value in the data = 16170
			report("Output is incorrect!")
			severity error;
	end process;
end architecture myProg;

architecture reg_test of testBeanch is
signal add1,add2,add3: std_logic_vector(4 downto 0);-- add1 and add2 is for read operation whereas add3 is for write operation
signal	enable: std_logic := '0'; 
signal	clk: std_logic := '0';
signal	input: std_logic_vector(31 downto 0);
signal	out1,out2: std_logic_vector(31 downto 0);

begin
	system: entity work.reg(num1) port map (add1,add2,add3,enable,clk,input,out1,out2);
	clk <= not clk after 20 ns;
	enable <= '1' after 60 ns; --in the first 60 ns nothing will change as enable = 0;
	add1 <= "01100","00110" after 300 ns;
	add2 <= "01001","01010" after 300 ns;
	add3 <= "01100", "01001" after 200 ns;
	input <= x"A000B000",x"1110CF00" after 200 ns;
	
end architecture reg_test;

architecture alu_test of testBeanch is
signal a,b: std_logic_vector(31 downto 0);
signal	opcode: std_logic_vector(5 downto 0);
signal	result: std_logic_vector(31 downto 0);

begin
	system: entity work.alu(num1) port map (a,b,opcode,result);
		
	a <= x"FFFF_FFFF"; -- a = -1;
	b <= x"0000_0007"; -- b = 7;
	
	opcode <= "000110","001000" after 20 ns, "001010" after 40 ns,"001100" after 60 ns,
	"001110" after 80 ns,"001011" after 100 ns, "001101" after 120 ns, "001111" after 140 ns,
	"000010" after 160 ns, "000011" after 180 ns, "001001" after 200 ns;	
	
end architecture alu_test;