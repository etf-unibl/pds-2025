library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 


entity simple_alu is
    port (i_A : in std_logic_vector(3 downto 0);
          i_B : in std_logic_vector(3 downto 0);
          i_SEL : in std_logic_vector(1 downto 0);
          o_RES : out std_logic_vector(3 downto 0);
          o_C : out std_logic);
end simple_alu;

architecture rtl of simple_alu is
	signal sum_res_sig, diff_res_sig : std_logic_vector(4 downto 0);
	signal sar2_res_sig, shl4_res_sig : std_logic_vector(3 downto 0);
	signal carry_sum, carry_diff : std_logic;

begin
	sum_res_sig <= std_logic_vector(unsigned('0' & i_A) + unsigned('0' & i_B));
	diff_res_sig <= std_logic_vector(unsigned('0' & i_A) - unsigned('0' & i_B));
	
	carry_sum <= sum_res_sig(4);
	carry_diff <= diff_res_sig(4);
	
	-- sar2(a): 1100 -> 1111 -> |MSB|MSB|3|2|
    	sar2_res_sig <= (i_A(3) & i_A(3)) & i_A(3 downto 2);	
	 
	-- shl4(b): 1100 -> 0000 always 0000 for 4-bit number
	shl4_res_sig <= (others => '0');
	
	with i_SEL select
		o_C <= carry_sum when "00",
				 carry_diff when "01",
				 '0' when others;
				 
	with i_SEL select
		o_RES <= sum_res_sig(3 downto 0) when "00",
				   diff_res_sig(3 downto 0) when "01",
					sar2_res_sig when "10",
					shl4_res_sig when "11",
					(others => '0') when others;


end rtl;
	

