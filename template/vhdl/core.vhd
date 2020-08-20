library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity core is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;

        -- instruction interface
        mem_i_out    : out mem_out_type;
        mem_i_in     : in  mem_in_type;

        -- data interface
        mem_d_out    : out mem_out_type;
        mem_d_in     : in  mem_in_type
    );
end core;

architecture impl of core is

    signal mem_d_out_s : mem_out_type;
    signal mem_d_in_s : mem_in_type;

begin

    pipeline_inst : entity work.pipeline
    port map (
        clk => clk,
        reset => reset,
        mem_i_out => mem_i_out,
        mem_i_in  => mem_i_in,
        --mem_d_out => mem_d_out_s, --with cache
        --mem_d_in  => mem_d_in_s --with cache
        mem_d_out => mem_d_out, --without cache
        mem_d_in  => mem_d_in --without cache
    );
	
/*
    cache_inst : entity work.cache
    generic map (
        ADDR_MASK => 14x"0FFF"
    )
    port map (
        clk    => clk,
        reset  => reset,

        mem_out_cpu  => mem_d_out_s,
        mem_in_cpu   => mem_d_in_s,
        mem_out_mem  => mem_d_out,
        mem_in_mem   => mem_d_in
    );
*/
end architecture;
