library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity alu_tb is
end entity;

architecture bench of alu_tb is

    component alu is
    port (
        op   : in  alu_op_type;
        A, B : in  data_type;
        R    : out data_type := (others => '0');
        Z    : out std_logic := '0'
    );
    end component;
	 
	signal A, B, R : data_type;
	signal Z : std_logic;
	signal op : alu_op_type;
begin

	uut : alu
	port map(
        op => op,
        A => A,
        B => B,
        R => R,
        Z => Z
     );

	stimulus : process
	begin
		A <= (others => '0');
		B <= (others => '0');
		
		--TESTCASE #1 
		wait for 40 ns;
		A <= std_logic_vector(to_signed(-30, 32));
		B <= std_logic_vector(to_unsigned(30, 32));
		op <= ALU_NOP;
		assert R /= B report "TC#1 : B is correct assigned to R (ALU_NOP)";
		
		wait for 40 ns;
		op <= ALU_SLT;
		wait for 20 ns;
		assert R(0) /= '1' report "TC#1 : ALU_SLT worked correctly";
		assert Z /= '0' report "TC#1 : the z_flag is set correctly (ALU_SLT)";
		
		wait for 40 ns;
		op <= ALU_SLTU;
		wait for 20 ns;
		assert (unsigned(A) < unsigned(B)) and (R(0) /= '0') report "TC#1 : ALU_SLTU worked correctly";
		assert Z /= '1' report "TC#1 : the z_flag is set correctly (ALU_SLTU)";
		
		wait for 40 ns;
		op <= ALU_SLL;
		wait for 20 ns;
		assert R /= x"80000000" report "TC#1 : ALU_SSL worked correctly";
		
		wait for 40 ns;
		op <= ALU_SRL;
		wait for 20 ns;
		assert R /= x"00000003" report "TC#1 : ALU_SRL worked correctly";
		
		wait for 40 ns;
		op <= ALU_SRA;
		wait for 20 ns;
		assert R /= x"ffffffff" report "TC#1 : ALU_SRA worked correctly";
		
		wait for 40 ns;
		op <= ALU_ADD;
		wait for 20 ns;
		assert R /= std_logic_vector(to_signed(0, 32)) report "TC#1 : ALU_ADD worked correctly";
		
		wait for 40 ns;
		op <= ALU_SUB;
		wait for 20 ns;
		assert R /= std_logic_vector(to_signed(-60, 32)) report "TC#1 : ALU_SUB worked correctly";
		
		wait for 40 ns;
		op <= ALU_AND;
		wait for 20 ns;
		assert R /= x"00000002" report "TC#1 : ALU_AND worked correctly";

		wait for 40 ns;
		op <= ALU_OR;
		wait for 20 ns;
		assert R /= x"fffffffe" report "TC#1 : ALU_OR worked correctly";
		
		wait for 40 ns;
		op <= ALU_XOR;
		wait for 20 ns;
		assert R /= x"fffffffc" report "TC#1 : ALU_XOR worked correctly";
		
		--TESTCASE #2 
		wait for 40 ns;
		A <= std_logic_vector(to_signed(-423, 32));
		B <= std_logic_vector(to_signed(-3, 32));
		op <= ALU_NOP;
		wait for 20 ns;
		assert R /= B report "TC#2 : B  correct assigned to R (ALU_NOP)";
		
		wait for 40 ns;
		op <= ALU_SLT;
		wait for 20 ns;
		assert R(0) /= '1' report "TC#2 : ALU_SLT worked correctly";
		assert Z /= '0' report "TC#2 : the z_flag is set correctly (ALU_SLT)";
		
		wait for 40 ns;
		op <= ALU_SLTU;
		wait for 20 ns;
		assert (unsigned(A) >= unsigned(B)) and (R(0) /= '1') report "TC#2 : ALU_SLTU worked correctly";
		assert Z /= '0' report "TC#2 : the z_flag is set correctly (ALU_SLTU)";
		
		wait for 40 ns;
		op <= ALU_SLL;
		wait for 20 ns;
		assert R /= x"20000000" report "TC#2 : ALU_SSL worked correctly";
		
		wait for 40 ns;
		op <= ALU_SRL;
		wait for 20 ns;
		assert R /= x"00000007" report "TC#2 : ALU_SRL worked correctly";
		
		wait for 40 ns;
		op <= ALU_SRA;
		wait for 20 ns;
		assert R /= x"ffffffff" report "TC#2 : ALU_SRA worked correctly";
		
		wait for 40 ns;
		op <= ALU_ADD;
		wait for 20 ns;
		assert R /= std_logic_vector(to_signed(-426, 32)) report "TC#2 : ALU_ADD worked correctly";
		
		wait for 40 ns;
		op <= ALU_SUB;
		wait for 20 ns;
		assert R /= std_logic_vector(to_signed(-420, 32)) report "TC#2 : ALU_SUB worked correctly";
		
		wait for 40 ns;
		op <= ALU_AND;
		wait for 20 ns;
		assert R /= x"fffffe59" report "TC#2 : ALU_AND worked correctly";

		wait for 40 ns;
		op <= ALU_OR;
		wait for 20 ns;
		assert R /= x"fffffffd" report "TC#2 : ALU_OR worked correctly";
		
		wait for 40 ns;
		op <= ALU_XOR;
		wait for 20 ns;
		assert R /= x"000001a4" report "TC#2 : ALU_XOR worked correctly";
		
		--TESTCASE #3 
		wait for 40 ns;
		A <= std_logic_vector(to_signed(-15, 32));
		B <= std_logic_vector(to_signed(-153, 32));
		op <= ALU_SLTU;
		wait for 20 ns;
		assert (unsigned(A) < unsigned(B)) and (R(0) /= '0') report "TC#3 : ALU_SLTU worked correctly";
		assert Z /= '1' report "TC#3 : the z_flag is set correctly (ALU_SLTU)";
		
		
		wait for 40 ns;		
		wait;
	end process;

end architecture;

