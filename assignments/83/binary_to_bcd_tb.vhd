-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     binary_to_bcd_tb.vhd
--
-- description:
--
--   This file implements test bench for binary_to_bcd unit.
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
--! @file binary_to_bcd_tb.vhd
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief @brief Empty entity for testbench
entity binary_to_bcd_tb is
end entity binary_to_bcd_tb;

--! @brief Architecture of dual_edge_detector test bench
architecture arch of binary_to_bcd_tb is
  constant c_CLK_PERIOD : time := 10 ns;
  component binary_to_bcd is
    port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      start_i  : in  std_logic;
      binary_i : in  std_logic_vector(12 downto 0);
      bcd1_o   : out std_logic_vector(3 downto 0);
      bcd2_o   : out std_logic_vector(3 downto 0);
      bcd3_o   : out std_logic_vector(3 downto 0);
      bcd4_o   : out std_logic_vector(3 downto 0);
      ready_o  : out std_logic
    );
  end component;

  signal clk_i    : std_logic := '0';
  signal rst_i    : std_logic := '1';
  signal start_i  : std_logic := '0';
  signal binary_i : std_logic_vector(12 downto 0) := (others => '0');
  signal bcd1_o   : std_logic_vector(3 downto 0);
  signal bcd2_o   : std_logic_vector(3 downto 0);
  signal bcd3_o   : std_logic_vector(3 downto 0);
  signal bcd4_o   : std_logic_vector(3 downto 0);
  signal ready_o  : std_logic;
  signal flag     : std_logic;

begin

  clk_gen : process
  begin
    if flag = '1' then
      wait;
    end if;
    clk_i <= '0';
    wait for c_CLK_PERIOD / 2;
    clk_i <= '1';
    wait for c_CLK_PERIOD / 2;
  end process clk_gen;

  uut : binary_to_bcd
    port map (
      clk_i    => clk_i,
      rst_i    => rst_i,
      start_i  => start_i,
      binary_i => binary_i,
      bcd1_o   => bcd1_o,
      bcd2_o   => bcd2_o,
      bcd3_o   => bcd3_o,
      bcd4_o   => bcd4_o,
      ready_o  => ready_o
    );

  stim_proc : process
    variable value    : integer;
    variable exp_bcd1 : std_logic_vector(3 downto 0);
    variable exp_bcd2 : std_logic_vector(3 downto 0);
    variable exp_bcd3 : std_logic_vector(3 downto 0);
    variable exp_bcd4 : std_logic_vector(3 downto 0);
    variable got_dec  : integer;
    variable exp_dec  : integer;
    variable error_count : integer := 0;
    variable total_tests : integer := 0;
  begin
    rst_i    <= '1';
    start_i  <= '0';
    binary_i <= (others => '0');
    flag <= '0';
    wait for 3 * c_CLK_PERIOD;
    rst_i <= '0';
    wait for c_CLK_PERIOD;

    for value in 0 to 8191 loop

      wait until rising_edge(clk_i) and ready_o = '1';

      binary_i <= std_logic_vector(to_unsigned(value, 13));
      start_i  <= '1';
      wait until rising_edge(clk_i);
      start_i  <= '0';

      wait until rising_edge(clk_i) and ready_o = '1';

      exp_bcd1 := std_logic_vector(to_unsigned(value / 1000, 4));
      exp_bcd2 := std_logic_vector(to_unsigned((value / 100) mod 10, 4));
      exp_bcd3 := std_logic_vector(to_unsigned((value / 10)  mod 10, 4));
      exp_bcd4 := std_logic_vector(to_unsigned(value mod 10, 4));

      exp_dec :=
          (to_integer(unsigned(exp_bcd1)) * 1000) +
          (to_integer(unsigned(exp_bcd2)) * 100)  +
          (to_integer(unsigned(exp_bcd3)) * 10)   +
          (to_integer(unsigned(exp_bcd4)));

      got_dec :=
          (to_integer(unsigned(bcd1_o)) * 1000) +
          (to_integer(unsigned(bcd2_o)) * 100)  +
          (to_integer(unsigned(bcd3_o)) * 10)   +
          (to_integer(unsigned(bcd4_o)));

      if (bcd1_o /= exp_bcd1) or
         (bcd2_o /= exp_bcd2) or
         (bcd3_o /= exp_bcd3) or
         (bcd4_o /= exp_bcd4)
      then
        error_count := error_count + 1;
        assert false report "ERROR: value=" & integer'image(value) &
               " expected=" & integer'image(exp_dec) &
               " got="      & integer'image(got_dec)
          severity error;
      end if;
    end loop;

    if error_count > 0 then
      assert false report "Simulation failed on " & integer'image(error_count) & " tests.";
    else
      assert false report "Simulation finished with 0 errors." severity note;
    end if;
    flag <= '1';
    wait;
  end process stim_proc;
end architecture arch;
