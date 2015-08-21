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
   
   jtag_if        jtag_if(clk_if.tck,reset_if.trst);
   clk_if         clk_if();
   reset_if       reset_if();
   system_shell   dut( jtag_if.slave_mp, clk_if, reset_if ); //stophere 
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
    //$dumpvars( 0, top );
   end
   
   initial begin
      uvm_config_db#( virtual jtag_if)::set( .cntxt( null ), .inst_name( "uvm_test_top*" ), .field_name( "jtag_if" ), .value( jtag_if ) );
      uvm_config_db#( virtual clk_if)::set( .cntxt( null ), .inst_name( "uvm_test_top*" ), .field_name( "clk_if" ), .value( clk_if ) );
      run_test();
   end
endmodule:top
