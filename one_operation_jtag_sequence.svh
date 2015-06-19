
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

//---------------------------------------------------------------------------
// Class: jtag_wr_sequence
//---------------------------------------------------------------------------
   
class jtag_wr_sequence extends uvm_reg_sequence;
   `uvm_object_utils( jtag_wr_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      ieee1149_1_reg_block       jtag_reg_block;
      uvm_status_e               status;
      //uvm_reg_data_t             value;
      bit [7:0]                  idcode;
      bit [`MAX_DR_WIDTH-1:0]    dr_length;

      $cast( jtag_reg_block, model );
      dr_length = 8;
      idcode = 8'h55;
      write_reg( jtag_reg_block.idcode_reg, status, { idcode, dr_length } );
  endtask: body
endclass: jtag_wr_sequence

