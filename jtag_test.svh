
//---------------------------------------------------------------------------
// Class: jtag_base_test
//---------------------------------------------------------------------------
class jtag_base_test extends uvm_test;
   `uvm_component_utils( jtag_base_test )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   jtag_configuration       jtag_cfg;
   //jtag_env               jtag_env;
   jtag_env                 env;
   ieee1149_1_reg_block     jtag_reg_block; 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      env = jtag_env::type_id::create( .name( "env" ), .parent( this ) );

      jtag_reg_block = ieee1149_1_reg_block::type_id::create( .name("jtag_reg_block"), .parent( this ));
      jtag_reg_block.build();
    
      jtag_cfg.jtag_reg_block = jtag_reg_block;
      assert(uvm_config_db#( virtual jtag_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_cfg.jtag_vi) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
      uvm_config_db#( bit )::set( .cntxt( null ), .inst_name( "*" ), .field_name( "gen_stil_file" ), .value( `OFF ) );
      
   endfunction: build_phase

   virtual function void start_of_simulation_phase( uvm_phase phase );
      super.start_of_simulation_phase( phase );
      uvm_top.print_topology();
   endfunction: start_of_simulation_phase

endclass: jtag_base_test

//---------------------------------------------------------------------------
// Class: jtag_1149_1_test
//---------------------------------------------------------------------------

class jtag_1149_1_test extends jtag_base_test;
   `uvm_component_utils( jtag_1149_1_test )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   task configure_phase (uvm_phase phase);
      phase.raise_objection( .obj( this ));
      uvm_config_db#( bit )::set( .cntxt( null ), .inst_name( "*" ), .field_name( "gen_stil_file" ), .value( `ON ) );
      phase.drop_objection( .obj( this ));
   endtask

   task pre_main_phase( uvm_phase phase);
      int stil_fd;
      bit           gen_stil_file;
      phase.raise_objection( .obj( this ));
      
      assert(uvm_config_db#(bit)::get ( .cntxt( null ), .inst_name( "*" ), .field_name( "gen_stil_file" ), .value( gen_stil_file) ));
      if (gen_stil_file == `ON)begin
         stil_fd = $fopen("jtag_1149_1_test.stil", "w");
         $fdisplay(stil_fd,"STIL 1.0;");
         uvm_config_db#( int )::set( .cntxt( null ), .inst_name( "*" ), .field_name( "stil_fd" ), .value( stil_fd ) );
         $display("stil_fd = %h",stil_fd);
         $fclose(stil_fd);
         stil_fd = $fopen("jtag_1149_1_test.stil", "a");
         $fdisplay(stil_fd,"header1.0;");
         $display("stil_fd = %h",stil_fd);
      end
      phase.drop_objection( .obj( this ));
   endtask

   task main_phase( uvm_phase phase);
      jtag_wr_sequence      jtag_reg_seq;
      
      phase.raise_objection( .obj( this ), .description( "start of test" ));

      jtag_reg_seq = jtag_wr_sequence::type_id::create( "jtag_reg_seq" );
      jtag_reg_seq.model = jtag_reg_block;
      jtag_reg_seq.start( .sequencer( env.agent.sqr ) );
      
      phase.drop_objection( .obj( this ), .description( "end of test" ));
     endtask: main_phase
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
