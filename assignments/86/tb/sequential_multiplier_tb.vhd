-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     sequential_multiplier_tb
--
-- description:
--
--   This file implements test bench of multiplicaiton of two numbers in
--   FSM style.
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
use std.textio.all;

--! @file sequential_multiplier_tb.vhd
--! @brief Testbench for the sequential multiplier
--! @details This testbench applies all possible 8-bit input combinations
--!          to the sequential multiplier and checks if the output matches
--!          the expected multiplication result. Results are logged to CSV.

--! @brief Testbench entity for sequential multiplier
entity sequential_multiplier_tb is
end entity sequential_multiplier_tb;

--! @brief Testbench architecture
--! @details Generates clock, applies input sequences, waits for completion,
--!          checks output, logs results to CSV, and reports test pass/fail.
architecture arch of sequential_multiplier_tb is

  --! @brief Sequential multiplier component declaration
  component sequential_multiplier
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      start_i : in  std_logic;
      a_i     : in  std_logic_vector(7 downto 0);
      b_i     : in  std_logic_vector(7 downto 0);
      c_o     : out std_logic_vector(15 downto 0);
      ready_o : out std_logic
    );
  end component;

  --! @brief Clock period for simulation
  constant c_CLK_PERIOD : time := 32 ns;
  --! @brief Maximum operand value
  constant c_MAX_VALUE  : natural := 255;

  --! @brief Testbench signals
  signal clk_i     : std_logic := '0';                                --! Clock signal
  signal rst_i     : std_logic := '1';                                --! Active-high reset
  signal start_i   : std_logic := '0';                                --! Start signal for multiplier
  signal a_i       : std_logic_vector(7 downto 0) := (others => '0'); --! Operand a
  signal b_i       : std_logic_vector(7 downto 0) := (others => '0'); --! Operand b
  signal c_o       : std_logic_vector(15 downto 0);                   --! Multiplier output
  signal ready_o   : std_logic;                                       --! Ready signal from multiplier
  signal run_clock : boolean := true;                                 --! Control variable for clock process

  --! @brief CSV file for logging simulation results
  file f_csv : text open write_mode is "results.csv";

begin

  --! @brief Instantiate the sequential multiplier
  uut : sequential_multiplier
    port map(
      clk_i   => clk_i,
      rst_i   => rst_i,
      start_i => start_i,
      a_i     => a_i,
      b_i     => b_i,
      c_o     => c_o,
      ready_o => ready_o
    );

  --! @brief Clock generation process
  --! @details Generates a continuous clock signal for the simulation
  clk_process : process
  begin
    while run_clock loop
      clk_i <= '0';
      wait for c_CLK_PERIOD / 2;
      clk_i <= '1';
      wait for c_CLK_PERIOD / 2;
    end loop;
    clk_i <= '0';
    wait;
  end process clk_process;

  --! @brief Test sequence process
  --! @details Applies all possible combinations of 8-bit inputs, starts the multiplier,
  --!          waits for ready signal, logs actual and expected results to CSV,
  --!          and reports overall test pass/fail.
  test_process : process
    variable line_buf        : line;            --! Temporary variable for CSV line
    variable actual_result   : natural;         --! Multiplier output as integer
    variable expected_result : natural;         --! Expected multiplication result
    variable test_passed     : boolean := true; --! Test status
    variable cycles_count    : natural := 0;    --! Cycle counter

    --! @brief Procedure to check FSM behavior in the design
    --! @details Verifies that FSM is idle after reset, performs a simple operation,
    --!          detects state transitions via ready_o, waits for completion, and checks result.
    procedure check_fsm_features is
    begin
      assert ready_o = '1'
        report "FSM not in idle state after reset"
        severity error;

      a_i <= "00000001";
      b_i <= "00000001";
      start_i <= '1';
      wait until rising_edge(clk_i);
      start_i <= '0';
      wait for c_CLK_PERIOD / 4;

      assert ready_o = '0'
        report "FSM did not start operation (ready_o stayed '1')"
        severity error;

      cycles_count := 0;
      while ready_o = '0' and cycles_count < 20 loop
        wait until rising_edge(clk_i);
        cycles_count := cycles_count + 1;
      end loop;

      assert ready_o = '1'
        report "FSM timeout: did not return to idle"
        severity error;

      assert to_integer(unsigned(c_o)) = 1
        report "FSM produced incorrect result"
        severity error;
    end procedure check_fsm_features;

  begin

    rst_i <= '1';
    wait for 3 * c_CLK_PERIOD;
    rst_i <= '0';
    wait until rising_edge(clk_i);

    check_fsm_features;

    write(line_buf, string'("a,b,actual,expected"));
    writeline(f_csv, line_buf);

    for a_val in 0 to c_MAX_VALUE loop
      for b_val in 0 to c_MAX_VALUE loop
        a_i <= std_logic_vector(to_unsigned(a_val, 8));
        b_i <= std_logic_vector(to_unsigned(b_val, 8));

        start_i <= '1';
        wait until rising_edge(clk_i);
        start_i <= '0';

        wait until ready_o = '1' and rising_edge(clk_i);

        actual_result := to_integer(unsigned(c_o));
        expected_result := a_val * b_val;

        write(line_buf, a_val);
        write(line_buf, string'(","));
        write(line_buf, b_val);
        write(line_buf, string'(","));
        write(line_buf, actual_result);
        write(line_buf, string'(","));
        write(line_buf, expected_result);
        writeline(f_csv, line_buf);

        if actual_result /= expected_result then
          test_passed := false;
        end if;

      end loop;
    end loop;

    if test_passed then
      assert false report "All tests passed!" severity note;
    else
      assert false report "Some tests failed! Check results.csv" severity error;
    end if;

    run_clock <= false;
    wait;
  end process test_process;

end architecture arch;
