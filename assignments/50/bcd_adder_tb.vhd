-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     bcd_adder_tb
--
-- description:
--
--   This file implements a test bench for bcd_adder unit.
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

entity bcd_adder_tb is
end bcd_adder_tb;

architecture bcd_adder_tb_arch of bcd_adder_tb is
  component bcd_adder is
    port(
      A_i   : in  std_logic_vector(11 downto 0);
      B_i   : in  std_logic_vector(11 downto 0);
      SUM_o : out std_logic_vector(15 downto 0)
    );
  end component;
  signal s_A : std_logic_vector(11 downto 0);
  signal s_B : std_logic_vector(11 downto 0);
  signal s_SUM : std_logic_vector(15 downto 0);
  type output_vector_array is array (natural range <>) of std_logic_vector (15 downto 0);
  type input_vector_array is array (natural range <>) of std_logic_vector (11 downto 0);
  constant input_vectors_A : input_vector_array := (
    "000000000000",
    "100010001001",
    "011101111001",
    "010101010101",
    "100101010000",
    "011101110000",
    "100000101001",
    "100101100011",
    "010110010111",
    "001100110011",
    "001110011001",
    "100101110111",
    "100001000101",
    "100001000101"
  );
  constant input_vectors_B : input_vector_array := (
    "100001000101",
    "010110010111",
    "100000101001",
    "100101010000",
    "001110011001",
    "011101110000",
    "010101010101",
    "100001000101",
    "011101111001",
    "100101100011",
    "000000000000",
    "100101110111",
    "001100110011",
    "100010001001"
  );
  constant output_vectors : output_vector_array := (
    "0000100001000101",
    "0001010010000110",
    "0001011000001000",
    "0001010100000101",
    "0001001101001001",
    "0001010101000000",
    "0001001110000100",
    "0001100000001000",
    "0001001101110110",
    "0001001010010110",
    "0000001110011001",
    "0001100101010100",
    "0001000101111000",
    "0001011100110100"
  );
begin
  DUT : bcd_adder port map(
    A_i => s_A,
    B_i => s_B,
    SUM_o => s_SUM
  );

  STIMULI : process
    variable error_count : integer := 0;
    variable total_tests : integer := 0;
    variable expected : std_logic_vector(15 downto 0);
  begin
    s_A <= "000000000000";
    s_B <= "000000000000";

    assert false report "--- TESTING ---" severity note;
    for i in input_vectors_A'range loop
      total_tests := total_tests + 1;
      s_A <= input_vectors_A(i);
      s_B <= input_vectors_B(i);
      wait for 10 ns;
      expected := output_vectors(i);

      if(s_SUM /= expected) then
        assert false
        report "Adding failed: inputs="
          & integer'image(to_integer(unsigned(s_A(11 downto 8))))
          & integer'image(to_integer(unsigned(s_A(7 downto 4))))
          & integer'image(to_integer(unsigned(s_A(3 downto 0))))
          & " and "
          & integer'image(to_integer(unsigned(s_B(11 downto 8))))
          & integer'image(to_integer(unsigned(s_B(7 downto 4))))
          & integer'image(to_integer(unsigned(s_B(3 downto 0))))
          & "; expected ="
          & integer'image(to_integer(unsigned(expected(15 downto 12))))
          & integer'image(to_integer(unsigned(expected(11 downto 8))))
          & integer'image(to_integer(unsigned(expected(7 downto 4))))
          & integer'image(to_integer(unsigned(expected(3 downto 0))))
          & "; actual="
          & integer'image(to_integer(unsigned(s_SUM(15 downto 12))))
          & integer'image(to_integer(unsigned(s_SUM(11 downto 8))))
          & integer'image(to_integer(unsigned(s_SUM(7 downto 4))))
          & integer'image(to_integer(unsigned(s_SUM(3 downto 0))))
        severity error;
        error_count := error_count + 1;
      end if;
    end loop;
    wait for 10 ns;
    report "--- FINISHED TESTING ---";
    report "Total tests: " & integer'image(total_tests);
    report "Failed tests: " & integer'image(error_count);

    if(error_count = 0) then
      report "--- TEST PASSED ---";
    else
      report "--- TEST FAILED ---";
    end if;
    wait;
  end process;
end;
