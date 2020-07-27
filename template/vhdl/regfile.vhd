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

    constant zeros : std_logic_vector(reg_adr_type'range) := (others => '0');
    signal reg_data1, reg_data2 : data_type; 
    signal reg_data1_nxt, reg_data2_nxt : data_type; 
    signal int_wrdata : data_type; 
    signal int_wraddr : reg_adr_type; 

    signal first_one : boolean := true; 

begin
    sync : process(reset, clk, stall)
    begin
        if reset = '0' then
            reg_file <= (others => (others => '0'));
	    reg_data1 <= (others => '0'); 
	    reg_data2 <= (others => '0');
		
	    int_rdaddr1 <= (others => '0'); 
	    int_rdaddr2 <= (others => '0'); 		
 
        elsif rising_edge(clk) and stall = '0' then --stall causes the circuit not to latch input values
		reg_data1 <= reg_data1_nxt; 
		reg_data2 <= reg_data2_nxt; 

		if first_one then 
			int_rdaddr1 <= (others => '0'); 
			int_rdaddr2 <= (others => '0'); 		
			first_one <= false; 
		else 
			int_rdaddr1 <= rdaddr1; 
			int_rdaddr2 <= rdaddr2; 
		end if; 

		int_wrdata <= wrdata; 
		int_wraddr <= wraddr; 

		if regwrite = '1' and wraddr /= zeros then
			reg_file(to_integer(unsigned(wraddr))) <= wrdata;
		elsif regwrite = '1' then
			reg_file(to_integer(unsigned(zeros))) <= (others => '0');
		end if;  
        
	elsif rising_edge(clk) and stall = '1' then 
		
		reg_data1 <= reg_data1_nxt; 
		reg_data2 <= reg_data2_nxt; 
		
		--just copied from above	
		if first_one then 
			int_rdaddr1 <= (others => '0'); 
			int_rdaddr2 <= (others => '0'); 		
			first_one <= false; 
		else 
			int_rdaddr1 <= rdaddr1; 
			int_rdaddr2 <= rdaddr2; 
		end if; 

		int_wrdata <= wrdata; 
		int_wraddr <= wraddr; 

		if regwrite = '1' and wraddr /= zeros then
			reg_file(to_integer(unsigned(wraddr))) <= wrdata;
		elsif regwrite = '1' then
			reg_file(to_integer(unsigned(zeros))) <= (others => '0');
		end if;  
        

	end if; 
    
    end process;

    reg_file_read : process(int_rdaddr1, int_rdaddr2, int_wrdata, int_wraddr, reg_data1, reg_data2, reg_file, stall, regwrite)
    begin

		
			--read
			rddata1 <= reg_file(to_integer(unsigned(int_rdaddr1))); 
			rddata2 <= reg_file(to_integer(unsigned(int_rdaddr2))); 

			if stall = '0' then 
				reg_data1_nxt <= reg_file(to_integer(unsigned(int_rdaddr1))); 
				reg_data2_nxt <= reg_file(to_integer(unsigned(int_rdaddr2))); 
			else 
				reg_data1_nxt <= reg_data1; 
				reg_data2_nxt <= reg_data2; 
			end if; 
		
			if stall = '0' then
			
				if int_rdaddr1 = zeros then 
					rddata1 <= (others => '0'); 
				end if; 

				if int_rdaddr2 = zeros then
					rddata2 <= (others => '0'); 
				end if; 

				if int_rdaddr1 = int_wraddr and regwrite = '1' then 
					rddata1 <= int_wrdata; 
				        reg_data1_nxt <= int_wrdata; 
			
					if int_rdaddr1 = zeros then 
						rddata1 <= (others => '0');
					end if; 
				
				end if; 

				if int_rdaddr2 = int_wraddr and regwrite = '1' then 
					rddata2 <= int_wrdata; 
					reg_data1_nxt <= int_wrdata; 

					if int_rdaddr2 = zeros then 
						rddata2 <= (others => '0');
					end if; 
				end if; 
	
			else 
				--keep old values if stalled
	
				rddata1 <= reg_data1; 
				rddata2 <= reg_data2; 
			end if; 

    end process;
    
end architecture;
