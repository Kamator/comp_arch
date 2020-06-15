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
    signal tmp_rdaddr1, tmp_rdaddr2 : reg_adr_type := (others => '0');
	 constant zeros : std_logic_vector(reg_adr_type'range) := (others => '0');
begin
    sync : process(reset, clk, stall)
    begin
        if reset = '0' then
            reg_file <= (others => (others => '0'));
            tmp_rdaddr1 <= (others => '0');
            tmp_rdaddr2 <= (others => '0');
        elsif rising_edge(clk) and stall = '0' then --stall causes the circuit not to latch input values
            tmp_rdaddr1 <= rdaddr1;
            tmp_rdaddr2 <= rdaddr2;
				if regwrite = '1' and wraddr /= zeros then
					reg_file(to_integer(unsigned(wraddr))) <= wrdata;
				end if;    
        end if;
    
    end process;
    
    reg_file_read : process(all)
    begin
        rddata1 <= reg_file(to_integer(unsigned(tmp_rdaddr1)));
        rddata2 <= reg_file(to_integer(unsigned(tmp_rdaddr2)));
        
        if tmp_rdaddr1 = wraddr and tmp_rdaddr1 /= zeros and regwrite = '1' and stall = '0' then
            rddata1 <= wrdata;
        elsif tmp_rdaddr2 = wraddr and tmp_rdaddr2 /= zeros and regwrite = '1' and stall = '0' then
            rddata2 <= wrdata;
        end if;    
    end process;
    
end architecture;
