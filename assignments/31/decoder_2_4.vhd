-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     decoder_2_4
--
-- description:
--
--   This file implements a 2-to-4 line decoder with enable input.
--   The decoder activates one of four output lines based on a 2-bit
--   input combination when the enable signal is set to logic '1'.
--   When the enable input is '0', all outputs are inactive ('0').
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

entity decoder_2_4 is
  port(
    a_i : in  std_logic_vector(1 downto 0);
    e_i : in  std_logic;
    y_o : out std_logic_vector(3 downto 0)
  );
end decoder_2_4;

architecture arch of decoder_2_4
is
-- Temporary signal used to hold decoder output before enable control
  signal y_tmp : std_logic_vector(3 downto 0);
begin
  with a_i select
    y_tmp <= "0001" when "00",
             "0010" when "01",
             "0100" when "10",
             "1000" when others;
  y_o <= y_tmp when e_i = '1' else "0000";
end arch;
