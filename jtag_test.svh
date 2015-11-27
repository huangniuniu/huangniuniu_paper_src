
//---------------------------------------------------------------------------
// Class: jtag_base_test
//---------------------------------------------------------------------------
class jtag_base_test extends uvm_test;
   `uvm_component_utils( jtag_base_test )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   jtag_configuration       jtag_cfg;
   TCK_clk_configuration    TCK_clk_cfg;
   SYSCLK_clk_configuration SYSCLK_clk_cfg;
   reset_configuration      reset_cfg;
   pad_configuration        pad_cfg;
   //jtag_env               jtag_env;
   jtag_env                 env;
   dft_register_block     dft_reg_block; 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      TCK_clk_cfg = TCK_clk_configuration::type_id::create( .name( "TCK_clk_cfg" ) );
      SYSCLK_clk_cfg = SYSCLK_clk_configuration::type_id::create( .name( "SYSCLK_clk_cfg" ) );
      reset_cfg = reset_configuration::type_id::create( .name( "reset_cfg" ) );
      pad_cfg = pad_configuration::type_id::create( .name( "pad_cfg" ) );

      env = jtag_env::type_id::create( .name( "env" ), .parent( this ) );

      dft_reg_block = dft_register_block::type_id::create( .name("dft_reg_block"), .parent( this ));
      dft_reg_block.build();
    
      jtag_cfg.reg_block = dft_reg_block;
      assert(uvm_config_db#( virtual jtag_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_cfg.jtag_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");

      assert(uvm_config_db#( virtual clk_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "TCK_clk_if" ), .value( TCK_clk_cfg.clk_vi) ))
      assert(uvm_config_db#( virtual clk_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "SYSCLK_clk_if" ), .value( SYSCLK_clk_cfg.clk_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
      
      assert(uvm_config_db#( virtual reset_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_if" ), .value( reset_cfg.reset_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
      
      assert(uvm_config_db#( virtual pad_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "pad_if" ), .value( pad_cfg.pad_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
      
      jtag_cfg.gen_stil_file = `OFF;
      TCK_clk_cfg.gen_stil_file = `OFF;
      SYSCLK_clk_cfg.gen_stil_file = `OFF;
      reset_cfg.gen_stil_file = `OFF;
      pad_cfg.gen_stil_file = `OFF;

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
      uvm_config_db#( TCK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( TCK_clk_cfg ) );
      uvm_config_db#( SYSCLK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( SYSCLK_clk_cfg ) );
      uvm_config_db#( reset_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_cfg" ), .value( reset_cfg ) );
      uvm_config_db#( pad_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "pad_cfg" ), .value( pad_cfg ) );
      
   endfunction: build_phase

   virtual function void start_of_simulation_phase( uvm_phase phase );
      super.start_of_simulation_phase( phase );
      uvm_top.print_topology();
   endfunction: start_of_simulation_phase

endclass: jtag_base_test

//---------------------------------------------------------------------------
// Class: jtag_simple_test
//---------------------------------------------------------------------------

class jtag_simple_test extends jtag_base_test;
   `uvm_component_utils( jtag_simple_test )
   string         report_id = "jtag_simple_test" ; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
      //factory.set_type_override_by_name("jtag_driver","jtag_driver_atpg","*");
      //jtag_driver::type_id::set_type_override(jtag_driver_atpg::get_type(),1);
   endfunction: new
   
   function void build_phase( uvm_phase phase);
      super.build_phase( phase );

      jtag_cfg.gen_stil_file = `ON;
      jtag_cfg.stil_file_name = "jtag_simple_test.stil";
      jtag_cfg.tck_half_period = `TCK_HALF_PERIOD;
      
      TCK_clk_cfg.gen_stil_file = `ON;
      TCK_clk_cfg.half_period = `TCK_HALF_PERIOD;
      TCK_clk_cfg.free_running = 0;
      
      SYSCLK_clk_cfg.gen_stil_file = `OFF;
      SYSCLK_clk_cfg.half_period = `SYSCLK_HALF_PERIOD;
      SYSCLK_clk_cfg.free_running = 1;
      
      reset_cfg.gen_stil_file = `ON;

      jtag_cfg.pad_info_init();
      TCK_clk_cfg.pad_info_init();
      SYSCLK_clk_cfg.pad_info_init();
      reset_cfg.pad_info_init();

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
      uvm_config_db#( TCK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( TCK_clk_cfg ) );
      uvm_config_db#( SYSCLK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( SYSCLK_clk_cfg ) );
      uvm_config_db#( reset_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_cfg" ), .value( reset_cfg ) );
      
      `uvm_info(report_id,jtag_cfg.convert2string,UVM_DEBUG);
   endfunction: build_phase

   task main_phase( uvm_phase phase);
      one_operation_jtag_sequence         jtag_reg_seq;
      
      phase.raise_objection( .obj( this ), .description( "start of test" ));

      jtag_reg_seq = one_operation_jtag_sequence::type_id::create( "jtag_reg_seq" );
      jtag_reg_seq.start( env.agent.sqr);
      
      phase.drop_objection( .obj( this ), .description( "end of test" ));
   endtask: main_phase

   //function void report_phase(uvm_phase phase);
   //   string            stil_str;
   //   int               stil_fd;
   //   phase.raise_objection( .obj( this ), .description( "start of report_phase" ));
   //   if(jtag_cfg.gen_stil_file == `ON) begin
   //      stil_fd = $fopen("jtag_simple_test.stil", "a");
   //      stil_str = $sformatf("}\n");
   //      $fdisplay(stil_fd,stil_str);
   //   end
   //   phase.drop_objection( .obj( this ), .description( "end of report_phase" ));
   //endfunction: report_phase
endclass: jtag_simple_test

//---------------------------------------------------------------------------
// Class: jtag_1149_1_test
//---------------------------------------------------------------------------

class jtag_1149_1_test extends jtag_base_test;
   `uvm_component_utils( jtag_1149_1_test )
   string         report_id = "jtag_1149_1_test" ; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
      //factory.set_type_override_by_name("jtag_driver","jtag_driver_atpg","*");
      //jtag_driver::type_id::set_type_override(jtag_driver_atpg::get_type(),1);
   endfunction: new
   
   function void build_phase( uvm_phase phase);
      super.build_phase( phase );

      jtag_cfg.gen_stil_file = `ON;
      jtag_cfg.stil_file_name = "jtag_1149_1_test.stil";
      jtag_cfg.tck_half_period = `TCK_HALF_PERIOD;
      
      TCK_clk_cfg.gen_stil_file = `ON;
      TCK_clk_cfg.half_period = `TCK_HALF_PERIOD;
      TCK_clk_cfg.free_running = 0;
      
      SYSCLK_clk_cfg.gen_stil_file = `OFF;
      SYSCLK_clk_cfg.half_period = `SYSCLK_HALF_PERIOD;
      SYSCLK_clk_cfg.free_running = 1;
      
      reset_cfg.gen_stil_file = `ON;

      jtag_cfg.pad_info_init();
      TCK_clk_cfg.pad_info_init();
      SYSCLK_clk_cfg.pad_info_init();
      reset_cfg.pad_info_init();

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
      uvm_config_db#( TCK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( TCK_clk_cfg ) );
      uvm_config_db#( SYSCLK_clk_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( SYSCLK_clk_cfg ) );
      uvm_config_db#( reset_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_cfg" ), .value( reset_cfg ) );
      
      `uvm_info(report_id,jtag_cfg.convert2string,UVM_DEBUG);
   endfunction: build_phase

   task main_phase( uvm_phase phase);
      jtag_wr_sequence     jtag_reg_seq;
      
      phase.raise_objection( .obj( this ), .description( "start of test" ));

      jtag_reg_seq = jtag_wr_sequence::type_id::create( "jtag_reg_seq" );
      jtag_reg_seq.model = dft_reg_block;
      jtag_reg_seq.start( .sequencer( env.reg_layering.dft_reg_sqr) );
      
      phase.drop_objection( .obj( this ), .description( "end of test" ));
   endtask: main_phase

   //function void report_phase(uvm_phase phase);
   //   string            stil_str;
   //   int               stil_fd;
   //   phase.raise_objection( .obj( this ), .description( "start of report_phase" ));
   //   if(jtag_cfg.gen_stil_file == `ON) begin
   //      stil_fd = $fopen("jtag_1149_1_test.stil", "a");
   //      stil_str = $sformatf("}\n");
   //      $fdisplay(stil_fd,stil_str);
   //   end
   //   phase.drop_objection( .obj( this ), .description( "end of report_phase" ));
   //endfunction: report_phase
endclass: jtag_1149_1_test

//---------------------------------------------------------------------------
// Class: jtag_test
//---------------------------------------------------------------------------

class jtag_test extends uvm_test;
   `uvm_component_utils( jtag_test )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   jtag_configuration   jtag_cfg;
   //jtag_env             jtag_env;
   jtag_env             env;
    
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      env = jtag_env::type_id::create( .name( "env" ), .parent( this ) );

      assert(uvm_config_db#( virtual jtag_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_cfg.jtag_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase);
      one_operation_jtag_sequence jtag_seq;
      
      phase.raise_objection( .obj( this ), .description( "start of test" ));

      jtag_seq = one_operation_jtag_sequence::type_id::create( "jtag_seq" );
      assert( jtag_seq.randomize() );
      `uvm_info( "jtag_test", { "\n",jtag_seq.sprint() }, UVM_LOW );
      jtag_seq.start( env.agent.sqr);
      
      phase.drop_objection( .obj( this ), .description( "end of test" ));
     endtask: run_phase
endclass: jtag_test
