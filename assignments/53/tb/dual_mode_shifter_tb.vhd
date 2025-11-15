-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025
-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_shifter_tb
--
-- description:
--
--   This file implements testbench for dual-mode shifter logic.
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

entity dual_mode_shifter_tb is
end dual_mode_shifter_tb;
architecture dual_mode_shifter_arch of dual_mode_shifter_tb is
-- constants
-- signals
  signal MODE_i   : std_logic;
  signal SH_IN_i  : std_logic_vector(15 downto 0);
  signal SH_OUT_o : std_logic_vector(15 downto 0);
  component dual_mode_shifter
    port (
    MODE_i   : in  std_logic;
    SH_IN_i  : in  std_logic_vector(15 downto 0);
    SH_OUT_o : out std_logic_vector(15 downto 0)
    );
  end component;
  type test_vector_array is array (natural range <>) of std_logic_vector (15 downto 0);
  constant test_vectors : test_vector_array := (
  "0000000000000000",
  "1111111111111111",
  "1010101010101010",
  "0101010101010101",
  "1111111100000000",
  "0000000011111111",
  "1111000011110000",
  "1000000000000001",
  "0111111111111110",
  "0011001100110011",
  "0011100100101001",
  "1101111011101111",
  "1000010001000001"
  );
begin
  i1 : dual_mode_shifter
  port map (
-- list connections between master ports and signals
  MODE_i => MODE_i,
  SH_IN_i => SH_IN_i,
  SH_OUT_o => SH_OUT_o
  );
  init : process
-- variable declarations
  begin
        -- code that executes only once
    wait;
  end process init;
  always : process
-- optional sensitivity list
-- (        )
-- variable declarations
    variable expected : std_logic_vector(15 downto 0);
  begin
        -- code executes for every event on sensitivity list
    MODE_i <= '0'; -- left shifting
    for i in test_vectors'range loop
      SH_IN_i <= test_vectors(i);
      wait for 10 ns;
      expected := test_vectors(i)(14 downto 0) & test_vectors(i)(15 downto 15);
      assert SH_OUT_o = expected
      report "LEFT rotation failed: input=" & integer'image(to_integer(unsigned(SH_IN_i))) &
      "; expected=" & integer'image(to_integer(unsigned(expected))) &
      "; actual=" & integer'image(to_integer(unsigned(SH_OUT_o)))
      severity error;
    end loop;
    report "Left shifting test finished.";
    MODE_i <= '1'; -- right shifting
    for i in test_vectors'range loop
      SH_IN_i <= test_vectors(i);
      wait for 10 ns;
      expected := test_vectors(i)(0 downto 0) & test_vectors(i)(15 downto 1);
      assert SH_OUT_o = expected
      report "RIGHT rotation failed: input=" & integer'image(to_integer(unsigned(SH_IN_i))) &
      "; expected=" & integer'image(to_integer(unsigned(expected))) &
      "; actual=" & integer'image(to_integer(unsigned(SH_OUT_o)))
      severity error;
    end loop;
    report "Right shifting test finished.";
    wait for 10 ns;
    report "Test completed.";
    wait;
  end process always;
end dual_mode_shifter_arch;
