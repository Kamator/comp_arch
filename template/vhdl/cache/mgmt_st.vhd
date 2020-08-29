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
    signal index_to_mgmt : c_index_type;
    signal int_wr, int_rd, int_valid, int_dirty : std_logic := '0';
    signal int_tag : c_tag_type := (others => '0'); 
    signal update_mgmt_info : std_logic; 
    signal int_mgmt_info_in, mgmt_info_in, int_mgmt_info_out, reg_mgmt_info_out, mgmt_info_out : c_mgmt_info := MGMT_NOP;
begin

    mgmt_st_1w_inst : mgmt_st_1w
    generic map(
        SETS_LD => SETS_LD
    )
    port map(
        clk  => clk,
        reset => reset,

        index => index_to_mgmt,
        we => update_mgmt_info,
        we_repl => '0',

        mgmt_info_in => mgmt_info_in,
        mgmt_info_out => mgmt_info_out
    );


mpx : process(all)
begin
	index_to_mgmt <= index;
	mgmt_info_in <= MGMT_NOP;
  	way_out <= (others => '0'); 
	tag_out <= (others => '0');
	valid_out <= '0';
	hit_out <= '0';
	dirty_out <= '0';	
 	
        if wr = '1' then
    	  -- store --> write hit (an entry will get dirty)
    	
       		if mgmt_info_out.tag = tag_in and mgmt_info_out.valid = '1' then
        		tag_out <= int_tag;     --nice to know for cache (but not necessary)
        		valid_out <= int_valid; --valid will be zero now
        		hit_out <= '1';         --write hit (some entry is now dirty)
        
			--update mgmt info entry
  			update_mgmt_info <= '1';
			mgmt_info_in.valid <= valid_in; 
			mgmt_info_in.dirty <= dirty_in;	
			mgmt_info_in.replace <= '0';
			mgmt_info_in.tag <= tag_in; 
    		end if;

	-- not(int_tag = tag and mgmt_info.valid = 1)
	-- by deMorgan's Rule
	-- int_tag != tag or mgmt_info.valid = 0
    
    --store --> write miss (no entry will get dirty)
    		if mgmt_info_out.valid = '0' or int_mgmt_info_out.tag /= int_tag then
        		tag_out <= mgmt_info_out.tag;
        		valid_out <= mgmt_info_out.valid;
			dirty_out <= mgmt_info_out.dirty;
      			hit_out <= '0';
   		 end if;

  elsif rd = '1' then

    -- load --> read hit
    if mgmt_info_out.tag = tag_in and mgmt_info_out.valid = '1' then
        tag_out <= mgmt_info_out.tag;
	dirty_out <= mgmt_info_out.dirty;
        valid_out <= mgmt_info_out.valid;
        hit_out <= '1';    
    end if;
    
    --load --> read miss
    if mgmt_info_out.tag /= int_tag then
        tag_out <= mgmt_info_out.tag;
        valid_out <= mgmt_info_out.valid;
	dirty_out <= mgmt_info_out.dirty;
        hit_out <= '0';

    end if;

 end if;
end process;

/*
sync : process (clk, reset)
begin
    if reset = '0' then 
        index_to_mgmt  <= (others => '0');
	int_index <= (others => '0');
        int_wr <= '0';
        int_rd <= '0';
        int_valid <= '0';
        int_dirty <= '0';
        int_tag <= (others => '0');   
        int_mgmt_info_in <= MGMT_NOP;

    elsif rising_edge(clk) then
        int_index <= index;
	index_to_mgmt <= index;
        int_wr <= wr;
        int_rd <= rd;
        int_valid <= valid_in;
        int_dirty <= dirty_in;
        int_tag <= tag_in;    
        int_mgmt_info_out <= mgmt_info_out;
    end if;
end process;
*/
/*
--mem address - ADDRESS_WIDTH := 14:  1101 0110 0010 11 --> INDEX: 1011 & TAG_SIZE := 10: 1101 0110 00
logic: process(all)
begin
  tag_out <= (others => '0');
  valid_out <= '0';
  hit_out <= '0';
  dirty_out <= '0';
  way_out <= (others => '0'); 
  mgmt_info_in <= MGMT_NOP;
  update_mgmt_info <= '0';

  --always fully define mgmt_info_in (needed in lower level)
  --store --> entry present & valid?

  if int_wr = '1' then
    -- store --> write hit (an entry will get dirty)
    if int_mgmt_info_out.tag = int_tag and int_mgmt_info_out.valid = '1' then
        tag_out <= int_tag;     --nice to know for cache (but not necessary)
        valid_out <= int_valid; --valid will be zero now
        hit_out <= '1';         --write hit (some entry is now dirty)
        
	--update mgmt info entry
  	update_mgmt_info <= '1';
	mgmt_info_in.valid <= int_valid; 
	mgmt_info_in.dirty <= int_dirty;	
	mgmt_info_in.replace <= '0';
	mgmt_info_in.tag <= int_tag; 
 
    end if;

	-- not(int_tag = tag and mgmt_info.valid = 1)
	-- by deMorgan's Rule
	-- int_tag != tag or mgmt_info.valid = 0
    
    --store --> write miss (no entry will get dirty)
    if int_mgmt_info_in.valid = '0' or int_mgmt_info_out.tag /= int_tag then
        tag_out <= int_tag;
        valid_out <= int_valid;
	dirty_out <= '0';
        hit_out <= '0';
        
    end if;

    
  elsif rd = '1' then

    -- load --> read hit
    if int_mgmt_info_out.tag = int_tag and int_mgmt_info_out.valid = '1' then
        tag_out <= int_tag;
	dirty_out <= int_mgmt_info_out.dirty;
        valid_out <= int_mgmt_info_out.valid;
        hit_out <= '1';    
    end if;
    
    --load --> read miss
    if int_mgmt_info_out.tag /= int_tag then
        tag_out <= int_mgmt_info_out.tag;
        valid_out <= int_mgmt_info_out.valid;
	dirty_out <= int_mgmt_info_out.dirty;
        hit_out <= '0';

    end if;

 end if;


end process;
*/
end architecture;
