-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     four_bit_signed_comparator_v2
--
-- description:
--
--   4-bit comparator (logic-based, bit-by-bit implementation).
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

entity four_bit_signed_comparator_v2 is
  port (
    A_i    : in  std_logic_vector(3 downto 0);
    B_i    : in  std_logic_vector(3 downto 0);
    AGTB_o : out std_logic
  );
end entity four_bit_signed_comparator_v2;

architecture arch of four_bit_signed_comparator_v2 is
  signal a3, a2, a1, a0 : std_logic;
  signal b3, b2, b1, b0 : std_logic;
begin
  a3 <= A_i(3);
  a2 <= A_i(2);
  a1 <= A_i(1);
  a0 <= A_i(0);

  b3 <= B_i(3);
  b2 <= B_i(2);
  b1 <= B_i(1);
  b0 <= B_i(0);

  AGTB_o <= ((not a3) and b3) or
            ((a3 xnor b3) and ((a2 and (not b2)) or
            ((a2 xnor b2) and a1 and (not b1)) or
            ((a2 xnor b2) and (a1 xnor b1) and a0 and (not b0))));
end architecture arch;
