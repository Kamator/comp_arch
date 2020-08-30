library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.single_clock_rw_ram_pkg.all;

entity data_st_1w is
    generic (
        SETS_LD  : natural := SETS_LD
    );
    port (
        clk       : in std_logic;
        we        : in std_logic;
        rd        : in std_logic;
        index     : in c_index_type;
        byteena   : in mem_byteena_type;
        data_in   : in mem_data_type;
        data_out  : out mem_data_type
);
end entity;

architecture impl of data_st_1w is
	constant BYTE_WIDTH : integer := 8;
	signal r_byte_one, r_byte_two : std_logic_vector(BYTE_WIDTH-1 downto 0); 
	signal r_byte_three, r_byte_four : std_logic_vector(BYTE_WIDTH-1 downto 0);
	signal w_byte_one, w_byte_two : std_logic_vector(BYTE_WIDTH-1 downto 0); 
	signal w_byte_three, w_byte_four : std_logic_vector(BYTE_WIDTH-1 downto 0);
	signal int_index : c_index_type; 
	signal int_we : std_logic; 
	signal int_byteena : mem_byteena_type;
begin

	--7 downto 0
	single_clock_rw_ram_inst_1 : single_clock_rw_ram
	generic map(
		ADDR_WIDTH => SETS_LD,  --number of sets is number of addresses of ram (usually 16) 
		DATA_WIDTH => BYTE_WIDTH --usual data size
	)
	port map(
		clk => clk, 
		data_in => w_byte_one,
		write_address  => int_index, 
		read_address => int_index,
		we => int_we,
		data_out => r_byte_one	
	);
 
	--15 downto 8
	single_clock_rw_ram_inst_2 : single_clock_rw_ram
	generic map(
		ADDR_WIDTH => SETS_LD,  --number of sets is number of addresses of ram (usually 16) 
		DATA_WIDTH => BYTE_WIDTH --usual data size
	)
	port map(
		clk => clk, 
		data_in => w_byte_two,
		write_address  => int_index, 
		read_address => int_index,
		we => int_we,
		data_out => r_byte_two	
	);

	--23 downto 16
	single_clock_rw_ram_inst_3 : single_clock_rw_ram
	generic map(
		ADDR_WIDTH => SETS_LD,  --number of sets is number of addresses of ram (usually 16) 
		DATA_WIDTH => BYTE_WIDTH --usual data size
	)
	port map(
		clk => clk, 
		data_in => w_byte_three,
		write_address  => int_index, 
		read_address => int_index,
		we => int_we,
		data_out => r_byte_three	
	);

	--31 downto 24
	single_clock_rw_ram_inst_4 : single_clock_rw_ram
	generic map(
		ADDR_WIDTH => SETS_LD,  --number of sets is number of addresses of ram (usually 16) 
		DATA_WIDTH => BYTE_WIDTH --usual data size
	)
	port map(
		clk => clk, 
		data_in => w_byte_four,
		write_address  => int_index, 
		read_address => int_index,
		we => int_we,
		data_out => r_byte_four	
	);

	sync_p : process(clk)
	begin
		
		if rising_edge(clk) then

		--byteena scheme
		--std_logic_vector is 31 downto 0, therefore "0001" is the last byte, 7 downto 0
		-- therefore "0011" is last halfword, 15 downto 0
		-- therefore "1111" is the word, 31 downto 

		/*
		w_byte_one <= (others => '0'); 
		w_byte_two <= (others => '0'); 
		w_byte_three <= (others => '0'); 
		w_byte_four <= (others => '0');  */

		int_index <= index; 
		int_we <= we; 
		int_byteena <= byteena;

		case byteena is 
			when "0001" =>  
				--read
				--data_out(7 downto 0) <= r_byte_one; 
				--write
				w_byte_one <= data_in(7 downto 0); 			

			when "0010" => 
				--read
				--data_out(7 downto 0) <= r_byte_two; 
				--write
				w_byte_two <= data_in(15 downto 8); 			
	
			when "0011" => 
				--read
				--data_out(15 downto 0) <= r_byte_two & r_byte_one; 
				--write
				w_byte_one <= data_in(7 downto 0); 
				w_byte_two <= data_in(15 downto 8); 

			when "0100" => 
				--read
				--data_out(7 downto 0) <= r_byte_three;
				--write
				w_byte_three <= data_in(23 downto 16); 	 

			when "1000" => 
				--read
				--data_out(7 downto 0) <= r_byte_four; 
				--write
				w_byte_four <= data_in(31 downto 24); 

			when "1100" => 
				--read
				--data_out(15 downto 0) <= r_byte_four & r_byte_three; 
				--write
				w_byte_four <= data_in(31 downto 24); 
				w_byte_three <= data_in(23 downto 16); 	
			
			when "1111" => 
				--read
				--data_out(31 downto 16) <= r_byte_four & r_byte_three; 
				--data_out(15 downto 0) <= r_byte_two & r_byte_one; 
				--write
				w_byte_one <= data_in(7 downto 0); 
				w_byte_two <= data_in(15 downto 8); 
				w_byte_three <= data_in(23 downto 16); 
				w_byte_four <= data_in(31 downto 24); 

			when others => 
				null; 
		end case; 
			
	end if; 

	end process;

	logic : process(all)
	begin

		data_out <= (others => '0');

		--reading of ram
		case int_byteena is 
			when "0001" =>  
				--read
				data_out(7 downto 0) <= r_byte_one; 
				--write
				--w_byte_one <= data_in(7 downto 0); 			

			when "0010" => 
				--read
				data_out(7 downto 0) <= r_byte_two; 
				--write
				--w_byte_two <= data_in(15 downto 8); 			
	
			when "0011" => 
				--read
				data_out(15 downto 0) <= r_byte_two & r_byte_one; 
				--write
				--w_byte_one <= data_in(7 downto 0); 
				--w_byte_two <= data_in(15 downto 8); 

			when "0100" => 
				--read
				data_out(7 downto 0) <= r_byte_three;
				--write
				--w_byte_three <= data_in(23 downto 16); 	 

			when "1000" => 
				--read
				data_out(7 downto 0) <= r_byte_four; 
				--write
				--w_byte_four <= data_in(31 downto 24); 

			when "1100" => 
				--read
				data_out(15 downto 0) <= r_byte_four & r_byte_three; 
				--write
				--w_byte_four <= data_in(31 downto 24); 
				--w_byte_three <= data_in(23 downto 16); 	
			
			when "1111" => 
				--read
				data_out(31 downto 16) <= r_byte_four & r_byte_three; 
				data_out(15 downto 0) <= r_byte_two & r_byte_one; 
				--write
				--w_byte_one <= data_in(7 downto 0); 
				--w_byte_two <= data_in(15 downto 8); 
				--w_byte_three <= data_in(23 downto 16); 
				--w_byte_four <= data_in(31 downto 24); 

			when others => 
				null; 
		end case; 	
	end process;
end architecture;
