library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity mem is
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- to Ctrl
        mem_busy      : out std_logic;

        -- from EXEC
        mem_op        : in  mem_op_type; --was passed
        wbop_in       : in  wb_op_type;  --will be passed on
        pc_new_in     : in  pc_type;     --will be passed on
        pc_old_in     : in  pc_type;	 --will be passed on 
        aluresult_in  : in  data_type;   --result of computation (also adressess) 
        wrdata        : in  data_type;   --some byte/halfword/word that needs to be saved
        zero          : in  std_logic;   --zero flag 

        -- to EXEC (forwarding)
        reg_write     : out reg_write_type;

        -- to FETCH
        pc_new_out    : out pc_type;   
        pcsrc         : out std_logic;

        -- to WB
        wbop_out      : out wb_op_type;
        pc_old_out    : out pc_type;
        aluresult_out : out data_type;
        memresult     : out data_type;

        -- memory controller interface
        mem_out       : out mem_out_type;
        mem_in        : in  mem_in_type;

        -- exceptions
        exc_load      : out std_logic;
        exc_store     : out std_logic
    );
end mem;

architecture rtl of mem is
	
	component memu is 
	   port (
       		-- to mem
      		op   : in  memu_op_type; --access type
        	A    : in  data_type;    --address
        	W    : in  data_type;    --write data (one word) 
        	R    : out data_type := (others => '0');  --result of mem access

        	B    : out std_logic := '0'; --busy
        	XL   : out std_logic := '0'; --load exception
        	XS   : out std_logic := '0';  --store exception

        	-- to memory controller
        	D    : in  mem_in_type; --interface from memory (result of access)
        	M    : out mem_out_type := MEM_OUT_NOP --interface to memory (to start access)
    		);
	end component;

/*	--signals to memu
	signal memu_op : memu_op_type; 
	signal memu_A, memu_W, memu_R : data_type; 
	signal memu_B, memu_XL, memu_XS : std_logic; 
	signal memu_D : mem_in_type; 
	signal memu_M : mem_out_type;  */

	--internal signals 
	signal int_mem_op : MEM_OP_TYPE; 
	signal int_wbop_in : WB_OP_TYPE; 
	signal int_pc_new_in : PC_TYPE; 
	signal int_pc_old_in : PC_TYPE; 
	signal int_aluresult_in : DATA_TYPE; 
	signal int_wrdata : DATA_TYPE; 
	signal int_zero : std_logic; 
	signal int_mem_in : MEM_IN_TYPE; 

	--internal signals for memu 
	signal int_A, int_W, int_R : data_type; 
	signal int_B, int_XL, int_XS : std_logic; 
	signal int_D : mem_in_type; 
	signal int_M : mem_out_type; 

begin
	memu_inst : memu
	port map(
		op => int_mem_op.mem,
		A => int_aluresult_in,
		W => int_wrdata,
		R => memresult,
		B => mem_busy, 
		XL => exc_load,
		XS => exc_store,
		D => mem_in,
		M => mem_out
	); 
	
	sync_p : process(clk, reset, stall, flush)
	begin
		if reset = '0' then 
			--reset
			int_mem_op <= MEM_NOP;
			int_pc_old_in <= (others => '0');  
			int_wbop_in <= WB_NOP; 
			int_aluresult_in <= (others => '0'); 
			int_wrdata <= (others => '0'); 
	
		elsif flush = '1' then 
			--flush
			int_mem_op <= MEM_NOP; 
			int_D <= MEM_IN_NOP; 
			int_M <= MEM_OUT_NOP; 

		elsif rising_edge(clk) and stall = '0' and flush = '0' then 
			--sync
			int_mem_op <= mem_op; 
			int_wbop_in <= wbop_in; 
			int_pc_new_in <= pc_new_in; 
			int_pc_old_in <= pc_old_in; 	 
			int_aluresult_in <= aluresult_in; 
			int_wrdata <= wrdata; 	

		elsif stall = '1' then 
			int_mem_op.mem.memread <= '0';
			int_mem_op.mem.memwrite <= '0'; 

		end if;	
	end process; 

	logic : process(all)
	begin
		--send to subsequent pipeline stages
		pc_new_out <= int_pc_new_in; 
		wbop_out <= int_wbop_in; 
		pc_old_out <= int_pc_old_in; 
		aluresult_out <= int_aluresult_in; 

		reg_write.reg <= int_wbop_in.rd; 
		reg_write.write <= '0'; 
		reg_write.data <= (others => '0');

		pcsrc <= '0'; 

		if int_mem_op.branch = BR_BR or int_mem_op.branch = BR_CND or int_mem_op.BR_CNDI then
			if to_integer(unsigned(int_aluresult_in)) = 1 then
				pcsrc <= '1';
			else 
				pcsrc <= '0'; 
			end  if; 
		end if; 
		
		/*
		if int_mem_op.branch = BR_NOP and memu_B = '0' then

			mem_busy <= '0'; 			

			--pass memtype to memu
			memu_op <= int_mem_op.mem;
			memu_A <= int_aluresult_in; 
			memu_W <= int_wrdata; 
				
			
			
			--only read/write if stall is low
			/*if stall = '0' and int_aluresult_in /= x"00000000" then 
				memu_op.memread <= int_mem_op.mem.memread; 
				memu_op.memwrite <= int_mem_op.mem.memwrite; 
			else 
				memu_op.memread <= '0'; 
				memu_op.memwrite <= '0'; 
			end if; */
			
			memresult <= memu_R; 
			exc_load <= memu_XL; 
			exc_store <= memu_XS; 
		
			memu_D <= int_mem_in;  		
	
		elsif memu_B = '1' and int_mem_op.branch = BR_NOP then 
			mem_busy <= '1'; 		
				
		else 
			mem_busy <= '0'; 
			--branch thingy 
			if to_integer(unsigned(int_aluresult_in)) = 1 then
				--branch taken
				pcsrc <= '1';  
			else
				pcsrc <= '0'; 
			end if; 
		end if;  */
	end process; 	
end architecture;
