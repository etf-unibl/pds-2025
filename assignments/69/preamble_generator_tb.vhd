-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     preamble_generator_tb
--
-- description:
--
--   This file implements a test bench for preamble_generator unit.
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
--! @file preamble_generator_tb.vhd
--! @brief Testbench for the preamble_generator module.
--! @details this testbench verifies the functionality of the preamble_generator, which
--! should output the fixed 8-bit preamble sequence "10101010" after start_i is
--! asserted. The TB generates the clock, applies stimulus (reset and start
--! pulses), and checks whether the output matches the expected pattern.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--! @brief Top-level testbench entity (no ports).
entity preamble_generator_tb is
end preamble_generator_tb;
--! @brief Architecture of preamble_generator test bench
--! @details Implements self-checking test bench.
--! This architecture consists of three processes, one generates cycle,
--! second one implements tests and the third (output_checker) checks whether the
--! output matches the expected output
--! Output checker stores the number of failed tests
architecture arch of preamble_generator_tb is
  component preamble_generator
    port(
    clk_i   : in  std_logic; --! @brief clk_i   Clock input
    rst_i   : in  std_logic; --! @brief rst_i   Asynchronous reset input
    start_i : in  std_logic; --! @brief start_i Start signal that triggers preamble generation
    data_o  : out std_logic  --! @brief data_o  Single-bit output generating one symbol per clock cycle
  );
  end component;
  signal clk_i_tb                 : std_logic;
  signal rst_i_tb                 : std_logic;
  signal start_i_tb               : std_logic;
  signal data_o_tb                : std_logic;
  signal end_flag                 : std_logic := '0';
  constant c_EXPECTED_OUTPUT : std_logic_vector(7 downto 0) := "10101010";
  constant c_CLK_PERIOD           : time := 40 ns;
begin
  uut : preamble_generator
  port map(
  clk_i   => clk_i_tb,
  rst_i   => rst_i_tb,
  start_i => start_i_tb,
  data_o  => data_o_tb
  );
  cycle_generator : process
  begin
    if end_flag = '1' then
      wait;
    end if;
    clk_i_tb <= '1';
    wait for c_CLK_PERIOD/2;
    clk_i_tb <= '0';
    wait for c_CLK_PERIOD/2;
  end process cycle_generator;
  stimulation : process
  begin
    rst_i_tb <= '0';
    start_i_tb <= '0';
    wait for 10 ns;
    start_i_tb <= '1';
    wait for 40 ns;
    start_i_tb <= '0';
    wait for 330 ns;
    start_i_tb <= '1';
    wait for 40 ns;
    start_i_tb <= '0';
    wait for 100 ns;
    rst_i_tb <= '1';
    wait for 50 ns;
    rst_i_tb <= '0';
    wait for 40 ns;
    start_i_tb <= '1';
    wait for 330 ns;
    start_i_tb <= '0';
    end_flag <= '1';
    wait;
  end process stimulation;
  output_checker : process
    variable error_counter : integer := 0;
  begin
    while true loop
      wait until rising_edge(clk_i_tb);
      if start_i_tb = '1' then
        assert false report "--- TESTING ---" severity note;
        for i in 0 to 7 loop
          wait until rising_edge(clk_i_tb);
          if rst_i_tb = '1' then
            assert false report "Reset detected, sequence generation stopped." severity note;
            exit;
          end if;
          if data_o_tb /= c_EXPECTED_OUTPUT(7-i) then
            assert false report "Error at position " & integer'image(7-i) &
            " expected " & std_logic'image(c_EXPECTED_OUTPUT(7-i)) &
            " but got " & std_logic'image(data_o_tb) severity error;
            error_counter := error_counter + 1;
          end if;
        end loop;
      end if;
      wait until end_flag = '1';
      if error_counter = 0 then
        assert false report "--- TESTING PASSED ---" severity note;
      else
        assert false report "--- TESTING FAILED ---" severity note;
      end if;
      wait;
    end loop;
  end process output_checker;
end arch;
