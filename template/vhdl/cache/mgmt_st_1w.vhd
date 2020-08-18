library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st_1w is
    generic (
        SETS_LD  : natural := SETS_LD
    );
    port (
        clk     : in std_logic;
        reset   : in std_logic;

        index   : in c_index_type;
        we      : in std_logic;
        we_repl : in std_logic;

        mgmt_info_in  : in c_mgmt_info;
        mgmt_info_out : out c_mgmt_info
);
end entity;

architecture impl of mgmt_st_1w is
    type CACHE_T is array (0 to SETS-1) of c_mgmt_info;
    signal cache : CACHE_T;
    signal int_index : c_index_type;
    --signal int_we, int_we_repl : std_logic;
    --signal int_mgmt_info_in : c_mgmt_info;

begin
    sync : process(reset, clk)
    begin
        if reset = '0' then
           cache <= (others => MGMT_NOP);
	        int_index <= (others => '0'); 
        elsif rising_edge(clk) then 
			  int_index <= index; 
	        
           if we = '1' then
              cache(to_integer(unsigned(index))) <= mgmt_info_in;
           end if;  
        
		  end if;
    
    end process;
    
    mgmt_info_out <= cache(to_integer(unsigned(int_index))); 

   
end architecture;
