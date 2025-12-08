-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     nrzi_encoder_tb
--
-- description:
--
--   This file implements a NRZI(Non-return-to-zero) encoding test-bench.
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

--! @file nrzi_encoder_tb.vhd
--! @brief Testbench for NRZI encoder
--! @details This testbench applies multiple input sequences to the NRZI encoder
--!          and compares the output with expected NRZI encoded values.

--! @brief Testbench entity for NRZI encoder
entity nrzi_encoder_tb is
end nrzi_encoder_tb;

--! @brief Testbench architecture
--! @details Generates clock, applies input sequences, checks output, and reports errors.
architecture arch of nrzi_encoder_tb is

  --! @brief NRZI encoder component declaration
  component nrzi_encoder
    port (
      clk_i  : in  std_logic; --! Input clock
      rst_i  : in  std_logic; --! Active-high reset
      data_i : in  std_logic; --! Input data to encode
      data_o : out std_logic  --! NRZI encoded output
    );
  end component;

  --! @brief Testbench signals
  signal clk_i  : std_logic    := '0'; --! Clock signal
  signal rst_i  : std_logic    := '0'; --! Reset signal
  signal data_i : std_logic    := '0'; --! Input data signal
  signal data_o : std_logic;           --! Output from NRZI encoder
  signal test_stop : std_logic := '0'; --! Test stop signal

  --! @brief Clock period
  constant c_CLK_PERIOD : time := 10 ns;

  --! @brief Type for a single input sequence
  type t_data_array is array (0 to 3) of std_logic;

  --! @brief Type for multiple sequences
  type t_seq_array  is array (0 to 2) of t_data_array;

  --! @brief Input sequences to test
  constant c_INPUT_SEQUENCES  : t_seq_array := (
    ('1','0','1','0'),
    ('0','1','1','0'),
    ('1','1','0','1')
  );
  --! @brief Expected output sequences to test
  constant c_EXPECTED_OUTPUTS : t_seq_array := (
    ('1','1','0','0'),
    ('0','1','0','0'),
    ('1','0','0','1')
  );

begin

  --! @brief Instantiate the NRZI encoder
  uut : nrzi_encoder
    port map(
      clk_i  => clk_i,
      rst_i  => rst_i,
      data_i => data_i,
      data_o => data_o
    );

  --! @brief Clock generation process
  clk_process : process
  begin
    while test_stop = '0' loop
      clk_i <= '0';
      wait for c_CLK_PERIOD/2;
      clk_i <= '1';
      wait for c_CLK_PERIOD/2;
    end loop;
    wait;
  end process clk_process;

  --! @brief Test sequence application and checking process
  --! @details Applies multiple input sequences to the NRZI encoder, compares
  --!          output with expected values, counts errors, and reports results.
  tb : process
    variable error_count : integer := 0; --! Counts number of errors detected
  begin

    rst_i <= '1';
    wait for c_CLK_PERIOD*2;
    rst_i <= '0';
    wait for c_CLK_PERIOD*2;

    for s in c_INPUT_SEQUENCES'range loop
      for i in c_INPUT_SEQUENCES(s)'range loop
        data_i <= c_INPUT_SEQUENCES(s)(i);
        wait for c_CLK_PERIOD;

        if data_o /= c_EXPECTED_OUTPUTS(s)(i) then
          assert false report "error: input=" & std_logic'image(data_i) &
                 ", data_o=" & std_logic'image(data_o) &
                 ", expected=" & std_logic'image(c_EXPECTED_OUTPUTS(s)(i))
            severity warning;
          error_count := error_count + 1;
        else
          assert false report "Correct output: input=" & std_logic'image(data_i) &
                 ", data_o=" & std_logic'image(data_o) severity note;
        end if;
      end loop;

      wait for c_CLK_PERIOD;
    end loop;

    assert false report "Total errors: " & integer'image(error_count) severity note;

    test_stop <= '1';
    assert false report "Simulation finished" severity note;
    wait;
  end process tb;

end architecture arch;
