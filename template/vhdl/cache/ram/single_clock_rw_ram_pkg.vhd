library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package single_clock_rw_ram_pkg is

    component single_clock_rw_ram is
        generic (
            ADDR_WIDTH : integer;
            DATA_WIDTH : integer
        );
        port (
            clk           : in std_logic;
            data_in       : in std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
            write_address : in std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
            read_address  : in std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
            we            : in std_logic;
            data_out      : out std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
        );
    end component;

end package;
