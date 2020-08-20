library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
    port (
        -- to mem
        op   : in  memu_op_type; --access type
        A    : in  data_type;    --address
        W    : in  data_type;    --write data (one word) 
        R    : out data_type := (others => '0');  --result of mem access

        B    : out std_logic := '0'; --busy
        XL   : out std_logic := '0'; --load exception
        XS   : out std_logic := '0';  --store exception

        -- to memory controller
        D    : in  mem_in_type; --interface from memory (result of access)
        M    : out mem_out_type := MEM_OUT_NOP --interface to memory (to start access)
    );
end memu;

/**
* Designed by Philipp Geisler
* e11775812@student.tuwien.ac.at
*
**/

/*
	Documentation
	mem_op_type => read, write, memtype
		memtype => b, bu, h, hu, w
	interface dmem operates on word access (pipeline in byte access)

*/

architecture rtl of memu is
begin
	logic : process (all)
	begin
	
	--no latches
	M <= MEM_OUT_NOP; 
	B <= D.busy; 
	XS <= '0'; 
	XL <= '0';  
	R <= to_little_endian(D.rddata); 

	--try this for result tracking
	
	if op.memtype = MEM_BU then 	
				--unsigned values /* 
		
				if A(1 downto 0) = "00" then 
					--first byte accessed, others zero
					R <= x"000000" & D.rddata(31 downto 24);
				elsif A(1 downto 0) = "01" then 
					--second byte accessed, others zero
					R <= x"000000" & D.rddata(23 downto 16); 
				elsif A(1 downto 0) = "10" then 
					--third byte accessed, others zero
					R <= x"000000" & D.rddata(15 downto 8); 
				elsif A(1 downto 0) = "11" then 
					--fourth byte accessed, others zero
					R <= x"000000" & D.rddata(7 downto 0); 
				end if; 

				/*
				if A(1 downto 0) = "00" then 
					--first byte accessed, others zero
					R <= D.rddata(31 downto 24) & x"000000";
				elsif A(1 downto 0) = "01" then 
					--second byte accessed, others zero
					R <= D.rddata(23 downto 16) & x"000000"; 
				elsif A(1 downto 0) = "10" then 
					--third byte accessed, others zero
					R <= D.rddata(15 downto 8) & x"000000"; 
				elsif A(1 downto 0) = "11" then 
					--fourth byte accessed, others zero
					R <= D.rddata(7 downto 0) & x"000000"; 
				end if;
				*/
				
		end if; 
 
	
	if op.memread = '1' and D.busy = '0' then 

		--read access to memory
		M.wr <= '0'; 	 
		--therefore no store exception possible
		XS <= '0'; 
		M.byteena <= (others => '-'); 
		M.wrdata  <= (others => '-'); 
		
		--&"00" because the word address is needed
		--M.address <= A(ADDR_WIDTH-1 downto 2) & "00"; 
		
		if signed(A) > 0 then 
			M.address <= "00" & A(ADDR_WIDTH-1 downto 2); 
		else 
			M.address <= "11" & A(ADDR_WIDTH-1 downto 2); 
		end if; 
	
		case op.memtype is 

			when MEM_B => 

				--no load exception when accessing single bytes
				XL <= '0'; 
				M.rd <= '1';
 
				--keep signed values
				if A(1 downto 0) = "00" then 
					--first byte accessed (msb due to endianness)
					R (7 downto 0)   <= D.rddata(31 downto 24); 
					--get the sign bit
					R (31 downto 8)  <= (others => D.rddata(31)); 
				elsif A(1 downto 0) = "01" then 
					--second byte accessed
					R (7 downto 0)   <= D.rddata(23 downto 16); 
					--get the sign bit
					R (31 downto 8)  <= (others => D.rddata(23)); 
				elsif A(1 downto 0) = "10" then 
					--third byte accessed
					R (7 downto 0)   <= D.rddata(15 downto 8); 
					--get the sign bit
					R (31 downto 8)  <= (others => D.rddata(15)); 
				elsif A(1 downto 0) = "11" then 
					--fourth byte accessed
					R (7 downto 0)   <= D.rddata(7 downto 0); 
					--get the sign bit
					R (31 downto 8)  <= (others => D.rddata(7)); 
				end if; 

			when MEM_BU => 

				--no load exception when accessing single bytes
				XL <= '0'; 
				M.rd <= '1'; 

				--unsigned values 
				if A(1 downto 0) = "00" then 
					--first byte accessed, others zero
					R <= x"000000" & D.rddata(31 downto 24);
				elsif A(1 downto 0) = "01" then 
					--second byte accessed, others zero
					R <= x"000000" & D.rddata(23 downto 16); 
				elsif A(1 downto 0) = "10" then 
					--third byte accessed, others zero
					R <= x"000000" & D.rddata(15 downto 8); 
				elsif A(1 downto 0) = "11" then 
					--fourth byte accessed, others zero
					R <= x"000000" & D.rddata(7 downto 0); 
				end if; 
			
			when MEM_H => 
				--halfword, signed values

				if A(1 downto 0) = "00" or A(1 downto 0) = "01" then 
					--first halfword accessed
					R (7 downto 0)   <= D.rddata(31 downto 24); 
					R (15 downto 8)  <= D.rddata(23 downto 16);
					--get the sign bit 
					R (31 downto 16) <= (others => D.rddata(31)); 

					--load exception 
					if A(1 downto 0) = "01" then 
						XL <= '1'; 
						M.rd <= '0'; 
					else 
						XL <= '0'; 
						M.rd <= '1'; 
					end if; 

				elsif A(1 downto 0) = "10" or A(1 downto 0) = "11" then 
				 	--second halfword accessed
					R (7 downto 0)   <= D.rddata(15 downto 8);
					R (15 downto 8)  <= D.rddata(7 downto 0); 
					--get the sign bit
					R (31 downto 16) <= (others => D.rddata(15)); 

 					--load exception 
					if A(1 downto 0) = "11" then 
						XL <= '1'; 
						M.rd <= '0'; 
					else 
						XL <= '0'; 
						M.rd <= '1'; 
					end if; 

				end if; 

			when MEM_HU => 
				--halfword, unsigned values

				if A(1 downto 0) = "00" or A(1 downto 0) = "01" then
					--first halfword accessed
					R (7 downto 0)   <= D.rddata(31 downto 24); 
					R (15 downto 8)  <= D.rddata(23 downto 16); 
					R (31 downto 16) <= (others => '0'); 

					--load exception 
					if A(1 downto 0) = "01" then 
						XL <= '1'; 
						M.rd <= '0'; 
					else 
						XL <= '0'; 
						M.rd <= '1'; 
					end if; 

				elsif A(1 downto 0) = "10" or A(1 downto 0) = "11" then 
					--second halfword accessed
					R (7 downto 0)   <= D.rddata(15 downto 8); 
					R (15 downto 8)  <= D.rddata(7 downto 0); 
					R (31 downto 16) <= (others => '0');
					
					--load exception 
					if A(1 downto 0) = "11" then 
						XL <= '1'; 
						M.rd <= '0'; 
					else 
						XL <= '0'; 
						M.rd <= '1'; 
					end if;

				end if; 

			when MEM_W => 
				--word
		
				R (7 downto 0)   <= D.rddata(31 downto 24); 
				R (15 downto 8)  <= D.rddata(23 downto 16); 
				R (23 downto 16) <= D.rddata(15 downto 8); 
				R (31 downto 24) <= D.rddata(7 downto 0); 		
			
				--load exception
				if A(1 downto 0) = "01" or A(1 downto 0) = "10" or A(1 downto 0) = "11" then 
					XL <= '1'; 
					M.rd <= '0'; 
				else 
					XL <= '0'; 
					M.rd <= '1'; 
				end if; 
		
			end case; 
			
	elsif op.memwrite = '1' then 
		--write access to memory occurs here
		M.rd <= '0'; 	
		M.wr <= '1'; 	
		R <= (others => '0'); 
		--therefore no load exceptions possible
		XL <= '0'; 

		--&"00" because the word address is needed
 		--M.address <= A(ADDR_WIDTH-1 downto 2) & "00";  

		if signed(A) > 0 then 
			M.address <= "00" & A(ADDR_WIDTH-1 downto 2); 
		else 
			M.address <= "11" & A(ADDR_WIDTH-1 downto 2); 
		end if;
 
		case op.memtype is 
			when MEM_B | MEM_BU => 
				--no load exception when loading single bytes
				XL <= '0'; 

				if A(1 downto 0) = "00" then 
					--first byte accessed
					--little endian => transmit ls byte
					M.byteena <= "1000"; 
					M.wrdata (31 downto 24) <= W(7 downto 0); 
					M.wrdata (23 downto 0)  <= (others => '-'); 

				elsif A(1 downto 0) = "01" then 
					--second byte accessed
					--little endian => transmit ls byte
					M.byteena <= "0100"; 
					M.wrdata (31 downto 24) <= (others => '-'); 
					M.wrdata (23 downto 16) <= W(7 downto 0); 
					M.wrdata (15 downto 0)  <= (others => '-'); 					
				elsif A(1 downto 0) = "10" then 
					--third byte accessed
					--little endian => transmit ls byte
					M.byteena <= "0010"; 
					M.wrdata (31 downto 16) <= (others => '-'); 
					M.wrdata (15 downto 8)  <= W(7 downto 0); 
					M.wrdata (7 downto 0)   <= (others => '-'); 
	
				elsif A(1 downto 0) = "11" then 
					--fourth byte accessed
					--little endian => transmit ls byte
					M.byteena <= "0001"; 
					M.wrdata (31 downto 8) <= (others => '-'); 
					M.wrdata (7 downto 0)  <= W(7 downto 0); 
				end if; 
			
			when MEM_H | MEM_HU => 
				if A(1 downto 0) = "00" or A(1 downto 0) = "01" then 
					--first halfword accessed
					--little endian => transmit ls halfword
					M.byteena <= "1100"; 
					M.wrdata (31 downto 24) <= W(7 downto 0); 
					M.wrdata (23 downto 16) <= W(15 downto 8); 
					M.wrdata (15 downto 0)  <= (others => '-'); 
					
					--store exception
					if A(1 downto 0) = "01" then 
						XS <= '1'; 
						M.wr <= '0';  --no writing that raises an exception
					else 
						XS <= '0'; 
						M.wr <= op.memwrite; 
					end if; 
				

				elsif A(1 downto 0) = "10" or A(1 downto 0) = "11" then 
					--second halfword accessed
					--little endian => transmit ls halfword 
					M.byteena <= "0011"; 
					M.wrdata (31 downto 16) <= (others => '-'); 
					M.wrdata (15 downto 8)  <= W(7 downto 0); 
					M.wrdata (7 downto 0)   <= W(15 downto 8); 

					--store exception
					if A(1 downto 0) = "11" then 
						XS <= '1'; 
						M.wr <= '0'; 
					else 
						XS <= '0'; 
						M.wr <= op.memwrite; 
					end if; 
				end if; 

			when MEM_W => 
				--whole word is accessed	
		 		M.byteena <= "1111"; 
				--to little endian
				M.wrdata (31 downto 24) <= W(7 downto 0); 
				M.wrdata (23 downto 16) <= W(15 downto 8); 
				M.wrdata (15 downto 8)  <= W(23 downto 16); 
				M.wrdata (7 downto 0)   <= W(31 downto 24); 
		
				--store exception
				if A(1 downto 0) = "01" or A(1 downto 0) = "10" or A(1 downto 0) = "11" then
					XS <= '1'; 
					M.wr <= '0'; 
				else 
					XS <= '0'; 
					M.wr <= op.memwrite; 
				end if; 
		end case;

	else 
			M <= MEM_OUT_NOP;  
			XL <= '0'; 
			XS <= '0'; 
			--R <= (others => '0');			
	end if; 
	end process;  
end architecture;
