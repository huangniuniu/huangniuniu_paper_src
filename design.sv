// Code your design here
include "uvm_macros.svh"
include "jtag_pkg.sv"
include "jtag_if.sv"

//------------------------------------------------------------------------------
// Module: system_shell
//   This is the DUT.
//------------------------------------------------------------------------------

module system_shell( jtag_if.slave_mp jtag_if );
   import jtag_pkg::*; 
       
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
   wire           muxed_tdo; 
  
   assign   reset = jtag_if.trst;
   assign   tck = jtag_if.tck;
   assign   tdi = jtag_if.tdi;

   always@(posedge tck or posedge reset) begin
      if(reset) c_state <= TEST_LOGIC_RESET;
      else c_state <= n_state;
   end

   always@(*) begin
      case (c_state)
         TEST_LOGIC_RESET : n_state[3:0] = jtag_if.tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
         RUN_TEST_IDLE    : n_state[3:0] = jtag_if.tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
         SELECT_DR_SCAN   : n_state[3:0] = jtag_if.tms ? SELECT_IR_SCAN   : CAPTURE_DR;
         CAPTURE_DR       : n_state[3:0] = jtag_if.tms ? EXIT1_DR         : SHIFT_DR;
         SHIFT_DR         : n_state[3:0] = jtag_if.tms ? EXIT1_DR         : SHIFT_DR;
         EXIT1_DR         : n_state[3:0] = jtag_if.tms ? UPDATE_DR        : PAUSE_DR;
         PAUSE_DR         : n_state[3:0] = jtag_if.tms ? EXIT2_DR         : PAUSE_DR;
         EXIT2_DR         : n_state[3:0] = jtag_if.tms ? UPDATE_DR        : SHIFT_DR;
         UPDATE_DR        : n_state[3:0] = jtag_if.tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
         SELECT_IR_SCAN   : n_state[3:0] = jtag_if.tms ? TEST_LOGIC_RESET : CAPTURE_IR;
         CAPTURE_IR       : n_state[3:0] = jtag_if.tms ? EXIT1_IR         : SHIFT_IR;
         SHIFT_IR         : n_state[3:0] = jtag_if.tms ? EXIT1_IR         : SHIFT_IR;
         EXIT1_IR         : n_state[3:0] = jtag_if.tms ? UPDATE_IR        : PAUSE_IR;
         PAUSE_IR         : n_state[3:0] = jtag_if.tms ? EXIT2_IR         : PAUSE_IR;
         EXIT2_IR         : n_state[3:0] = jtag_if.tms ? UPDATE_IR        : SHIFT_IR;
         UPDATE_IR        : n_state[3:0] = jtag_if.tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
      endcase
   end

   assign shift_ir =    (c_state == SHIFT_IR);
   assign shift_dr =    (c_state == SHIFT_DR);
   assign capture_ir =  (c_state == CAPTURE_IR);
   assign capture_dr =  (c_state == CAPTURE_DR);
   assign update_ir =   (c_state == UPDATE_IR);
   assign update_dr =   (c_state == UPDATE_DR);

   //-------------------------------------------------------------------------------
   //1149_1 reg block 
   //-------------------------------------------------------------------------------
   wire[`IR_WIDTH-1:0]      ir;
   wire                     ir_tdo;
   wire                     sel_ir;

   assign sel_ir = c_state == SELECT_IR_SCAN || c_state == CAPTURE_IR || c_state == SHIFT_IR || c_state == EXIT1_IR || c_state == UPDATE_IR;
   
   JTAGTDR  jtag_ir( .RSTVAL ({`IR_WIDTH{1'b1}}), 
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


   wire[`IR_WIDTH-1:0]      idcode;
   wire                     idcode_tdo;
   wire                     sel_idcode;

   JTAGTDR  idcode_tdr( .RSTVAL (8'h6c), 
                     .CAP_D  (idcode),
                     .TDR_Q  (idcode),
                     .CAP    (capture_ir),  
                     .SHF    (shift_ir),
                     .UPD    (update_ir),
                     .TRST   (reset),
                     .TCK    (tck),
                     .TDI    (tdi),
                     .TDO    (idcode_tdo),
                     .SEL    (sel_idcode)  
                    );  







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
   
   always @* begin
     TdrShf = SHF & SEL;  // Only shift this TDR segment if the SEL for this TDR is set
     TdrCap = CAP & SEL;  // Only capture this TDR segment if the SEL for this TDR is set
     TdrUpd = UPD & SEL;  // Only update this TDR segment if the SEL for this TDR is set
     ShTdrNxt = {TDI,ShTdrNxt[LENGTH-1:1]};
   end

   always @(posedge TRST or posedge TCK) begin
      if(TRST) begin
         TDR_Q <= RSTVAL;
      end
      else begin
         if(TdrUpd) TDR_Q <= ShTdr;
         if(TdrCap) ShTdr <= CAP_D;
         if(TdrShf) begin
            ShTdr <= {TDI,ShTdr[LENGTH-1:1]};
            TDO <= ShTdr[0];
         end
      end
   end
   endmodule: JTAGTDR
endmodule: system_shell
