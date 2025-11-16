-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_comparator
--
-- description:
--
--   This file implements a dual-mode comparator for signed-magnitude numbers.
--
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

entity dual_mode_comparator is
  port (
        A_i    : in  std_logic_vector(7 downto 0);
        B_i    : in  std_logic_vector(7 downto 0);
        MODE_i : in  std_logic;
        AGTB_o : out std_logic
  );
end dual_mode_comparator;

architecture arch of dual_mode_comparator is
  signal a1_b0        : std_logic; -- A negative, B positive detection
  signal agtb_mag     : std_logic; -- Magnitude comparison result
  signal magnitude_eq : std_logic; -- Magnitude equality detection in case of (-5>-5 etc.)
  signal both_zero    : std_logic; -- Both magnitudes are zero (+0/-0)
  signal xor_mag_sign : std_logic; -- XOR result for signed negative logic
begin
  a1_b0    <= '1' when a_i(7) = '1' and b_i(7) = '0' else '0';
  agtb_mag <= '1' when a_i(6 downto 0) > b_i(6 downto 0) else '0';

  -- Additional XNOR logic is required to properly handle equality cases (-5=-5, +0=-0 etc.)
  process(A_i, B_i)
    variable temp_eq : std_logic;
    variable a_zero  : std_logic;
    variable b_zero  : std_logic;
  begin
    temp_eq := '1';
    a_zero  := '1';
    b_zero  := '1';

    for i in 0 to 6 loop
      temp_eq := temp_eq and (A_i(i) xnor B_i(i));
      a_zero  := a_zero and not A_i(i);
      b_zero  := b_zero and not B_i(i);
    end loop;

    magnitude_eq <= temp_eq;
    both_zero    <= a_zero and b_zero;
  end process;

  xor_mag_sign <= agtb_mag xor A_i(7);
  -- Output selection
  AGTB_o <=
   '0'          when MODE_i = '1' and both_zero = '1' else
   '0'          when A_i(7) = B_i(7) and magnitude_eq = '1' else
   agtb_mag     when MODE_i = '0' and A_i(7) = B_i(7) else
   xor_mag_sign when A_i(7) = B_i(7) else
   a1_b0        when MODE_i = '0' else
   not a1_b0;

end arch;
