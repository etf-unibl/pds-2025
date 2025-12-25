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
--   This file tests sequential multiplier.
--
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
use std.textio.all;

use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

--! @brief Testbench for the sequential multiplier
--! @details
--! This testbench:
--! - Reads input vectors from a CSV file
--! - Applies operands to the sequential multiplier
--! - Waits for ready_o assertion
--! - Compares expected and real outputs
--! - Writes results to an output CSV file
entity sequential_multiplier_tb is
end sequential_multiplier_tb;

--! @brief Testbench architecture
--! @details
--! Implements clock generation, file I/O, stimulus application,
--! and result checking.
architecture arch of sequential_multiplier_tb is
  --! @brief Sequential multiplier DUT
  --! @details
  --! Multiplies two 8-bit operands using a sequential algorithm.
  component sequential_multiplier
    port(
      clk_i   : in  std_logic;                     --! Clock input
      rst_i   : in  std_logic;                     --! Asynchronous reset
      start_i : in  std_logic;                     --! Start pulse (1 cycle)
      a_i     : in  std_logic_vector(7 downto 0);  --! Operand A
      b_i     : in  std_logic_vector(7 downto 0);  --! Operand B
      c_o     : out std_logic_vector(15 downto 0); --! Product output
      ready_o : out std_logic                      --! Computation done flag
    );
  end component;
  signal clk_i_test     : std_logic;
  signal rst_i_test     : std_logic;
  signal start_i_test   : std_logic;
  signal a_i_test       : std_logic_vector(7 downto 0);
  signal b_i_test       : std_logic_vector(7 downto 0);
  signal c_o_expected   : std_logic_vector(15 downto 0);
  signal c_o_real_value : std_logic_vector(15 downto 0);
  signal ready_o_test   : std_logic;
  file input_buf        : text;
  file output_buf       : text;
  signal stop_flag      : boolean := false;
  constant c_CLK_PERIOD : time := 40 ns;
begin
  uut : sequential_multiplier
    port map(clk_i   => clk_i_test,
             rst_i   => rst_i_test,
             start_i => start_i_test,
             a_i     => a_i_test,
             b_i     => b_i_test,
             c_o     => c_o_real_value,
             ready_o => ready_o_test);
  --! @brief Clock generation process
  --! @details
  --! Generates a free-running clock until stop_flag is asserted.
  clk_process : process
  begin
    while not stop_flag loop
      clk_i_test <= '0';
      wait for c_CLK_PERIOD/2;
      clk_i_test <= '1';
      wait for c_CLK_PERIOD/2;
    end loop;
    clk_i_test <= '0';
    wait;
  end process clk_process;
  --! @brief Main testbench process
  --! @details
  --! Handles file I/O, stimulus generation, synchronization
  --! with ready_o, and result comparison.
  test_process : process
    --! @brief Starts one multiplication transaction
    --! @details
    --! Generates a single-cycle start_i pulse after reset is deasserted.
    procedure start_execution is
    begin
      start_i_test <= '0';
      rst_i_test   <= '0';
      wait for c_CLK_PERIOD;
      start_i_test <= '1';
      wait for c_CLK_PERIOD;
      start_i_test <= '0';
    end procedure start_execution;
    --! @brief Ends the simulation
    --! @details
    --! Stops the clock and terminates the testbench.
    procedure end_execution is
    begin
      start_i_test <= '0';
      stop_flag <= true;
    end procedure end_execution;
    variable read_col_from_file_buf : line;
    variable write_col_to_file_buf : line;
    variable buff_data_from_file_buf : line;
    variable a_i_read_value : natural range 0 to 255;
    variable b_i_read_value : natural range 0 to 255;
    variable c_o_read_value : natural range 0 to 65535;
    variable comma_value : character;
    variable good_value_read : boolean;
  begin
    file_open(input_buf,"testbench_files/input_file.csv",read_mode);
    file_open(output_buf,"testbench_files/output_file.csv",write_mode);
    write(write_col_to_file_buf,string'("##a_i_test, b_i_test, c_o_expected, c_o, status"));
    writeline(output_buf, write_col_to_file_buf);
    while not endfile(input_buf) loop
      readline(input_buf, read_col_from_file_buf);
      read(read_col_from_file_buf,a_i_read_value, good_value_read);
      next when not good_value_read;
      read(read_col_from_file_buf, comma_value);
      read(read_col_from_file_buf,b_i_read_value, good_value_read);
      assert good_value_read report "Bad value in file";
      read(read_col_from_file_buf, comma_value);
      read(read_col_from_file_buf,c_o_read_value, good_value_read);
      assert good_value_read report "Bad value in file";
      a_i_test <= std_logic_vector(to_unsigned(a_i_read_value,8));
      b_i_test <= std_logic_vector(to_unsigned(b_i_read_value,8));
      start_execution;
      c_o_expected <= std_logic_vector(to_unsigned(c_o_read_value,16));
      wait until ready_o_test = '1';
      wait until rising_edge(clk_i_test);
      write(write_col_to_file_buf, to_integer(unsigned(a_i_test)));
      write(write_col_to_file_buf, string'(","));
      write(write_col_to_file_buf, to_integer(unsigned(b_i_test)));
      write(write_col_to_file_buf, string'(","));
      write(write_col_to_file_buf, to_integer(unsigned(c_o_expected)));
      write(write_col_to_file_buf, string'(","));
      write(write_col_to_file_buf, to_integer(unsigned(c_o_real_value)));
      write(write_col_to_file_buf, string'(","));
      if c_o_real_value /= c_o_expected then
        write(write_col_to_file_buf, string'("NOT OK"));
      else
        write(write_col_to_file_buf, string'("OK"));
      end if;
      writeline(output_buf, write_col_to_file_buf);
    end loop;
    file_close(input_buf);
    file_close(output_buf);
    end_execution;
    wait;
  end process test_process;
end arch;
