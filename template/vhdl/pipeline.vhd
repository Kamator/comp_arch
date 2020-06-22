library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;
use work.pipeline_pkg.all; 

entity pipeline is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;

        -- instruction interface
        mem_i_out    : out mem_out_type;
        mem_i_in     : in  mem_in_type;

        -- data interface
        mem_d_out    : out mem_out_type;
        mem_d_in     : in  mem_in_type
    );
end pipeline;

architecture impl of pipeline is
	--pc stuff
	signal pc_to_fetch : pc_type; 
	signal pc_from_fetch : pc_type; 
	signal pc_from_decode : pc_type; 
	signal pc_old_from_ex : pc_type;
	signal pc_new_from_ex : pc_type; 
	signal pc_new_from_mem : pc_type; 
	signal pc_old_from_mem : pc_type; 

	--op stuff
	signal exec_op : exec_op_type; 
	signal mem_op : mem_op_type; 
	signal wb_op  : wb_op_type; 

	signal mem_op_from_ex : mem_op_type; 
	signal wb_op_from_ex : wb_op_type; 

	signal wb_op_from_mem : wb_op_type; 


	--other stuff
	signal instr : instr_type; 
	signal mem_data_out : mem_out_type; 
	signal mem_data_in  : mem_in_type; 
	signal reg_write : reg_write_type; 
	signal stall : std_logic; 
	signal exc_dec : std_logic; 
	signal aluresult : data_type; 
	signal wrdata : data_type; 
	signal zero : std_logic; 
	signal pcsrc : std_logic;
        signal aluresult_from_mem : data_type; 
	signal memresult : data_type; 	
	signal exc_load : std_logic; 
	signal exc_store : std_logic; 
begin

	fetch_inst : fetch
	port map(
		clk => clk,
		reset => reset,
		stall => stall, 
		flush => '0',
		mem_busy => open,
		pc_in => pc_to_fetch,
		pc_out => pc_from_fetch,
		instr => instr,
		mem_out => mem_d_out,
		mem_in  => mem_d_in
	);

	decode_inst : decode
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
		flush => '0',
		pc_in => pc_from_fetch,
		instr => instr,
		reg_write => reg_write,
		pc_out => pc_from_decode,
		exec_op => exec_op,
		mem_op => mem_op,
		wb_op => wb_op,
		exc_dec => exc_dec
	);

	exec_inst : exec 
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
		flush => '0',
		op => exec_op,
		pc_in => pc_from_decode,
		pc_old_out => pc_old_from_ex,
		pc_new_out => pc_new_from_ex,
		aluresult => aluresult,
		wrdata => wrdata,
		zero => zero,
		memop_in => mem_op,
		memop_out => mem_op_from_ex,
		wbop_in => wb_op,
		wbop_out => wb_op_from_ex,
		exc_op => open,
		reg_write_mem => REG_WRITE_NOP,
		reg_write_wr => reg_write_wr
	); 

	mem_inst : mem
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
		flush => '0',
		mem_busy => open,
		mem_op => mem_op_from_ex,
		wbop_in => wb_op_from_ex,
		pc_new_in => pc_new_from_ex,
		pc_old_in => pc_old_from_ex,
		aluresult_in => aluresult,
		wrdata => wrdata,
		zero => zero,
		reg_write => open,
		pc_new_out => pc_new_from_mem,
		pcsrc => pcsrc,
		wbop_out => wb_op_from_mem,
		pc_old_out => pc_old_from_mem,
		aluresult_out => aluresult_from_mem,
		memresult => memresult,
		mem_out => mem_d_out,
		mem_in  => mem_d_in,
		exc_load => exc_load,
		exc_store => exc_store
	); 

	wb_inst : wb
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
		flush => '0',
		op => wb_op_from_mem,
		aluresult => aluresult_from_mem,
		memresult => memresult,
		pc_old_in => pc_old_from_mem,
		pc_new_in => pc_new_from_mem,
		reg_write => reg_write
	); 

	stall_logic : process(mem_d_in) 
	begin
		if mem_d_in.busy = '0' then 
			stall = '0'; 
		else 
			stall = '1'; 
		end if; 
	end process; 

end architecture;
