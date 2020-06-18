library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

use work.core_pkg.all; 
use work.op_pkg.all; 
use work.mem_pkg.all; 

entity wb_tb is 
end entity; 

architecture beh of wb_tb is 

	signal clk, reset : std_logic; 
	constant CLK_PERIOD : time := 40 ns; 
	signal stop_clock : boolean := false; 
	signal op : wb_op_type; 
	signal aluresult : data_type; 
	signal memresult : data_type; 
	signal pc_old_in : pc_type; 
	signal pc_new_in : pc_type; 

	signal reg_write : reg_write_type; 	

	component wb is 
	port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from MEM
        op         : in  wb_op_type;
        aluresult  : in  data_type;
        memresult  : in  data_type;
        pc_old_in  : in  pc_type;
        pc_new_in  : in  pc_type;

        -- to FWD and DEC
        reg_write  : out reg_write_type
	);
	end component;
begin

	uut : wb
	port map(
		clk => clk,
		reset => reset,
		stall => '0',
		flush => '0',
		op => op,
		aluresult => aluresult,
		memresult => memresult,
		pc_old_in => pc_old_in,
		pc_new_in => pc_new_in,
		reg_write => reg_write
	); 

	stimulus : process
	begin

		wait until rising_edge(clk); 
		reset <= '1'; 
		wait for 3*CLK_PERIOD; 
		reset <= '0'; 
		wait for CLK_PERIOD; 
		reset <= '1'; 
		wait for 3*CLK_PERIOD; 

		--TESTCASE #1 -> write result of computation to $rd
		op.write <= '1'; 
		op.rd    <= "00010"; 
		op.src   <= WBS_ALU; 

		aluresult <= x"00DDCA00"; 
		memresult <= x"00000000"; 
		
		pc_old_in <= x"001C"; 
		pc_new_in <= x"0020"; 
		
		wait for 2*CLK_PERIOD; 
		
		report "TESTCASE #1"; 
		if reg_write.write = '1' then report "reg_write.write = 1"; else report 
		"reg_write.write = 0"; end if;  
		report "reg_write.reg = " & integer'image(to_integer(unsigned(reg_write.reg))); 
		report "reg_write.data = " & integer'image(to_integer(unsigned(reg_write.data)));
		
		wait for 5*CLK_PERIOD;	
		
		--TESTCASE #2 -> write result of computation to $rd
		op.write <= '1'; 
		op.rd    <= "00010"; 
		op.src   <= WBS_MEM; 

		aluresult <= x"00000000"; 
		memresult <= x"00DDCA00"; 
		
		pc_old_in <= x"001C"; 
		pc_new_in <= x"0020"; 
		
		wait for 2*CLK_PERIOD; 
		
		report "TESTCASE #2"; 
		if reg_write.write = '1' then report "reg_write.write = 1"; else report 
		"reg_write.write = 0"; end if;  
		report "reg_write.reg = " & integer'image(to_integer(unsigned(reg_write.reg))); 
		report "reg_write.data = " & integer'image(to_integer(unsigned(reg_write.data)));
		
		wait for 5*CLK_PERIOD;	

		wait;


	end process; 

	gen_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD/2; 
			wait for CLK_PERIOD; 
		end loop; 
		wait; 
	end process; 	

end architecture; 
