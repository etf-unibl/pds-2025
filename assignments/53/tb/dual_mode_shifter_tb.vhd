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
architecture arch of dual_mode_shifter_tb is
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
  type t_test_vector_array is array (natural range <>) of std_logic_vector (15 downto 0);
  constant c_TEST_VECTORS : t_test_vector_array := (
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
  MODE_i   => MODE_i,
  SH_IN_i  => SH_IN_i,
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
    variable expected       : std_logic_vector(15 downto 0);
    variable error_count    : integer := 0;
  begin
        -- code executes for every event on sensitivity list
    MODE_i <= '0'; -- left shifting
    for i in c_TEST_VECTORS'range loop
      SH_IN_i <= c_TEST_VECTORS(i);
      wait for 10 ns;
      expected := c_TEST_VECTORS(i)(14 downto 0) & c_TEST_VECTORS(i)(15 downto 15);
      if SH_OUT_o /= expected then
        assert false
        report "LEFT rotation failed: input=" & integer'image(to_integer(unsigned(SH_IN_i))) &
        "; expected=" & integer'image(to_integer(unsigned(expected))) &
        "; actual=" & integer'image(to_integer(unsigned(SH_OUT_o)))
        severity error;
        error_count := error_count + 1;
      end if;
    end loop;
    assert false report "Left shifting test finished." severity note;
    MODE_i <= '1'; -- right shifting
    for i in c_TEST_VECTORS'range loop
      SH_IN_i <= c_TEST_VECTORS(i);
      wait for 10 ns;
      expected := c_TEST_VECTORS(i)(0 downto 0) & c_TEST_VECTORS(i)(15 downto 1);
      if SH_OUT_o /= expected then
        assert false
        report "RIGHT rotation failed: input=" & integer'image(to_integer(unsigned(SH_IN_i)))
        & "; expected=" & integer'image(to_integer(unsigned(expected))) &
        "; actual=" & integer'image(to_integer(unsigned(SH_OUT_o)))
        severity error;
        error_count := error_count + 1;
      end if;
    end loop;
    assert false report "Right shifting test finished." severity note;
    wait for 10 ns;
    if error_count = 0 then
      assert false report "Test completed." severity note;
    else
      assert false report "Test finshed with errors." severity error;
    end if;
    wait;
  end process always;
end arch;
