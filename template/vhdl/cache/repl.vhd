library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity repl is
    generic (
        WAYS  : natural := WAYS
    );
    port (
        valid_in      : in std_logic_vector(WAYS-1 downto 0);
        dirty_in      : in std_logic_vector(WAYS-1 downto 0);
        replace_in    : in std_logic_vector(WAYS-1 downto 0);
        replace_out   : out std_logic_vector(WAYS-1 downto 0)
    );
end entity;

architecture impl of repl is
begin
end architecture;
