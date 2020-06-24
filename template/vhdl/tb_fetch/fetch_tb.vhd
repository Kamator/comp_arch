library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch_tb is
end entity;

architecture bench of fetch_tb is

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
	end component;
	 
	signal clk, reset, stall, flush, pcsrc : std_logic;
	signal pc_in, pc_out : pc_type;
	signal instr : instr_type;
	signal mem_out : mem_out_type;
	signal mem_in : mem_in_type;
	constant CLK_PERIOD : time := 40 ns;
	signal stop_clk : boolean := false;
begin

	uut : fetch
	port map(
       clk => clk,
       reset => reset,
       stall => stall,
       flush => flush,
       mem_busy => mem_in.busy,
       pcsrc => pcsrc,
       pc_in => pc_in,
       pc_out => pc_out,
       instr => instr,
       mem_out => mem_out,
       mem_in  => mem_in
     );

	stimulus : process
	begin
		reset <= '0';
		stall <= '0';
		flush <= '0';
		pcsrc <= '0';
		pc_in <= (others => '0');
		mem_in.busy <= '0';
		mem_in.rddata <= (others => '0');
		wait for CLK_PERIOD;
		reset <= '1';
		pc_in <= (others => '0');
		mem_in.rddata <= (0 => '0', others => '0');
		wait for CLK_PERIOD;
		mem_in.rddata <= ( 31 => '1', 1 => '1', others => '0');
		stall <= '1';
		wait for CLK_PERIOD;
		stall <= '0';
				
		wait for 2*CLK_PERIOD;		
		stop_clk <= true;
		wait;
	end process;

	generate_clk : process
	begin
	    while not stop_clk loop
	    	clk <= '0', '1' after CLK_PERIOD/2;
			wait for CLK_PERIOD;
	    end loop;
	    wait;
	end process;
	
end architecture;

