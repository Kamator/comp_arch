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
    signal reg_write_mem1, reg_write_wb1, reg_write_mem2, reg_write_wb2 : reg_write_type;
    signal reg1, reg2 : reg_adr_type;
    signal val1, val2 : data_type;
    signal do_fwd1, do_fwd2 : std_logic;
	 
	 component fwd is
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
    end component;
    
begin

    fwd_inst1 : fwd
    port map(
        reg_write_mem => reg_write_mem1,
        reg_write_wb => reg_write_wb1,
        reg => reg1,
        val => val1,
        do_fwd => do_fwd1
    );
    
    fwd_inst2 : fwd
    port map(
        reg_write_mem => reg_write_mem2,
        reg_write_wb => reg_write_wb2,
        reg => reg2,
        val => val2,
        do_fwd => do_fwd2
    );
    
    process(all)
    begin
        do_fwd <= '0';
        val <= (others => '0');
        if reg_write_mem1.write = '1' then
            if reg_write_mem1.reg /= zeros and reg = reg_write_mem1.reg then
                do_fwd1 <= '1';
                val1 <= reg_write_mem.data;
            end if;
        end if;
        
        if reg_write_wb2.write = '1' then
            if reg_write_wb2.reg /= zeros and reg = reg_write_wb2.reg then
                do_fwd2 <= '1';
                val2 <= reg_write_wb.data;
            end if;
        end if;
        
    end process;

end architecture;

