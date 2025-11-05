library ieee;

use ieee.std_logic_1164.all;


entity four_bit_full_adder is
    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          i_C : in std_logic;
          o_SUM : out std_logic_vector(3 downto 0);
          o_C : out std_logic);
end four_bit_full_adder;
architecture str_arch of four_bit_full_adder is
	component one_bit_full_adder
	port
	(
		i_1 : in std_logic;
		i_2 : in std_logic;
		c_in : in std_logic;
		sum : out std_logic;
		c_out : out std_logic
	);
end component;
	signal s1, s2, s3 : std_logic;
begin
	u1 : one_bit_full_adder
		port map(i_1 => i_A(0), i_2 => i_B(0), c_in => i_C, sum => o_SUM(0), c_out => s1);
	u2 : one_bit_full_adder
		port map(i_1 => i_A(1), i_2 => i_B(1), c_in => s1, sum => o_SUM(1), c_out => s2);
	u3 : one_bit_full_adder
		port map(i_1 => i_A(2), i_2 => i_B(2), c_in => s2, sum => o_SUM(2), c_out => s3);
	u4 : one_bit_full_adder
		port map(i_1 => i_A(3), i_2 => i_B(3), c_in => s3, sum => o_SUM(3), c_out => o_C);
	
end str_arch;		
		