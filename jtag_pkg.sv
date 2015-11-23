//------------------------------------------------------------------------------
// Package: jtag_pkg
//------------------------------------------------------------------------------

package jtag_pkg;
import uvm_pkg::*;

typedef enum bit[1:0] { IEEE_1149_1, IEEE_1500, IEEE_1687} protocol_e;
typedef enum bit[3:0] { TEST_LOGIC_RESET, RUN_TEST_IDLE, SELECT_DR_SCAN, CAPTURE_DR,
                        SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR,UPDATE_DR,SELECT_IR_SCAN,
                        CAPTURE_IR,SHIFT_IR,EXIT1_IR,PAUSE_IR,EXIT2_IR,UPDATE_IR} ieee_1149_1_fsm_e;
`define   CLK_STOP_LOW        255    
`define   TCK_HALF_PERIOD     20     
`define   SYSCLK_HALF_PERIOD  12     
`define   ON                  1
`define   OFF                 0 
//`define   IR_WIDTH            8
`define   MAX_DR_WIDTH        32
`define   IEEE_1149_IR_WIDTH  8
`define   IEEE_1500_IR_WIDTH  10 
`define   LVL1SIB_WIDTH       2 
`define   LVL2SIB_WIDTH       2 
//`define   SIB_WIDTH           (`LVL1SIB_WIDTH + `LVL2SIB_WIDTH 
`define   SIB_WIDTH           4
`define   DFT_REG_ADDR_WIDTH  `IEEE_1500_IR_WIDTH
`define   MAX_N_BYTES         10 
`define   TEST_LOGIC_RESET    4'h0
`define   RUN_TEST_IDLE       4'h1
`define   SELECT_DR_SCAN      4'h2
`define   CAPTURE_DR          4'h3  
`define   SHIFT_DR            4'h4
`define   EXIT1_DR            4'h5
`define   PAUSE_DR            4'h6
`define   EXIT2_DR            4'h7
`define   UPDATE_DR           4'h8
`define   SELECT_IR_SCAN      4'h9
`define   CAPTURE_IR          4'ha
`define   SHIFT_IR            4'hb
`define   EXIT1_IR            4'hc
`define   PAUSE_IR            4'hd
`define   EXIT2_IR            4'he
`define   UPDATE_IR           4'hf                 
//`
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

