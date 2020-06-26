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
        memresult  : in  data_type;
        pc_old_in  : in  pc_type;
	pc_new_in  : in  pc_type;

        -- to FWD and DEC
        reg_write  : out reg_write_type
    );
end wb;

architecture rtl of wb is
	signal int_op : wb_op_type; 
	signal int_aluresult : data_type; 
	signal int_memresult : data_type; 
	signal int_pc_old_in : pc_type; 
	signal int_pc_new_in : pc_type; 
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
		elsif flush = '1' then	
			--flush pipeline
			int_op <= WB_NOP; 
			int_aluresult <= (others => '0'); 
			int_memresult <= (others => '0');
			int_pc_old_in <= (others => '0'); 	
			int_pc_new_in <= (others => '0'); 

		elsif rising_edge(clk) and stall = '0' then
			int_op <= op; 
			int_aluresult <= aluresult; 
			--int_memresult <= memresult; 
			int_pc_old_in <= pc_old_in; 
			int_pc_new_in <= pc_new_in; 
		end if; 
	end process; 

	logic : process(int_op, int_aluresult, memresult, int_pc_new_in, int_pc_old_in)
	begin
		reg_write.write <= '0'; 
		reg_write.reg   <= (others => '0'); 
		reg_write.data  <= (others => '0');

		if int_op.write = '1' then
			reg_write.write <= '1'; 
			reg_write.reg   <= int_op.rd; 
			
			if int_op.src = WBS_ALU then
				reg_write.data <= int_aluresult; 
			
			elsif int_op.src = WBS_MEM then 
				reg_write.data <= to_little_endian(memresult); 
			
			else 
				reg_write.data(15 downto 0) <= int_pc_new_in; 
				reg_write.data(31 downto 16) <= (others => '0'); 
			end if; 

		else 
			reg_write <= REG_WRITE_NOP; 
		end if; 
		
	end process; 

end architecture;
