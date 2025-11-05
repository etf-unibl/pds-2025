library ieee;
use ieee.std_logic_1164.all;

entity four_bit_full_subtractor is

    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          i_C : in std_logic;
          o_SUB : out std_logic_vector(3 downto 0);
          o_C : out std_logic);
			 
end four_bit_full_subtractor;

architecture fbfs_arch of four_bit_full_subtractor is

	component one_bit_full_subtractor
		port
		(
			i_A : in std_logic;
			i_B : in std_logic;
			i_C : in std_logic;
			o_SUB : out std_logic;
			o_C : out std_logic
		);
	end component;
	
	signal c1, c2, c3 : std_logic;
	
	begin
	
		u1 : one_bit_full_subtractor
			port map(i_A => i_A(0), i_B => i_B(0), i_C => i_C, o_SUB => o_SUB(0), o_C => c1);
		u2 : one_bit_full_subtractor
			port map(i_A => i_A(1), i_B => i_B(1), i_C => c1,  o_SUB => o_SUB(1), o_C => c2);
		u3 : one_bit_full_subtractor
			port map(i_A => i_A(2), i_B => i_B(2), i_C => c2,  o_SUB => o_SUB(2), o_C => c3);
		u4 : one_bit_full_subtractor
			port map(i_A => i_A(3), i_B => i_B(3), i_C => c3,  o_SUB => o_SUB(3), o_C => o_C);

end fbfs_arch;
