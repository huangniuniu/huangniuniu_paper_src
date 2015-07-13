//------------------------------------------------------------------------------
//TDR definition
`define IDCODE_OPCODE         `IR_WIDTH'hfc
`define IDCODE_LENGTH         8
`define IDCODE_RST_VALUE      `IDCODE_LENGTH'h6c

`define BYPASS_OPCODE         `IR_WIDTH'hff
`define BYPASS_LENGTH         1
`define BYPASS_RST_VALUE      `BYPASS_LENGTH'h0
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Class: ieee1149_bypass_reg
//------------------------------------------------------------------------------

class ieee1149_bypass_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_bypass_reg )

        uvm_reg_field dr_length;
   rand uvm_reg_field bypass;

   function new( string name = "ieee1149_bypass_reg" );
      super.new( .name( name ), .n_bits( `MAX_DR_WIDTH + `BYPASS_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( 0    ), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      bypass = uvm_reg_field::type_id::create( "bypass" );
      bypass.configure( .parent                 ( this ), 
                       .size                   ( `BYPASS_LENGTH    ), 
                       .lsb_pos                ( `MAX_DR_WIDTH    ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `BYPASS_RST_VALUE    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );

   endfunction: build
endclass: ieee1149_bypass_reg

//------------------------------------------------------------------------------
// Class: ieee1149_idcode_reg
//------------------------------------------------------------------------------

class ieee1149_idcode_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_idcode_reg )

        uvm_reg_field dr_length;
   rand uvm_reg_field idcode;
        uvm_reg_field gen_stil;
        uvm_reg_field chk_ir_tdo;
        uvm_reg_field exp_ir_value;
        uvm_reg_field chk_dr_tdo;
        uvm_reg_field exp_dr_value;

   function new( string name = "ieee1149_idcode_reg" );
      super.new( .name( name ), .n_bits( `MAX_DR_WIDTH + `IDCODE_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( 0    ), 
                        .access                 ( "RW" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      idcode = uvm_reg_field::type_id::create( "idcode" );
      idcode.configure( .parent                 ( this ), 
                       .size                   ( `IDCODE_LENGTH    ), 
                       .lsb_pos                ( `MAX_DR_WIDTH    ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `IDCODE_RST_VALUE    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
/*
      gen_stil = uvm_reg_field::type_id::create( "gen_stil" );
      gen_stil.configure( .parent                 ( this ), 
                       .size                   ( 1), 
                       .lsb_pos                ( `MAX_DR_WIDTH+`IDCODE_LENGTH    ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0), 
                       .has_reset              ( 0    ), 
                       .is_rand                ( 0    ), 
                       .individually_accessible( 0   ) );

      chk_ir_tdo = uvm_reg_field::type_id::create( "chk_ir_tdo" );
      chk_ir_tdo.configure( .parent                 ( this ), 
                       .size                   ( 1), 
                       .lsb_pos                ( `MAX_DR_WIDTH+`IDCODE_LENGTH+1    ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0), 
                       .has_reset              ( 0    ), 
                       .is_rand                ( 0    ), 
                       .individually_accessible( 0   ) );

      chk_dr_tdo = uvm_reg_field::type_id::create( "chk_dr_tdo" );
      chk_dr_tdo.configure( .parent                 ( this ), 
                       .size                   ( 1), 
                       .lsb_pos                ( `MAX_DR_WIDTH+`IDCODE_LENGTH+2   ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0), 
                       .has_reset              ( 0    ), 
                       .is_rand                ( 0    ), 
                       .individually_accessible( 0   ) );

      exp_ir_value = uvm_reg_field::type_id::create( "exp_ir_value" );
      exp_ir_value.configure( .parent                 ( this ), 
                       .size                   ( `IR_WIDTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH+`IDCODE_LENGTH+3   ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0), 
                       .has_reset              ( 0    ), 
                       .is_rand                ( 0    ), 
                       .individually_accessible( 0   ) );

      exp_dr_value = uvm_reg_field::type_id::create( "exp_dr_value" );
      exp_dr_value.configure( .parent                 ( this ), 
                       .size                   ( `IDCODE_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH+`IDCODE_LENGTH+3+`IR_WIDTH), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0), 
                       .has_reset              ( 0    ), 
                       .is_rand                ( 0    ), 
                       .individually_accessible( 0   ) );

*/





   endfunction: build
endclass: ieee1149_idcode_reg

//------------------------------------------------------------------------------
// Class: ieee1149_1_reg_block
//------------------------------------------------------------------------------

class ieee1149_1_reg_block extends uvm_reg_block;
   `uvm_object_utils( ieee1149_1_reg_block )

   rand ieee1149_bypass_reg   bypass_reg;
   rand ieee1149_idcode_reg   idcode_reg;
   uvm_reg_map                reg_map;

   function new( string name = "ieee1149_1_reg_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      bypass_reg = ieee1149_bypass_reg::type_id::create( "bypass_reg" );
      bypass_reg.configure( .blk_parent( this ) );
      bypass_reg.build();

      idcode_reg = ieee1149_idcode_reg::type_id::create( "idcode_reg" );
      idcode_reg.configure( .blk_parent( this ) );
      idcode_reg.build();

      reg_map = create_map( .name( "reg_map" ), .base_addr( `IR_WIDTH'h00 ), 
                            .n_bytes( `MAX_N_BYTES ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map.add_reg( .rg( bypass_reg ), .offset( `BYPASS_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( idcode_reg  ), .offset( `IDCODE_OPCODE ), .rights( "RW" ) );
      lock_model(); // finalize the address mapping
   endfunction: build

endclass: ieee1149_1_reg_block   


