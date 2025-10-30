library ieee;
use ieee.std_logic_1164.all;

entity one_bit_full_adder is
	port(
		i_A : in std_logic;
		i_B : in std_logic;
		i_C : in std_logic;
		o_SUM : out std_logic;
		o_C : out std_logic
	);
end one_bit_full_adder;

architecture obfa_arch of one_bit_full_adder is
	signal input : std_logic_vector(2 downto 0);
	signal output : std_logic_vector(1 downto 0);
begin
	input <= i_A & i_B & i_C;
	with input select
		output <= "00" when "000",
				  "01" when "001"|"010"|"100",
				  "10" when "011"|"101"|"110",
				  "11" when "111",
				  "00" when others;
	o_SUM <= output(0);
	o_C <= output(1);
end obfa_arch;
