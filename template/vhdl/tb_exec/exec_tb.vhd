library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.mem_pkg.all; 
use work.core_pkg.all; 
use work.op_pkg.all;

entity exec_tb is
end entity; 

architecture beh of exec_tb is 
	constant CLK_PERIOD : time := 40 ns; 
	signal stop_clock : boolean := false; 
	signal clk : std_logic; 
	signal reset, stall, flush : std_logic; 
	signal op : exec_op_type; 
	signal pc_in : pc_type; 
	signal memop_in : mem_op_type; 
	signal wbop_in : wb_op_type; 

	--other signals
	signal pc_old_out : pc_type; 
	signal pc_new_out : pc_type; 
	signal aluresult : data_type; 
	signal wrdata : data_type; 
	signal zero : std_logic; 
	signal memop_out : mem_op_type; 
	signal wbop_out : wb_op_type; 	

	component exec is 
	   port (
       	clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- from DEC
        op            : in  exec_op_type;
        pc_in         : in  pc_type;

        -- to MEM
        pc_old_out    : out pc_type;
        pc_new_out    : out pc_type;
        aluresult     : out data_type;
        wrdata        : out data_type;
        zero          : out std_logic;

        memop_in      : in  mem_op_type;
        memop_out     : out mem_op_type;
        wbop_in       : in  wb_op_type;
        wbop_out      : out wb_op_type;

        -- FWD
        exec_op       : out exec_op_type;
        reg_write_mem : in  reg_write_type;
        reg_write_wr  : in  reg_write_type
    );	
	end component;

begin

	exec_inst : exec
	port map(
		clk => clk,
		reset => reset,
		stall => stall, 
		flush => flush,
		op => op,
		pc_in => pc_in,
		pc_old_out => pc_old_out,
		pc_new_out => pc_new_out,
		aluresult => aluresult,
		wrdata => wrdata,
		zero => zero,
		memop_in => memop_in,
		memop_out => memop_out,
		wbop_in => wbop_in,
		wbop_out => wbop_out,
		exec_op => open,
		reg_write_mem => REG_WRITE_NOP, 
		reg_write_wr => REG_WRITE_NOP
	); 

	stimulus : process
	begin
		reset <= '1'; 
		stall <= '0'; 
		flush <= '0'; 

		--test reset
		wait for 3*CLK_PERIOD; 
		reset <= '0'; 
		wait for 3*CLK_PERIOD; 
		reset <= '1'; 		
		
		wait until rising_edge(clk);
		wait for 5*CLK_PERIOD; 
		--TESTCASE #1, just adding two unsigned integers
		--checking r-type instructions
		op.aluop <= ALU_ADD; 
		op.imm_flag <= '0'; 
		op.store_flag <= '0'; 
		op.pc_flag <= '0'; 
		op.rs1 <= "00010"; 
		op.rs2 <= "00011"; 
		op.readdata1 <= x"0000ABCD"; 
		op.readdata2 <= x"00000001"; 	
		op.imm <= (others => '0'); 
	
		pc_in <= x"0020"; 
		memop_in <= MEM_NOP; 
		wbop_in <= WB_NOP;
	
		wait for 2*CLK_PERIOD; 
		
		report "A = 43981, B = 1"; 
		report "aluresult = " & integer'image(to_integer(unsigned(aluresult)));
		report "wrdata = " & integer'image(to_integer(unsigned(wrdata)));  
		report "pc_in = " & integer'image(to_integer(unsigned(pc_in))); 
		report "pc_new_out = " & integer'image(to_integer(unsigned(pc_new_out)));

		wait for 4*CLK_PERIOD;

		--TESTCASE #2, just adding with immediates
		op.aluop <= ALU_ADD; 
		op.imm_flag <= '1'; 
		op.store_flag <= '0'; 
		op.pc_flag <= '0'; 
		op.rs1 <= "00010"; 
		op.rs2 <= "00011"; 
		op.readdata1 <= x"0000ABC7"; 
		op.readdata2 <= (others => '0');
		op.imm <= x"00000005"; 

		pc_in <= x"0020"; 
		memop_in <= MEM_NOP; 
		wbop_in <= WB_NOP; 
	
		wait for 2*CLK_PERIOD;

		report "A = " & integer'image(to_integer(unsigned(op.readdata1))) & ", imm = 5"; 
		report "aluresult = "& integer'image(to_integer(unsigned(aluresult))); 
		report "wrdata = " & integer'image(to_integer(unsigned(wrdata))); 
		
		wait for 5*CLK_PERIOD;
	
		--TESTCASE #3, jump instruction 	
		op.aluop <= ALU_SUB; 
		op.imm_flag <= '0'; 
		op.store_flag <= '0'; 
		op.pc_flag <= '1'; 
		op.rs1 <= ZERO_REG; 
		op.rs2 <= ZERO_REG; 
		op.readdata1 <= x"0000ABC7"; 
		op.readdata2 <= x"0000ABC7";
		op.imm <= x"00000070"; 
		
		pc_in <= x"0023"; 
		memop_in <= MEM_NOP; 
		wbop_in <= WB_NOP; 

		wait for 2*CLK_PERIOD; 

		report "rs1 = " & integer'image(to_integer(unsigned(op.readdata1))) & ", rs2 = " &
				integer'image(to_integer(unsigned(op.readdata2))); 
		report "pc_new_out = " & integer'image(to_integer(unsigned(pc_new_out))); 
		report "pc_old_out = " & integer'image(to_integer(unsigned(pc_old_out))); 
		report "aluresult  = " & integer'image(to_integer(unsigned(aluresult)));  
		report "wrdata = " & integer'image(to_integer(unsigned(wrdata))); 

		wait for 5*CLK_PERIOD;
	
		--TESTCASE #4, store instruction 	
		op.aluop <= ALU_ADD; 
		op.imm_flag <= '0'; 
		op.store_flag <= '1'; 
		op.pc_flag <= '0'; 
		op.rs1 <= ZERO_REG; 
		op.rs2 <= ZERO_REG; 
		op.readdata1 <= x"000000C8"; 
		op.readdata2 <= x"00DDABC7";
		op.imm <= x"00000078"; --word offset 
		
		pc_in <= x"0024"; --word adress 
		memop_in <= MEM_NOP; 
		wbop_in <= WB_NOP; 
		
		wait for 2*CLK_PERIOD;
	
		report "Saving value : " & integer'image(to_integer(unsigned(op.readdata2))) &
			" @ location : " & integer'image(to_integer(unsigned(aluresult))); 

		wait;
	end process; 


	create_clock : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD/2; 
			wait for CLK_PERIOD; 
		end loop; 
		wait; 
	end process; 

end architecture; 
