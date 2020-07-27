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

	signal int_pc_cnt_nxt : pc_type; 
	signal int_pc_cnt : pc_type; 
	signal int_instr, int_instr_nxt : instr_type; 
	signal flush_appeared, flush_appeared_nxt : std_logic; 

begin
	sync_p : process(clk, reset, stall, flush, int_pc_cnt_nxt, pcsrc)
	begin
		if reset = '0' then 
			int_pc_cnt <= std_logic_vector(to_signed(-4,pc_type'length)); 
			int_instr <= NOP_INST; 
		
		elsif rising_edge(clk) and flush = '1' and reset = '1' then 
			int_instr <= NOP_INST; 
			int_pc_cnt <= int_pc_cnt_nxt; 			

		elsif rising_edge(clk) and stall = '0' and flush = '0' and pcsrc = '0' then 
			int_pc_cnt <= int_pc_cnt_nxt; 
			int_instr <= int_instr_nxt; 
		
		elsif rising_edge(clk) and stall = '0' and flush = '0' and pcsrc = '1' then 
			--branch the next instruction
			int_pc_cnt <= pc_in; 
			int_instr <= int_instr_nxt; 
		end if; 
	
	end process; 

	logic : process(int_pc_cnt,mem_in, pc_in, pcsrc, int_instr, reset, flush)
	begin


		if pcsrc = '0' and flush = '0' then 
			int_pc_cnt_nxt <= std_logic_vector(unsigned(int_pc_cnt) + 4);

		/*elsif pcsrc = '1' and flush = '0' then 
			int_pc_cnt_nxt <= pc_in; */
			
		else 
			--should not happen
			int_pc_cnt_nxt <= (others => '0'); 
		end if; 
		
		--mem_out
		mem_out <= MEM_OUT_NOP; 

		--instr to decode
		int_instr_nxt <= int_instr; 
		instr <= int_instr; 

		--pc_out
		pc_out <= int_pc_cnt; 

		mem_busy <= mem_in.busy; 

		if mem_in.busy = '0'  then
			--removed "and flush = '0'"
			--pass new request with next pc
			if flush = '0' then 
				mem_out.address <= std_logic_vector(unsigned(int_pc_cnt(15 downto 2))+1); 
			else 
				mem_out.address <= std_logic_vector(unsigned(int_pc_cnt(15 downto 2)));
			end if; 
			
			if pcsrc = '0' and flush = '0' then 
				mem_out.rd <= '1'; 
			
			elsif pcsrc = '1' and flush = '1' then 
				mem_out.rd <= '1'; 
				
			else
				mem_out.rd <= '0'; 
				
			end if; 

			mem_out.byteena <= (others => '1'); 
			mem_out.wrdata <= (others => '0'); 

			/*if pcsrc = '1' then 
				--if the next instruction has to be branched
				mem_out.address <= pc_in(15 downto 2);

			end if; */
	

			--pass on to instr
			instr <= to_little_endian(mem_in.rddata);  
		end if;  

		/*if pcsrc = '1' then 
			int_pc_cnt_nxt <= pc_in; 
		end if; */

	end process; 

end architecture; 
