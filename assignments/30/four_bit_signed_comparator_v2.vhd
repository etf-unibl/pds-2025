library ieee;
use ieee.std_logic_1164.all;

entity four_bit_signed_comparator_v2 is
    port (
			 i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          o_AGTB : out std_logic
			 );
end four_bit_signed_comparator_v2;

architecture rtl of four_bit_signed_comparator_v2 is
	signal a3,a2, a1, a0 : std_logic;
	signal b3,b2, b1, b0 : std_logic;
	
begin

-- A > B kada je A pozitivno a B negativno i ako je prvi niyi bit A=1 i B=0 za jednake A3 i B3(bit znaka)
	a3 <= i_A(3);
    a2 <= i_A(2);
    a1 <= i_A(1);
    a0 <= i_A(0);

    b3 <= i_B(3);
    b2 <= i_B(2);
    b1 <= i_B(1);
    b0 <= i_B(0);

	o_AGTB  <= ((not a3) and b3) or 
			    	((a3 xnor b3) and ((a2 and (not b2)) or 
					((a2 xnor b2) and a1 and (not b1)) or((a2 xnor b2) and (a1 xnor b1) and a0 and (not b0))));
end rtl;