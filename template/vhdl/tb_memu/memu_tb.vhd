library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.op_pkg.all; 
use work.mem_pkg.all; 
use work.core_pkg.all; 

entity memu_tb is 
end entity; 

--
-- This testbench testes the memory unit.
-- E.g. read/write access to the memory (especially the translation)
-- No clock process needed as the memu operates fully on RTL Level
--

architecture beh of memu_tb is

	component memu is 
	port (
       		-- to mem
        	op   : in  memu_op_type; --access type
     		A    : in  data_type;    --address
        	W    : in  data_type;    --write data (one word) 
        	R    : out data_type; --result of mem access

        	B    : out std_logic; --busy
        	XL   : out std_logic; --load exception
        	XS   : out std_logic;  --store exception

        	-- to memory controller
        	D    : in  mem_in_type; --interface from memory (result of access)
        	M    : out mem_out_type := MEM_OUT_NOP --interface to memory (to start access)
    	);
	end component;
	
	signal op : memu_op_type; 
	signal A, W, R : data_type; 
	signal B, XL, XS : std_logic; 
	signal D : mem_in_type; 
	signal M : mem_out_type; 
	constant null_vec : std_logic_vector(31 downto 0) := x"00000000"; 
begin

	memu_int : memu 
	port map(
		op => op,
	 	A => A,
		W => W,
		R => R,
		B => B,
		XL => XL,
		XS => XS,
		D => D,
		M => M
	); 

	stimulus : process
	begin
		wait for 20 ns;

		--TESTCASE #1 Write Word 0xFFFFFFFF to Word Adress 0x123 & "00"; 
		op.memread <= '0'; 
		op.memwrite <= '1'; 
		op.memtype <= MEM_W; 

		A <= x"00000230"; 
		W <= x"FFFFFFFF"; 
		
		D.busy <= '0'; 
		D.rddata <= (others => '0'); 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #1 => 
		assert R /= null_vec report 	"TC#1 : Result is NULL VEC."; 
		assert B /= '0' report 		"TC#1 : Busy flag zero.";
		assert XL /= '0' report 	"TC#1 : No load exception.";
		assert XS /= '0' report 	"TC#1 : No store exeption.";
		assert M.address /= A(13 downto 0) report "TC#1 : Address correct.";
		assert M.byteena /= "1111" report "TC#1 : Byteena correct."; 
		assert M.wrdata /= W report 	"TC#1 : Data correct.\n\n";

		wait for 100 ns;
 
		--TESTCASE #2 READ Word 0xFFFFFFFF from Word Adress 0x123 & "00"; 
		op.memread <= '1'; 
		op.memwrite <= '0'; 
		op.memtype <= MEM_W; 

		A <= x"00000230"; 
		W <= null_vec; 
		
		D.busy <= '1'; 
		D.rddata <= x"FFFFFFFF"; 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #2 => 
		assert R /= D.rddata report 	"TC#2 : Result is D.rddata."; 
		assert B /= '1' report 		"TC#2 : Busy flag one.";
		assert XL /= '0' report 	"TC#2 : No load exception.";
		assert XS /= '0' report 	"TC#2 : No store exeption.";
		assert M.address /= A(13 downto 0) report "TC#2 : Address correct.";

		wait for 100 ns; 	

		--TESTCASE #3 STORE Word 0xAABBCCDD to Word Adress 0x123 & "00"
		--(special endianess check)
		op.memread <= '0'; 
		op.memwrite <= '1'; 
		op.memtype <= MEM_W; 

		A <= x"00000230"; 
		W <= x"AABBCCDD"; 
		
		D.busy <= '0'; 
		D.rddata <= (others => '0'); 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #3 => 
		assert R /= null_vec report 	"TC#3 : Result is NULL VEC."; 
		assert B /= '0' report 		"TC#3 : Busy flag zero.";
		assert XL /= '0' report 	"TC#3 : No load exception.";
		assert XS /= '0' report 	"TC#3 : No store exeption.";
		assert M.address /= A(13 downto 0) report "TC#3 : Address correct.";
		assert M.byteena /= "1111" report "TC#3 : Byteena correct."; 
		assert M.wrdata /= x"DDCCBBAA" report 	"TC#3 : Data and endianess correct.";

		wait for 100 ns; 

		--TESTCASE #4 READ word 0xDDCCBBAA from Word Adress 0x123 & "00"
		op.memread <= '1'; 
		op.memwrite <= '0'; 
		op.memtype <= MEM_W; 

		A <= x"00000230"; 
		W <= null_vec; 
		
		D.busy <= '1'; 
		D.rddata <= x"DDCCBBAA"; 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #4 => 
		assert R /= x"AABBCCDD" report 	"TC#4 : Result is D.rddata."; 
		assert B /= '1' report 		"TC#4 : Busy flag one.";
		assert XL /= '0' report 	"TC#4 : No load exception.";
		assert XS /= '0' report 	"TC#4 : No store exeption.";
		assert M.address /= A(13 downto 0) report "TC#4 : Address correct.";
		
		wait for 100 ns; 	
	
		--TESTCASE #5 STORE Word 0xAABBCCDD to Word Adress 0x123 & "01"
		--(store exception)
		op.memread <= '0'; 
		op.memwrite <= '1'; 
		op.memtype <= MEM_W; 

		A <= x"0000023" & "0001"; 
		W <= x"AABBCCDD"; 
		
		D.busy <= '0'; 
		D.rddata <= (others => '0'); 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #5 => 
		assert R /= null_vec report 	"TC#5 : Result is NULL VEC."; 
		assert B /= '0' report 		"TC#5 : Busy flag zero.";
		assert XL /= '0' report 	"TC#5 : No load exception.";
		assert XS /= '1' report 	"TC#5 : Store exeption happened.";
		assert M.wr /= '0' report 	"TC#5 : No write issued."; 
		assert M.rd /= '0' report 	"TC#5 : No read issued."; 

		wait for 100 ns; 

		--TESTCASE #6 READ word 0xDDCCBBAA from Word Adress 0x123 & "01"
		--(load exception)
		op.memread <= '1'; 
		op.memwrite <= '0'; 
		op.memtype <= MEM_W; 

		A <= x"0000023" & "0001"; 
		W <= null_vec; 
		
		D.busy <= '1'; 
		D.rddata <= x"DDCCBBAA"; 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #6 => 
		assert R /= x"AABBCCDD" report 	"TC#6 : Result is D.rddata."; 
		assert B /= '1' report 		"TC#6 : Busy flag one.";
		assert XL /= '1' report 	"TC#6 : Load exception happened.";
		assert XS /= '0' report 	"TC#6 : No store exeption.";
		assert M.wr /= '0' report 	"TC#6 : No write issued."; 
		assert M.rd /= '0' report 	"TC#6 : No read issued."; 
		
		wait for 100 ns; 	
		
		--TESTCASE #7 STORE Halfword 0xCCDD to Halfword Adress 0x123 & "10"
		op.memread <= '0'; 
		op.memwrite <= '1'; 
		op.memtype <= MEM_H; 

		A <= x"0000023" & "0010"; 
		W <= x"AABBCCDD"; 
		
		D.busy <= '0'; 
		D.rddata <= (others => '0'); 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #7 => 
		assert R /= null_vec report 	"TC#7 : Result is NULL VEC."; 
		assert B /= '0' report 		"TC#7 : Busy flag zero.";
		assert XL /= '0' report 	"TC#7 : No load exception.";
		assert XS /= '0' report 	"TC#7 : No store exeption.";
		assert M.wr /= '0' report 	"TC#7 : Write issued."; 
		assert M.rd /= '0' report 	"TC#7 : No read issued."; 
		assert M.address /= A(13 downto 2) & "00" report "TC#7 : Adress correct.";
		assert M.byteena /= "0011" report "TC#7 : Byteena correct."; 
		assert M.wrdata /= "--------" & "--------" & x"DDCC" report "TC#7 : Wrdata correct.";

		wait for 100 ns;
 
		--TESTCASE #8 STORE Byte 0xDD to Byte Adress 0x123 & "10"
		op.memread <= '0'; 
		op.memwrite <= '1'; 
		op.memtype <= MEM_B; 

		A <= x"0000023" & "0010"; 
		W <= x"AABBCCDD"; 
		
		D.busy <= '0'; 
		D.rddata <= (others => '0'); 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #8 => 
		assert R /= null_vec report 	"TC#8 : Result is NULL VEC."; 
		assert B /= '0' report 		"TC#8 : Busy flag zero.";
		assert XL /= '0' report 	"TC#8 : No load exception.";
		assert XS /= '0' report 	"TC#8 : No store exeption.";
		assert M.wr /= '0' report 	"TC#8 : Write issued."; 
		assert M.rd /= '0' report 	"TC#8 : No read issued."; 
		assert M.address /= A(13 downto 2) & "00" report "TC#8 : Adress correct.";
		assert M.byteena /= "0010" report "TC#8 : Byteena correct."; 
		assert M.wrdata /= "--------" & "--------" & x"DD" & "--------" report "TC#8 : Wrdata correct.";

		--TESTCASE #9 READ Halfword (unsigned) 0xAABB from Halfword Adress 0x123 & "10"
		op.memread <= '1'; 
		op.memwrite <= '0'; 
		op.memtype <= MEM_HU; 

		A <= x"0000023" & "0010"; 
		W <= null_vec; 
		
		D.busy <= '1'; 
		D.rddata <= x"DDCCBBAA"; 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #9 => 
		assert R /= x"0000AABB" report 	"TC#9 : Result is D.rddata."; 
		assert B /= '1' report 		"TC#9 : Busy flag one.";
		assert XL /= '0' report 	"TC#9 : No load exception.";
		assert XS /= '0' report 	"TC#9 : No store exeption.";
		assert M.wr /= '0' report 	"TC#9 : No write issued."; 
		assert M.rd /= '1' report 	"TC#9 : Read issued."; 
		
		wait for 100 ns; 	

		--TESTCASE #10 READ Byte (unsigned) 0xBB from Halfword Adress 0x123 & "10"
		op.memread <= '1'; 
		op.memwrite <= '0'; 
		op.memtype <= MEM_BU; 

		A <= x"0000023" & "0010"; 
		W <= null_vec; 
		
		D.busy <= '1'; 
		D.rddata <= x"DDCCBBAA"; 	 
		
		wait for 10 ns; 
		
		--expected results of TESTCASE #10 => 
		assert R /= x"000000BB" report 	"TC#10 : Result is D.rddata."; 
		assert B /= '1' report 		"TC#10 : Busy flag one.";
		assert XL /= '0' report 	"TC#10 : No load exception.";
		assert XS /= '0' report 	"TC#10 : No store exeption.";
		assert M.wr /= '0' report 	"TC#10 : No write issued."; 
		assert M.rd /= '1' report 	"TC#10 : Read issued."; 
		
		wait for 100 ns; 	

		wait;
		
		--
		-- Further Testcases to be added. Especially the ones that do the signed stuff.
		--
		-- Philipp Geisler, 09.06.2020
	

	end process; 


end architecture; 
