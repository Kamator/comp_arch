library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;

entity regfile is
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
end entity;

architecture rtl of regfile is
    type REG_MEMORY is array (0 to REG_COUNT-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_file : REG_MEMORY := (others => (others => '0'));
    signal int_rdaddr1, int_rdaddr2 : reg_adr_type := (others => '0');
	 signal latch_rdaddr1, latch_rdaddr2 : reg_adr_type := (others => '0');
	 signal int_rddata1, int_rddata2 : data_type := (others => '0');
	 constant zeros : std_logic_vector(reg_adr_type'range) := (others => '0');
	 constant x_addr : std_logic_vector(reg_adr_type'range) := (others => 'X');
begin
    sync : process(reset, clk, stall)
    begin
        if reset = '0' then
            reg_file <= (others => (others => '0'));
            latch_rdaddr1 <= (others => '0');
				latch_rdaddr2 <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then --stall causes the circuit not to latch input values
            latch_rdaddr1 <= int_rdaddr1;
            latch_rdaddr2 <= int_rdaddr2;
				if regwrite = '1' and wraddr /= zeros then
					reg_file(to_integer(unsigned(wraddr))) <= wrdata;
				else
					reg_file(to_integer(unsigned(zeros))) <= (others => '0');
				end if;    
        end if;
    
    end process;
	 
	 int_rdaddr1 <= rdaddr1;
	 int_rdaddr2 <= rdaddr2;
	 rddata1 <= int_rddata1;
	 rddata2 <= int_rddata2;
    
    reg_file_read : process(all)
    begin
		if stall = '0' and int_rdaddr1 /= x_addr and int_rdaddr2 /= x_addr and reset = '1' then
			int_rddata1 <= reg_file(to_integer(unsigned(int_rdaddr1)));
			int_rddata2 <= reg_file(to_integer(unsigned(int_rdaddr2)));
		  
			if int_rdaddr1 = wraddr and int_rdaddr1 /= zeros and regwrite = '1' then
				int_rddata1 <= wrdata;
			elsif int_rdaddr2 = wraddr and int_rdaddr2 /= zeros and regwrite = '1' then
            int_rddata2 <= wrdata;
			end if;
		end if;		
    end process;
    
end architecture;
