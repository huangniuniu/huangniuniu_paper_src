// Code your design here
`include "uvm_macros.svh"
`include "jtag_pkg.sv"
`include "jtag_if.sv"
//------------------------------------------------------------------------------
// Module: system_shell
//   This is the DUT.
//------------------------------------------------------------------------------

`ifdef UVM_TB
module system_shell( jtag_if.slave_mp jtag_if, clk_if.dut_mp tck_clk_if, clk_if.dut_mp sysclk_clk_if,reset_if.dut_mp reset_if, pad_if.dut_mp pad_if);
   import jtag_pkg::*; 
`else
module top ( TDI, TMS, TRST,RESET_L,TCK,SYSCLK,TDO);
   input TDI,TMS,TRST,RESET_L,TCK,SYSCLK;
   output TDO;
`endif
       
   //-------------------------------------------------------------------------------
   //1149_1 FSM
   //-------------------------------------------------------------------------------
   reg[3:0]       c_state;
   reg[3:0]       n_state;
   wire           shift_ir;
   wire           shift_dr;
   wire           update_ir;
   wire           update_dr;
   wire           capture_ir;
   wire           capture_dr;
   wire           reset; 
   wire           tck; 
   wire           tdi; 
   wire           sysclk; 
`ifdef UVM_TB
   wire           RESET_L = reset_if.RESET_L; 
`else
   wire           RESET_L;
`endif
   wire           VDD; 
   wire           VSS; 
   reg            muxed_tdo; 
   
   //-------------------------------------------------------------------------------
   //1149_1 reg block 
   //-------------------------------------------------------------------------------
   wire[`IEEE_1149_IR_WIDTH-1:0]              ir;
   wire                             ir_tdo;
   reg                              sel_ir;
   reg                              sel_dr;

   //idcode tdr
   wire[`IDCODE_LENGTH-1:0]         idcode;
   wire                             idcode_tdo;
   reg                              sel_idcode;
 
   //bypass tdr
   wire[`BYPASS_LENGTH-1:0]         bypass;
   wire                             bypass_tdo;
   reg                              sel_bypass;
   
   //-------------------------------------------------------------------------------
   //1149_1 FSM
   //-------------------------------------------------------------------------------
   
`ifdef UVM_TB
   assign   reset = reset_if.trst;
   assign   tck = tck_clk_if.clk;
   assign   tdi = jtag_if.tdi;
   assign   jtag_if.tdo = muxed_tdo;
`else
   assign   reset = TRST;
   assign   tck = TCK;
   assign   tdi = TDI;
   assign   TDO = muxed_tdo;
`endif
   always@(posedge tck or posedge reset) begin
      if(reset) c_state <= `TEST_LOGIC_RESET;
      else c_state <= n_state;
   end

   always@(*) begin
      case (c_state)
         `TEST_LOGIC_RESET : n_state[3:0] = jtag_if.tms ? `TEST_LOGIC_RESET : `RUN_TEST_IDLE;
         `RUN_TEST_IDLE    : n_state[3:0] = jtag_if.tms ? `SELECT_DR_SCAN   : `RUN_TEST_IDLE;
         `SELECT_DR_SCAN   : n_state[3:0] = jtag_if.tms ? `SELECT_IR_SCAN   : `CAPTURE_DR;
         `CAPTURE_DR       : n_state[3:0] = jtag_if.tms ? `EXIT1_DR         : `SHIFT_DR;
         `SHIFT_DR         : n_state[3:0] = jtag_if.tms ? `EXIT1_DR         : `SHIFT_DR;
         `EXIT1_DR         : n_state[3:0] = jtag_if.tms ? `UPDATE_DR        : `PAUSE_DR;
         `PAUSE_DR         : n_state[3:0] = jtag_if.tms ? `EXIT2_DR         : `PAUSE_DR;
         `EXIT2_DR         : n_state[3:0] = jtag_if.tms ? `UPDATE_DR        : `SHIFT_DR;
         `UPDATE_DR        : n_state[3:0] = jtag_if.tms ? `SELECT_DR_SCAN   : `RUN_TEST_IDLE;
         `SELECT_IR_SCAN   : n_state[3:0] = jtag_if.tms ? `TEST_LOGIC_RESET : `CAPTURE_IR;
         `CAPTURE_IR       : n_state[3:0] = jtag_if.tms ? `EXIT1_IR         : `SHIFT_IR;
         `SHIFT_IR         : n_state[3:0] = jtag_if.tms ? `EXIT1_IR         : `SHIFT_IR;
         `EXIT1_IR         : n_state[3:0] = jtag_if.tms ? `UPDATE_IR        : `PAUSE_IR;
         `PAUSE_IR         : n_state[3:0] = jtag_if.tms ? `EXIT2_IR         : `PAUSE_IR;
         `EXIT2_IR         : n_state[3:0] = jtag_if.tms ? `UPDATE_IR        : `SHIFT_IR;
         `UPDATE_IR        : n_state[3:0] = jtag_if.tms ? `SELECT_DR_SCAN   : `RUN_TEST_IDLE;
      endcase
   end

   assign shift_ir =    (c_state == `SHIFT_IR);
   assign shift_dr =    (c_state == `SHIFT_DR);
   assign capture_ir =  (c_state == `CAPTURE_IR);
   assign capture_dr =  (c_state == `CAPTURE_DR);
   assign update_ir =   (c_state == `UPDATE_IR);
   assign update_dr =   (c_state == `UPDATE_DR);

   //-------------------------------------------------------------------------------
   //instruction allocation
   //-------------------------------------------------------------------------------
   always@(*)begin
      case(ir)
         `BYPASS_OPCODE:   sel_bypass = 1'b1;
         `IDCODE_OPCODE:   sel_idcode = 1'b1;
      endcase
   end
   //-------------------------------------------------------------------------------
   //tdo mux 
   //-------------------------------------------------------------------------------
   always@(*)begin
      if(sel_ir)
         muxed_tdo = ir_tdo;
      else if(sel_dr)begin
         case(ir)
            `BYPASS_OPCODE:    muxed_tdo = bypass_tdo;
            `IDCODE_OPCODE:    muxed_tdo = idcode_tdo;
         endcase
      end
      else muxed_tdo = 1'bz;
   end
   //-------------------------------------------------------------------------------
   //1149_1 reg block 
   //-------------------------------------------------------------------------------

   assign sel_ir = c_state == `SELECT_IR_SCAN || c_state == `CAPTURE_IR || c_state == `SHIFT_IR || c_state == `EXIT1_IR || c_state == `UPDATE_IR;
   assign sel_dr = c_state == `SELECT_DR_SCAN || c_state == `CAPTURE_DR || c_state == `SHIFT_DR || c_state == `EXIT1_DR || c_state == `UPDATE_DR;
   
   JTAGTDR  #(`IEEE_1149_IR_WIDTH)jtag_ir ( .RSTVAL ({`IEEE_1149_IR_WIDTH{1'b1}}), 
                     .CAP_D  (ir),
                     .TDR_Q  (ir),
                     .CAP    (capture_ir),  
                     .SHF    (shift_ir),
                     .UPD    (update_ir),
                     .TRST   (reset),
                     .TCK    (tck),
                     .TDI    (tdi),
                     .TDO    (ir_tdo),
                     .SEL    (sel_ir)  
                    );  


   JTAGTDR #(8) idcode_tdr ( .RSTVAL (`IDCODE_RST_VALUE), 
                     .CAP_D  (idcode),
                     .TDR_Q  (idcode),
                     .CAP    (capture_dr),  
                     .SHF    (shift_dr),
                     .UPD    (update_dr),
                     .TRST   (reset),
                     .TCK    (tck),
                     .TDI    (tdi),
                     .TDO    (idcode_tdo),
                     .SEL    (sel_idcode)  
                    );  


   JTAGTDR #(1) bypass_tdr ( .RSTVAL (`BYPASS_RST_VALUE), 
                     .CAP_D  (bypass),
                     .TDR_Q  (bypass),
                     .CAP    (capture_dr),  
                     .SHF    (shift_dr),
                     .UPD    (update_dr),
                     .TRST   (reset),
                     .TCK    (tck),
                     .TDI    (tdi),
                     .TDO    (bypass_tdo),
                     .SEL    (sel_bypass)  
                    );  







`ifdef UVM_TB
endmodule: system_shell
`else
endmodule: top 
`endif

module JTAGTDR (RSTVAL, CAP_D, TDR_Q, CAP, SHF, UPD, TRST, TCK, TDI, TDO, SEL);

parameter LENGTH = 1;

// 1149.1 interface
input       [LENGTH-1:0]  RSTVAL;           // Reset value for TDR
input       [LENGTH-1:0]  CAP_D;            // Capture value into TDR
output reg  [LENGTH-1:0]  TDR_Q;            // Update register from TDR

input                     CAP;              // TAP state machine is in the Capture-DR
input                     SHF;              // TAP state machine is in the Shift-DR
input                     UPD;              // TAP state machine is in the Update-DR
input                     TRST;             // Test reset
input                     TCK;              // Test clock
input                     TDI;              // Test data input
output reg                TDO;              // Test data output
input                     SEL;              // Connect to 1687 SIB or 1149.1 decoded instruction or just 1'b1

reg TdrShf;
reg TdrCap;
reg TdrUpd;
reg [LENGTH-1:0] ShTdr;
reg temp;

always @* begin
  TdrShf = SHF & SEL;  // Only shift this TDR segment if the SEL for this TDR is set
  TdrCap = CAP & SEL;  // Only capture this TDR segment if the SEL for this TDR is set
  TdrUpd = UPD & SEL;  // Only update this TDR segment if the SEL for this TDR is set
end

always @(posedge TRST or posedge TCK) begin
   if(TRST) begin
      TDR_Q <= RSTVAL;
   end
   else begin
      if(TdrUpd) TDR_Q <= ShTdr;
      if(TdrCap) ShTdr <= CAP_D;
      if(TdrShf) begin
         {ShTdr,temp} <= {TDI,ShTdr};
      end
   end
end
always @(posedge TRST or negedge TCK) begin
   if(TRST) begin
      TDO <= 1'b0;
   end
   else begin
      if(TdrShf) 
         TDO <= ShTdr[0];
   end
end

endmodule: JTAGTDR

