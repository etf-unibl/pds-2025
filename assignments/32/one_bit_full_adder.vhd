library ieee;
use ieee.std_logic_1164.all;

entity one_bit_full_adder is
	port(
		i_1 : in std_logic;
		i_2 : in std_logic;
		c_in : in std_logic;
		sum : out std_logic;
		c_out : out std_logic
		);

end one_bit_full_adder;
architecture blc_arch of one_bit_full_adder is
	signal s1,s2,s3,p1,p2,p3,p4,p5,p6,p7,p8, p9, p10 : std_logic;
	signal i1_not, i2_not, cin_not : std_logic;
begin

	i1_not <= not i_1;
	i2_not <= not i_2;
	cin_not <= not c_in;
	
	p1 <= i1_not and i2_not;
	p2 <= i1_not and i_2;
	p3 <= i_1 and i2_not;
	p4 <= i_1 and i_2;
	p5 <= p1 and c_in;
	p6 <= p2 and cin_not;
	p7 <= p3 and cin_not;
	p8 <= p4 and c_in;
	
	s1 <= p5 or p6;
	s2 <= p7 or p8;
	
	sum <= s1 or s2;
	
	p9 <= p2 and c_in;
	p10 <= p3 and c_in;
	
	s3 <= p9 or p10;
	c_out <= s3 or p4;
	
end blc_arch;
	
	
	
	
	
	
	
	
	