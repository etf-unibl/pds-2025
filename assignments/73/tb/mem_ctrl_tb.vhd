-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     mem_ctrl_tb
--
-- description:
--
--   This file implements a testbench for memory controller that manages read
--   and write operations to a hypothetical memory device.
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
--! @file mem_ctrl_tb.vhd
--! @brief Implements a testbench for memory controller that manages read and
--  write operations to a hypothetical memory device.
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use ieee.std_logic_textio.all;

--! @brief Empty testbench entity for the mem_ctrl_tb.
entity mem_ctrl_tb is
end mem_ctrl_tb;
--! @brief Arcitecture implementing the testbench of memory controller.
architecture arch of mem_ctrl_tb is
  --! @brief Constant that represents one period of CLK signal.
  constant c_T : time          := 20 ns;
  --! @brief Signals used for providing input data and catching output data
  --! used for testing purposes.
  signal burst_i : std_logic   := '0'; --! Signal for enabling burst reading mode.
  signal clk_i   : std_logic   := '0'; --! Clock signal.
  signal mem_i   : std_logic   := '0'; --! Signal for representing memory access request.
  signal oe_o    : std_logic;          --! Output enable signal.
  signal rst_i   : std_logic   := '1'; --! Reset signal (active when '1').
  signal rw_i    : std_logic   := '0'; --! Read/write operation control signal.
  signal we_me_o : std_logic;          --! Write enable signal (Mealy logic).
  signal we_o    : std_logic;          --! Write enable signal (Moore logic).
  --! @brief File objects used for manipulating CSV files.
  --! @details These objects are used to read input data and to store results after
  --! performing the tests.
  file input_buf  : text; --! File object used to read input data.
  file output_buf : text; --! File object used to write output data.
  --! @brief Component representing the memory controller.
  component mem_ctrl
    port (
  burst_i : in std_logic;
  clk_i   : in std_logic;
  mem_i   : in std_logic;
  oe_o    : out std_logic;
  rst_i   : in std_logic;
  rw_i    : in std_logic;
  we_me_o : out std_logic;
  we_o    : out std_logic
  );
  end component;
begin
  --! @brief Instantiation of the memory controller.
  i1 : mem_ctrl
  port map (
  burst_i  => burst_i,
  clk_i    => clk_i,
  mem_i    => mem_i,
  oe_o     => oe_o,
  rst_i    => rst_i,
  rw_i     => rw_i,
  we_me_o  => we_me_o,
  we_o     => we_o
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
  --! memory controller, and writes results to output CSV file.
  always : process
    --! @brief Variables used for reading and writing CSV files.
    variable read_col_from_input_buf   : line;
    variable write_col_to_output_buf   : line;
   --! @brief Variables representing input and expected output signals.
    variable v_mem_i                   : std_logic;
    variable v_rw_i                    : std_logic;
    variable v_burst_i                 : std_logic;
    variable v_oe_o                    : std_logic;
    variable v_we_o                    : std_logic;
    variable v_we_me_o                 : std_logic;
   --! @brief CSV parsing variables.
    variable v_comma                   : character;
    variable v_good_num                : boolean;

  begin
    --! @brief Open input CSV file in read mode.
    file_open(input_buf, "mem_ctrl_input.csv", read_mode);
    --! @brief Open input CSV file in write mode.
    file_open(output_buf, "mem_ctrl_output.csv", write_mode);

    --! Write CSV header.
    write(write_col_to_output_buf,
    string'("mem_i,rw_i,burst_i,oe_o,we_o,we_me_o,mem_ctrl_test_results"));
    writeline(output_buf, write_col_to_output_buf);

    --! @brief Main loop for reading inputs, applying test and writing results.
    while not endfile(input_buf) loop
      --! @brief Read one line from input CSV.
      readline(input_buf, read_col_from_input_buf);

      --! @brief Parse input signals from CSV line.
      read(read_col_from_input_buf, v_mem_i, v_good_num);
      next when not v_good_num;
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_rw_i, v_good_num);
      assert v_good_num report "Invalid value for input data rw_i";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_burst_i, v_good_num);
      assert v_good_num report "Invalid value for input data burst_i";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_oe_o, v_good_num);
      assert v_good_num report "Invalid value for input data oe_o";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_we_o, v_good_num);
      assert v_good_num report "Invalid value for input data we_o";
      read(read_col_from_input_buf, v_comma);
      read(read_col_from_input_buf, v_we_me_o, v_good_num);
      assert v_good_num report "Invalid value for input data we_me_o";

      --! @brief Apply input signals to memory controller.
      mem_i   <= v_mem_i;
      rw_i    <= v_rw_i;
      burst_i <= v_burst_i;
      wait until rising_edge(clk_i);

      --! @brief Write applied inputs and calculated outputs to output CSV.
      write(write_col_to_output_buf, mem_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, rw_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, burst_i);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, oe_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, we_o);
      write(write_col_to_output_buf, string'(","));
      write(write_col_to_output_buf, we_me_o);

      --! @brief Check if outputs match expected values and reports an error if they do not.
      --! @details Test results are written to the output CSV file and also reported via assertions.
      if v_oe_o /= oe_o or v_we_o /= we_o or v_we_me_o /= we_me_o then
        assert false report
        "Output mismatch! Given inputs (MEM,RW,BURST)=(" &
        std_logic'image(v_mem_i) & "," & std_logic'image(v_rw_i) & "," & std_logic'image(v_burst_i) &
        "). Expected (OE,WE,WE_ME)=(" &
        std_logic'image(v_oe_o) & "," & std_logic'image(v_we_o) & "," & std_logic'image(v_we_me_o) &
        "), got (" & std_logic'image(oe_o) & "," & std_logic'image(we_o) & "," & std_logic'image(we_me_o) & ")."
        severity error;
        write(write_col_to_output_buf, string'(",ERROR"));
      else
        write(write_col_to_output_buf, string'(",OK"));
      end if;
      writeline(output_buf, write_col_to_output_buf);
    end loop;

    --! @brief Close input and output files.
    file_close(input_buf);
    file_close(output_buf);
    wait;
  end process always;
end arch;
