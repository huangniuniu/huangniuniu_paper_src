//------------------------------------------------------------------------------
// Package: jtag_pkg
//------------------------------------------------------------------------------

package jtag_pkg;
import uvm_pkg::*;

typedef enum bit[1:0] { IEEE_1149_1, IEEE_1500, IEEE_1687} protocol_e;
typedef enum bit[3:0] { TEST_LOGIC_RESET, RUN_TEST_IDLE, SELECT_DR_SCAN, CAPTURE_DR,
                        SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR,UPDATE_DR,SELECT_IR_SCAN,
                        CAPTURE_IR,SHIFT_IR,EXIT1_IR,PAUSE_IR,EXIT2_IR,UPDATE_IR} ieee_1149_1_fsm_e;
`define   DEBUG        1
`define   IR_WIDTH     8
`define   MAX_DR_WIDTH 32
`define   MAX_N_BYTES  128
`include "ral.svh"
`include "jtag_configuration.svh"
//`include "jtag_transaction.svh"
//`include "jtag_driver.svh"
//`include "jtag_monitor.svh"
//`include "jtag_agent.svh"
//`include "jtag_scoreboard.svh"
`include "jtag_env.svh"
`include "one_operation_jtag_sequence.svh"
`include "jtag_test.svh"
endpackage: jtag_pkg

