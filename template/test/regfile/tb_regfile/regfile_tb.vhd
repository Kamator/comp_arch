library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pkg.all;

entity regfile_tb is
end entity;

architecture bench of regfile_tb is

    component regfile is
    port (
        clk              : in  std_logic;
        reset            : in  std_logic;
        stall            : in  std_logic;
        rdaddr1, rdaddr2 : in  reg_adr_type;
        rddata1, rddata2 : out data_type;
        wraddr           : in  reg_adr_type;
        wrdata           : in  data_type;
        regwrite         : in  std_logic
    );
    end component;
	signal clk, reset, stall, regwrite : std_logic;
	signal rdaddr1, rdaddr2, wraddr : reg_adr_type;
	signal rddata1, rddata2, wrdata : data_type;
	constant CLK_PERIOD : time := 40 ns;
	signal stop_clk : boolean := false;
begin

	uut : regfile
	port map(
          clk => clk,
          reset => reset,
          stall => stall,
          rdaddr1 => rdaddr1,
          rdaddr2 => rdaddr2,
          rddata1 => rddata1,
			 rddata2 => rddata2,
          wraddr => wraddr,
          wrdata => wrdata,
          regwrite => regwrite 
        );

	stimulus : process
	begin
		reset <= '0';
		stall <= '0';
		rdaddr1 <= (others => '0');
		rdaddr2 <= (others => '0');
		regwrite <= '0';
		wraddr <= (others => '0');
		wrdata <= (others => '0');
		wait until rising_edge(clk);
		reset <= '1';
		rdaddr1 <= "00000";
		rdaddr2 <= "00000";
		regwrite <= '1';
		wraddr <= "00000";
		wrdata <= x"000000FF";
		wait until rising_edge(clk);
		rdaddr1 <= "00001";
		wraddr <= "00001";
		wrdata <= x"000000AB";
		wait until rising_edge(clk);
		rdaddr1 <= "00000";
		rdaddr2 <= "00001";
		wraddr <= "00010";
		wrdata <= x"000000CD";
		wait until rising_edge(clk);
		rdaddr1 <= "00001";
		rdaddr2 <= "00010";
		regwrite <= '0';
		wrdata <= x"000000EF";
		wait until rising_edge(clk);
		stall <= '1';
		rdaddr1 <= "00000";
		regwrite <= '1';
		wraddr <= "00001";
		wrdata <= x"00000055";
		wait until rising_edge(clk);
		stall <= '0';
		rdaddr2 <= "00001";
		wrdata <= x"00000007";
		wait until rising_edge(clk);
		wraddr <= "00000";
		wait for CLK_PERIOD/4;
		wraddr <= "00001";
		wrdata <= x"00000033";
		wait until falling_edge(clk);
		wait for CLK_PERIOD/4;
		rdaddr1 <= "00010";
		rdaddr2 <= "00000";
		wraddr <= "00000";
		wrdata <= x"00000011";
		wait for CLK_PERIOD;
		wraddr <= "00010";
		wrdata <= x"00000044";
		
		
		
		wait for CLK_PERIOD;
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

