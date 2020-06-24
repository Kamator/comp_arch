library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

use work.core_pkg.all; 
use work.op_pkg.all; 
use work.mem_pkg.all; 

entity fetch is
<<<<<<< HEAD
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
=======
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
	signal int_zero, int_zero_nxt : std_logic; 
	signal int_instr, int_instr_nxt : instr_type; 

	signal alu_A : data_type; 
	signal alu_R : data_type; 
	signal alu_Z : std_logic; 
>>>>>>> 1bdb79c0121754749f3c8a6dda672b3601aad351
begin

	alu_inst : alu
	port map(
		op => ALU_ADD,
		A => alu_A,
		B => x"00000004",
		R => alu_R,
		Z => alu_Z
	); 


	sync_p : process(clk, reset, stall, flush)
	begin
<<<<<<< HEAD
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
=======
		if reset = '0' then 
			int_pc_cnt <= std_logic_vector(to_signed(-4,pc_type'length)); 
			int_instr <= NOP_INST; 
		elsif stall = '1' then 
			--tbc

		elsif flush = '1' then 
			int_instr_nxt <= NOP_INST; 

		elsif rising_edge(clk) and stall = '0' and flush = '0' then 
			int_pc_cnt <= int_pc_cnt_nxt; 
			int_instr <= int_instr_nxt; 
			int_zero <= int_zero_nxt; 
>>>>>>> 1bdb79c0121754749f3c8a6dda672b3601aad351
		end if; 
	
	end process; 

	logic : process(int_pc_cnt, alu_R, alu_Z, mem_in, pc_in, pcsrc)
	begin
<<<<<<< HEAD
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
=======
		alu_A(PC_WIDTH-1 downto 0) <= int_pc_cnt; 
		alu_A(31 downto PC_WIDTH) <= (others => '0');
		int_pc_cnt_nxt <= alu_R(PC_WIDTH-1 downto 0); 
		
		--mem_out
		mem_out <= MEM_OUT_NOP; 

		--instr to decode
		int_instr_nxt <= int_instr; 
		instr <= int_instr; 

		--pc_out
		pc_out <= int_pc_cnt; 

		--zero flag
		int_zero_nxt <= alu_Z; 

		mem_busy <= mem_in.busy; 

		if mem_in.busy = '0' then
			--pass new request with next pc
			mem_out.address <= alu_R(ADDR_WIDTH-1 downto 0); 
			mem_out.rd <= '1'; 
			mem_out.byteena <= (others => '1'); 
			mem_out.wrdata <= (others => '0'); 

			--pass on to instr
			instr <= to_little_endian(mem_in.rddata); 
		end if;  

		if pcsrc = '1' then 
			int_pc_cnt_nxt <= pc_in; 
		end if; 

	end process; 

end architecture; 
>>>>>>> 1bdb79c0121754749f3c8a6dda672b3601aad351
