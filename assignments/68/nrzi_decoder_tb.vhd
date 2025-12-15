-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     nrzi_decoder_tb
--
-- description:
--
--   This file implements a NRZI decoding test-bench.
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


-----------------------------------------------------------------------------
--! @file nrzi_decoder_tb.vhd
--! @brief Testbench for NRZI decoder
--! @details This testbench applies three different input sequences to the NRZI decoder
--!          and compares the output with expected binary values.
-----------------------------------------------------------------------------


--! Use standard library
library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Empty testbench entity
entity nrzi_decoder_tb is
end nrzi_decoder_tb;

--! @brief Testbench architecture for nrzi_decoder
--! @details Defines input sequnces and expected sequnces, generates clock
--!          and checks if logic of nrzi decoder is correct
architecture arch of nrzi_decoder_tb is

  --! @brief NRZI decoder component declaration
  component nrzi_decoder
    port (
      clk_i  : in  std_logic; --! Input clock
      rst_i  : in  std_logic; --! Active-high reset
      data_i : in  std_logic; --! NRZI encoded input
      data_o : out std_logic  --! Decoded output
    );
  end component;

  --! @brief Testbench signals
  signal clk_i  : std_logic := '0';
  signal rst_i  : std_logic := '0';
  signal data_i : std_logic := '0';
  signal data_o : std_logic;
  signal test_stop : std_logic := '0';

  --! @brief Clock period
  constant c_CLK_PERIOD : time := 10 ns;

  --! @brief Type for a single NRZI input sequence
  type t_data_array is array (0 to 3) of std_logic;
  --! @brief Type for an array of NRZI input sequences
  type t_seq_array  is array (0 to 2) of t_data_array;

  --! @brief NRZI input sequnces
  constant c_INPUT_SEQUENCES  : t_seq_array := (
    ('0','0','0','0'),  --! NRZI code for binary array 0,0,0,0
    ('0','1','0','1'),  --! NRZI code for binary array 0,1,1,1
    ('0','1','1','1')   --! NRZI code for binary array 0,1,0,0
  );

  --! @brief Expected decoded outputs
  constant c_EXPECTED_OUTPUTS : t_seq_array := (
    ('0','0','0','0'),
    ('0','1','1','1'),
    ('0','1','0','0')
  );

begin

  --! @brief Instantiate the NRZI decoder
  uut : nrzi_decoder
    port map(
      clk_i  => clk_i,
      rst_i  => rst_i,
      data_i => data_i,
      data_o => data_o
    );

  --! @brief Clock generation
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

  --! @brief Test sequence application and checking
  --! @details Applies multiple NRZI input sequences to the NRZI decoder, compares output with expected values,
  --!          counts errors, applies reset after every input sequence and reports results.
  test_process : process
    variable error_count : integer := 0;
  begin

    rst_i <= '1';
    wait for c_CLK_PERIOD*2;
    rst_i <= '0';
    wait for c_CLK_PERIOD*2;

    for seq_index in c_INPUT_SEQUENCES'range loop
      for bit_index in c_INPUT_SEQUENCES(seq_index)'range loop
        data_i <= c_INPUT_SEQUENCES(seq_index)(bit_index);
        wait for c_CLK_PERIOD;

        if data_o /= c_EXPECTED_OUTPUTS(seq_index)(bit_index) then
          assert false report "error: input=" & std_logic'image(data_i) &
                 ", data_o=" & std_logic'image(data_o) &
                 ", expected=" & std_logic'image(c_EXPECTED_OUTPUTS(seq_index)(bit_index))
            severity warning;
          error_count := error_count + 1;
        else
          assert false report "Correct output: input=" & std_logic'image(data_i) &
                 ", data_o=" & std_logic'image(data_o) severity note;
        end if;
      end loop;

      rst_i <= '1';
      data_i <= '0';

      wait for c_CLK_PERIOD*2;
      rst_i <= '0';
      wait for c_CLK_PERIOD*2;

      wait for c_CLK_PERIOD;
    end loop;

    assert false report "Total errors: " & integer'image(error_count) severity note;

    test_stop <= '1';
    assert false report "Simulation finished" severity note;
    wait;
  end process test_process;

end architecture arch;
