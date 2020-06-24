library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- to control
        mem_busy   : out std_logic;

        pcsrc      : in  std_logic;
        pc_in      : in  pc_type;
        pc_out     : out pc_type := (others => '0');
        instr      : out instr_type;

        -- memory controller interface
        mem_out   : out mem_out_type;
        mem_in    : in  mem_in_type
    );
end fetch;

architecture rtl of fetch is
	signal prg_cnt, prg_cnt_next : pc_type;
	signal int_instr : instr_type;
	signal int_pc_cnt : pc_type;  
begin

	sync : process(reset, clk)
	begin
		if reset = '0' then 
			mem_busy <= '0';
			prg_cnt <= std_logic_vector(to_signed(-4, pc_type'LENGTH));
			int_instr <= (others => '0');
			int_pc_cnt <= (others => '0');
		elsif rising_edge(clk) and stall = '0' then
		   prg_cnt <= prg_cnt_next;
			int_instr <= mem_in.rddata;
			int_pc_cnt <= std_logic_vector(unsigned(prg_cnt_next) - 4);   
		end if;
	end process;
	

	prg_cnt_proc : process(stall, pcsrc, prg_cnt, pc_in)
	begin
		prg_cnt_next <= prg_cnt; 
		instr <= NOP_INST; 
		pc_out <= prg_cnt;
		if stall = '0' and pcsrc = '1' and reset = '1' then
			-- branch was taken
			pc_out <= pc_in; 
			prg_cnt_next <= pc_in;	 
		elsif stall = '0' and pcsrc = '0' and reset = '1' then 
			prg_cnt_next <= std_logic_vector(unsigned(prg_cnt) + 4); 
			pc_out <= int_pc_cnt; 
			instr <= to_little_endian(int_instr);	
		end if; 
	end process; 

	/*program_counter : process(all)
	begin
		prg_cnt_next <= prg_cnt;
		instr <= NOP_INST; 

		if stall = '0' and pcsrc = '1' then
			prg_cnt_next <= pc_in;
			prg_cnt_next <= prg_cnt;
			instr <= NOP_INST;
		elsif stall = '0' and pcsrc = '0' then
			prg_cnt_next <= std_logic_vector(unsigned(prg_cnt) + 4);
			pc_out <= prg_cnt;
			instr <= to_little_endian(int_instr);
		end if;	
	end process; */
	
	flush_proc : process(pcsrc, mem_in, prg_cnt)
	begin		
		if mem_in.busy = '1' then 
			mem_out <= MEM_OUT_NOP; 
		else
			mem_out.rd <= '1';
			mem_out.address <= prg_cnt(13 downto 0);
			mem_out.wr <= '0';
			mem_out.byteena <= (others => '1');
			mem_out.wrdata <= (others => '0');
		end if;	
	end process;
	
end architecture;
