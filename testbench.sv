//---------------------------------------------------------------------------
// module: top
//---------------------------------------------------------------------------
module top;
   import uvm_pkg::*;

   logic          tck;
   logic          trst;
   
   jtag_if        jtag_if( tck, trst );
   system_shell   dut( jtag_if.slave_mp );  
   initial begin
      tck = 0;
      #10ns;
      forever #10ns tck = ~tck;
   end

   initial begin
      trst = 0;
      #50ns;
      trst = 1;
      #50ns;
      trst = 0;
   end
   
   initial begin
      uvm_config_db#( virtual jtag_if)::set( .cntxt( null ), .inst_name( "uvm_test_top" ), .field_name( "jtag_if" ), .value( jtag_if ) );
      run_test();
   end
endmodule:top
