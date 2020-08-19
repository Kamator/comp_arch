library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;


entity wb is
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from MEM
        op         : in  wb_op_type;
        aluresult  : in  data_type;
        memresult  : in  data_type; --is not little endian! 
        pc_old_in  : in  pc_type;
	pc_new_in  : in  pc_type;

        -- to FWD and DEC
        reg_write  : out reg_write_type
    );
end wb;

architecture rtl of wb is
	signal int_op : wb_op_type; 
	signal int_aluresult : data_type; 
	signal int_memresult, int_memresult_nxt : data_type; 
	signal int_pc_old_in : pc_type; 
	signal int_pc_new_in : pc_type; 
	signal old_stall, old_stall_nxt : std_logic; 
begin

	sync_p : process(clk, reset, stall, flush)
	begin
		if reset = '0' then 
			--global reset
			int_op <= WB_NOP; 
			int_aluresult <= (others => '0'); 
			int_memresult <= (others => '0');
			int_pc_old_in <= (others => '0'); 	
			int_pc_new_in <= (others => '0'); 
			old_stall <= '0'; 

		elsif flush = '1' then	
			--flush pipeline
			int_op <= WB_NOP; 
			int_aluresult <= (others => '0'); 
			int_memresult <= (others => '0');
			int_pc_old_in <= (others => '0'); 	
			int_pc_new_in <= (others => '0'); 
			old_stall <= '0'; 

		elsif rising_edge(clk) and stall = '0' then
			int_op <= op; 
			int_aluresult <= aluresult; 
			int_memresult <= to_little_endian(memresult); 
			int_pc_old_in <= pc_old_in; 
			int_pc_new_in <= pc_new_in; 
			old_stall <= old_stall_nxt; 

		elsif rising_edge(clk) and stall = '1' then 
			old_stall <= old_stall_nxt; 
			int_memresult <= int_memresult_nxt; 	
		end if;  
	end process; 


	logic : process(int_memresult, op, aluresult, memresult, pc_new_in, pc_old_in, stall, old_stall)
	begin

		if stall = '1' then 
			int_memresult_nxt <= to_little_endian(memresult); 
		
		elsif stall = '0' and old_stall = '1' then 
			--try this elsif
			int_memresult_nxt <= int_memresult;  
		else 
			int_memresult_nxt <= (others => '0'); 
		end if; 

		reg_write.write <= '0'; 
		reg_write.reg   <= op.rd; 
		reg_write.data  <= (others => '0');

		old_stall_nxt <= stall; 

		if op.write = '1' then
			reg_write.write <= '1'; 
			--reg_write.reg   <= int_op.rd; 
			
			if op.src = WBS_ALU then
				reg_write.data <= aluresult; 
			
			elsif op.src = WBS_MEM then 
				reg_write.data <= to_little_endian(memresult); 
		
				if stall = '0' and old_stall = '1' then 	
					reg_write.data <= int_memresult; 
				end if; 
			
			elsif op.src = WBS_OPC then 
				--JAL/JALR
 				reg_write.data <= aluresult; 
				--reg_write.data(15 downto 0) <= pc_new_in; 
				--reg_write.data(31 downto 16) <= (others => '0'); 
			end if; 

		else 
			reg_write <= REG_WRITE_NOP; 
		end if; 
		
	end process; 
end architecture;
