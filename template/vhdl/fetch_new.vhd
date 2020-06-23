library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

use work.core_pkg.all; 
use work.op_pkg.all; 
use work.mem_pkg.all; 

entity fetch is
	port (
		clk : in std_logic;
		reset : in std_logic; 
		stall : in std_logic; 
		flush : in std_logic; 

		--to control
		mem_busy  : out std_logic; 
		
		pcsrc : in std_logic; 
		pc_in : in pc_type; 
		pc_out : out pc_type; 
		instr : out instr_type; 
		
		-- memory controller interface
		mem_out : out mem_out_type; 
		mem_in : in mem_in_type
	); 

end fetch; 

architecture rtl of fetch is 

	component alu is 
	port (
        	op   : in  alu_op_type;
        	A, B : in  data_type;
        	R    : out data_type := (others => '0');
        	Z    : out std_logic := '0'
	);
	end component; 

	signal int_pc_cnt, int_pc_cnt_nxt : pc_type; 
	signal int_zero, int_zero_nxt; 
	signal int_instr, int_instr_nxt : instr_type; 

	signal alu_A : data_type; 
	signal alu_R : data_type; 
	signal alu_Z : std_logic; 
begin

	alu_inst : alu
	port map(
		op => ALU_ADD,
		A => alu_A,
		B => x"00000004"
		R => alu_R,
		Z => alu_Z
	); 


	sync_p : process(clk, reset, stall, flush)
	begin
		if reset = '0' then 
			int_pc_cnt <= std_logic_vector(to_signed(-4,pc_type'length)); 
			int_instr <= NOP_INSTR; 
		elsif stall = '1' then 
			--tbc

		elsif flush = '1' then 
			int_instr_nxt <= NOP_INST; 

		elsif rising_edge(clk) and stall = '0' and flush = '0' then 
			int_pc_cnt <= int_pc_cnt_nxt; 
			int_instr <= int_instr_nxt; 
			int_zero <= int_zero_nxt; 
		end if; 
	
	end process; 

	logic : process(int_pc_cnt, alu_R, alu_Z, mem_in)
	begin
		alu_A <= int_pc_cnt; 
		int_pc_cnt_nxt <= alu_R(PC_WIDTH-1 downto 0); 
		
		--mem_out
		mem_out <= MEM_OUT_NOP; 
		--instr to decode
		int_instr_nxt <= int_instr; 
		instr <= int_instr; 
		--pc_out
		pc_out <= alu_R(PC_WIDTH-1 downto 0); 
		--zero flag
		int_zero_nxt <= alu_Z; 

		if mem_in.busy = '0' then
			--pass new request
			mem_out.address <= alu_R(PC_WIDTH-1 downto 0); 
			mem_out.rd <= '1'; 
			mem_out.byteena <= (others => '1'); 
			mem_out.wrdata <= (others => '0'); 

			--pass on to instr
			instr <= to_little_endian(wrdata); 
		end if; 

	end process; 

end architecture; 
