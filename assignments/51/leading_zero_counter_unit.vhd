-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     leading_zero_counter_unit
--
-- description:
--
--   This file implements a leading zero counter circuit.
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

entity leading_zero_counter_unit is
  port (
    INPUT_DATA_i  : in  std_logic_vector(15 downto 0);
    OUTPUT_DATA_o : out std_logic_vector(4 downto 0)
);
end entity leading_zero_counter_unit;

architecture arch of leading_zero_counter_unit is

  signal lzc0, lzc1, lzc2, lzc3 : std_logic_vector(2 downto 0);
  signal all_zeros : std_logic_vector(3 downto 0);

  component lzc4_unit
    port(
      INPUT_DATA_i  : in  std_logic_vector(3 downto 0);
      OUTPUT_DATA_o : out std_logic_vector(2 downto 0)
    );
  end component;

begin

  u0 : lzc4_unit
    port map (
      INPUT_DATA_i  => INPUT_DATA_i(15 downto 12),
      OUTPUT_DATA_o => lzc0
    );

  u1 : lzc4_unit
    port map (
      INPUT_DATA_i  => INPUT_DATA_i(11 downto 8),
      OUTPUT_DATA_o => lzc1
    );

  u2 : lzc4_unit
    port map (
      INPUT_DATA_i  => INPUT_DATA_i(7 downto 4),
      OUTPUT_DATA_o => lzc2
    );

  u3 : lzc4_unit
    port map (
      INPUT_DATA_i  => INPUT_DATA_i(3 downto 0),
      OUTPUT_DATA_o => lzc3
    );

  all_zeros(0) <= '1' when INPUT_DATA_i(15 downto 12) = "0000" else '0';
  all_zeros(1) <= '1' when INPUT_DATA_i(11 downto 8) = "0000" else '0';
  all_zeros(2) <= '1' when INPUT_DATA_i(7 downto 4) = "0000" else '0';
  all_zeros(3) <= '1' when INPUT_DATA_i(3 downto 0) = "0000" else '0';

  lzc_proc : process(INPUT_DATA_i, all_zeros, lzc0, lzc1, lzc2, lzc3)
  begin

    if all_zeros(0) = '0' then
      OUTPUT_DATA_o <= "00" & lzc0;
    elsif all_zeros(1) = '0' then
      OUTPUT_DATA_o <= std_logic_vector(resize(unsigned(lzc1) + 4, 5));
    elsif all_zeros(2) = '0' then
      OUTPUT_DATA_o <= std_logic_vector(resize(unsigned(lzc2), 5) + 8);
    elsif all_zeros(3) = '0' then
      OUTPUT_DATA_o <= std_logic_vector(resize(unsigned(lzc3), 5) + 12);
    else
      OUTPUT_DATA_o <= "10000";
    end if;

  end process lzc_proc;
end arch;
