library ieee;
use ieee.std_logic_1164.all;

use work.mem_pkg.all;

package cache_pkg is
    constant WAYS_LD : natural := 0;
    constant SETS_LD : natural := 4;
    constant INDEX_SIZE : natural :=SETS_LD;
    constant TAG_SIZE : natural :=ADDR_WIDTH-INDEX_SIZE;
    constant WAYS : natural := 2**WAYS_LD;
    constant SETS : natural := 2**SETS_LD;
    subtype ways_range is natural range 0 to WAYS-1;
    subtype sets_range is natural range 0 to SETS-1;

    subtype c_tag_type is std_logic_vector(TAG_SIZE-1 downto 0);
    subtype c_index_type is std_logic_vector(INDEX_SIZE-1 downto 0);
    subtype c_way_type is std_logic_vector(WAYS_LD-1 downto 0);

    type c_mgmt_info is record
        valid : std_logic;
        dirty : std_logic;
        replace : std_logic;
        tag : c_tag_type;
    end record;
	 
	 constant MGMT_NOP : c_mgmt_info := (
		'0',
		'0',
		'0',
		(others => '0')
	 );
end package;
