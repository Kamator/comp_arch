library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;
--use work.pipeline_pkg.all; 

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

	signal stall : std_logic; 	

	--pc stuff
	signal pc_to_fetch : pc_type; 
	signal pc_from_fetch : pc_type; 
	signal pc_from_decode : pc_type; 
	signal pc_old_from_ex : pc_type;
	signal pc_new_from_ex : pc_type; 
	signal pc_new_from_mem : pc_type; 
	signal pc_old_from_mem : pc_type; 

	--op stuff
	signal exec_op_from_dec : exec_op_type; 
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
	signal exc_dec : std_logic; 
	signal aluresult : data_type; 
	signal wrdata : data_type; 
	signal zero : std_logic; 
	signal pcsrc : std_logic;
        signal aluresult_from_mem : data_type; 
	signal memresult : data_type; 	
	signal exc_load : std_logic; 
	signal exc_store : std_logic; 

	--stall and flush logic
	signal stall_fetch : std_logic; 
	signal stall_dec : std_logic; 
	signal stall_exec : std_logic;
	signal stall_mem : std_logic; 
	signal stall_wb : std_logic; 
	
	signal flush_fetch : std_logic; 
	signal flush_dec : std_logic; 
	signal flush_exec : std_logic; 
	signal flush_mem : std_logic; 
	signal flush_wb : std_logic; 
	
	signal dmem_busy_to_stall : std_logic; 
	signal imem_busy_to_stall : std_logic; 
	signal busy_to_stall : std_logic; 

	--forwarding
	signal exec_op_to_fwd : exec_op_type; 	
	signal reg_write_mem_to_fwd : reg_write_type; 
      	signal reg_write_mem, reg_write_wr : reg_write_type; 
	signal val1, val2 : data_type;
   	signal do_fwd1, do_fwd2 : std_logic; 
	
	component fetch is 
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
	end component fetch; 

	component decode is
    	port (
        clk, reset : in  std_logic;
        stall      : in  std_logic;
        flush      : in  std_logic;

        -- from fetch
        pc_in      : in  pc_type;
        instr      : in  instr_type;

        -- from writeback
        reg_write  : in reg_write_type;

        -- towards next stages
        pc_out     : out pc_type;
        exec_op    : out exec_op_type;
        mem_op     : out mem_op_type;
        wb_op      : out wb_op_type;

        -- exceptions
        exc_dec    : out std_logic
    	);
	end component decode;


	component exec is
    	port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- from DEC
        op            : in  exec_op_type;
        pc_in         : in  pc_type;

        -- to MEM
        pc_old_out    : out pc_type;
        pc_new_out    : out pc_type;
        aluresult     : out data_type; --result of ALU computation
        wrdata        : out data_type; --value that might be stored to memory (not SRAM!)
        zero          : out std_logic;

        memop_in      : in  mem_op_type;
        memop_out     : out mem_op_type; --forwarded to MEM stage
        wbop_in       : in  wb_op_type;
        wbop_out      : out wb_op_type;  --forwarded to WB stage

        -- FWD
        exec_op       : out exec_op_type;
        reg_write_mem : in  reg_write_type;
        reg_write_wr  : in  reg_write_type
    	);
	end component exec;

	component mem is
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
	end component mem;

	component wb is
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
	end component wb;

	component ctrl is
	port(
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
        wb_op_mem   : in  wb_op_type;
        exec_op     : in  exec_op_type;

        pcsrc_in : in std_logic;
        pcsrc_out : out std_logic

	); 
	end component; 
	
	component fwd is
    port (
        -- from Mem
        reg_write_mem : in reg_write_type;

        -- from WB
        reg_write_wb  : in reg_write_type;

        -- from/to EXEC
        reg    : in  reg_adr_type;
        val    : out data_type;
        do_fwd : out std_logic
    );
	end component;   

begin

	fwd_inst_1 : fwd
   	port map(
        	reg_write_mem => reg_write_mem_to_fwd,
        	reg_write_wb => reg_write,
        	reg => exec_op_to_fwd.rs1,
        	val => val1,
        	do_fwd => do_fwd1
    	);
    
   	fwd_inst_2 : fwd
   	port map(
        	reg_write_mem => reg_write_mem_to_fwd,
        	reg_write_wb => reg_write,
        	reg => exec_op_to_fwd.rs2,
        	val => val2,
        	do_fwd => do_fwd2
   	);	
	
	fwd_mpx : process(do_fwd1, do_fwd2, val1, val2, reg_write, exec_op_to_fwd)
	--27.07 changed sensitivity list
	begin
	
		
		reg_write_wr <= REG_WRITE_NOP; 
		reg_write_mem <= REG_WRITE_NOP; 
	
		if do_fwd1 = '1' then 
			
			if reg_write.reg = exec_op_to_fwd.rs1 then		
				reg_write_wr.write <= '1'; 
				reg_write_wr.reg <= exec_op_to_fwd.rs1; 
				reg_write_wr.data <= val1; 

			else
				reg_write_mem.write <= '1'; 
				reg_write_mem.reg <= exec_op_to_fwd.rs1; 
				reg_write_mem.data <= val1; 

			end if; 
		end if; 

		if do_fwd2 = '1' then 
			
			if reg_write.reg = exec_op_to_fwd.rs2 then		
				reg_write_wr.write <= '1'; 
				reg_write_wr.reg <= exec_op_to_fwd.rs2; 
				reg_write_wr.data <= val2; 
		 
			else
				reg_write_mem.write <= '1'; 
				reg_write_mem.reg <= exec_op_to_fwd.rs2; 
				reg_write_mem.data <= val2;

			end if; 

		end if; 
	end process; 
	
	mpx_stall : process(imem_busy_to_stall, dmem_busy_to_stall)
	begin
		if imem_busy_to_stall = '1' or dmem_busy_to_stall = '1' then 
			busy_to_stall <= '1'; 
		else 
			busy_to_stall <= '0'; 
		end if; 

	end process; 


	ctrl_inst : ctrl
	port map(
		clk => clk,
		reset => reset, 
		stall => busy_to_stall,
		stall_fetch => stall_fetch,
		stall_dec => stall_dec,
		stall_exec => stall_exec,
		stall_mem => stall_mem,
		stall_wb => stall_wb,
		flush_fetch => flush_fetch,
		flush_dec => flush_dec,
		flush_exec => flush_exec,
		flush_mem => flush_mem,
		flush_wb => flush_wb,
		wb_op_mem => wb_op_from_mem, 
		exec_op => exec_op_to_fwd,
		--until fwd is finished
		pcsrc_in => pcsrc,
		pcsrc_out => open
	); 

	fetch_inst : fetch
	port map(
		clk => clk,
		reset => reset,
		stall => stall_fetch, 
		flush => flush_fetch,
		mem_busy => imem_busy_to_stall,
		pcsrc => pcsrc,
		pc_in => pc_new_from_mem,
		pc_out => pc_from_fetch,
		instr => instr,
		mem_out => mem_i_out,
		mem_in  => mem_i_in
	);

	decode_inst : decode
	port map(
		clk => clk,
		reset => reset,
		stall => stall_dec,
		flush => flush_dec,
		pc_in => pc_from_fetch,
		instr => instr,
		reg_write => reg_write,
		pc_out => pc_from_decode,
		exec_op => exec_op_from_dec,
		mem_op => mem_op,
		wb_op => wb_op,
		exc_dec => exc_dec
	);

	exec_inst : exec 
	port map(
		clk => clk,
		reset => reset,
		stall => stall_exec,
		flush => flush_exec,
		op => exec_op_from_dec,
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
		exec_op => exec_op_to_fwd,
		reg_write_mem => reg_write_mem,
		reg_write_wr => reg_write_wr
	); 

	mem_inst : mem
	port map(
		clk => clk,
		reset => reset,
		stall => stall_mem,
		flush => flush_mem,
		mem_busy => dmem_busy_to_stall,
		mem_op => mem_op_from_ex,
		wbop_in => wb_op_from_ex,
		pc_new_in => pc_new_from_ex,
		pc_old_in => pc_old_from_ex,
		aluresult_in => aluresult,
		wrdata => wrdata,
		zero => zero,
		reg_write => reg_write_mem_to_fwd,
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
		stall => stall_wb,
		flush => flush_wb,
		op => wb_op_from_mem,
		aluresult => aluresult_from_mem,
		memresult => memresult,
		pc_old_in => pc_old_from_mem,
		pc_new_in => pc_new_from_mem,
		reg_write => reg_write
	); 

end architecture;
