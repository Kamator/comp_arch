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
	signal int_pc_cnt, int_pc_cnt_nxt : pc_type; 
	signal int_instr : instr_type; 
	signal read : std_logic;
 
begin

	sync_p : process(clk, reset, stall, flush, pcsrc, mem_in, pc_in) 
	begin 
		if reset = '0' then 
			int_pc_cnt <= std_logic_vector(to_signed(-4, pc_type'length)); 
			int_instr <= NOP_INST; 
			read <= '1'; 
		

		elsif rising_edge(clk) and flush = '1' and stall = '0' then 
			int_pc_cnt <= int_pc_cnt_nxt; 
			int_instr <= NOP_INST; 
			read <= '1'; 	
	

		elsif rising_edge(clk) and flush = '0' and stall = '0' then 
			--regular mode 
			int_instr <= to_little_endian(mem_in.rddata); 
			read <= '1'; 	
			int_pc_cnt <= int_pc_cnt_nxt; 

		end if; 
	end process; 

	mem_logic : process(mem_in, int_pc_cnt, read, flush, stall, pcsrc, pc_in)
	begin

		mem_out <= MEM_OUT_NOP; 		

		mem_busy <= mem_in.busy; 

		if mem_in.busy = '0' then 
			mem_out.rd <= read;  

			mem_out.byteena <= (others => '1'); 
			mem_out.wrdata <= (others => '0'); 
		
			--has to be next instruction to fetch
			if stall = '0' then 
				mem_out.address <= std_logic_vector(unsigned(int_pc_cnt(15 downto 2))+1);
			else 
				mem_out.address <= std_logic_vector(unsigned(int_pc_cnt(15 downto 2)));  
			end if; 	
	
			if pcsrc = '1' then 
				mem_out.address <= std_logic_vector(unsigned(pc_in(15 downto 2)));
			end if; 

		end if; 
		
	end process; 

	instr_logic : process(int_instr, int_pc_cnt, mem_in, pc_in, pcsrc)
	begin
		instr <= NOP_INST; 
		pc_out <= x"FFFC"; 

	if int_pc_cnt /= x"FFFC" then 
		instr <= int_instr;  
		pc_out <= std_logic_vector(unsigned(int_pc_cnt)-4); 

		int_pc_cnt_nxt <= std_logic_vector(unsigned(int_pc_cnt)+4); 
		
		if pcsrc = '1' then 
			int_pc_cnt_nxt <=std_logic_vector(unsigned(pc_in)); 
			pc_out <= pc_in; 
		end if; 
	else
		int_pc_cnt_nxt <= std_logic_vector(unsigned(int_pc_cnt)+4); 
	end if;  

	end process; 

end architecture; 

