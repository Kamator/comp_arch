library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
    port (
        clk, reset  : in std_logic;
        stall       : in std_logic;

        stall_fetch : out std_logic;
        stall_dec   : out std_logic;
        stall_exec  : out std_logic;
        stall_mem   : out std_logic;
        stall_wb    : out std_logic;

        flush_fetch : out std_logic;
        flush_dec   : out std_logic;
        flush_exec  : out std_logic;
        flush_mem   : out std_logic;
        flush_wb    : out std_logic;

        -- from FWD
        wb_op_mem   : in  wb_op_type; --wb thats currently in mem stage
        exec_op     : in  exec_op_type; --whats currently in exec stage

        pcsrc_in : in std_logic;
        pcsrc_out : out std_logic
    );
end ctrl;

architecture rtl of ctrl is

	signal int_wb_op_mem : wb_op_type; 
	signal int_exec_op   : exec_op_type; 
	signal int_pcsrc_in  : std_logic; 
	signal critical_reg_1  : reg_adr_type;
	signal critical_reg_2  : reg_adr_type; 
	signal st_cnt, st_cnt_nxt : unsigned(7 downto 0);  
	signal fwd_load : std_logic; 
begin

	sync_p : process(clk, reset, stall)
	begin
		if reset = '0' then 
			int_wb_op_mem <= WB_NOP; 
			int_exec_op <= EXEC_NOP; 
			int_pcsrc_in <= '0'; 
			critical_reg_1 <= (others => '0'); 
			critical_reg_2 <= (others => '0'); 
			st_cnt <= (others => '0'); 
			fwd_load <= '0'; 			

		elsif rising_edge(clk) and reset = '1' and stall = '0' then 
			int_wb_op_mem <= wb_op_mem; 
			int_exec_op <= exec_op; 
			int_pcsrc_in <= pcsrc_in; 	
			critical_reg_1 <= exec_op.rs1; 
			critical_reg_2 <= exec_op.rs2; 
			st_cnt <= st_cnt_nxt; 
	
			if wb_op_mem.src = WBS_MEM then 	
				fwd_load <= wb_op_mem.write; 
			else 
				fwd_load <= '0'; 
			end if; 
		end if; 
	end process; 

	logic : process(fwd_load, int_wb_op_mem, int_exec_op, int_pcsrc_in, critical_reg_1, critical_reg_2, st_cnt, stall, pcsrc_in)
	begin
		--default values
		stall_fetch <= '0'; 
		stall_dec   <= '0'; 	
		stall_exec  <= '0'; 
		stall_mem   <= '0'; 
		stall_wb    <= '0'; 

		flush_fetch <= '0'; 
		flush_dec   <= '0'; 
		flush_exec  <= '0'; 
		flush_mem   <= '0'; 
		flush_wb    <= '0'; 

		pcsrc_out <= int_pcsrc_in; 

		--counter
		st_cnt_nxt <= st_cnt; 

		if pcsrc_in = '1' then 
			--changed int to direct
			--branch hazard - flush fetch, dec, exec and mem
			flush_fetch <= '1'; 
			flush_dec   <= '1'; 
			flush_exec  <= '1';  
		end if; 
		
		--pipeline needs to be stalled (verzögert) if a load instruction saves a value
		--into a register that is accessed in the next instruction. Thus, the pipeline needs
		--to be stalled as long as the memu unit is busy	
  
		if stall = '1' and fwd_load = '0' then 
			--memory load occured (stall until busy = 0)
			stall_fetch <= '1'; 
			stall_dec   <= '1'; 	
			stall_exec  <= '1'; 
			stall_mem   <= '1'; 
			stall_wb    <= '1'; 
		end if;  

		if fwd_load = '1' then 	
			if st_cnt < 2 then 
				stall_fetch <= '1'; 
				stall_dec   <= '1'; 	
				stall_exec  <= '1';
				stall_mem   <= '1'; 
				st_cnt_nxt <= st_cnt + 1; 
			else
				st_cnt_nxt <= (others => '0'); 
			end if;  
		else 
			st_cnt_nxt <= (others => '0'); 
		end if; 
	end process; 
end architecture;
