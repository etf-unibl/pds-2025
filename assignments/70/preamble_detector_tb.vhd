-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     preamble_detector_tb
--
-- description:   Self-checking testbench for preamble_detector.
--                Generates clock and reset, applies a serial test vector
--                to data_i and uses assert statements to verify that
--                match_o is asserted exactly when the preamble "10101010"
--                appears on the input.
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
--!   Generates clock and reset, applies a serial test vector to data_i
--!   and uses assert statements to verify that match_o is asserted
--!   exactly when the preamble "10101010" appears on the input.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity without ports.
--! @details
--!   The testbench instantiates the DUT and generates all required
--!   stimulus signals internally.
entity preamble_detector_tb is
end preamble_detector_tb;

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
  signal C_DATA_VEC : std_logic_vector(23 downto 0) := "001010101010101010000000";

begin

  uut : preamble_detector
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      data_i  => data_i,
      match_o => match_o
    );

  --! @brief Clock generator with 20 ns period.
  clk_process : process
  begin
    clk_i <= '0';
    wait for 10 ns;
    clk_i <= '1';
    wait for 10 ns;
  end process clk_process;

  --! @brief Stimulus and self-checking process.
  --! @details
  --!   Shifts the input bits from C_DATA_VEC into the DUT and maintains
  --!   a reference shift register last_bits. Whenever last_bits
  --!   equals "10101010", the process expects match_o = '1';
  --!   otherwise it expects match_o = '0'.
  sim_proc : process
    variable last_bits : std_logic_vector(7 downto 0) := (others => '0');
  begin
    rst_i  <= '1';
    data_i <= '0';
    wait for 40 ns;
    rst_i  <= '0';
    wait for 20 ns;

    for i in 0 to 23 loop
      data_i <= C_DATA_VEC(i);

      wait until rising_edge(clk_i);
      wait for 1 ns;  -- allow signals in DUT to settle

      last_bits := last_bits(6 downto 0) & C_DATA_VEC(i);

      if last_bits = "10101010" then
        assert match_o = '1'
          severity error;
      else
        assert match_o = '0'
          severity error;
      end if;
    end loop;

    wait;
  end process sim_proc;

end arch;
