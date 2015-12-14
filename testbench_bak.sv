// Code your testbench here
// or browse Examples
//---------------------------------------------------------------------------
// module: top
//---------------------------------------------------------------------------
module top;
   `timescale 1ns/1ns
   import uvm_pkg::*;

   //logic          tck;
   //logic          trst;
  clk_if         TCK_clk_if(); 
  jtag_if        jtag_if(TCK_clk_if.clk,reset_if.trst);
  clk_if         SYSCLK_clk_if(); 
  reset_if       reset_if(TCK_clk_if.clk);
  pad_if         pad_if(TCK_clk_if.clk);
  system_shell   dut( jtag_if, TCK_clk_if.dut_mp,SYSCLK_clk_if.dut_mp, reset_if, pad_if);
  
   //initial begin
   //   tck = 0;
   //   #10ns;
   //   forever #`TCK_HALF_PERIOD tck = ~tck;
   //end

   //initial begin
   //   trst = 0;
   //   #50ns;
   //   trst = 1;
   //   #50ns;
   //   trst = 0;
   //end
  
   initial begin // waveform
      $vcdpluson;
      //$dumpfile( "dump.vcd" );
      $dumpvars( 0, top );
   end
   
   initial begin
      uvm_config_db#( virtual jtag_if)::set( .cntxt( null ), .inst_name( "" ), .field_name( "jtag_if" ), .value( jtag_if ) );
      uvm_config_db#( virtual clk_if)::set( .cntxt( null ), .inst_name( "" ), .field_name( "TCK_clk_if" ), .value( TCK_clk_if ) );
      uvm_config_db#( virtual clk_if)::set( .cntxt( null ), .inst_name( "" ), .field_name( "SYSCLK_clk_if" ), .value( SYSCLK_clk_if ) );
      uvm_config_db#( virtual reset_if)::set( .cntxt( null ), .inst_name( "" ), .field_name( "reset_if" ), .value( reset_if ) );
      uvm_config_db#( virtual pad_if)::set( .cntxt( null ), .inst_name( "" ), .field_name( "pad_if" ), .value( pad_if ) );
      run_test();
   end
endmodule:top

