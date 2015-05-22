//---------------------------------------------------------------------------
// Class: jtag_test
//---------------------------------------------------------------------------

class jtag_test extends uvm_test;
   `uvm_component_utils( jtag_test )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   jtag_configuration   jtag_cfg;
   jtag_env             jtag_env;
    
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::creat( "jtag_cfg" );
      jtag_env = jtag_env::type_id::creat( "jtag_env" );

      assert(uvm_config_db#( virtual jtag_if )::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_cfg.jtag_vi) ));
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");

      uvm_config_db#( jtag_configuration )::set( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg ) );
   endfunction: build_phase

   function void run_phase( uvm_phase phase);
      one_operation_jtag_sequence jtag_seq;
      
      phase.raise_objection( .obj( this ), .description( "start of test" ));

      jtag_seq = one_operation_jtag_sequence::type_id::creat( "jtag_seq" );
      assert( jtag_seq.randomize() );
      `uvm_info( "jtag_test", { "\n",jtag_seq.sprint() }, UVM_LOW );
      jtag_seq.start( jtag_env.agent.sqr);
      
      #100ns;
      phase.drop_objection( .obj( this ), .description( "end of test" ));
   endfunction: run_phase
endclass: jtag_test
