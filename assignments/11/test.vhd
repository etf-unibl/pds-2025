library ieee;
use ieee.std_logic_1164.all;

entity jk_ff is
	port(
	i_j : in std_logic;
	i_k : in std_logic;
	i_clk : in std_logic;
	i_rst_n : in std_logic;
	i_pre_n : in std_logic;
	o_q : out std_logic;
	o_qn : out std_logic);
end jk_ff;

architecture jk_ff_arch of jk_ff is
begin

end architecture;
