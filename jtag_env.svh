//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;

    rand  protocol_e                 protocol;

    rand  bit [`IR_WIDTH-1:0]        o_ir;

    rand  int unsigned               o_dr_length;
    bit                              o_dr[];
    //rand  bit [o_dr_length-1:0]      o_dr;
    
   //tdo_dr_queue/tdo_ir_queue  store tdo data
    bit                              tdo_dr_queue[$];
    bit                              tdo_ir_queue[$];

    //tdi_dr_queue/tdi_ir_queue  store tdi data
    bit                              tdi_dr_queue[$];
    bit                              tdi_ir_queue[$];
   
    `uvm_object_utils( jtag_transaction )
    
    function new(string name = "jtag_transaction");
        super.new(name);
        o_dr = new[ o_dr_length ];

    endfunction
    
    constraint o_dr_length_c { 
       o_dr_length >= 8;
       o_dr_length <= 64;
    }
    
    function void post_randomize;
        o_dr = new[ o_dr_length ];
        
        foreach( o_dr[i] )
            o_dr[i] = $urandom;
    endfunction: post_randomize
    
    function string convert2string();
        string       s;
        int unsigned hex_value;
        int unsigned four_bits_num = o_dr_length / 4;
        int unsigned remainder = o_dr_length % 4;

        s = super.convert2string();
        
        $sformat(s, "%s\n ////////////////////////////////////////////////////////////\n jtag_transaction\n protocol \t%0s\n o_ir \t%8b\n o_dr_length \t%0d\n o_dr \t",s, protocol.name(), o_ir, o_dr_length);
         
        if (remainder != 0) begin
            if (remainder == 1)
                hex_value = o_dr[four_bits_num*4];
            else if (remainder == 2)
                hex_value = o_dr[four_bits_num*4 + 1] *2 + o_dr[four_bits_num*4];
            else if (remainder == 3)
                hex_value = o_dr[four_bits_num*4 + 2] *4 + o_dr[four_bits_num*4 + 1] *2 + o_dr[four_bits_num*4];
            $sformat(s, "%s%0h",s,hex_value);
        end 
        
        for ( int i = 0; i < four_bits_num; i++) begin
            hex_value = o_dr[i*4+3] *8 + o_dr[i*4+2] *4 + o_dr[i*4+1] *2 + o_dr[i*4];
            $sformat(s, "%s%0h",s,hex_value);
        end
        
        $sformat(s, "%s\n ////////////////////////////////////////////////////////////\n",s);
        return s;
    endfunction: convert2string

    function string print_queue();
       string     s;

       $sformat(s, "\n ///////////////tdi_ir_queue//////////////////////////\n" );
       foreach( tdi_ir_queue[i] )
            $sformat(s, "%s%0b",s,tdi_ir_queue[$-i] );
       $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);

       $sformat(s, "%s\n ///////////////tdi_dr_queue//////////////////////////\n",s);
       foreach( tdi_dr_queue[i] )
            $sformat(s, "%s%0b",s,tdi_dr_queue[$-i] );
       $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);

       $sformat(s, "%s\n ///////////////tdo_ir_queue//////////////////////////\n",s);
       foreach( tdo_ir_queue[i] )
            $sformat(s, "%s%0b",s,tdo_ir_queue[$-i] );
       $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);

       $sformat(s, "%s\n ///////////////tdo_dr_queue//////////////////////////\n",s);
       foreach( tdo_dr_queue[i] )
            $sformat(s, "%s%0b",s,tdo_dr_queue[$-i] );
       $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);
       return s;
    endfunction: print_queue
endclass:jtag_transaction

//------------------------------------------------------------------------------
// class: jtag_monitor
//------------------------------------------------------------------------------
class jtag_monitor extends uvm_monitor;
   `uvm_component_utils( jtag_monitor )

   virtual jtag_if jtag_vi;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
  
   uvm_analysis_port #(jtag_transaction) jtag_ap;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      //assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_vi) ));
      //else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
      
      jtag_ap = new( .name("jtag_ap"), .parent(this) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      
      ieee_1149_1_fsm_e     c_state;
      jtag_transaction      jtag_tx;
     
      @(negedge jtag_vi.monitor_mp.trst) begin
         c_state = TEST_LOGIC_RESET;
      end
      forever @jtag_vi.monitor_mp.monitor_cb begin
         `uvm_info( "mon",{ "before assignment ",c_state.name }, UVM_DEBUG );
         `uvm_info( "mon",{ $sformatf( "tms = %0b, tdi = %0b", jtag_vi.monitor_mp.monitor_cb.tms, jtag_vi.monitor_mp.monitor_cb.tdi ) }, UVM_DEBUG );
         if( c_state == CAPTURE_IR)begin
            //create a jtag transaction for boradcasting.
            jtag_tx = jtag_transaction::type_id::create( .name("jtag_tx") );
            jtag_tx.o_dr_length = 0;
         end
         
         if( c_state == UPDATE_DR)begin
            jtag_ap.write(jtag_tx);
            `uvm_info("mon",{jtag_tx.print_queue()}, UVM_LOW);
         end

         case (c_state)
            TEST_LOGIC_RESET: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = RUN_TEST_IDLE;
            end
            
            RUN_TEST_IDLE: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = SELECT_DR_SCAN;
            end
            
            SELECT_DR_SCAN: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = SELECT_IR_SCAN;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = CAPTURE_DR;
            end

            CAPTURE_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT1_DR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = SHIFT_DR;
            end
            
            SHIFT_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT1_DR;

               jtag_tx.o_dr_length = jtag_tx.o_dr_length + 1;

               //collects tdi/tdo data 
               jtag_tx.tdi_dr_queue = { jtag_tx.tdi_dr_queue,jtag_vi.monitor_mp.monitor_cb.tdi };
               jtag_tx.tdo_dr_queue = { jtag_tx.tdo_dr_queue,jtag_vi.monitor_mp.monitor_cb.tdo };

            end

            EXIT1_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = UPDATE_DR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = PAUSE_DR;
            end
            
            PAUSE_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT2_DR;
            end
            
            EXIT2_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = UPDATE_DR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = SHIFT_DR;
            end
            
            UPDATE_DR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = SELECT_DR_SCAN;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = RUN_TEST_IDLE;
            end
            
            SELECT_IR_SCAN: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = TEST_LOGIC_RESET;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = CAPTURE_IR;
            end

            CAPTURE_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT1_IR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = SHIFT_IR;
            end
            
            SHIFT_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT1_IR;

               //collects tdi/tdo data 
               jtag_tx.tdi_ir_queue = { jtag_tx.tdi_ir_queue,jtag_vi.monitor_mp.monitor_cb.tdi };
               jtag_tx.tdo_ir_queue = { jtag_tx.tdo_ir_queue,jtag_vi.monitor_mp.monitor_cb.tdo };
            end

            EXIT1_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = UPDATE_IR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = PAUSE_IR;
            end
            
            PAUSE_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = EXIT2_IR;
            end
            
            EXIT2_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = UPDATE_IR;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = SHIFT_IR;
            end
            
            UPDATE_IR: begin
               if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b1) c_state = SELECT_DR_SCAN;
               else if(jtag_vi.monitor_mp.monitor_cb.tms == 1'b0) c_state = RUN_TEST_IDLE;
            end   
         endcase
         
         `uvm_info( "mon",{ "after assignment ",c_state.name }, UVM_DEBUG );
      end
   endtask: run_phase    


endclass:jtag_monitor

//---------------------------------------------------------------------------
// Class: jtag_driver
//---------------------------------------------------------------------------

class jtag_driver extends uvm_driver#( jtag_transaction );
   `uvm_component_utils( jtag_driver )

   virtual jtag_if jtag_vi;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      //uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_vi) );
	 
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jtag_transaction jtag_tx;
	  string           fsm_nstate;
      
      jtag_vi.master_mp.posedge_cb.tms <= 1;
      @(negedge jtag_vi.master_mp.trst);
      forever begin
         seq_item_port.get_next_item( jtag_tx );
         `uvm_info( "jtag_tx", { "\n",jtag_tx.convert2string() }, UVM_LOW );
         ////take jtag fsm into test_logic_reset state
         //for(int i = 0; i < 5; i ++) begin
         //   @jtag_vi.master_mp.posedge_cb;
         //   jtag_vi.master_mp.posedge_cb.tms <= 1;
         //end
     
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;

         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         //take jtag fsm into select_ir_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_ir_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         //take jtag fsm into capture_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         //take jtag fsm into shift_ir state
         for(int i = 0; i < `IR_WIDTH; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            fsm_nstate = "take jtag fsm into shift_ir state ";
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            //collect shift out ir
            //jtag_tx.tdo_ir_queue = { jtag_tx.tdo_ir_queue, jtag_vi.master_mp.posedge_cb.tdo };
            
            //shift ir in
            //@(negedge jtag_vi.master_mp.tck);
            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[i-1];
         end

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[`IR_WIDTH-1];
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
        
         //take jtag fsm into update_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
        
         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         //take jtag fsm into capture_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         //take jtag fsm into shift_dr state
         for(int i = 0; i < jtag_tx.o_dr_length; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            fsm_nstate = "take jtag fsm into shift_dr state ";
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
            //collect shift out dr
            //jtag_tx.tdo_dr_queue = { jtag_tx.tdo_dr_queue, jtag_vi.master_mp.posedge_cb.tdo };
            
            //shift dr in
            //@(negedge jtag_vi.master_mp.tck);
            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[i-1];
         end

         //take jtag fsm into exit1_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[jtag_tx.o_dr_length-1];
         
         fsm_nstate = "take jtag fsm into exit1_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
        
         //take jtag fsm into update_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
        
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
	     seq_item_port.item_done();
      end
   endtask: run_phase
endclass: jtag_driver

//---------------------------------------------------------------------------
// Class: jtag_sequencer
//---------------------------------------------------------------------------
typedef uvm_sequencer #(jtag_transaction) jtag_sequencer;

//------------------------------------------------------------------------------
// Class: ieee_1149_1_reg_adapter
//------------------------------------------------------------------------------

class ieee_1149_1_reg_adapter extends uvm_reg_adapter;
   `uvm_object_utils( ieee_1149_1_reg_adapter )

   function new( string name = "" );
      super.new( name );
      supports_byte_enable = 0;
      provides_responses   = 0;
   endfunction: new

   virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
      jtag_transaction  jtag_tx = jtag_transaction::type_id::create("jtag_tx");
    
      jtag_tx.protocol = IEEE_1149_1;
      jtag_tx.o_ir = rw.addr;
      jtag_tx.o_dr_length = rw.data[`MAX_DR_WIDTH-1 : 0];
      jtag_tx.o_dr = new[jtag_tx.o_dr_length];
      for( int i = 0; i < jtag_tx.o_dr_length; i++) begin
          jtag_tx.o_dr[i] = rw.data[`MAX_DR_WIDTH + i];
      end
      return jtag_tx;
   endfunction: reg2bus

   virtual function void bus2reg( uvm_sequence_item bus_item, ref uvm_reg_bus_op rw );
      jtag_transaction  jtag_tx;
      
      logic queue_comp_rslt = 1;
      
      if ( ! $cast( jtag_tx, bus_item ) ) begin
         `uvm_fatal( get_name(), "bus_item is not of the jtag_transaction type." )
         return;
      end
       
      rw.data[`MAX_DR_WIDTH-1 : 0] = jtag_tx.o_dr_length;
      foreach( jtag_tx.tdo_dr_queue[i] ) begin
          rw.data[`MAX_DR_WIDTH + i] = jtag_tx.tdi_dr_queue[i];
          if( jtag_tx.tdo_dr_queue[i] != jtag_tx.tdi_dr_queue[i] ) queue_comp_rslt = 0; 
      end
      
      rw.addr = 0;
      foreach( jtag_tx.tdi_ir_queue[i] ) begin
          rw.addr[i] = jtag_tx.tdi_ir_queue[i];
      end

      `uvm_info("adapter", {$sformatf("rw.addr=%0h,rw.data=%0h", rw.addr,rw.data)}, UVM_DEBUG);
      rw.kind = ( queue_comp_rslt ) ? UVM_READ : UVM_WRITE;
         
      rw.status = UVM_IS_OK;
   endfunction: bus2reg
endclass: ieee_1149_1_reg_adapter



//---------------------------------------------------------------------------
// Class: jtag_agent
//---------------------------------------------------------------------------

class jtag_agent extends uvm_agent;
   `uvm_component_utils( jtag_agent )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   //handles for agent's components
   jtag_sequencer               sqr;
   jtag_driver                  drv;
   jtag_monitor                 mon;
   ieee_1149_1_reg_adapter      jtag_reg_adapter; 
   //jtag_config       m_config;

   //configuration knobs
   //localparam OFF = 1'b0, ON = 1'b1;
   
   //handles for monitor's analysis port
   uvm_analysis_port#( jtag_transaction ) jtag_ap;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      sqr = jtag_sequencer::type_id::create(.name( "sqr" ), .parent(this));
      drv = jtag_driver::type_id::create   (.name( "drv" ), .parent(this));
      mon = jtag_monitor::type_id::create  (.name( "mon" ), .parent(this));
      jtag_reg_adapter = ieee_1149_1_reg_adapter::type_id::create  (.name( "jtag_reg_adapter " ), .parent(this));
      
      jtag_ap = new( .name("jtag_ap"), .parent(this) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      drv.seq_item_port.connect(sqr.seq_item_export);
      mon.jtag_ap.connect(jtag_ap);
   endfunction: connect_phase
endclass:jtag_agent

//---------------------------------------------------------------------------
// Class: jtag_scoreboard
//---------------------------------------------------------------------------

class jtag_scoreboard extends uvm_subscriber#( jtag_transaction );
   `uvm_component_utils( jtag_scoreboard )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void write( jtag_transaction t);
	   uvm_table_printer p = new;
       `uvm_info("jtag_scoreboard",{"\n",t.sprint(p)},UVM_LOW);
   endfunction: write

endclass:jtag_scoreboard

//------------------------------------------------------------------------------
// Class: jtag_reg_predictor
//------------------------------------------------------------------------------

typedef uvm_reg_predictor#( jtag_transaction ) jtag_reg_predictor;




//---------------------------------------------------------------------------
// Class: jtag_env
//---------------------------------------------------------------------------

class jtag_env extends uvm_env;
   `uvm_component_utils( jtag_env )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   //handles for env's components
   jtag_agent           agent;
   jtag_scoreboard      scoreboard;
   jtag_configuration   cfg;
   jtag_reg_predictor   reg_predictor;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      agent = jtag_agent::type_id::create           (.name( "agent"      ), .parent(this));
      scoreboard = jtag_scoreboard::type_id::create (.name( "scoreboard" ), .parent(this));
      reg_predictor = jtag_reg_predictor::type_id::create(.name( "reg_predictor" ), .parent(this));
      
      assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( cfg) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      agent.jtag_ap.connect(scoreboard.analysis_export);

      agent.mon.jtag_vi = cfg.jtag_vi;
      agent.drv.jtag_vi = cfg.jtag_vi;
      cfg.jtag_reg_block.reg_map.set_sequencer( .sequencer( agent.sqr ),
                                                .adapter( agent.jtag_reg_adapter ) );
      reg_predictor.map     = cfg.jtag_reg_block.reg_map;
      reg_predictor.adapter = agent.jtag_reg_adapter;
      agent.jtag_ap.connect( reg_predictor.bus_in );
   endfunction: connect_phase
endclass:jtag_env
