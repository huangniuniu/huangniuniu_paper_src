//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;

    rand  protocol_e                 portocol;

    rand  bit [`IR_WIDTH-1:0]        o_ir;

    rand  unsigned int               o_dr_length;
    rand  bit                        o_dr[];
    //rand  bit [o_dr_length-1:0]      o_dr;
    
    //i_dr_queue/i_ir_queue  store tdo data
    bit                              i_dr_queue[$];
    bit                              i_ir_quene[$];

    //o_dr_queue/o_ir_queue  store tdi data
    bit                              o_dr_queue[$];
    bit                              o_ir_quene[$];
    
    function new (string name = "jtag_transaction");
        super.new(name); 
    endfunction

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
      `define TEST_LOGIC_RESET 4'h0
      `define RUN_TEST_IDLE    4'h1
      `define SELECT_DR_SCAN   4'h2
      `define CAPTURE_DR       4'h3
      `define SHIFT_DR         4'h4
      `define EXIT1_DR         4'h5
      `define PAUSE_DR         4'h6
      `define EXIT2_DR         4'h7
      `define UPDATE_DR        4'h8
      `define SELECT_IR_SCAN   4'h9
      `define CAPTURE_IR       4'ha
      `define SHIFT_IR         4'hb
      `define EXIT1_IR         4'hc
      `define PAUSE_IR         4'hd
      `define EXIT2_IR         4'he
      `define UPDATE_IR        4'hf
      
      logic [3:0] c_state; 
      
      jtag_transaction jtag_tx;
      
      fork
         forever @(posedge jtag_vi.monitor_mp.trst)
            c_state = `TEST_LOGIC_RESET;

         forever @(posedge jtag_vi.monitor_mp.tck) begin
            if( c_state == `CAPTURE_IR)begin
               //creat a jtag transaction for boradcasting.
               jtag_tx = jtag_transaction::type_id::creat( .name("jtag_tx") );
            end
            
            if( c_state == `UPDATE_DR)begin
               jtag_ap.write(jtag_tx);
            end

            case (c_state)
               `TEST_LOGIC_RESET: begin
                  if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `RUN_TEST_IDLE;
               end
               
               `RUN_TEST_IDLE: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `SELECT_DR_SCAN;
               end
               
               `SELECT_DR_SCAN: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `SELECT_IR_SCAN;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `CAPTURE_DR;
               end

               `CAPTURE_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT1_DR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `SHIFT_DR;
               end
               
               `SHIFT_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT1_DR;

                  //collects tdi/tdo data 
                  jtag_tx.o_dr_queue.push_back( jtag_vi.monitor_mp.tdi);
                  jtag_tx.i_dr_queue.push_back( jtag_vi.monitor_mp.tdo);
               end

               `EXIT1_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `UPDATE_DR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `PAUSE_DR;
               end
               
               `PAUSE_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT2_DR;
               end
               
               `EXIT2_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `UPDATE_DR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `SHIFT_DR;
               end
               
               `UPDATE_DR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `SELECT_DR_SCAN;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `RUN_TEST_IDLE;
               end
               
               `SELECT_IR_SCAN: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `TEST_LOGIC_RESET;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `CAPTURE_IR;
               end

               `CAPTURE_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT1_IR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `SHIFT_IR;
               end
               
               `SHIFT_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT1_IR;

                  //collects tdi/tdo data 
                  jtag_tx.o_ir_queue.push_back( jtag_vi.monitor_mp.tdi);
                  jtag_tx.i_ir_queue.push_back( jtag_vi.monitor_mp.tdo);
               end

               `EXIT1_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `UPDATE_IR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `PAUSE_IR;
               end
               
               `PAUSE_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `EXIT2_IR;
               end
               
               `EXIT2_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `UPDATE_IR;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `SHIFT_IR;
               end
               
               `UPDATE_IR: begin
                  if(jtag_vi.monitor_mp.tms == 1'b1) c_state = `SELECT_DR_SCAN;
                  else if(jtag_vi.monitor_mp.tms == 1'b0) c_state = `RUN_TEST_IDLE;
               end   
            endcase
         end
      join   
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
	  
      seq_item_port.get_next_item( jtag_tx );
      forever begin
         ////take jtag fsm into test_logic_reset state
         //for(int i = 0; i < 5; i ++) begin
         //   @(posedge jtag_vi.master_mp.tck);
         //   jtag_vi.master_mp.tms <= 1;
         //end
     
         //take jtag fsm into run_test_idle state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 0;

         //take jtag fsm into select_dr_scan state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;

         //take jtag fsm into select_ir_scan state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;

         //take jtag fsm into capture_ir state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 0;

         //take jtag fsm into shift_ir state
         for(int i = 0; i < IR_WIDTH; i ++) begin
            @(posedge jtag_vi.master_mp.tck);
            jtag_vi.master_mp.tms <= 0;
            
            //collect shift out ir
            jtag_tx.i_ir_quene.push_back(jtag_vi.master_mp.tdo);
            
            //shift ir in
            @(negedge jtag_vi.master_mp.tck);
            jtag_vi.master_mp.tdi <= jtag_tx.o_ir[i];
         end

         //take jtag fsm into exit_ir state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;
        
         //take jtag fsm into update_ir state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;
        
         //take jtag fsm into select_dr_scan state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;
         
         //take jtag fsm into capture_dr state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 0;

         //take jtag fsm into shift_dr state
         for(int i = 0; i < o_dr_length; i ++) begin
            @(posedge jtag_vi.master_mp.tck);
            jtag_vi.master_mp.tms <= 0;
            
            //collect shift out dr
            jtag_tx.i_dr_quene.push_back(jtag_vi.master_mp.tdo);
            
            //shift dr in
            @(negedge jtag_vi.master_mp.tck);
            jtag_vi.master_mp.tdi <= jtag_tx.o_dr[i];
         end

         //take jtag fsm into exit_dr state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;
        
         //take jtag fsm into update_dr state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 1;
        
         //take jtag fsm into run_test_idle state
         @(posedge jtag_vi.master_mp.tck);
         jtag_vi.master_mp.tms <= 0;

	     seq_item_port.item_done();
      end
   endtask: run_phase
endclass: jtag_driver

//---------------------------------------------------------------------------
// Class: jtag_sequencer
//---------------------------------------------------------------------------
typedef uvm_sequencer #(jtag_transaction) jtag_sequencer;

//---------------------------------------------------------------------------
// Class: jtag_agent
//---------------------------------------------------------------------------

class jtag_agent extends uvm_agent#( jtag_transaction );
   `uvm_component_utils( jtag_agent )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   //handles for agent's components
   jtag_sequencer    sqr;
   jtag_dirver       drv;
   jtag_monitor      mon;

   //jtag_config       m_config;

   //configuration knobs
   //localparam OFF = 1'b0, ON = 1'b1;
   
   //handles for monitor's analysis port
   uvm_analysis_port jtag_ap;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      sqr = jtag_sequencer::type_id::creat(.name(sqr), .parent(this));
      drv = jtag_sequencer::type_id::creat(.name(drv), .parent(this));
      mon = jtag_sequencer::type_id::creat(.name(mon), .parent(this));
      
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
      `uvm_info("jtag_scoreboard",t.sprint(p),UVM_LOW);
   endfunction: write

endclass:jtag_scoreboard


//---------------------------------------------------------------------------
// Class: jtag_env
//---------------------------------------------------------------------------

class jtag_env extends uvm_env#( jtag_transaction );
   `uvm_component_utils( jtag_env )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   //handles for env's components
   jtag_agent           agent;
   jtag_scoreboard      scoreboard;
   jtag_configuration   cfg;
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      agent = jtag_sequencer::type_id::creat(.name(agent), .parent(this));
      scoreboard = jtag_sequencer::type_id::creat(.name(scoreboard), .parent(this));
      
      assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg) ));
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      agent.jtag_ap.connect(scoreboard.analysis_export);

      agent.mon.jtag_vi = cfg.jtag_vi;
      agent.drv.jtag_vi = cfg.jtag_vi;
   endfunction: connect_phase
endclass:jtag_env
