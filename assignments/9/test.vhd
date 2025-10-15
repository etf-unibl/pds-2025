library ieee;
use ieee.std_logic_1164.all;

entity nand2_gate is
   port ( A_i, B_i: in std_logic;
          Y_o: out std_logic
        );
end nand2_gate;

architecture beh_nand2 of nand2_gate is
begin
   Y_o <= A_i nand B_i;
end beh_nand2;
