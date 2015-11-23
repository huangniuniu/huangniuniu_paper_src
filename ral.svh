//------------------------------------------------------------------------------
//TDR definition
`define SCANCONFIG_OPCODE         `IEEE_1500_IR_WIDTH'h24
`define SCANCONFIG_LENGTH         14
`define SCANCONFIG_RST_VALUE      `SCANCONFIG_LENGTH'h6c
//`define SCANCONFIG_ADDR           {`SCANCONFIG_OPCODE,`SIB_WIDTH'b0010} 
`define SCANCONFIG_ADDR           `DFT_REG_ADDR_WIDTH'h242  

`define IDCODE_OPCODE         `IEEE_1500_IR_WIDTH'hfc
`define IDCODE_LENGTH         8
`define IDCODE_RST_VALUE      `IDCODE_LENGTH'h6c
`define IDCODE_ADDR           {`IDCODE_OPCODE,`SIB_WIDTH'b0101} 

`define BYPASS_OPCODE         `IEEE_1149_IR_WIDTH'hff
`define BYPASS_LENGTH         1
`define BYPASS_RST_VALUE      `BYPASS_LENGTH'h0
`define BYPASS_ADDR          {`BYPASS_OPCODE,`SIB_WIDTH'h0} 

`define I1687_OPCODE         `IEEE_1149_IR_WIDTH'hf0
`define I1687_LENGTH         `LVL1SIB_WIDTH 
`define I1687_RST_VALUE      `I1687_LENGTH'h0
`define I1687_ADDR          {`I1687_OPCODE,`SIB_WIDTH'h0} 

`define SUB_CLIENT_SIB_OPCODE         `IEEE_1500_IR_WIDTH'hc0
`define SUB_CLIENT_SIB_LENGTH         `LVL2SIB_WIDTH 
`define SUB_CLIENT_SIB_RST_VALUE      `SUB_CLIENT_SIB_LENGTH'h0
`define SUB_CLIENT_SIB_ADDR           {`SUB_CLIENT_SIB_OPCODE,`SIB_WIDTH'b0001} 
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Class: ieee1149_bypass_reg
//------------------------------------------------------------------------------

class ieee1149_bypass_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_bypass_reg )

   rand uvm_reg_field bypass;

   function new( string name = "ieee1149_bypass_reg" );
      super.new( .name( name ), .n_bits( `BYPASS_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      bypass = uvm_reg_field::type_id::create( "bypass" );
      bypass.configure( .parent                 ( this ), 
                       .size                   ( `BYPASS_LENGTH    ), 
                       .lsb_pos                ( 0), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `BYPASS_RST_VALUE    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );

   endfunction: build
endclass: ieee1149_bypass_reg

//------------------------------------------------------------------------------
// Class: ieee1500_idcode_reg
//------------------------------------------------------------------------------

class ieee1500_idcode_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_idcode_reg )

   rand uvm_reg_field idcode;
    function new( string name = "ieee1500_idcode_reg" );
      super.new( .name( name ), .n_bits( `IDCODE_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
     idcode = uvm_reg_field::type_id::create( "idcode" );
      idcode.configure( .parent                 ( this ), 
                       .size                   ( `IDCODE_LENGTH    ), 
                       .lsb_pos                ( 0), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `IDCODE_RST_VALUE    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_idcode_reg

//------------------------------------------------------------------------------
// Class: ieee1500_scanconfig_reg
//------------------------------------------------------------------------------

class ieee1500_scanconfig_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_scanconfig_reg )

   rand uvm_reg_field scanconfig;
      function new( string name = "ieee1500_scanconfig_reg" );
      super.new( .name( name ), .n_bits( `SCANCONFIG_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      scanconfig = uvm_reg_field::type_id::create( "scanconfig" );
      scanconfig.configure( .parent                 ( this ), 
                       .size                   ( `SCANCONFIG_LENGTH), 
                       .lsb_pos                ( 0), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `SCANCONFIG_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_scanconfig_reg


//------------------------------------------------------------------------------
// Class: ieee1500_sub_client_sib_reg
//------------------------------------------------------------------------------

class ieee1500_sub_client_sib_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_sub_client_sib_reg )

   rand uvm_reg_field sub_client_sib;
   
   function new( string name = "ieee1500_sub_client_sib_reg" );
   super.new( .name( name ), .n_bits( `SUB_CLIENT_SIB_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      sub_client_sib = uvm_reg_field::type_id::create( "sub_client_sib" );
      sub_client_sib.configure( .parent                 ( this ), 
                       .size                   ( `SUB_CLIENT_SIB_LENGTH), 
                       .lsb_pos                ( 0), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `SUB_CLIENT_SIB_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_sub_client_sib_reg


//------------------------------------------------------------------------------
// Class: dft_register_block
//------------------------------------------------------------------------------

class dft_register_block extends uvm_reg_block;
   `uvm_object_utils( dft_register_block )

   rand ieee1149_bypass_reg            bypass_reg;
   rand ieee1500_idcode_reg            idcode_reg;
   rand ieee1500_scanconfig_reg        scanconfig_reg;
   rand ieee1500_sub_client_sib_reg    sub_client_sib_reg;
   uvm_reg_map                         reg_map;

   function new( string name = "dft_register_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      bypass_reg = ieee1149_bypass_reg::type_id::create( "bypass_reg" );
      bypass_reg.configure( .blk_parent( this ) );
      bypass_reg.build();

      idcode_reg = ieee1500_idcode_reg::type_id::create( "idcode_reg" );
      idcode_reg.configure( .blk_parent( this ) );
      idcode_reg.build();

      scanconfig_reg = ieee1500_scanconfig_reg::type_id::create( "scanconfig_reg" );
      scanconfig_reg.configure( .blk_parent( this ) );
      scanconfig_reg.build();

      sub_client_sib_reg = ieee1500_sub_client_sib_reg::type_id::create( "sub_client_sib_reg" );
      sub_client_sib_reg.configure( .blk_parent( this ) );
      sub_client_sib_reg.build();

      //reg_map = create_map( .name( "reg_map" ), .base_addr( `DFT_REG_ADDR_WIDTH'b0 ),.n_bytes( `MAX_N_BYTES ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map = create_map( .name( "dft_reg_map" ), .base_addr( 0 ),.n_bytes( `MAX_N_BYTES ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map.add_reg( .rg( bypass_reg ), .offset( `BYPASS_ADDR), .rights( "RW" ) );
      reg_map.add_reg( .rg( idcode_reg  ), .offset( `IDCODE_ADDR ), .rights( "RW" ) );
      reg_map.add_reg( .rg( scanconfig_reg), .offset( `SCANCONFIG_ADDR), .rights( "RW" ) );
      reg_map.add_reg( .rg( sub_client_sib_reg), .offset( `SUB_CLIENT_SIB_ADDR), .rights( "RW" ) );
      lock_model(); // finalize the address mapping
   endfunction: build

endclass: dft_register_block   


