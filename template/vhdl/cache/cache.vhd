library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.core_pkg.all;

entity cache is
    generic (
        SETS_LD   : natural          := SETS_LD;
        WAYS_LD   : natural          := WAYS_LD;
        ADDR_MASK : mem_address_type := (others => '1')
    );
    port (
        clk : in std_logic;
        reset : in std_logic;

        mem_out_cpu : in  mem_out_type;
        mem_in_cpu  : out mem_in_type;
        mem_out_mem : out mem_out_type;
        mem_in_mem  : in  mem_in_type
    );
end entity;

architecture behav of cache is 
	
	component data_st is
    generic (
        SETS_LD  : natural := SETS_LD;
        WAYS_LD  : natural := WAYS_LD
    );
    port (
        clk       : in std_logic;
        we        : in std_logic;
        rd        : in std_logic;
        way       : in c_way_type;
        index     : in c_index_type;
        byteena   : in mem_byteena_type;

        data_in   : in mem_data_type;
        data_out  : out mem_data_type
    );
	end component;
	
	component mgmt_st is
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
	end component;
	
   type CACHE_CNTRL_STATE is (IDLE, READ_CACHE, READ_MEM_START, READ_MEM, WRITE_BACK_START, WRITE_BACK);
   signal state, state_next : CACHE_CNTRL_STATE;
	signal int_mem_out_cpu, int_mem_out_cpu_nxt : mem_out_type;
	signal wr_updating_mgmt_info, rd_mgmt_info, we_updating_stored_data, rd_stored_data, valid_in, valid_out, dirty_in, dirty_out, hit_out  : std_logic;
	signal way, way_out : c_way_type;
	signal tag_in, tag_out : c_tag_type;
	signal int_index, int_index_nxt : c_index_type;
	signal index_to_mgmt : c_index_type;
	signal index_to_data : c_index_type;  
	signal int_tag, int_tag_nxt : c_tag_type; 
	signal tag_to_mgmt : c_tag_type; 
	signal byteena : mem_byteena_type;
	signal data_in, data_out : mem_data_type;
	signal int_data, int_data_nxt : data_type; 
	signal write_back_flag : std_logic;
	signal read_hit, read_hit_nxt : std_logic;
	signal valid_hit, valid_hit_nxt : std_logic;  
   constant zeros_addr : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	 data_st_inst : data_st
    generic map(
        SETS_LD => SETS_LD,
        WAYS_LD => WAYS_LD
    )
    port map (
        clk => clk,
        we  => we_updating_stored_data,
        rd  => rd_stored_data,
        way => (others => '0'),
        index => index_to_data,
        byteena => byteena,

        data_in => data_in,
        data_out => data_out
    );

	mgmt_st_inst : mgmt_st
   generic map (
        SETS_LD => SETS_LD,
        WAYS_LD => WAYS_LD
    )
    port map (
        clk => clk,
        reset => reset,

        index => index_to_mgmt,
        wr => wr_updating_mgmt_info,
        rd => rd_mgmt_info,

        valid_in => valid_in,
        dirty_in => dirty_in,
        tag_in => tag_to_mgmt,
	way_out => way_out,
        valid_out => valid_out,
        dirty_out => dirty_out,
        tag_out => tag_out,
        hit_out => hit_out
	);

	sync : process(clk, reset)
	begin
		if reset = '0' then
			state <= IDLE;
			int_mem_out_cpu <= MEM_OUT_NOP;
			way <= (others => '0');
			int_index <= (others => '0'); 
			int_tag <= (others => '0');
			int_data <= (others => '0');
			read_hit <= '0';	
			valid_hit <= '0';

		elsif rising_edge(clk) then
			state <= state_next;
			int_index <= int_index_nxt;
			int_mem_out_cpu <= int_mem_out_cpu_nxt;
			int_tag <= int_tag_nxt; 
			int_data <= int_data_nxt;
			read_hit <= read_hit_nxt;
			valid_hit <= valid_hit_nxt; 

		end if;
	end process;	
	
	fsm : process(all)
	begin
		state_next <= state;
		rd_mgmt_info <= '0';
		mem_in_cpu <= MEM_IN_NOP;
		mem_in_cpu.busy <= mem_in_mem.busy;
		data_in <= (others => '0');
		rd_stored_data <= '0';
		we_updating_stored_data <= '0';
		mem_out_mem <= MEM_OUT_NOP;
		dirty_in <= '0';
		valid_in <= '0';
		tag_in <= (others => '0');
		wr_updating_mgmt_info <= '0';
		byteena <= (others => '0');
		int_mem_out_cpu_nxt <= int_mem_out_cpu; 
		int_index_nxt <= int_index; 		
		int_tag_nxt <= int_tag; 
		index_to_mgmt <= int_index; 
		index_to_data <= int_index; 

		tag_to_mgmt <= int_tag; 
		int_data_nxt <= int_data;
		read_hit_nxt <= read_hit; 
		valid_hit_nxt <= valid_hit;


		if ((unsigned(ADDR_MASK) xor unsigned(mem_out_cpu.address)) and unsigned(mem_out_cpu.address)) /= zeros_addr then --bypass cache
			mem_in_cpu <= mem_in_mem;
			mem_out_mem <= mem_out_cpu;	
		
		else		
	
		  case state is 
			 when IDLE => --no mem request from the processor
							

				rd_mgmt_info <= '1';

				write_back_flag <= '0';

				int_mem_out_cpu_nxt <= mem_out_cpu; 
				int_index_nxt <= mem_out_cpu.address(SETS_LD-1 downto 0); 
				int_tag_nxt <= mem_out_cpu.address(ADDR_WIDTH-1 downto SETS_LD); 

				index_to_data <= mem_out_cpu.address(SETS_LD-1 downto 0);
				index_to_mgmt <= mem_out_cpu.address(SETS_LD-1 downto 0);

				tag_to_mgmt <= mem_out_cpu.address(ADDR_WIDTH-1 downto SETS_LD); 

				--use mem_out here so that the correct one is next
				if mem_out_cpu.rd = '1' then
					state_next <= READ_CACHE;

					rd_stored_data <= '1';

					read_hit_nxt <= hit_out; 
					valid_hit_nxt <= valid_out; 
					--dirty isn't important here
					
					--get data
					int_data_nxt <= data_out; 

				elsif mem_out_cpu.wr = '1' then 
					--place dirty flag 

					data_in <= mem_out_cpu.wrdata; 				
					byteena <= mem_out_cpu.byteena;
				
					mem_out_mem <= mem_out_cpu; 
				
					if hit_out = '1' then 
						--update data in cache
						wr_updating_mgmt_info <= '1';
						dirty_in <= '1';
						we_updating_stored_data <= '1';
						mem_out_mem <= MEM_OUT_NOP;			
		
					end if; 
				end if;

			when READ_CACHE => 
				write_back_flag <= '0';
				
				--to RAM/MGMT
				rd_mgmt_info <= '1';
				rd_stored_data <= '1';

				mem_in_cpu.busy <= not(read_hit);
				mem_in_cpu.rddata <= int_data; 

				if read_hit = '1' then 
					state_next <= IDLE; 
				else
					state_next <= READ_MEM_START;
				end if; 

			when READ_MEM_START => --first cycle of mem rd
				--to mem_cpu
				mem_in_cpu.busy <= '1';
				mem_in_cpu.rddata <= (others => '0'); 

				--to dmem
				mem_out_mem.rd <= '1';
				mem_out_mem.address <= int_mem_out_cpu.address;
				
				state_next <= READ_MEM; 

			 when READ_MEM => --waiting for mem req to finish and wr rslt into cache
				--to mem of cpu
				mem_in_cpu.busy <= mem_in_mem.busy;
				mem_in_cpu.rddata <= mem_in_mem.rddata;

				--some results come when busy is high....
				int_data_nxt <= mem_in_mem.rddata; 			 	
			
				--mgmt info
				tag_in <= int_mem_out_cpu.address(ADDR_WIDTH-1 downto SETS_LD);
				index_to_mgmt <= int_mem_out_cpu.address(SETS_LD-1 downto 0); 
	
				--to RAM
				byteena <= (others => '1');
				data_in <= mem_in_mem.rddata; 

				if mem_in_mem.busy = '0' then
				
					--update in RAM
					we_updating_stored_data <= '1';

					--update mgmt info 
					wr_updating_mgmt_info <= '1';

					state_next <= IDLE;
			 	end if;
	
			 when WRITE_BACK_START => --first cycle of mem wr (if dirty bit was '1')
				mem_out_mem.wr <= '1';
				mem_out_mem.address <= int_index & tag_out;
				
				state_next <= WRITE_BACK;
			 when WRITE_BACK => --finish wr op
				rd_stored_data <= '1';
				mem_out_mem.wrdata <= data_out;
				
				if mem_in_mem.busy = '0' then 
					state_next <= IDLE;
				end if;
			 when others => state_next <= IDLE;	
		end case;
		end if; 
	end process;	


end architecture;
