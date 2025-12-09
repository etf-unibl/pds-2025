-----------------------------------------------------------------------------
-- Faculty of Electrical Engineering
-- PDS 2025
-- https://github.com/etf-unibl/pds-2025/
-----------------------------------------------------------------------------
--
-- unit name:     mem_ctrl
--
-- description:
--
--   This file implements a memory controller that manages read and write
--   operations to a hypothetical memory device. It supports single and burst
--   read operations.
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
--! @file mem_ctrl.vhd
--! @brief Implements a memory controller that manages read and write
--  operations to a hypothetical memory device
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


--! @brief Entity definition of mem_ctrl.
entity mem_ctrl is
  port (
  clk_i   : in  std_logic; --! Clock signal
  rst_i   : in  std_logic; --! Reset signal (active when '1')
  mem_i   : in  std_logic; --! Signal for representing memory access request
  rw_i    : in  std_logic; --! Read/write operation control signal
  burst_i : in  std_logic; --! Signal for enabling burst (multiple) reading
  oe_o    : out std_logic; --! Output enable signal
  we_o    : out std_logic; --! Write enable signal (Moore logic)
  we_me_o : out std_logic  --! Write enable signal (Mealy logic)
);
end mem_ctrl;

--! @brief Architecture implementing the memory controller logic.
architecture arch of mem_ctrl is
  --! Type that represents possible states of memory controller (based on FSM).
  type t_mc_sm_type is (idle, read1, read_burst_1, read2, read3, read4, write);
  --! @brief Registers for current and next states of the FSM.
  signal state_reg, state_next : t_mc_sm_type;
begin
  --! State register process that implements logic of generating clock signal.
  process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      state_reg <= idle;
    elsif rising_edge(clk_i) then
      state_reg <= state_next; --! Change of state happens on rising edge of CLK.
    end if;
  end process;
  --! @brief Next-state logic process implementing state transitions.
  process(state_reg, mem_i, rw_i, burst_i)
  begin
    case state_reg is
      when idle =>
        if mem_i = '1' then
          if rw_i = '1' then
            if burst_i = '0' then
              state_next <= read1; --! Single read operation.
            else
              state_next <= read_burst_1; --! Burst read operation.
            end if;
          else
            state_next <= write;
          end if;
        else
          state_next <= idle;
        end if;
      when write =>
        state_next <= idle;
      when read1 =>
        state_next <= idle;
      when read_burst_1 =>
        state_next <= read2;
      when read2 =>
        state_next <= read3;
      when read3 =>
        state_next <= read4;
      when read4 =>
        state_next <= idle;
    end case;
  end process;
  --! @brief Moore output logic process generating outputs based on the current state.
  --! Current state changes on next rising edge of CLK.
  process(state_reg)
  begin
    we_o <= '0'; --! Default value.
    oe_o <= '0'; --! Default value.
    case state_reg is
      when idle =>
      when write =>
        we_o <= '1';
      when read1 =>
        oe_o <= '1';
      when read_burst_1 =>
        oe_o <= '1';
      when read2 =>
        oe_o <= '1';
      when read3 =>
        oe_o <= '1';
      when read4 =>
        oe_o <= '1';
    end case;
  end process;
  --! @brief Mealy output logic process generating output based on inputs and state.
  --! Curent state changes on transition from one state to another.
  process(state_reg, mem_i, rw_i)
  begin
    we_me_o <= '0'; --! Default value.
    case state_reg is
      when idle =>
        if (mem_i = '1') and (rw_i = '0') then
          we_me_o <= '1';
        end if;
      when write =>
      when read1 =>
      when read_burst_1 =>
      when read2 =>
      when read3 =>
      when read4 =>
    end case;
  end process;
end arch;
