-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2024
-- https://github.com/etf-unibl/pds-2024
-----------------------------------------------------------------------------
--
-- unit name:     dual_edge_detector_tb
--
-- description:
--
--   This is a test bench for dual_edge_detector.
--   It uses a test-vector table with expected output and
--   compares it to DUT output.
--
-----------------------------------------------------------------------------
-- Copyright (c) 2024 Faculty of Electrical Engineering
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright 2024 Faculty of Electrical Engineering
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

--! @file dual_edge_detector_tb.vhd
--! @brief Testbench for dual_edge_detector
--! @details
--! This testbench verifies the dual_edge_detector using a table of test
--! vectors. Each vector contains two consecutive samples of the input
--! strobe_i.
--!
--! The testbench performs:
--! - clock generation (clk_gen)
--! - reset generation (rst_i pulse at the beginning)
--! - stimulus application and checking (stimulus_check)
--!
--! For each test vector:
--! 1) strobe_i is driven with the first sample
--! 2) after one clock period, strobe_i is driven with the second sample
--! 3) shortly after the transition, DUT output is compared to expected_out
--!
--! The testbench reports each test using severity note and stops with
--! severity error if a mismatch is detected.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity
entity dual_edge_detector_tb is
end dual_edge_detector_tb;

--! @brief Testbench architecture
--! @details
--! Instantiates the DUT and contains clock/reset generation and
--! self-checking stimulus.
architecture arch of dual_edge_detector_tb is

  --! @brief DUT component declaration
  component dual_edge_detector is
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      strobe_i : in  std_logic;
      p_o      : out std_logic
         );
  end component;

  signal clk_i    : std_logic := '0'; --! Clock signal
  signal rst_i    : std_logic := '0'; --! Reset signal, asserted at start then deasserted
  signal strobe_i : std_logic := '0'; --! DUT input stimulus signal
  signal p_o      : std_logic;        --! DUT output signal to be checked

  signal i : integer := 0;            --! Clock cycle counter for ending the simulation clock

  constant c_T : time := 20 ns;       --! Clock period
  constant c_CLK_NUM : integer := 20; --! Number of clock cycles to generate before stopping clk_gen

  --! @brief Test vector record type
  --! @details
  --! strobe_in(1) is applied first, then strobe_in(0) is applied second.
  --! expected_out is the expected DUT output value for that transition.
  type t_test_vector is record
    strobe_in    : std_logic_vector(1 downto 0);
    expected_out : std_logic;
  end record t_test_vector;
  
  --! @brief Array type holding multiple test vectors.
  type t_test_vector_array is array(natural range <>) of t_test_vector;

  --! @brief Test vector table.
  --! @details
  --! Each entry represents two consecutive samples of strobe_i and the
  --! expected output pulse.
  constant c_TEST_VECTORS : t_test_vector_array := (
    ("00", '0'),
    ("01", '1'),
    ("10", '1'),
    ("01", '1'),
    ("11", '0'),
    ("10", '1'),
    ("10", '1'),
    ("01", '1'),
    ("11", '0')
    );

begin
  
  --! @brief Unit Under Test (UUT) instantiation.
  uut : dual_edge_detector
    port map(
      clk_i    => clk_i,
      rst_i    => rst_i,
      strobe_i => strobe_i,
      p_o      => p_o
    );
 
  --! @brief Reset generation.
  --! @details
  --! rst_i is asserted at time 0 and deasserted after half a clock period. 
  rst_i <= '1', '0' after c_T/2;

  --! @brief Clock generator process.
  --! @details
  --! Generates a periodic clock with period c_T.
  --! Stops after c_CLK_NUM cycles.
  clk_gen : process
  begin
    clk_i <= '0';
    wait for c_T/2;
    clk_i <= '1';
    wait for c_T/2;
    if i = c_CLK_NUM then
      wait;
    else
      i <= i + 1;
    end if;
  end process clk_gen;

  --! @brief Stimulus and self-checking process.
  --! @details
  --! Iterates over c_TEST_VECTORS:
  --! - drives strobe_i with two consecutive samples per vector
  --! - prints the current test details (severity note)
  --! - asserts that DUT output matches expected_out (severity error on fail)
  stimulus_check : process
  begin
    for i in c_TEST_VECTORS'range loop
      strobe_i <= c_TEST_VECTORS(i).strobe_in(1);
      wait for c_T;
      strobe_i <= c_TEST_VECTORS(i).strobe_in(0);
      wait for c_T/8;

      assert false
      report "Test " & integer'image(i) & " : " & LF &
             "strobe_in = " &
             std_logic'image(c_TEST_VECTORS(i).strobe_in(1)) &
             std_logic'image(c_TEST_VECTORS(i).strobe_in(0)) & LF &
             "expected_out = " &
             std_logic'image(c_TEST_VECTORS(i).expected_out) & LF &
             "actual_out = " &
             std_logic'image(p_o)
      severity note;

      assert (p_o = c_TEST_VECTORS(i).expected_out)
      report "Test failed for index " & integer'image(i)
      severity error;

      wait for c_T;
    end loop;

    assert false
    report "Test successfully completed."
    severity note;

    wait;
  end process stimulus_check;

end arch;
