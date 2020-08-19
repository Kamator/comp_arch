library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.mem_pkg.all; 
use work.core_pkg.all; 
use work.op_pkg.all;
use work.single_clock_rw_ram_pkg.all; 
use work.cache_pkg.all; 

entity data_st_tb is
end entity; 

architecture beh of data_st_tb is 
	constant CLK_PERIOD : time := 40 ns; 
	signal stop_clock : boolean := false; 
	signal clk : std_logic; 

	signal we : std_logic; 
	signal rd : std_logic; 
	signal index : c_index_type; 
	signal byteena : mem_byteena_type; 
	signal data_in : mem_data_type; 
	signal data_out : mem_data_type; 

	component data_st is 
		 generic (
       		 	SETS_LD  : natural := SETS_LD;
        		WAYS_LD  : natural := WAYS_LD
    		 );
    		 port (
        		clk       : in std_logic;
        		we        : in std_logic;
        		rd        : in std_logic;
        		way       : in c_way_type;
        		index     : in c_index_type;
        		byteena   : in mem_byteena_type;

        		data_in   : in mem_data_type;
        		data_out  : out mem_data_type
    		 );
	end component; 

begin
	
	data_st_inst : data_st
	generic map(
		SETS_LD => SETS_LD,
		WAYS_LD => WAYS_LD
	)
	port map(
		clk => clk,
		we => we, 
		rd => rd, 
		way => (others => '0'),
		index => index,
		byteena => byteena,
		data_in => data_in,
		data_out => data_out
	); 
	

	stimulus : process 
	begin
		we <= '0'; 
		rd <= '0'; 
		index <= (others => '0'); 
		byteena <= (others => '0'); 
		data_in <= (others => '0'); 
		
		wait until rising_edge(clk); 
		wait for 2*CLK_PERIOD; 
		--TESTCASE #1 write word to index "0111"
		we <= '1'; 
		rd <= '0'; 
		index <= "0111"; 
		byteena <= "1111"; 
		data_in <= x"DEADBEEF"; 
		wait for CLK_PERIOD; 
		we <= '0'; 
		rd <= '0'; 
		index <= (others => '0'); 
		byteena <= (others => '0'); 
		data_in <= (others => '0'); 
		wait for CLK_PERIOD; 
		--TESTCASE #2 read word from index "0111"
		we <= '0'; 
		rd <= '1'; 
		index <= "0111"; 
		byteena <= "1111";
		wait for CLK_PERIOD; --reading takes one cycle
		wait for CLK_PERIOD/2;  
		rd <= '0'; 
		assert data_out = x"DEADBEEF" report "TC#2 - WRONG VALUE WAS READ."; 
		wait for CLK_PERIOD/2; 
		--wait for CLK_PERIOD; 
		--TESTCASE #3 write halfword to index "0101"
		we <= '1'; 
		rd <= '0'; 
		index <= "0101"; 
		byteena <= "0011"; 
		data_in <= x"0000BEEF"; 
		wait for CLK_PERIOD; 
		we <= '0'; 
		rd <= '0'; 
		index <= (others => '0'); 
		byteena <= (others => '0'); 
		data_in <= (others => '0'); 
		wait for CLK_PERIOD; 
		--TESTCASE #4 read halfword from index "0101"
		we <= '0'; 
		rd <= '1'; 
		index <= "0101"; 
		byteena <= "0011";
		wait for CLK_PERIOD; --reading takes one cycle 
		rd <= '0'; 
		assert data_out = x"0000BEEF" report "TC#4 - WRONG VALUE WAS READ."; 
		wait for CLK_PERIOD; 
		--TESTCASE #5 write byte to index "0100"
		we <= '1'; 
		rd <= '0'; 
		index <= "0100"; 
		byteena <= "0010"; 
		data_in <= x"0000FF00"; 
		wait for CLK_PERIOD; 
		we <= '0'; 
		rd <= '0'; 
		index <= (others => '0'); 
		byteena <= (others => '0'); 
		data_in <= (others => '0'); 
		wait for CLK_PERIOD; 
		--TESTCASE #6 read byte from index "0100"
		we <= '0'; 
		rd <= '1'; 
		index <= "0100"; 
		byteena <= "0010";
		wait for CLK_PERIOD; --reading takes one cycle 
		rd <= '0';
		assert data_out = x"000000FF" report "TC#6 - WRONG VALUE WAS READ."; 
		wait for CLK_PERIOD; 
		wait; 
	end process; 

	create_clock : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD/2; 
			wait for CLK_PERIOD; 
		end loop; 
		wait; 
	end process; 

end architecture; 
