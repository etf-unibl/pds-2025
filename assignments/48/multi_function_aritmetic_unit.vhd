-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     multi_function_aritmetic_unit
--
-- description:
--
--   This unit implements an unsigned 16-bit arithmetic block that performs
--   one of the following operations:
--     - A_i + B_i
--     - A_i - B_i
--     - A_i + 1
--     - A_i - 1
--   The operation is selected using the 2-bit control input CTRL_i.
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

entity multi_function_aritmetic_unit is
  port (
    A_i    : in  std_logic_vector(15 downto 0);
    B_i    : in  std_logic_vector(15 downto 0);
    CTRL_i : in  std_logic_vector(1 downto 0);
    RES_o  : out std_logic_vector(15 downto 0)
  );
end multi_function_aritmetic_unit;

-- direct architecture

architecture arch of multi_function_aritmetic_unit is
begin
  comb_proc : process (A_i, B_i, CTRL_i)
  begin
    if CTRL_i = "00" then
      RES_o <= std_logic_vector(unsigned(A_i) + unsigned(B_i));
    elsif CTRL_i = "01" then
      RES_o <= std_logic_vector(unsigned(A_i) - unsigned(B_i));
    elsif CTRL_i = "10" then
      RES_o <= std_logic_vector(unsigned(A_i) + 1);
    else
      RES_o <= std_logic_vector(unsigned(A_i) - 1);
    end if;
  end process comb_proc;
end arch;

-- shared architecture

-- architecture shared_arch of multi_function_aritmetic_unit is
--  signal src0_u : unsigned(16 downto 0);
--  signal src1_u : unsigned(16 downto 0);
--  signal r_u    : unsigned(16 downto 0);
--  signal b_tmp_s : std_logic_vector(15 downto 0);
--  signal cin_s   : std_logic;
--  constant c_ONE : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
-- begin
--  -- extend A_i to 17 bits, LSB is '1'
--  src0_u <= unsigned(A_i & '1');
--
--  -- prepare second operand according to CTRL_i
--  b_tmp_s <= B_i        when CTRL_i = "00" else
--             not B_i    when CTRL_i = "01" else
--             c_ONE      when CTRL_i = "10" else
--             not c_ONE;
--
--  -- prepare carry-in bit
--  cin_s <= '0' when CTRL_i = "00" else
--           '0' when CTRL_i = "10" else
--           '1';
--
--  -- merge B_tmp and CIN into a 17-bit operand
--  src1_u <= unsigned(b_tmp_s & cin_s);
--
--  -- single shared adder
--  r_u <= src0_u + src1_u;
--
--  -- drop LSB, take bits 16 downto 1
--  RES_o <= std_logic_vector(r_u(16 downto 1));
-- end shared_arch;
--
-- configuration multi_function_aritmetic_unit_direct_cfg
--  of multi_function_aritmetic_unit is
--  for shared_arch
--  end for;
-- end multi_function_aritmetic_unit_direct_cfg;
--
-- configuration multi_function_aritmetic_unit_direct_cfg
--  of multi_function_aritmetic_unit is
--  for arch
--  end for;
-- end multi_function_aritmetic_unit_direct_cfg;
