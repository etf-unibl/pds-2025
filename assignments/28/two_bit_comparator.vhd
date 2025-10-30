library ieee;
use ieee.std_logic_1164.all;

entity two_bit_comparator is
    port (
        a : in std_logic_vector(1 downto 0);
        b : in std_logic_vector(1 downto 0);
        agtb : out std_logic;  
        aeqb : out std_logic;  
        altb : out std_logic   
    );
end two_bit_comparator;

architecture two_bit_arch of two_bit_comparator is
begin

	 agtb <= '1' when a > b else '0';
    aeqb <= '1' when a = b else '0';
    altb <= '1' when a < b else '0';

end two_bit_arch;