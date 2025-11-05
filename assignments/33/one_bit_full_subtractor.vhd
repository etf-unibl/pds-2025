library ieee;
use ieee.std_logic_1164.all;

entity one_bit_full_subtractor is

    port (i_A : in std_logic;
          i_B : in std_logic;
          i_C : in std_logic;
          o_SUB : out std_logic;
          o_C : out std_logic);
			 
end one_bit_full_subtractor;

architecture obfs_arch of one_bit_full_subtractor is

begin

	o_SUB <= i_A xor i_B xor i_C;
	o_C <= (i_B and i_C) or ((not i_A) and i_C) or ((not i_A) and i_B);

end obfs_arch;