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
        pc_old_in     : in  pc_type;     --will be passed on 
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

--result of memory load can come WITHIN the same cycle or IN THE NEXT cycle (if cashed) OTHERWISE
--as soon as mem_busy gets low 

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

	--INTERNAL LOGIC 
	signal int_mem_op : mem_op_type; 
	signal int_wbop_in : wb_op_type; 
	signal int_pc_new_in : pc_type; 
	signal int_pc_old_in : pc_type; 
	signal int_aluresult_in : data_type; 
	signal int_wrdata : data_type; 
	signal int_memresult, int_memresult_nxt : data_type;  
	
	--MEMU
	signal memu_address : data_type; 
	signal memu_wrdata : data_type; 
	signal memu_response : data_type; 
	signal memu_busy : std_logic; 
	signal memu_xl : std_logic; 
	signal memu_xs : std_logic; 

	constant addr_threshold : unsigned := x"00002000"; 
	
begin

	memu_inst : memu
	port map(
		op => int_mem_op.mem,
		A => memu_address,
		W => memu_wrdata,
		R => memu_response,
		B => memu_busy,
		XL => memu_xl,
		XS => memu_xs,
		D => mem_in,
		M => mem_out
	); 	

	sync_p : process(clk, flush, stall, reset)
	begin
		if reset = '0' then 
			int_mem_op <= MEM_NOP; 
			int_pc_old_in <= (others => '0'); 
			int_pc_new_in <= (others => '0'); 
			int_wbop_in <= WB_NOP; 
			int_aluresult_in <= (others => '0'); 
			int_wrdata <= (others => '0');
			int_memresult <= (others => '0'); 
			int_memresult <= (others => '0'); 
		
		elsif flush = '1' then
			int_mem_op <= MEM_NOP; 
			int_pc_old_in <= (others => '0'); 
			int_pc_new_in <= (others => '0'); 
			int_wbop_in <= WB_NOP; 
			int_aluresult_in <= (others => '0'); 
			int_wrdata <= (others => '0');
			int_memresult <= (others => '0'); 
			int_memresult <= (others => '0'); 
		
		elsif rising_edge(clk) and stall= '0' then 
			int_mem_op <= mem_op; 
			int_wbop_in <= wbop_in; 
			int_pc_new_in <= pc_new_in; 
			int_pc_old_in <= pc_old_in; 
			int_aluresult_in <= aluresult_in; 
			int_wrdata <= wrdata; 
			int_memresult <= int_memresult_nxt; 
		
		elsif rising_edge(clk) and stall = '1' then
			int_mem_op.mem.memread <= '0';
			int_mem_op.mem.memwrite <= '0';	
			int_memresult <= int_memresult_nxt; 	
		end if; 
		
	end process; 

	pc_p : process(int_pc_new_in, int_aluresult_in, int_mem_op)
	begin
	
		pc_new_out <= int_pc_new_in; 


		if unsigned(int_aluresult_in) /= 0 and int_mem_op.branch /= BR_NOP then 
			--branch is taken
			pcsrc <= '1'; 
		else 	
			--branch is not taken
			pcsrc <= '0'; 
		end if; 
		
	end process; 


	reg_write_p : process(stall, wbop_in, memu_response, int_aluresult_in, mem_op, int_wbop_in, int_mem_op, aluresult_in, int_memresult)
	begin
		--might be wbop.. not sure
		reg_write.reg <= wbop_in.rd; 
		reg_write.write <= '0'; 
		reg_write.data <= (others => '0'); 
		
		if stall = '1' then 

			reg_write.reg <= int_wbop_in.rd; 

			--might be wbop... not sure... because if stalled the corr package is int
			if int_wbop_in.write = '1' and int_wbop_in.src = WBS_MEM then 
				reg_write.write <= '1'; 
				reg_write.data <= memu_response;

				if unsigned(int_aluresult_in) > addr_threshold then 
					reg_write.data <= int_memresult; 
				end if;  

			else 
				reg_write.write <= '0';
				reg_write.data <= (others => '0');
			end if;  
	
		else 
			--if timing problem, check here
			if wbop_in.write = '1' and wbop_in.src = WBS_MEM then 
				reg_write.write <= '1'; 
				reg_write.data <= memu_response; 
				
			elsif wbop_in.write = '1' and wbop_in.src = WBS_ALU then 
			
				reg_write.write <= '1'; 
	
				if mem_op.branch /= BR_NOP then 
					reg_write.data <= int_memresult; 
				else 
					reg_write.data <= aluresult_in; 
				end if; 
			end if; 
		end if; 
	end process; 

	read_write_p : process(memu_xl, memu_xs, int_wrdata, int_memresult, int_wbop_in, int_pc_old_in, int_aluresult_in, memu_busy, memu_response, int_mem_op, stall)
	begin	
		int_memresult_nxt <= int_memresult; 
		
		memresult <= int_memresult; 
		wbop_out <= int_wbop_in; 	
		pc_old_out <= int_pc_old_in; 
		aluresult_out <= int_aluresult_in; 
		mem_busy <= memu_busy; 
	
		exc_load <= memu_xl; 
		exc_store <= memu_xs;
		

		if stall = '1' then 
			--if pipeline is stalled and memresult needs to be kept alive
			int_memresult_nxt <= int_memresult; 
		else
			int_memresult_nxt <= (others => '0');
		end if;

		if int_mem_op.mem.memread = '1' then
			mem_busy <= '1'; 
			memu_address <= int_aluresult_in; 
			memu_wrdata <= (others => '0'); 
			--response can come in the next cycle! --> alway stall when mem-access
			int_memresult_nxt <= memu_response; 
	
		elsif int_mem_op.mem.memwrite = '1' then 
			mem_busy <= '0'; 
			memu_address <= int_aluresult_in; 
			memu_wrdata <= int_wrdata; 	
		else 
			memu_address <= (others => '0'); 
			memu_wrdata <= (others => '0'); 
		end if; 

	end process; 

end architecture; 


