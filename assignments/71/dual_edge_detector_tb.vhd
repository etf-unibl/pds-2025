-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     dual_edge_detector_tb
--
-- description:
--
--   This file implements a test bench for dual_edge_detector unit.
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

-----------------------------------------------------------------------------
--! @file dual_edge_detector_tb.vhd
--! @brief Implements test bench for dual_edge_detector
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Empty entity for testbench
entity dual_edge_detector_tb is
end dual_edge_detector_tb;

--! @brief Architecture of dual_edge_detector test bench
--! Implements self-checking test bench.
--! Inside stimuli process there are 9 tests.
--! Process verifier check for results and stores number of tests
--! and number of failed results.
architecture arch of dual_edge_detector_tb is
  component dual_edge_detector is
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      strobe_i : in  std_logic;
      p_o      : out std_logic
  );
  end component;
  signal clk_s    : std_logic;
  signal rst_s    : std_logic;
  signal strobe_s : std_logic;
  signal p_s      : std_logic;
  signal flag     : std_logic := '0';
begin
  uut : dual_edge_detector port map(
    clk_i    => clk_s,
    rst_i    => rst_s,
    strobe_i => strobe_s,
    p_o      => p_s
  );

  clk : process
  begin
    if flag = '1' then
      wait;
    end if;
    clk_s <= '0';
    wait for 10 ns;
    clk_s <= '1';
    wait for 10 ns;
  end process clk;

  stimuli : process
  begin
    rst_s <= '0';
    wait for 40 ns;
    strobe_s <= '1';
    wait for 50 ns;
    strobe_s <= '0';
    wait for 100 ns;
    strobe_s <= '1';
    wait for 390 ns;
    strobe_s <= '0';
    wait for 170 ns;
    strobe_s <= '1';
    wait for 144 ns;
    strobe_s <= '0';
    wait for 190 ns;
    strobe_s <= '1';
    wait for 150 ns;
    strobe_s <= '0';
    wait for 189 ns;
    strobe_s <= '1';

    flag <= '1';
    wait;
  end process stimuli;

  verifier : process
    variable error_count : integer := 0;
    variable total_tests : integer := 0;
    variable expected    : std_logic;
  begin
    if total_tests = 0 then
      assert false report "--- TESTING ---" severity note;
    end if;

    wait on strobe_s;
    total_tests := total_tests + 1;
    wait for 25 ns; -- Wait for output to to get activated
    if p_s = '0' then -- Output should always be high on strobe_i changes
      error_count := error_count + 1;
    end if;
    if flag = '1' then
      assert false report "--- FINISHED TESTING ---" severity note;
      assert false report "Total tests: " & integer'image(total_tests) severity note;
      assert false report "Failed tests: " & integer'image(error_count) severity note;

      if error_count = 0 then
        assert false report "--- TEST PASSED ---" severity note;
      else
        assert false report "--- TEST FAILED ---" severity error;
      end if;
      wait;
    end if;
  end process verifier;
end arch;
