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
      uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_if" ), .value( jtag_vi) );
	 
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jtag_transaction jtag_tx;
	  
      seq_item_port.get_next_item( jtag_tx );
      forever begin
         ////take jtag fsm into test_logic_reset state
         //for(int i = 0; i < 5; i ++) begin
         //   @(posedge jtag_vi.tck);
         //   jtag_vi.tms <= 1;
         //end
     
         //take jtag fsm into run_test_idle state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 0;

         //take jtag fsm into select_dr_scan state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;

         //take jtag fsm into select_ir_scan state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;

         //take jtag fsm into capture_ir state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 0;

         //take jtag fsm into shift_ir state
         for(int i = 0; i < IR_WIDTH; i ++) begin
            @(posedge jtag_vi.tck);
            jtag_vi.tms <= 0;
            
            //collect shift out ir
            jtag_tx.i_ir_quene.push_back(jtag_vi.tdo);
            
            //shift ir in
            @(negedge jtag_vi.tck);
            jtag_vi.tdi <= jtag_tx.o_ir[i];
         end

         //take jtag fsm into exit_ir state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;
        
         //take jtag fsm into update_ir state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;
        
         //take jtag fsm into select_dr_scan state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;
         
         //take jtag fsm into capture_dr state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 0;

         //take jtag fsm into shift_dr state
         for(int i = 0; i < o_dr_length; i ++) begin
            @(posedge jtag_vi.tck);
            jtag_vi.tms <= 0;
            
            //collect shift out dr
            jtag_tx.i_dr_quene.push_back(jtag_vi.tdo);
            
            //shift dr in
            @(negedge jtag_vi.tck);
            jtag_vi.tdi <= jtag_tx.o_dr[i];
         end

         //take jtag fsm into exit_dr state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;
        
         //take jtag fsm into update_dr state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 1;
        
         //take jtag fsm into run_test_idle state
         @(posedge jtag_vi.tck);
         jtag_vi.tms <= 0;

	     seq_item_port.item_done();
      end
   endtask: run_phase
endclass: jtag_driver

