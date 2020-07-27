library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.core_pkg.all; 
use work.op_pkg.all; 
use work.mem_pkg.all; 

entity ctrl_tb is 
end entity; 

architecture beh of ctrl_tb is 

	signal stop_clk : boolean := false; 
	constant CLK_PERIOD : time := 40 ns; 	

	signal clk, reset, stall : std_logic; 
	signal wb_op_mem : wb_op_type; 
	signal exec_op : exec_op_type; 
	signal pcsrc_in, pcsrc_out : std_logic; 

	signal stall_fetch : std_logic;
        signal stall_dec   : std_logic;
        signal stall_exec  : std_logic;
        signal stall_mem   : std_logic;
        signal stall_wb    : std_logic;

        signal flush_fetch : std_logic;
        signal flush_dec   : std_logic;
        signal flush_exec  : std_logic;
        signal flush_mem   : std_logic;
        signal flush_wb    : std_logic;

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
	end component ctrl; 


begin
	uut : ctrl
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
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
		wb_op_mem => wb_op_mem,
		exec_op => exec_op,
		pcsrc_in => pcsrc_in,
		pcsrc_out => pcsrc_out
	); 


	stimulus : process
	begin
		reset <= '0'; 
		stall <= '0'; 
		wb_op_mem <= WB_NOP; 
		exec_op   <= EXEC_NOP;
		pcsrc_in <= '0';  
		wait until rising_edge(clk); 
		wait for CLK_PERIOD;
		reset <= '1'; 	
	
		--TESTCASE #1 - no branch taken		
 		
		pcsrc_in <= '0'; 
	
		wait for CLK_PERIOD; 		

		assert stall_fetch = '0' report "stall_fetch != 0"; 
		assert stall_dec   = '0' report "stall_dec   != 0";
		assert stall_exec  = '0' report "stall_exec  != 0";
		assert stall_mem   = '0' report "stall_mem   != 0";
		assert stall_wb    = '0' report "stall_wb    != 0"; 

		assert flush_fetch = '0' report "flush_fetch != 0";
		assert flush_dec   = '0' report "flush_dec   != 0"; 
		assert flush_exec  = '0' report "flush_exec  != 0"; 
		assert flush_mem   = '0' report "flush_mem   != 0"; 
		assert flush_wb    = '0' report "flush_wb    != 0"; 
	
		wait for 5*CLK_PERIOD; 

		--TESTCASE #2 - branch was taken, fetch, dec and exec need to be flushed

		pcsrc_in <= '1'; 	

		wait for CLK_PERIOD; 
	
		assert stall_fetch = '0' report "stall_fetch != 0"; 
		assert stall_dec   = '0' report "stall_dec   != 0";
		assert stall_exec  = '0' report "stall_exec  != 0";
		assert stall_mem   = '0' report "stall_mem   != 0";
		assert stall_wb    = '0' report "stall_wb    != 0"; 

		assert flush_fetch = '0' report "flush_fetch != 0";
		assert flush_dec   = '0' report "flush_dec   != 0"; 
		assert flush_exec  = '0' report "flush_exec  != 0"; 
		assert flush_mem   = '0' report "flush_mem   != 0"; 
		assert flush_wb    = '0' report "flush_wb    != 0"; 
	
		wait; 
		
	end process; 

	gen_clk : process
	begin
		while not stop_clk loop
			clk <= '0', '1' after CLK_PERIOD/2; 
			wait for CLK_PERIOD; 
		end loop; 
		wait; 
	end process; 
end architecture; 
