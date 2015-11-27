
//---------------------------------------------------------------------------
// Class: one_operation_jtag_sequence
//---------------------------------------------------------------------------
   
class one_operation_jtag_sequence extends uvm_sequence#( jtag_transaction);
   `uvm_object_utils( one_operation_jtag_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jtag_transaction                 jtag_tx;
      bit [`IEEE_1149_IR_WIDTH-1:0]    ir;
      bit [`IDCODE_LENGTH-1:0]         dr;

      jtag_tx = jtag_transaction::type_id::create( .name( "jtag_tx" ) );
      start_item( jtag_tx );

      jtag_tx.o_ir = new[`IEEE_1149_IR_WIDTH];
      jtag_tx.o_ir_length = `IEEE_1149_IR_WIDTH;
      ir = `IEEE_1149_IR_WIDTH'hfc;
      foreach(ir[i]) jtag_tx.o_ir[i] = ir[i];

      jtag_tx.o_dr = new[`IDCODE_LENGTH];
      jtag_tx.o_dr_length = `IDCODE_LENGTH;
      dr = `IDCODE_LENGTH'h3F;
      foreach(dr[i]) jtag_tx.o_dr[i] = dr[i];
      
      jtag_tx.chk_ir_tdo = 1;
      ir = {`IEEE_1149_IR_WIDTH{1'b1}};
      foreach(ir[i]) jtag_tx.exp_tdo_ir_queue.push_front(ir[i]);
      
      
      jtag_tx.chk_dr_tdo = 1;
      dr = `IDCODE_RST_VALUE;
      foreach(dr[i]) jtag_tx.exp_tdo_dr_queue.push_front(dr[i]);


      //assert( jtag_tx.randomize() );
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
      dft_register_block       jtag_reg_block;
      uvm_status_e               status;
      //uvm_reg_data_t             value;
      bit [`IDCODE_LENGTH-1:0]   idcode,exp_tdo_dr;
      bit [`MAX_DR_WIDTH-1:0]    dr_length;
      bit [`DFT_REG_ADDR_WIDTH-1:0]        exp_tdo_ir;
      bit                        chk_ir_tdo,chk_dr_tdo;
      bus_reg_ext                bus_reg_extension;

      //bus_reg_extension = bus_reg_ext::type_id::create(.name("bus_reg_extension"));

      $cast( jtag_reg_block, model );
      dr_length = `IDCODE_LENGTH;
      idcode = `IDCODE_LENGTH'h55;
      //bus_reg_extension.chk_ir_tdo = 1;
      //bus_reg_extension.chk_dr_tdo = 1;
      ////bus_reg_extension.exp_tdo_ir_q = new[`DFT_REG_ADDR_WIDTH]; 
      ////bus_reg_extension.exp_tdo_dr_q = new[`IDCODE_LENGTH]; 
      //exp_tdo_ir = `IDCODE_OPCODE;
      //exp_tdo_dr = `IDCODE_RST_VALUE;

      //foreach(bus_reg_extension.exp_tdo_ir_q[i]) begin
      //   bus_reg_extension.exp_tdo_ir_q[i] = exp_tdo_ir[0];
      //   exp_tdo_ir = exp_tdo_ir >> 1;
      //end

      //foreach(bus_reg_extension.exp_tdo_dr_q[i]) begin
      //   bus_reg_extension.exp_tdo_dr_q[i] = exp_tdo_dr[0];
      //   exp_tdo_dr = exp_tdo_dr >> 1;
      //end

      //write_reg( jtag_reg_block.idcode_reg, status, { idcode, dr_length }, .extension(bus_reg_extension) );
      write_reg( jtag_reg_block.idcode_reg, status, { idcode });
      //write_reg( jtag_reg_block.bypass_reg, status, { `BYPASS_LENGTH'h1});
  endtask: body
endclass: jtag_wr_sequence

