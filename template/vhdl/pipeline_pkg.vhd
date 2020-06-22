library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

--component declarations for pipeline.vhd

package pipeline_pkg is 

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

end package; 
