
//------------------------------------------------------------------------------
//Project specific
`define TOTAL_TILE_NUM           170
`define MC_CHAIN_LENGTH          8
//------------------------------------------------------------------------------
//1149 TDR definition
`define SCANCONFIG_OPCODE         `IR_WIDTH'h24
`define SCANCONFIG_LENGTH         14
`define SCANCONFIG_RST_VALUE      `SCANCONFIG_LENGTH'h6c

`define IDCODE_OPCODE         `IR_WIDTH'hfc
`define IDCODE_LENGTH         8
`define IDCODE_RST_VALUE      `IDCODE_LENGTH'h6c

`define BYPASS_OPCODE         `IR_WIDTH'hff
`define BYPASS_LENGTH         1
`define BYPASS_RST_VALUE      `BYPASS_LENGTH'h0

`define I1687_OPCODE         `IR_WIDTH'hf0
`define FST_LAYER_LENTH      5
//1500 TDR definition
`define VDCI_P1500_SETUP_OPCODE                    `IEEE1500_IR_WIDTH'h26f             
`define VDCI_P1500_SETUP_LENGTH     3
`define VDCI_P1500_SETUP_RST_VALUE                 `VDCI_P1500_SETUP_LENGTH'h0
`define VDCI_P1500_SETUP_EXIST_IN_TILE         `TOTAL_TILE_NUM'b0 | (1'b1 << 167)     

`define ROSEN_OPCODE                    `IEEE1500_IR_WIDTH'h1cb             
`define ROSEN_EXIST_IN_TILE         `TOTAL_TILE_NUM'b0 | (1'b1 << 169)     

`define PFH_COMMON_ROS_SETUP_OPCODE                    `IEEE1500_IR_WIDTH'h40             
`define PFH_COMMON_ROS_SETUP_LENGTH    8 
`define PFH_COMMON_ROS_SETUP_RST_VALUE                 `PFH_COMMON_ROS_SETUP_LENGTH'h0
`define PFH_COMMON_ROS_SETUP_EXIST_IN_TILE   `TOTAL_TILE_NUM'b111 

`define PFH_COMMON_ROS_STATUS_OPCODE                    `IEEE1500_IR_WIDTH'h41             
`define PFH_COMMON_ROS_STATUS_LENGTH    30 
`define PFH_COMMON_ROS_STATUS_RST_VALUE                 `PFH_COMMON_ROS_STATUS_LENGTH'h0
`define PFH_COMMON_ROS_STATUS_EXIST_IN_TILE   `TOTAL_TILE_NUM'b111 

`define ROSSETUP_OPCODE                    `IEEE1500_IR_WIDTH'h1ca             
`define ROSSETUP_LENGTH    60 
`define ROSSETUP_RST_VALUE                 `ROSSETUP_LENGTH'h0
`define ROSSETUP_EXIST_IN_TILE         `TOTAL_TILE_NUM'b0 | (1'b1 << 169)     

`define DAISY_MODE_OPCODE                    `IEEE1500_IR_WIDTH'h1
`define DAISY_MODE_LENGTH    1 
`define DAISY_MODE_RST_VALUE                 `DAISY_MODE_LENGTH'h0
`define DAISY_MODE_EXIST_IN_TILE         `TOTAL_TILE_NUM'b1 
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Class: ieee1149_bypass_reg
//------------------------------------------------------------------------------

class ieee1149_bypass_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_bypass_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
   rand uvm_reg_field bypass;

   function new( string name = "ieee1149_bypass_reg" );
      super.new( .name( name ), .n_bits(`PROTOCOL_WIDTH + `MAX_DR_WIDTH + `BYPASS_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      bypass = uvm_reg_field::type_id::create( "bypass" );
      bypass.configure( .parent                 ( this ), 
                       .size                   ( `BYPASS_LENGTH    ), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH    ), 
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

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
   rand uvm_reg_field idcode;

   function new( string name = "ieee1149_idcode_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `IDCODE_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "RW" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      idcode = uvm_reg_field::type_id::create( "idcode" );
      idcode.configure( .parent                 ( this ), 
                       .size                   ( `IDCODE_LENGTH    ), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH    ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `IDCODE_RST_VALUE    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );

   endfunction: build
endclass: ieee1149_idcode_reg

//------------------------------------------------------------------------------
// Class: ieee1149_scanconfig_reg
//------------------------------------------------------------------------------

class ieee1149_scanconfig_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_scanconfig_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
   rand uvm_reg_field scanconfig;

   function new( string name = "ieee1149_scanconfig_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `SCANCONFIG_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "RW" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      scanconfig = uvm_reg_field::type_id::create( "scanconfig" );
      scanconfig.configure( .parent                 ( this ), 
                       .size                   ( `SCANCONFIG_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH    ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `SCANCONFIG_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1149_scanconfig_reg

//------------------------------------------------------------------------------
// Class: ieee1149_mc_chain_reg
//------------------------------------------------------------------------------

class ieee1149_mc_chain_reg extends uvm_reg;
   `uvm_object_utils( ieee1149_mc_chain_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
   rand uvm_reg_field mc_chain;

   function new( string name = "ieee1149_mc_chain_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `mc_chain_LENGTH ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "RO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "RW" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      mc_chain = uvm_reg_field::type_id::create( "mc_chain" );
      mc_chain.configure( .parent                 ( this ), 
                       .size                   ( `MC_CHAIN_LENGTH    ), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH    ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );

   endfunction: build
endclass: ieee1149_mc_chain_reg



//------------------------------------------------------------------------------
// Class: ieee1149_1_reg_block
//------------------------------------------------------------------------------

class ieee1149_1_reg_block extends uvm_reg_block;
   `uvm_object_utils( ieee1149_1_reg_block )

   rand ieee1149_bypass_reg                     bypass_reg;
   rand ieee1149_idcode_reg                     idcode_reg;
   rand ieee1149_scanconfig_reg                 scanconfig_reg;
   rand ieee1149_mc_chain_reg                   mc_chain_reg;

   rand ieee1500_vdci_p1500_setup_reg           vdci_p1500_setup_reg;
   rand ieee1500_rossetup_reg                   rossetup_reg;
   rand ieee1500_rosen_reg                      rosen_reg;
   rand ieee1500_pfh_common_ros_status_reg      pfh_common_ros_status_reg;
   rand ieee1500_pfh_common_ros_setup_reg       pfh_common_ros_setup_reg;
   rand ieee1500_daisy_mode_reg                 daisy_mode_reg;
   
   uvm_reg_map                                  reg_map;

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

      scanconfig_reg = ieee1149_scanconfig_reg::type_id::create( "scanconfig_reg" );
      scanconfig_reg.configure( .blk_parent( this ) );
      scanconfig_reg.build();
      
      mc_chain_reg = ieee1149_mc_chain_reg::type_id::create( "mc_chain_reg" );
      mc_chain_reg.configure( .blk_parent( this ) );
      mc_chain_reg.build();
      
      vdci_p1500_setup_reg = ieee1500_vdci_p1500_setup_reg::type_id::create( "vdci_p1500_setup_reg" );
      vdci_p1500_setup_reg.configure( .blk_parent( this ) );
      vdci_p1500_setup_reg.build();

      rossetup_reg = ieee1500_rossetup_reg::type_id::create( "rossetup_reg" );
      rossetup_reg.configure( .blk_parent( this ) );
      rossetup_reg.build();

      rosen_reg = ieee1500_rosen_reg::type_id::create( "rosen_reg" );
      rosen_reg.configure( .blk_parent( this ) );
      rosen_reg.build();

      pfh_common_ros_status_reg = ieee1500_pfh_common_ros_status_reg::type_id::create( "pfh_common_ros_status_reg" );
      pfh_common_ros_status_reg.configure( .blk_parent( this ) );
      pfh_common_ros_status_reg.build();

      pfh_common_ros_setup_reg = ieee1500_pfh_common_ros_setup_reg::type_id::create( "pfh_common_ros_setup_reg" );
      pfh_common_ros_setup_reg.configure( .blk_parent( this ) );
      pfh_common_ros_setup_reg.build();

      daisy_mode_reg = ieee1500_daisy_mode_reg::type_id::create( "daisy_mode_reg" );
      daisy_mode_reg.configure( .blk_parent( this ) );
      daisy_mode_reg.build();


      reg_map = create_map( .name( "reg_map" ), .base_addr( `IR_WIDTH'h00 ), 
                            .n_bytes( `MAX_N_BYTES ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map.add_reg( .rg( bypass_reg ), .offset( `BYPASS_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( idcode_reg  ), .offset( `IDCODE_OPCODE ), .rights( "RW" ) );
      reg_map.add_reg( .rg( scanconfig_reg), .offset( `SCANCONFIG_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( mc_chain_reg), .offset( `I1687_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( vdci_p1500_setup_reg ), .offset( `VDCI_P1500_SETUP_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( rossetup_reg  ), .offset( `ROSSETUP_OPCODE ), .rights( "RW" ) );
      reg_map.add_reg( .rg( rosen_reg), .offset( `ROSEN_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( pfh_common_ros_setup_reg), .offset( `PFH_COMMON_ROS_SETUP_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( pfh_common_ros_status_reg), .offset( `PFH_COMMON_ROS_STATUS_OPCODE), .rights( "RW" ) );
      reg_map.add_reg( .rg( daisy_mode_reg), .offset( `DAISY_MODE_OPCODE), .rights( "RW" ) );
 
      lock_model(); // finalize the address mapping
   endfunction: build

endclass: ieee1149_1_reg_block   

//------------------------------------------------------------------------------
// Class: ieee1500_rossetup_reg
//------------------------------------------------------------------------------

class ieee1500_rossetup_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_rossetup_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field rossetup;

   function new( string name = "ieee1500_rossetup_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `ROSSETUP_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      rossetup = uvm_reg_field::type_id::create( "rossetup" );
      rossetup.configure( .parent                 ( this ), 
                       .size                   ( `ROSSETUP_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `ROSSETUP_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_rossetup_reg

//------------------------------------------------------------------------------
// Class: ieee1500_vdci_p1500_setup_reg
//------------------------------------------------------------------------------

class ieee1500_vdci_p1500_setup_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_vdci_p1500_setup_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field vdci_p1500_setup;

   function new( string name = "ieee1500_vdci_p1500_setup_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `VDCI_P1500_SETUP_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      vdci_p1500_setup = uvm_reg_field::type_id::create( "vdci_p1500_setup" );
      vdci_p1500_setup.configure( .parent                 ( this ), 
                       .size                   ( `VDCI_P1500_SETUP_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `VDCI_P1500_SETUP_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_vdci_p1500_setup_reg

//------------------------------------------------------------------------------
// Class: ieee1500_rosen_reg
//------------------------------------------------------------------------------

class ieee1500_rosen_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_rosen_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field rosen;

   function new( string name = "ieee1500_rosen_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `ROSEN_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      rosen = uvm_reg_field::type_id::create( "rosen" );
      rosen.configure( .parent                 ( this ), 
                       .size                   ( `ROSEN_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `ROSEN_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_rosen_reg


//------------------------------------------------------------------------------
// Class: ieee1500_pfh_common_ros_setup_reg
//------------------------------------------------------------------------------

class ieee1500_pfh_common_ros_setup_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_pfh_common_ros_setup_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field pfh_common_ros_setup;

   function new( string name = "ieee1500_pfh_common_ros_setup_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `PFH_COMMON_ROS_SETUP_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      pfh_common_ros_setup = uvm_reg_field::type_id::create( "pfh_common_ros_setup" );
      pfh_common_ros_setup.configure( .parent                 ( this ), 
                       .size                   ( `PFH_COMMON_ROS_SETUP_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `PFH_COMMON_ROS_SETUP_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_pfh_common_ros_setup_reg

//------------------------------------------------------------------------------
// Class: ieee1500_pfh_common_ros_status_reg
//------------------------------------------------------------------------------

class ieee1500_pfh_common_ros_status_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_pfh_common_ros_status_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field pfh_common_ros_status;

   function new( string name = "ieee1500_pfh_common_ros_status_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `PFH_COMMON_ROS_STATUS_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      pfh_common_ros_status = uvm_reg_field::type_id::create( "pfh_common_ros_status" );
      pfh_common_ros_status.configure( .parent                 ( this ), 
                       .size                   ( `PFH_COMMON_ROS_STATUS_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `PFH_COMMON_ROS_STATUS_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_pfh_common_ros_status_reg


//------------------------------------------------------------------------------
// Class: ieee1500_daisy_mode_reg
//------------------------------------------------------------------------------

class ieee1500_daisy_mode_reg extends uvm_reg;
   `uvm_object_utils( ieee1500_daisy_mode_reg )

        uvm_reg_field protocol;
        uvm_reg_field dr_length;
        uvm_reg_field exist_in_tile;
   rand uvm_reg_field daisy_mode;

   function new( string name = "ieee1500_daisy_mode_reg" );
      super.new( .name( name ), .n_bits( `PROTOCOL_WIDTH + `MAX_DR_WIDTH + `DAISY_MODE_LENGTH + `TOTAL_TILE_NUM ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      protocol = uvm_reg_field::type_id::create( "protocol" );
      protocol.configure( .parent                 ( this ), 
                        .size                   ( `PROTOCOL_WIDTH   ), 
                        .lsb_pos                ( 0), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );



      dr_length = uvm_reg_field::type_id::create( "dr_length" );
      dr_length.configure( .parent                 ( this ), 
                        .size                   ( `MAX_DR_WIDTH    ), 
                        .lsb_pos                ( `PROTOCOL_WIDTH    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );

      exist_in_tile = uvm_reg_field::type_id::create( "exist_in_tile" );
      exist_in_tile.configure( .parent                 ( this ), 
                        .size                   ( `TOTAL_TILE_NUM), 
                        .lsb_pos                ( `PROTOCOL_WIDTH + `MAX_DR_WIDTH   ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 0    ), 
                        .is_rand                ( 0    ), 
                        .individually_accessible( 0    ) );


      daisy_mode = uvm_reg_field::type_id::create( "daisy_mode" );
      daisy_mode.configure( .parent                 ( this ), 
                       .size                   ( `DAISY_MODE_LENGTH), 
                       .lsb_pos                ( `MAX_DR_WIDTH + `PROTOCOL_WIDTH + `TOTAL_TILE_NUM   ), 
                       .access                 ( "RW" ), 
                       .volatile               ( 0    ),
                       .reset                  ( `DAISY_MODE_RST_VALUE), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 0   ) );
   endfunction: build
endclass: ieee1500_daisy_mode_reg

