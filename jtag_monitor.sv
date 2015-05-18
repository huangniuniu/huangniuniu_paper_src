//------------------------------------------------------------------------------
// class: jtag_monitor
//------------------------------------------------------------------------------
class jtag_monitor extends uvm_monitor;
   `uvm_component_utils( jtag_driver )

   virtual jtag_if jtag_vi;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
  
   uvm_analysis_port #(jtag_transaction) jtag_ap;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_vi) ));
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
      
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

