library ieee;
use ieee.std_logic_1164.all;

entity four_bit_full_adder is
	port(
		i_A : in std_logic_vector(3 downto 0);
		i_B : in std_logic_vector(3 downto 0);
		i_C : in std_logic;
		o_SUM : out std_logic_vector(3 downto 0);
		o_C : out std_logic
	);
end four_bit_full_adder;

architecture fbfa_arch of four_bit_full_adder is
	component one_bit_full_adder is
		port(
			i_A : in std_logic;
			i_B : in std_logic;
			i_C : in std_logic;
			o_SUM : out std_logic;
			o_C : out std_logic
		);
	end component;
	signal s_C : std_logic_vector(2 downto 0);
begin
	a0 : one_bit_full_adder port map(
		i_A => i_A(0),
		i_B => i_B(0),
		i_C => i_C,
		o_SUM => o_SUM(0),
		o_C => s_c(0)
	);
	a1 : one_bit_full_adder port map(
		i_A => i_A(1),
		i_B => i_B(1),
		i_C => s_c(0),
		o_SUM => o_SUM(1),
		o_C => s_c(1)
	);
	a2 : one_bit_full_adder port map(
		i_A => i_A(2),
		i_B => i_B(2),
		i_C => s_c(1),
		o_SUM => o_SUM(2),
		o_C => s_c(2)
	);
	a3 : one_bit_full_adder port map(
		i_A => i_A(3),
		i_B => i_B(3),
		i_C => s_c(2),
		o_SUM => o_SUM(3),
		o_C => o_C
	);
end fbfa_arch;
