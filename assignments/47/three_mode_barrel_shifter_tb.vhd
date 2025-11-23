-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     three_mode_barrel_shifter_tb
--
-- description:
--
--   This file implements a test bench for three_mode_barrel_shifter_tb unit.
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
entity three_mode_barrel_shifter_tb is
end three_mode_barrel_shifter_tb;
architecture arch of three_mode_barrel_shifter_tb is
  component three_mode_barrel_shifter
    port(
    A_i : in  std_logic_vector(7 downto 0);
    LAR_i : in  std_logic_vector(1 downto 0);
    AMT_i : in  std_logic_vector(2 downto 0);
    Y_o   : out std_logic_vector(7 downto 0)
  );
  end component;
  signal A_i_tb   : std_logic_vector(7 downto 0);
  signal LAR_i_tb : std_logic_vector(1 downto 0);
  signal AMT_i_tb : std_logic_vector(2 downto 0);
  signal Y_o_tb   : std_logic_vector(7 downto 0);
begin
  uut : three_mode_barrel_shifter
  port map(
  A_i   => A_i_tb,
  LAR_i => LAR_i_tb,
  AMT_i => AMT_i_tb,
  Y_o   => Y_o_tb
  );
  stim_proc : process
  begin
    A_i_tb <= "10000001";
    LAR_i_tb <= "00";
    AMT_i_tb <= "000";
    wait for 200 ns;
    A_i_tb <= "10000001";
    LAR_i_tb <= "00";
    AMT_i_tb <= "001";
    wait for 200 ns;
    A_i_tb <= "10000001";
    LAR_i_tb <= "00";
    AMT_i_tb <= "111";
    wait for 200 ns;
    A_i_tb <= "10000001";
    LAR_i_tb <= "01";
    AMT_i_tb <= "011";
    wait for 200 ns;
    A_i_tb <= "10000001";
    LAR_i_tb <= "10";
    AMT_i_tb <= "011";
    wait for 200 ns;
    A_i_tb <= "01010101";
    LAR_i_tb <= "11";
    AMT_i_tb <= "101";
    wait for 200 ns;
    wait;
  end process stim_proc;
  check_proc : process
    variable expected : std_logic_vector(7 downto 0);
    variable error_flag : boolean;
    variable error_count : integer := 0;
  begin
    wait on A_i_tb, LAR_i_tb, AMT_i_tb;
    wait for 100 ns;
    if A_i_tb = "10000001" and LAR_i_tb = "00" and AMT_i_tb = "000" then
      expected := "10000001";
    elsif A_i_tb = "10000001" and LAR_i_tb = "00" and AMT_i_tb = "001" then
      expected := "11000000";
    elsif A_i_tb = "10000001" and LAR_i_tb = "00" and AMT_i_tb = "111" then
      expected := "00000011";
    elsif A_i_tb = "10000001" and LAR_i_tb = "01" and AMT_i_tb = "011" then
      expected := "00010000";
    elsif A_i_tb = "10000001" and LAR_i_tb = "10" and AMT_i_tb = "011" then
      expected := "11110000";
    elsif A_i_tb = "01010101" and LAR_i_tb = "11" and AMT_i_tb = "101" then
      expected := "01010101";
    else
      expected := (others => 'X');
    end if;
    if Y_o_tb /= expected then
      error_flag := true;
      error_count := error_count + 1;
    else
      error_flag := false;
    end if;
    assert not error_flag
      report "ERROR: A=" & integer'image(to_integer(unsigned(A_i_tb)))
      & " LAR=" & integer'image(to_integer(unsigned(LAR_i_tb)))
      & " AMT=" & integer'image(to_integer(unsigned(AMT_i_tb)))
      & " Expected=" & integer'image(to_integer(unsigned(expected)))
      & " Got=" & integer'image(to_integer(unsigned(Y_o_tb)))
      severity error;
    assert false report "--- FINISHED TESTING ---" severity note;
    wait for 10 ns;
    if error_count = 0 then
      assert false report "--- TEST PASSED ---" severity note;
    else
      assert false report "--- TEST FAILED ---" severity note;
    end if;
    wait;
  end process check_proc;
end arch;
