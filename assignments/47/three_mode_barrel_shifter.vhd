-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     three_mode_barrel_shifter
--
-- description:
--
--   This file implements three mode shifting logic.
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
entity three_mode_barrel_shifter is
  port (
  A_i   : in  std_logic_vector(7 downto 0);
  LAR_i : in  std_logic_vector(1 downto 0);
  AMT_i : in  std_logic_vector(2 downto 0);
  Y_o   : out std_logic_vector(7 downto 0)
  );
end three_mode_barrel_shifter;
architecture arch of three_mode_barrel_shifter is
begin
  with LAR_i select
  Y_o <= std_logic_vector(unsigned(A_i) ror to_integer(unsigned(AMT_i))) when "00",
  std_logic_vector(shift_right(unsigned(A_i),to_integer(unsigned(AMT_i)))) when "01",
  std_logic_vector(shift_right(signed(A_i),to_integer(unsigned(AMT_i)))) when "10",
  A_i when others;
end arch;
-- architecture rtl of three_mode_barrel_shifter is
-- begin
--    process(A_i, LAR_i, AMT_i)
--        variable amt       : natural range 0 to 7;
--        variable result_v  : std_logic_vector(7 downto 0);
--        variable prefix    : std_logic_vector(7 downto 0);
--        variable temp      : std_logic_vector(15 downto 0);
--    begin
--        amt := to_integer(unsigned(AMT_i));
--
--        if LAR_i = "00" then
--            for i in 0 to 7 loop
--                result_v(i) := A_i((i + amt) mod 8);
--            end loop;
--
--        elsif LAR_i = "01" then
--            if amt = 0 then
--                result_v := A_i;
--            elsif amt >= 8 then
--                result_v := (others => '0');
--            else
--                prefix := (others => '0');
--                temp   := prefix & A_i;
--                result_v := temp(7+amt downto amt);
--            end if;
--
--        elsif LAR_i = "10" then
--            if amt = 0 then
--                result_v := A_i;
--            elsif amt >= 8 then
--                result_v := (others => A_i(7));
--            else
--                prefix := (others => A_i(7));
--                temp   := prefix & A_i;
--                result_v := temp(7+amt downto amt);
--            end if;
--
--        else
--            result_v := A_i;
--        end if;
--
--        Y_o <= result_v;
--    end process;
-- end rtl;
