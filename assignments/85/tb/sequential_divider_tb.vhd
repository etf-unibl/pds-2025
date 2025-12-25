-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     sequential_divider_tb
--
-- description:
--
--   This file implements a testbench for sequential divider.
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
--! @file sequential_divider_tb.vhd
--! @brief Implements a testbench for sequential divider with CSV-based
--!        verification.
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use ieee.std_logic_textio.all;

--! Empty top-level entity for the sequential_divider_tb.
entity sequential_divider_tb is
end sequential_divider_tb;

--! Arcitecture implementing the testbench of sequential divider.
architecture arch of sequential_divider_tb is
  --! @brief Constant that represents one period of CLK signal.
  constant c_T : time := 10 ns;
  --! @brief Signals used for providing input data and catching output data
  --! used for testing purposes.
  signal a_i     : std_logic_vector(7 downto 0); --! Signal representing dividend.
  signal b_i     : std_logic_vector(7 downto 0); --! Signal representing divisor.
  signal clk_i   : std_logic;                    --! Clock signal.
  signal q_o     : std_logic_vector(7 downto 0); --! Quotient output signal.
  signal r_o     : std_logic_vector(7 downto 0); --! Remainder output signal.
  signal ready_o : std_logic;                    --! Output ready and calculation done signal.
  signal rst_i   : std_logic;                    --! Reset signal (active when '1').
  signal start_i : std_logic;                    --! Start signal used to initiate division (active when '1').
  --! @brief File objects used for manipulating CSV files.
  --! @details These objects are used to read input data and to store results after
  --! performing the tests.
  file input_buf  : text; --! File object used to read input data.
  file output_buf : text; --! File object used to write output data.
  --! @brief Component representing the sequential divider.
  component sequential_divider
    port (
    a_i     : in std_logic_vector(7 downto 0);
    b_i     : in std_logic_vector(7 downto 0);
    clk_i   : in std_logic;
    q_o     : out std_logic_vector(7 downto 0);
    r_o     : out std_logic_vector(7 downto 0);
    ready_o : out std_logic;
    rst_i   : in std_logic;
    start_i : in std_logic
    );
  end component;
begin
  --! @brief Instantiation of the sequential divider.
  i1 : sequential_divider
  port map (
-- list connections between master ports and signals
  a_i      =>  a_i,
  b_i      =>  b_i,
  clk_i    =>  clk_i,
  q_o      =>  q_o,
  r_o      =>  r_o,
  ready_o  =>  ready_o,
  rst_i    =>  rst_i,
  start_i  =>  start_i
  );

  --! @brief Reset generator: asserts reset for one clock period.
  rst_i <= '1', '0' after c_T;

  --! @brief Clock generator process.
  clk_gen : process
  begin
    clk_i <= '0';
    wait for c_T/2;
    clk_i <= '1';
    wait for c_T/2;
  end process clk_gen;

  --! @brief Main test process that reads input vectors, applies them to the
  --! sequential divider, and writes results to output CSV file.
  always : process
    --! @brief Variables used for reading and writing CSV files.
    variable read_col_from_input_buf   : line;
    variable write_col_to_output_buf   : line;
    --! @brief Variables representing input and expected output signals.
    variable v_a_i : std_logic_vector (7 downto 0);
    variable v_b_i : std_logic_vector (7 downto 0);
    variable v_q_o : std_logic_vector (7 downto 0);
    variable v_r_o : std_logic_vector (7 downto 0);
    variable v_ready_o : std_logic;
    variable v_start_i : std_logic;
    --! @brief CSV parsing variables.
    variable v_comma : character;
    variable v_good_num : boolean;

  begin
    -- code executes for every event on sensitivity list
    --! @brief Open input CSV file in read mode.
    file_open(input_buf, "sequential_divider_input.csv", read_mode);
    --! @brief Open input CSV file in write mode.
    file_open(output_buf, "sequential_divider_output.csv", write_mode);

    --! Write CSV header.
    write(write_col_to_output_buf,
    string'("start_i,a_i,b_i,q_o,r_o,ready_o,sequential_divider_test_results"));
    writeline(output_buf, write_col_to_output_buf);

    --! @brief Main loop for reading inputs, applying test and writing results.
    while not endfile(input_buf) loop
      --! @brief Read one line from input CSV.
      readline(input_buf, read_col_from_input_buf);

      --! @brief Parse input signals from CSV line.
      read(read_col_from_input_buf, v_start_i, v_good_num);
      next when not v_good_num;
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_a_i, v_good_num);
      assert v_good_num report "Invalid value for input data a_i";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_b_i, v_good_num);
      assert v_good_num report "Invalid value for input data b_i";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_q_o, v_good_num);
      assert v_good_num report "Invalid value for input data q_o";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_r_o, v_good_num);
      assert v_good_num report "Invalid value for input data r_o";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_ready_o, v_good_num);
      assert v_good_num report "Invalid value for input data ready_o";

      --! @brief Apply input signals to sequential divider.
      start_i  <= v_start_i;
      a_i      <= v_a_i;
      b_i      <= v_b_i;

      wait until rising_edge(clk_i);

      --! @brief Waiting for calculation process to end.
      if v_start_i = '1' then
        wait until ready_o = '1';
      end if;

      --! @brief Write applied inputs and calculated outputs to output CSV.
      write(write_col_to_output_buf, start_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, a_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, b_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, q_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, r_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, ready_o);

      --! @brief Check if outputs match expected values and reports an error if they do not.
      if v_q_o /= q_o or v_r_o /= r_o or v_ready_o /= ready_o then
        write(write_col_to_output_buf, string'(",ERROR"));
      else
        write(write_col_to_output_buf, string'(",OK"));
      end if;
      --! @brief Writing results in output file.
      writeline(output_buf, write_col_to_output_buf);
    end loop;

    --! @brief Close input and output files.
    file_close(input_buf);
    file_close(output_buf);
    wait;
  end process always;
end arch;
