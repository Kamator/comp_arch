library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
 
use work.core_pkg.all; 
use work.mem_pkg.all; 
use work.op_pkg.all; 

entity mem_tb is 
end entity; 

architecture beh of mem_tb is 

	signal clk, reset : std_logic; 
	signal stop_clock : boolean := false; 
	signal CLK_PERIOD : time := 40 ns; 
	
	signal mem_busy : std_logic; 
	signal mem_op   : mem_op_type;
        signal wbop_in       : wb_op_type;
        signal pc_new_in     :  pc_type;
        signal pc_old_in     :  pc_type;
        signal aluresult_in  :  data_type;
        signal wrdata        :  data_type;
        signal zero          :  std_logic;

        -- to EXEC (forwarding)
        signal reg_write : reg_write_type;

        -- to FETCH   
        signal pc_new_out    :  pc_type;
        signal pcsrc         :  std_logic;

        -- to WB      
        signal wbop_out      : wb_op_type;
        signal pc_old_out    : pc_type;
        signal aluresult_out : data_type;
        signal memresult     : data_type;

        -- memory controller interface
        signal mem_out       : mem_out_type;
        signal mem_in        : mem_in_type;

        -- exceptions 
        signal exc_load      : std_logic;
        signal exc_store     : std_logic; 

	component mem is 
	port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        stall         : in  std_logic;
        flush         : in  std_logic;

        -- to Ctrl    
        mem_busy      : out std_logic;

        -- from EXEC
        mem_op        : in  mem_op_type;
        wbop_in       : in  wb_op_type;
        pc_new_in     : in  pc_type;
        pc_old_in     : in  pc_type;
        aluresult_in  : in  data_type;
        wrdata        : in  data_type;
        zero          : in  std_logic;

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
	end component; 


begin

	mem_inst : mem
	port map(
		clk => clk,
		reset => reset,
		stall => '0',
		flush => '0',
		mem_busy => mem_busy,
		mem_op => mem_op,
		wbop_in => wbop_in,
		pc_new_in => pc_new_in,
		pc_old_in => pc_old_in,
		aluresult_in => aluresult_in,
		wrdata => wrdata,
		zero => zero,
		reg_write => reg_write,
		pc_new_out => pc_new_out,
		pcsrc => pcsrc,
		wbop_out => wbop_out,
		pc_old_out => pc_old_out,
		aluresult_out => aluresult_out,
		memresult => memresult,
		mem_out => mem_out,
		mem_in => mem_in,
		exc_load => exc_load,
		exc_store => exc_store
	); 

	stimulus : process
	begin
		reset <= '1'; 
		wait until rising_edge(clk); 
		wait for 2*CLK_PERIOD; 
		reset <= '0'; 
		wait for 2*CLK_PERIOD; 
		reset <= '1'; 
		wait for 3*CLK_PERIOD; 
		 
		--TESTCASE #1 -> no memory operation, no branch operation just forward values
		mem_op.branch <= BR_NOP; 
		mem_op.mem <= MEMU_NOP; 

		wbop_in.rd <= "00100"; --target register
		wbop_in.write <= '1';
		wbop_in.src <= WBS_ALU; --TELLS writeback stage to take result of AlU computation
		
		pc_new_in <= x"0020"; 
		pc_old_in <= x"0020";  --no branch target address needed to be calculated
			
		aluresult_in <= x"00000000";  --no adress was needed to be calculated
		wrdata <= x"00AA00BB"; 
		zero <= '0'; 

		wait for 2*CLK_PERIOD; 
		--to exec
		
		-- to FETCH
	
		report "TESTCASE #1"; 

		report "pc_new_out = " & integer'image(to_integer(unsigned(pc_new_out)));
		if pcsrc = '0' then report "pcsrc = 0"; else report "pcsrc = 1"; end if; 
		report "pc_old_out = " & integer'image(to_integer(unsigned(pc_old_out))); 
		report "aluresult_out = " & integer'image(to_integer(unsigned(aluresult_out))); 
		report "memresult  = " & integer'image(to_integer(unsigned(memresult))); 
		if exc_load = '0' then report "excload = 0"; else report "excload = '1'"; end if;
		if exc_store = '0' then report "exc_store = 0"; else report "exc_store = 1"; end if; 
		
		wait for 3*CLK_PERIOD; 

		--TESTCASE #2 -> store word to address $rd 		

		mem_op.branch <= BR_NOP; 
		mem_op.mem.memtype <= MEM_W; 
		mem_op.mem.memread <= '0';
		mem_op.mem.memwrite <= '1'; 

		wbop_in.rd <= "00100"; --target register
		wbop_in.write <= '1';
		wbop_in.src <= WBS_MEM; --TELLS writeback stage to take result of AlU computation
		
		pc_new_in <= x"0020"; 
		pc_old_in <= x"001c";  --no branch target address needed to be calculated
			
		aluresult_in <= x"00000AD0";  --address where to save halfword
		wrdata <= x"0000AABB"; 
		zero <= '0'; 

		wait for 2*CLK_PERIOD; 
		
		-- to FETCH

		report "TESTCASE #2";	

		report "pc_new_out = " & integer'image(to_integer(unsigned(pc_new_out)));
		if pcsrc = '0' then report "pcsrc = 0"; else report "pcsrc = 1"; end if; 
		report "pc_old_out = " & integer'image(to_integer(unsigned(pc_old_out))); 
		report "aluresult_out = " & integer'image(to_integer(unsigned(aluresult_out))); 
		report "memresult  = " & integer'image(to_integer(unsigned(memresult))); 
		if exc_load = '0' then report "excload = 0"; else report "excload = '1'"; end if;
		if exc_store = '0' then report "exc_store = 0"; else report "exc_store = 1"; end if; 
		
		wait for 3*CLK_PERIOD; 

		--TESTCASE #3 -> read halfword	

		mem_op.branch <= BR_NOP; 
		mem_op.mem.memtype <= MEM_H; 
		mem_op.mem.memread <= '1';
		mem_op.mem.memwrite <= '0'; 

		wbop_in.rd <= "00100"; --target register
		wbop_in.write <= '1';
		wbop_in.src <= WBS_MEM; --TELLS writeback stage to take result of MEM computation
		
		pc_new_in <= x"0020"; 
		pc_old_in <= x"001c";  --no branch target address needed to be calculated
			
		aluresult_in <= x"00000AD0";  --address where to save halfword
		wrdata <= x"00000000"; 
		zero <= '0'; 

		mem_in.busy <= '0'; 
		mem_in.rddata <= x"00DD00CC"; 

		wait for 2*CLK_PERIOD; 
		
		-- to FETCH

		report "TESTCASE #3";	

		report "pc_new_out = " & integer'image(to_integer(unsigned(pc_new_out)));
		if pcsrc = '0' then report "pcsrc = 0"; else report "pcsrc = 1"; end if; 
		report "pc_old_out = " & integer'image(to_integer(unsigned(pc_old_out))); 
		report "aluresult_out = " & integer'image(to_integer(unsigned(aluresult_out))); 
		report "memresult  = " & integer'image(to_integer(unsigned(memresult))); 
		if exc_load = '0' then report "excload = 0"; else report "excload = '1'"; end if;
		if exc_store = '0' then report "exc_store = 0"; else report "exc_store = 1"; end if; 
		

		wait;
	end process; 

	gen_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD/2; 
			wait for CLK_PERIOD; 
		end loop; 
		wait; 
	end process; 

end architecture; 
