--Based on https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/qts/qts_qii51007.pdf
--VHDL Single-Clock Simple Dual-Port Synchronous RAM with New Data Read-During-Write Behavior

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY single_clock_rw_ram IS
    GENERIC (
        ADDR_WIDTH : integer;
        DATA_WIDTH : integer
    );
    PORT (
        clk           : IN STD_LOGIC;
        data_in       : IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        write_address : IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
        read_address  : IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
        we            : IN STD_LOGIC;
        data_out      : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF single_clock_rw_ram IS
    TYPE MEM IS ARRAY(0 TO (2**ADDR_WIDTH)-1) OF STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    SIGNAL ram : MEM := (others => (others => '0'));
    SIGNAL read_address_reg : STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
BEGIN
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (we='1') THEN
                ram(to_integer(unsigned(write_address)))<=data_in;
            END IF;
            read_address_reg<=read_address;
        END IF;
    END PROCESS;
    data_out<=ram(to_integer(unsigned(read_address_reg)));
END ARCHITECTURE;
