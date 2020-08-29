library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st is
    generic (
        SETS_LD  : natural := SETS_LD;
        WAYS_LD  : natural := WAYS_LD
    );
    port (
        clk     : in std_logic;
        reset   : in std_logic;

        index   : in c_index_type;
        wr      : in std_logic;
        rd      : in std_logic;

        valid_in   : in std_logic;
        dirty_in   : in std_logic;
        tag_in     : in c_tag_type;
        way_out    : out c_way_type;
        valid_out  : out std_logic;
        dirty_out  : out std_logic;
        tag_out    : out c_tag_type;
        hit_out    : out std_logic
);
end entity;


--todo: 
--accessing the correct set 
--deciding whether an access is a HIT (tag comparison)
--handling updates for the management info (valid, dirty,..)
--searching for entries in all ways 
--keeping track of the replacement info

--store (writing to mem) --> check if corresponding entry is present and valid in the cache (ie read access to management information)
-- --> case of an write HIT: management info might have to be updated (dirty flag)

--load (read to the mem) --> check if corresponding entry is present and valid in the cache 
-- --> might require a write to the management info 


architecture impl of mgmt_st is

    component mgmt_st_1w is
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
    end component;

    signal int_index : c_index_type := (others => '0');
    signal int_wr, int_rd, int_valid, int_dirty : std_logic := '0';
    signal int_tag : c_tag_type := (others => '0'); 
    signal int_mgmt_info_in, mgmt_info_in, int_mgmt_info_out, reg_mgmt_info_out, mgmt_info_out : c_mgmt_info := MGMT_NOP;
begin

    mgmt_st_1w_inst : mgmt_st_1w
    generic map(
        SETS_LD => SETS_LD
    )
    port map(
        clk  => clk,
        reset => reset,

        index => index,
        we => int_wr,
        we_repl => '0',

        mgmt_info_in => mgmt_info_in,
        mgmt_info_out => mgmt_info_out
    );

sync : process (clk, reset)
begin
    if reset = '0' then 
        int_index <= (others => '0');
        int_wr <= '0';
        int_rd <= '0';
        int_valid <= '0';
        int_dirty <= '0';
        int_tag <= (others => '0');   
        int_mgmt_info_in <= MGMT_NOP;
    elsif rising_edge(clk) then
        int_index <= index;
        int_wr <= wr;
        int_rd <= rd;
        int_valid <= valid_in;
        int_dirty <= dirty_in;
        int_tag <= tag_in;    
        mgmt_info_out <= int_mgmt_info_out;
        int_mgmt_info_in <= mgmt_info_in;
	     reg_mgmt_info_out <= int_mgmt_info_out;
    end if;
end process;

--mem address - ADDRESS_WIDTH := 14:  1101 0110 0010 11 --> INDEX: 1011 & TAG_SIZE := 10: 1101 0110 00
process(all)
begin
  tag_out <= (others => '0');
  valid_out <= '0';
  hit_out <= '0';
  dirty_out <= '0';
  int_mgmt_info_out <= MGMT_NOP;
  way_out <= (others => '0');
  
  --store --> entry present & valid?
  if wr = '1' then
    -- store --> write hit
    if int_mgmt_info_in.tag = int_tag and int_mgmt_info_in.valid = '1' then
        tag_out <= int_tag;
        valid_out <= int_valid;
        hit_out <= '1';
        
        if int_mgmt_info_in.dirty = '0' then
            int_mgmt_info_out.dirty <= '1';
            dirty_out <= '1';
        end if;
        
        int_mgmt_info_out.valid <= int_valid;
        int_mgmt_info_out.tag <= int_tag;       
    
    end if;
    
    --store --> write miss
    if int_mgmt_info_in.valid = '0' then
        tag_out <= int_tag;
        valid_out <= int_valid;
        hit_out <= '0';
        
        int_mgmt_info_out.dirty <= '0';
        dirty_out <= '0';
                
        int_mgmt_info_out.valid <= int_valid;
        int_mgmt_info_out.tag <= int_tag;

    end if;

    if int_mgmt_info_in.tag /= int_tag then
		  tag_out <= reg_mgmt_info_out.tag;
        valid_out <= reg_mgmt_info_out.valid;
        hit_out <= '0';
       	int_mgmt_info_out.dirty <= reg_mgmt_info_out.dirty;    
        int_mgmt_info_out.valid <= reg_mgmt_info_out.valid;
        int_mgmt_info_out.tag <= reg_mgmt_info_out.tag;
    end if;
    
  elsif rd = '1' then
    -- load --> read hit
    if int_mgmt_info_in.tag = int_tag and int_mgmt_info_in.valid = '1' then
        tag_out <= int_tag;
        valid_out <= int_valid;
        hit_out <= '1';
        int_mgmt_info_out.valid <= int_valid;
        int_mgmt_info_out.tag <= int_tag;       
    
    end if;
    
    --load --> read miss
    if int_mgmt_info_in.valid = '0' then
        tag_out <= int_tag;
        valid_out <= int_valid;
        hit_out <= '0';                
        int_mgmt_info_out.valid <= int_valid;
        int_mgmt_info_out.tag <= int_tag;

    end if;

    if int_mgmt_info_in.tag /= int_tag then
	     tag_out <= reg_mgmt_info_out.tag;
        valid_out <= reg_mgmt_info_out.valid;
        hit_out <= '0';
       	int_mgmt_info_out.dirty <= reg_mgmt_info_out.dirty;    
        int_mgmt_info_out.valid <= reg_mgmt_info_out.valid;
        int_mgmt_info_out.tag <= reg_mgmt_info_out.tag;
    end if;
  end if;


end process;

end architecture;
