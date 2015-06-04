
//---------------------------------------------------------------------------
// Class: one_operation_jtag_sequence
//---------------------------------------------------------------------------
   
class one_operation_jtag_sequence extends uvm_sequence#( jtag_transaction);
   `uvm_object_utils( one_operation_jtag_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jtag_transaction jtag_tx;
      jtag_tx = jtag_transaction::type_id::create( .name( "jtag_tx" ) );
      start_item( jtag_tx );
      assert( jtag_tx.randomize() );
      finish_item( jtag_tx );
      `uvm_info( "jtag_tx", { "\n",jtag_tx.convert2string() }, UVM_LOW );
   endtask: body
endclass: one_operation_jtag_sequence

