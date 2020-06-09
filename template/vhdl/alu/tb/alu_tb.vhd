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

	signal clk : std_logic;
	signal res_n : std_logic;
	signal A, B, R : data_type;
	signal Z : std_logic;
	signal op : alu_op_type;

	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
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
		res_n <= '0';
		A <= (others => '0');
		B <= (others => '0');
		wait for CLK_PERIOD;
		res_n <= '1';
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		A <= ( 4 downto 0 => d"30", others => '0');
		B <= x"44842322";
		op <= ALU_NOP;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		A <= x"fffffffe";
		B <= x"44842322"; 
		op <= ALU_SLT;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		B <= (0 => '0', 1 => '0', others => '1');
		op <= ALU_SLTU;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		A <= x"fffffe92"; --365
		B <= x"00000019"; --25
		op <= ALU_SLL;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_SRL;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_SRA;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_ADD;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_SUB;
				
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_AND;

		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_OR;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		op <= ALU_XOR;
		
		wait for CLK_PERIOD;
		wait until rising_edge(clk);
		stop_clock <= true;
		
		wait;
	end process;

	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;

