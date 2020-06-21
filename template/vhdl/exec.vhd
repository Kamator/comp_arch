library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity exec is
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
        aluresult     : out data_type; --result of ALU computation
        wrdata        : out data_type; --value that might be stored to memory (not SRAM!) 
        zero          : out std_logic;

        memop_in      : in  mem_op_type;
        memop_out     : out mem_op_type; --forwarded to MEM stage
        wbop_in       : in  wb_op_type;
        wbop_out      : out wb_op_type;  --forwarded to WB stage

        -- FWD
        exec_op       : out exec_op_type;
        reg_write_mem : in  reg_write_type;
        reg_write_wr  : in  reg_write_type
    );
end exec;

architecture rtl of exec is

	component alu is   
            port (
        	op   : in  alu_op_type;
        	A, B : in  data_type;
        	R    : out data_type;
        	Z    : out std_logic
	    );
	end component; 

	--ALU Signals /
	signal alu_op: alu_op_type; 
	signal alu_A, alu_B : data_type; 
	signal alu_R : data_type; 
	signal alu_Z : std_logic; 

	--alu 2 signals
	signal alu_op_2 : alu_op_type; 
	signal alu_A_2, alu_B_2 : data_type; 
	signal alu_R_2 : data_type; 
	signal alu_Z_2 : std_logic;  

	--computing signals 
	signal int_op : exec_op_type; 
	signal int_pc_in : pc_type; 
	signal int_memop_in : mem_op_type; 
	signal int_wbop_in : wb_op_type;  
	signal int_wrdata : data_type; 

begin

	alu_inst_1 : alu 
	port map(
		op => alu_op,
		A => alu_A,
		B => alu_B,
		R => alu_R,
		Z => alu_Z
	); 

	alu_inst_2 : alu
	port map(
		op => alu_op_2,
		A => alu_A_2,
		B => alu_B_2,
		R => alu_R_2,
		Z => alu_Z_2
	); 

	sync_p : process(clk, reset, flush)
	begin
		if reset = '0' then 
			--global reset
			--reset internal signals
			int_op <= EXEC_NOP; 
			int_pc_in <= (others => '0'); 
			int_memop_in <= MEM_NOP; 
			int_wbop_in <= WB_NOP; 
			int_wrdata <= (others => '0'); 

		elsif flush = '1' then 
			--flush signal
			--flush internal signals 
			int_op <= EXEC_NOP; 
			int_pc_in <= (others => '0'); 
			int_memop_in <= MEM_NOP; 
			int_wbop_in <= WB_NOP; 
			int_wrdata <= (others => '0'); 

		elsif rising_edge(clk) and stall = '0' then 
			--put through directly to ALU, ALU 1 control signals 
			int_op <= op; 
			int_pc_in <= pc_in; 
			int_memop_in <= memop_in; 
			int_wbop_in <= wbop_in; 
			int_wrdata <= (others => '0'); 
		end if; 

	end process; 
	

	logic : process(int_op, int_pc_in, int_memop_in, int_wbop_in, alu_R)
	begin
		
		if int_op.aluop = ALU_NOP then 
			pc_old_out <= (others => '0'); 
			pc_new_out <= (others => '0');
		
			wrdata <= (others => '0'); 
			aluresult <= (others => '0'); 
		else  

			--alu operation 
			alu_op <= int_op.aluop; 
			aluresult <= alu_R; 		

			--forward directly
			pc_old_out <= int_pc_in; 
			memop_out <= int_memop_in; 
			wbop_out <= int_wbop_in; 	

			wrdata <= (others => '0'); 
		
			--calculate pc+4 with other ALU
			alu_op_2 <= ALU_ADD; 
			alu_A_2(15 downto 0) <= int_pc_in; 
			alu_A_2(31 downto 16) <= (others => '0');
			alu_B_2 <= x"00000004"; 
			pc_new_out <= alu_R_2(15 downto 0);
		
		end if; 

		--R-Type instructions
		if int_op.imm_flag = '0' and int_op.store_flag = '0' and int_op.pc_flag = '0' then 
				alu_A <= int_op.readdata1;
				alu_B <= int_op.readdata2;  

		--I-Type Instructions
		elsif int_op.imm_flag = '1' and int_op.store_flag = '0' and int_op.pc_flag = '0' then 				     alu_A <= int_op.readdata1; 
				alu_B <= int_op.imm; 
		
		--S-Type Instructions
		elsif int_op.imm_flag = '0' and int_op.store_flag = '1' and int_op.pc_flag = '0' then
				--address where to store that data
				alu_A <= int_op.readdata1; 
				alu_B <= int_op.imm; 
 
				--value thats stored by memory stage
				wrdata <= int_op.readdata2; 
		
		--B-Type Instructions
		elsif int_op.imm_flag = '0' and int_op.store_flag = '0' and int_op.pc_flag = '1' then
				alu_A <= int_op.readdata1; 
				alu_B <= int_op.readdata2; 
				
				if int_op.aluop = ALU_SUB then
					--beq/neq instruction
					aluresult(31 downto 1) <= (others => '0');
					aluresult(0) <= alu_Z;  
				else 
					--blt, bltu, bge, bgeu instructions
					aluresult <= alu_R; 
				end if; 
	
				--branch target address
				alu_A_2(15 downto 0) <= int_pc_in; 
				alu_A_2(31 downto 16) <= (others => '0'); 
				alu_B_2 <= int_op.imm; 
				pc_new_out <= alu_R_2(15 downto 0);

		--UJ - Instructions (JAL)
		elsif int_op.imm_flag = '1' and int_op.store_flag = '0' and int_op.pc_flag = '1' then
				alu_A(15 downto 0) <= int_pc_in; 
				alu_A(31 downto 16) <= (others => '0'); 
				alu_B <= int_op.imm; 
				
				--pc+4 stored in rd
				wrdata <= alu_R_2(15 downto 0); 		
				wrdata(31 downto 16) <= (others => '0'); 

				--pc_new_out .. jal, so pc_in + offset
				pc_new_out <= alu_R(15 downto 0); 

		--UJ - Instructions (JALR)
		elsif int_op.imm_flag = '0' and int_op.store_flag = '1' and int_op.pc_flag = '1' then
				alu_A <= int_op.readdata1; 
				alu_B <= int_op.imm; 

				--pc+4 stored in rd
				wrdata <= alu_R_2(15 downto 0); 
				wrdata(31 downto 16) <= (others => '0'); 

				--pc_new_out .. jalr, so rs1 + offset
				pc_new_out <= alu_R(15 downto 0);

		end if; 


	end process; 
		
	
end architecture;
