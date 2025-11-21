-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     eight_bit_divider
--
-- description:   8-bit unsigned divider
--
--   This file implements a combinational 8-bit unsigned divider using
--   the "shift, compare and subtract" algorithm.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2025 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2025 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eight_bit_divider is
  port (
    A_i : in  std_logic_vector(7 downto 0);
    B_i : in  std_logic_vector(7 downto 0);
    Q_o : out std_logic_vector(7 downto 0);
    R_o : out std_logic_vector(7 downto 0)
  );
end eight_bit_divider;

architecture arch of eight_bit_divider is
begin
  main_p : process (A_i, B_i)
    variable A, B, Q, R : unsigned(7 downto 0);
    variable i          : integer;
  begin
    A := unsigned(A_i);
    B := unsigned(B_i);

    if B = to_unsigned(0, 8) then
      Q_o <= (others => '0');
      R_o <= A_i;
    else
      Q := (others => '0');
      R := (others => '0');

      for i in 7 downto 0 loop
        R := shift_left(R, 1);
        R(0) := A(i);

        if R >= B then
          R := R - B;
          Q(i) := '1';
        else
          Q(i) := '0';
        end if;
      end loop;

      Q_o <= std_logic_vector(Q);
      R_o <= std_logic_vector(R);
    end if;
  end process main_p;
end arch;
