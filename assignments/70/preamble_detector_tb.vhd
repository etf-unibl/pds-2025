-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     preamble_detector_tb
--
-- description:   Self-checking testbench for preamble_detector.
--                Generates clock and reset, applies a serial test vector
--                and checks that match_o pulses once for each
--                non-overlapping occurrence of the "10101010" preamble.
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
-- OTHER DEALINGS IN THE SOFTWARE.
-----------------------------------------------------------------------------
--! @file preamble_detector_tb.vhd
--! @brief Self-checking testbench for the preamble_detector.
--! @details
--!   Drives a fixed serial test vector to data_i, compares match_o
--!   against a simple reference model and reports the total number
--!   of detected mismatches.

library ieee;
use ieee.std_logic_1164.all;


--! @brief Testbench entity without ports.
entity preamble_detector_tb is
end preamble_detector_tb;

--! @brief Testbench architecture for preamble_detector.
--! @details
--!   Instantiates the DUT, generates the clock and reset, and
--!   runs a self-checking stimulus process.
architecture arch of preamble_detector_tb is

  --! @brief Device under test (DUT).
  component preamble_detector is
    port (
      clk_i   : in  std_logic;  --! Clock input for the DUT.
      rst_i   : in  std_logic;  --! Asynchronous reset for the DUT.
      data_i  : in  std_logic;  --! Serial input bit driven by the testbench.
      match_o : out std_logic   --! DUT output that indicates detection of the preamble.
    );
  end component;

  signal clk_i   : std_logic := '0';
  signal rst_i   : std_logic := '0';
  signal data_i  : std_logic := '0';
  signal match_o : std_logic;

  --! @brief Serial test vector.
  --! Number of bits in the test vector.
  constant c_N : integer := 24;
  --! Test sequence containing the preamble.
  constant c_DATA_VEC : std_logic_vector(c_N - 1 downto 0) :=
    "001010101010101010000000";

begin

  uut : preamble_detector
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      data_i  => data_i,
      match_o => match_o
    );

  --! @brief Clock generator with 20 ns period.
  process
  begin
    clk_i <= '0';
    wait for 10 ns;
    clk_i <= '1';
    wait for 10 ns;
  end process;

  --! @brief Stimulus and check process.
  --! @details
  --!   Shifts bits from c_DATA_VEC, builds a reference window last_bits
  --!   and computes expected_match without allowing overlapping pulses.
  --!   Any mismatch between match_o and expected_match is counted.
  sim_proc : process
    variable last_bits : std_logic_vector(7 downto 0) := (others => '0');
    variable expected_match : std_logic;
    variable error_count : integer := 0;
    variable no_overlapping : integer range 0 to 7 := 0;

  begin
    rst_i  <= '1';
    data_i <= '0';
    wait for 40 ns;
    rst_i  <= '0';
    wait for 20 ns;

    for i in 0 to c_N - 1 loop
      data_i <= c_DATA_VEC(i);

      wait until rising_edge(clk_i);
      wait for 1 ns;  -- allow signals in DUT to settle

      last_bits := last_bits(6 downto 0) & c_DATA_VEC(i);

      if (last_bits = "10101010") and (no_overlapping = 0) then
        expected_match := '1';
        no_overlapping := 7;
      else
        expected_match := '0';
        if  no_overlapping > 0 then
          no_overlapping := no_overlapping - 1;
        end  if;
      end if;

      if match_o /= expected_match then
        assert false report " Error: cycle=" & integer'image(i) &
                 ", expected match_o=" & std_logic'image(expected_match) &
                 ", got=" & std_logic'image(match_o)
          severity error;
        error_count := error_count + 1;
      end if;
    end loop;

    if  error_count = 0 then
      assert false report "Simulation finished" severity note;
    else
      assert false report "Total errors: " & integer'image(error_count)
        severity error;
    end if;

    wait;
  end process sim_proc;

end arch;
