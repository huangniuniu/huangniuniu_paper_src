
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
      bit [`IDCODE_LENGTH-1:0]   idcode,exp_dr_value;
      bit [`MAX_DR_WIDTH-1:0]    dr_length;
      bit [`IR_WIDTH-1:0]        exp_ir_value;
      bit                        gen_stil,chk_ir_tdo,chk_dr_tdo;

      $cast( jtag_reg_block, model );
      dr_length = `IDCODE_LENGTH;
      idcode = `IDCODE_LENGTH'h55;
      gen_stil = 1;
      chk_ir_tdo = 1;
      chk_dr_tdo = 1;
      exp_ir_value = `IDCODE_OPCODE;
      exp_dr_value = `IDCODE_RST_VALUE;
      write_reg( jtag_reg_block.idcode_reg, status, { exp_dr_value,exp_ir_value,chk_dr_tdo,chk_ir_tdo,gen_stil,idcode, dr_length } );
  endtask: body
endclass: jtag_wr_sequence

