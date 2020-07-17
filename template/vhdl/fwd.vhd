library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity fwd is
    port (
        -- from Mem
        reg_write_mem : in reg_write_type;

        -- from WB
        reg_write_wb  : in reg_write_type;

        -- from/to EXEC
        reg    : in  reg_adr_type;
        val    : out data_type;
        do_fwd : out std_logic
    );
end fwd;

architecture rtl of fwd is
    constant zeros : reg_adr_type := (others => '0');   
begin    
   fwd_process : process(all)
    begin
        do_fwd <= '0';
        val <= (others => '0');
        if reg_write_mem.write = '1' then
            if reg_write_mem.reg /= zeros and reg = reg_write_mem.reg then
                do_fwd <= '1';
                val <= reg_write_mem.data;
            end if;
        end if;
        
        if reg_write_wb.write = '1' then
            if reg_write_wb.reg /= zeros and reg = reg_write_wb.reg then
                do_fwd <= '1';
                val <= reg_write_wb.data;
            end if;
        end if;
        
    end process;

end architecture;

