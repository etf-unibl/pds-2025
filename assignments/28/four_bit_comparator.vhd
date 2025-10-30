library ieee;
use ieee.std_logic_1164.all;

entity four_bit_comparator is
 port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          o_AGTB : out std_logic;
          o_AEQB : out std_logic;
          o_ALTB : out std_logic
		);
end four_bit_comparator;

architecture four_bit_arch of four_bit_comparator is

	component two_bit_comparator is
	port (
        a : in std_logic_vector(1 downto 0);
        b : in std_logic_vector(1 downto 0);
        agtb : out std_logic;  
        aeqb : out std_logic;  
        altb : out std_logic   
    );
	end component;
	-- High bits (i_A[3:2], i_B[3:2]) and low bits (i_A[1:0], i_B[1:0]) are compared separately
	-- signals are combined to determine final outputs: i_A>I_B, i_A=i_B, i_A<i_B
	signal high_gt, high_eq, high_lt : std_logic;
   signal low_gt, low_eq, low_lt   : std_logic;
	
begin

	cmp_high : two_bit_comparator
		port map (a => i_A(3 downto 2), b =>i_B(3 downto 2), agtb => high_gt, aeqb => high_eq, altb => high_lt);
	cmp_low : two_bit_comparator
		port map (a => i_A(1 downto 0), b => i_B(1 downto 0), agtb => low_gt, aeqb => low_eq, altb => low_lt);
	
	o_AGTB <= high_gt or (high_eq and low_gt);
   o_AEQB <= high_eq and low_eq;
   o_ALTB <= high_lt or (high_eq and low_lt);
end four_bit_arch;