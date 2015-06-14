//------------------------------------------------------------------------------
// Package: jtag_pkg
//------------------------------------------------------------------------------

package jtag_pkg;
import uvm_pkg::*;

typedef enum bit[1:0] { IEEE_1149_1, IEEE_1500, IEEE_1687} protocol_e;
`define   IR_WIDTH     8
`define   MAX_DR_WIDTH 32
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

