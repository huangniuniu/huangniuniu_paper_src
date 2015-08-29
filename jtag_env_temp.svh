//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;
    rand  protocol_e                 protocol;

    rand  bit [`IR_WIDTH-1:0]        o_ir;
    
    rand  bit                        update_ir;
    rand  int unsigned               o_dr_length;
    bit                              o_dr[];
    //rand  bit [o_dr_length-1:0]      o_dr;
    
   //tdo_dr_queue/tdo_ir_queue  store tdo data
    bit                              tdo_dr_queue[$];
    bit                              tdo_ir_queue[$];

    //tdi_dr_queue/tdi_ir_queue  store tdi data
    bit                              tdi_dr_queue[$];
    bit                              tdi_ir_queue[$];
  
    //bit                              gen_stil;
    bit                              chk_ir_tdo;
    bit                              chk_dr_tdo;
    bit                              exp_tdo_dr_queue[$];
    bit                              exp_tdo_ir_queue[$];
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
        
        $sformat(s, "%s\n ////////////////////////////////////////////////////////////\n jtag_transaction\n protocol \t%0s\n o_ir \t%`IR_WIDTHb\n o_dr_length \t%0d\n o_dr \t",s, protocol.name(), o_ir, o_dr_length);
         
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
        
        $sformat(s, "%s\n chk_ir_tdo = \t%d\n chk_dr_tdo = \t%d\n",s,  chk_ir_tdo, chk_dr_tdo);
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
       if(chk_ir_tdo) begin
          $sformat(s, "%s\n ///////////////exp_tdo_ir_queue//////////////////////////\n",s);
          foreach( exp_tdo_ir_queue[i] )
               $sformat(s, "%s%0b",s,exp_tdo_ir_queue[$-i] );
          $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);
       end
       if(chk_dr_tdo) begin
          $sformat(s, "%s\n ///////////////exp_tdo_dr_queue//////////////////////////\n",s);
          foreach( exp_tdo_dr_queue[i] )
               $sformat(s, "%s%0b",s,exp_tdo_dr_queue[$-i] );
          $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);
       end
       return s;
    endfunction: print_queue
endclass:jtag_transaction

//------------------------------------------------------------------------------
// class:bus_reg_ext 
//------------------------------------------------------------------------------
//This class is used to send information from a sequence to the adapter
class bus_reg_ext extends uvm_object;
   `uvm_object_utils(bus_reg_ext)
   bit    chk_ir_tdo; 
   bit    chk_dr_tdo; 
   bit    exp_tdo_dr[];
   bit    exp_tdo_ir[];
   bit    dr_ext[]; //store the register's filds if its total bits number > 64bits.
   
   function new(string name = "bus_reg_ext");
     super.new(name);
   endfunction : new
    
endclass : bus_reg_ext

//------------------------------------------------------------------------------
// class: i1687_transaction
//------------------------------------------------------------------------------
class i1687_transaction extends uvm_sequence_item;
   //1st layer SIB
   bit    unb_sib,soc_sib,cpc_sib,gnb_sib,esram_sib;
   //2nd layer SIB
   bit    mux_sib,lpct_sib,sel_wir,mc_en,esram_en3,esram_en2,esram_en1,esram_en0;
   //3nd layer 1500 access
   bit    gnb_wir_queue[$], gnb_wdr_queue[$], gnb_sft_ir_queue[$], gnb_sft_dr_queue[$]; 
   bit[`TOTAL_TILE_NUM-1:0]   tile_mc_chain; 
 
    `uvm_object_utils( i1687_transaction )
    
    function new(string name = "i1687_transaction");
        super.new(name);
    endfunction
endclass: i1687_transaction 

//------------------------------------------------------------------------------
// class:i1687_network_maintainer 
//------------------------------------------------------------------------------
//This class is used to send information from a sequence to the adapter
class i1687_network_maintainer extends uvm_driver#( i1687_newwork );
   `uvm_component_utils( i1687_network_maintainer)
   //1st layer SIB
   bit    unb_sib,soc_sib,cpc_sib,gnb_sib,esram_sib;
   //2nd layer SIB
   bit    mux_sib,lpct_sib,sel_wir = 1'b1,mc_en,esram_en3,esram_en2,esram_en1,esram_en0;
   //3nd layer 1500 access
   bit    gnb_wir_queue[$], gnb_wdr_queue[$], gnb_sft_ir_queue[$], gnb_sft_dr_queue[$]; 
   bit[`TOTAL_TILE_NUM-1:0]   tile_mc_chain; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      i1687_newwork        i1687_tx;
      forever begin
         if()
      end
   endtask: run_phase

   void function maintainer (ref i1687_newwork i1687_tx);
      gnb_sft_dr_queue.delete;
      gnb_sft_ir_queue.delete;
   
      //Concatnate unb sib
      gnb_sft_dr_queue = {gnb_sft_dr_queue,unb_sib}; 
      
      //Concatnate soc sib
      if(i1687_tx.soc_sib) begin
         if(soc_sib == 1'b0) begin //user want set 1st layer soc_sib 
            soc_sib = 1'b1;
            gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib}; 
         end
         else begin 
            mux_sib = i1687_tx.mux_sib;
            lpct_sib = i1687_tx.lpct_sib; 
            gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib,mux_sib,lpct_sib}; 
         end
      end //if(i1687_tx.soc_sib) 
      else begin
         if(soc_sib == 1'b1) begin //user want to close 1st layer soc_sib
            soc_sib = 1'b0;
            mux_sib = i1687_tx.mux_sib;
            lpct_sib = i1687_tx.lpct_sib;
            gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib,mux_sib,lpct_sib}; 
         end
         else
            gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib}; 
      end //if(!i1687_tx.soc_sib) 
      
      //Concatnate cpc sib
      gnb_sft_dr_queue = {gnb_sft_dr_queue,cpc_sib}; 
      
      //Concatnate gnb sib
      if(i1687_tx.gnb_sib) begin
         if(gnb_sib == 1'b0) begin //user want set 1st layer gnb_sib 
            gnb_sib = 1'b1;
            gnb_sft_dr_queue = {gnb_sft_dr_queue,gnb_sib}; 
         end
         else begin 
            mc_en = i1687_tx.mc_en;
            sel_wir = i1687_tx.sel_wir;
            gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib,mc_en}; 
            if(mc_en)
               gnb_sft_dr_queue = {gnb_sft_dr_queue,soc_sib,mc_en,tile_mc_chain}; 
            else begin
               gnb_sft_ir_queue = {gnb_sft_dr_queue,~sel_wir,gnb_wir_queue};
               gnb_sft_dr_queue = {gnb_sft_dr_queue,sel_wir,gnb_wdr_queue}; 
            end
         end
      end //if(i1687_tx.gnb_sib) 
      else begin
         if(gnb_sib == 1'b1) begin //user want to close 1st layer gnb_sib
            gnb_sib = 1'b0;
            mc_en = i1687_tx.mc_en;
            sel_wir = i1687_tx.sel_wir;
            gnb_sft_dr_queue = {gnb_sft_dr_queue,gnb_sib,sel_wir,gnb_wir_queue}; 
         end
         else
            gnb_sft_dr_queue = {gnb_sft_dr_queue,gnb_sib}; 
      end //if(!i1687_tx.gnb_sib) 
      
      //Concatnate esrm sib
      esram_sib = i1687_tx.esram_sib;
      gnb_sft_dr_queue = {gnb_sft_dr_queue,esram_sib}; 
   endfunction
endclass : i1687_network_maintainer

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
   
   virtual jtag_if         jtag_vi;
   bit                     gen_stil_file;
   string                  stil_file_name;
   int                     tck_half_period;
   jtag_configuration      jtag_cfg;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      assert(uvm_config_db#(jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( this.jtag_cfg) ));

      gen_stil_file = jtag_cfg.gen_stil_file;
      stil_file_name = jtag_cfg.stil_file_name;
      tck_half_period = jtag_cfg.tck_half_period;
      jtag_vi = jtag_cfg.jtag_vi;
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jtag_transaction  jtag_tx;

      string            fsm_nstate;
      string            stil_str;
      int               stil_fd;
      string            chk_tdo_value;

      //For STIL convertion
      if(gen_stil_file == `ON)begin
         stil_fd = $fopen("jtag_1149_1_test.stil", "a");
         //Header
         stil_str = $sformatf({"STIL1.0\n",
                               "Header{\n",
                               "  (Title %s )\n",
                               //"  (Date %t )\n",
                               "}\n"}, stil_file_name);
         $fdisplay(stil_fd,stil_str);
         
         //Signals
         stil_str = $sformatf({"Signals { \n",
                               "  TDO      Out;\n",
                               "  TCK       In;\n",
                               "  TRST      In;\n",
                               "  TDI       In;\n",
                               "  TMS       In;\n",
                            "}\n"});
         $fdisplay(stil_fd,stil_str);

         //Timing
         stil_str = $sformatf({"Timing \"TCK_DOMAIN\"{\n",
                               "  WaveformTable base {\n",
                               "     Period'%d';\n",
                               "       Waveforms {\n",
                               "          TCK  { 0P { '0ns' D; '%dns' D/U; '%dns' D; }}\n",
                               "          TDI  { 01 { '0ns' D; }}\n",
                               "          TMS  { 01 { '0ns' D; }}\n",
                               "          TRST { 01 { '0ns' D; }}\n",
                               "          TDO  { LHX { '0ns' Z; '%dns' L/H/X;}}\n",
                               "       }\n",
                               "  }//WaveformTable\n",
                              "}//Timing\n"},tck_half_period*2,tck_half_period,tck_half_period/2+tck_half_period,tck_half_period/2+tck_half_period/4);
         $fdisplay(stil_fd,stil_str);

         //PatternBurst
         stil_str = $sformatf({"PatternBurst \"%s\" {\n",
                               "    PatList { \" test_sequence\"; }\n",
                               "    }\n",
                               "}\n"},stil_file_name);
         $fdisplay(stil_fd,stil_str);
         
         //PatternExec
         stil_str = $sformatf({"PatternExec {\n",
                               "    Timing  \" TCK_DOMAIN\";\n",
                               "    PatternBurst \" %s\";\n",
                               "}\n"},stil_file_name);
         $fdisplay(stil_fd,stil_str);

         //Pattern
         stil_str = $sformatf({"Pattern test_sequence {\n",
                               "   //Reset DUT \n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 1; TDO = X;}\n",
                               "   V { TCK = 0; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n",
                               "   //Out of reset DUT \n"});
         $fdisplay(stil_fd,stil_str);
      end //if(gen_stil_file == `ON)

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

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into run_test_idle state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end
         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_dr_scan state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end
         //take jtag fsm into select_ir_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_ir_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_ir_scan state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end

         //take jtag fsm into capture_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into capture_ir state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end

         //take jtag fsm into shift_ir state
         for(int i = 0; i < `IR_WIDTH; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            fsm_nstate = "take jtag fsm into shift_ir state ";
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[i-1];
            
            if(gen_stil_file == `ON)begin
               if(jtag_tx.chk_ir_tdo) 
                  if(i != 0)
                     if(jtag_tx.exp_tdo_ir_queue[i-1])  chk_tdo_value = "H";
                     else chk_tdo_value = "L";
                  else chk_tdo_value = "X";
               else chk_tdo_value = "X";
               stil_str = $sformatf({"   //take jtag fsm into shift_ir state\n",
                                     "   V { TCK = P; TDI = %b; TMS = 0; TRST = 0; TDO = %s;}\n" }, (i != 0) ? jtag_tx.o_ir[i-1] : 1'b0,chk_tdo_value);
               $fdisplay(stil_fd,stil_str);
            end// if(gen_stil_file == `ON)
         end //for(int i = 0; i < `IR_WIDTH; i ++) begin

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[`IR_WIDTH-1];
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_ir_tdo) 
              if(jtag_tx.exp_tdo_ir_queue[`IR_WIDTH-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            stil_str = $sformatf({"   //take jtag fsm into exit1_ir state\n",
                                  "   V { TCK = P; TDI = %b; TMS = 1; TRST = 0; TDO = %s;}\n" }, jtag_tx.o_ir[`IR_WIDTH-1],chk_tdo_value);
            $fdisplay(stil_fd,stil_str);
         end// if(gen_stil_file == `ON)

         //take jtag fsm into update_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into update_ir state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       
         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_dr_scan state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       
         
         //take jtag fsm into capture_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into capture_dr state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       

         //take jtag fsm into shift_dr state
         for(int i = 0; i < jtag_tx.o_dr_length; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            fsm_nstate = "take jtag fsm into shift_dr state ";
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[i-1];
            if(gen_stil_file == `ON)begin
               if(jtag_tx.chk_dr_tdo) 
                  if(i != 0)
                     if(jtag_tx.exp_tdo_dr_queue[i-1])  chk_tdo_value = "H";
                     else chk_tdo_value = "L";
                  else chk_tdo_value = "X";
               else chk_tdo_value = "X";
               stil_str = $sformatf({"   //take jtag fsm into shift_dr state\n",
                                     "   V { TCK = P; TDI = %b; TMS = 0; TRST = 0; TDO = %s;}\n" }, (i != 0) ? jtag_tx.o_dr[i-1] : 1'b0,chk_tdo_value);
               $fdisplay(stil_fd,stil_str);
            end// if(gen_stil_file == `ON)

         end

         //take jtag fsm into exit1_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[jtag_tx.o_dr_length-1];
         
         fsm_nstate = "take jtag fsm into exit1_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
 
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_dr_tdo) 
              if(jtag_tx.exp_tdo_dr_queue[jtag_tx.o_dr_length-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            stil_str = $sformatf({"   //take jtag fsm into exit1_dr state\n",
                                  "   V { TCK = P; TDI = %b; TMS = 1; TRST = 0; TDO = %s;}\n" }, jtag_tx.o_dr[jtag_tx.o_dr_length-1],chk_tdo_value);
            $fdisplay(stil_fd,stil_str);
         end// if(gen_stil_file == `ON)

       
         //take jtag fsm into update_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
          
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into update_dr state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 1; TRST = 0; TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end        
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into run_test_idle state\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n",
                                  "   V { TCK = P; TDI = 0; TMS = 0; TRST = 0; TDO = X;}\n"});
            $fdisplay(stil_fd,stil_str);
         end        
         repeat (2) @jtag_vi.master_mp.posedge_cb;
	     seq_item_port.item_done();

      end
   endtask: run_phase
endclass: jtag_driver
//---------------------------------------------------------------------------
// Class: jtag_driver_atpg
//---------------------------------------------------------------------------

class jtag_driver_atpg extends jtag_driver;
   `uvm_component_utils( jtag_driver_atpg )
   
   virtual jtag_if         jtag_vi;
   bit                     gen_stil_file;
   string                  stil_file_name;
   int                     tck_half_period;
   jtag_configuration      jtag_cfg;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      assert(uvm_config_db#(jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( this.jtag_cfg) ));

      gen_stil_file = jtag_cfg.gen_stil_file;
      stil_file_name = jtag_cfg.stil_file_name;
      tck_half_period = jtag_cfg.tck_half_period;
      jtag_vi = jtag_cfg.jtag_vi;
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jtag_transaction  jtag_tx;

      string            fsm_nstate;
      string            stil_str;
      int               stil_fd;
      string            chk_tdo_value;

      //For STIL convertion
      if(gen_stil_file == `ON)begin
         stil_fd = $fopen("jtag_1149_1_test.stil", "a");
         //Header
         stil_str = $sformatf({"STIL1.0\n",
                               "Header{\n",
                               "  (Title %s )\n",
                               //"  (Date %t )\n",
                               "}\n"}, stil_file_name);
         $fdisplay(stil_fd,stil_str);
         
         //Signals
         stil_str = $sformatf({"Signals { \n",
                               "  BP_TDO      Out;\n",
                               "  BP_TCK       In;\n",
                               "  BP_TRST_L      In;\n",
                               "  BP_TDI       In;\n",
                               "  BP_TMS       In;\n",
                            "}\n"});
         $fdisplay(stil_fd,stil_str);

         //Timing
         stil_str = $sformatf({"Timing \"BP_TCK_DOMAIN\"{\n",
                               "  WaveformTable base {\n",
                               "     Period'%d';\n",
                               "       Waveforms {\n",
                               "          BP_TCK  { 0P { '0ns' D; '%dns' D/U; '%dns' D; }}\n",
                               "          BP_TDI  { 01 { '0ns' D; }}\n",
                               "          BP_TMS  { 01 { '0ns' D; }}\n",
                               "          BP_TRST_L { 01 { '0ns' D; }}\n",
                               "          BP_TDO  { LHX { '0ns' Z; '%dns' L/H/X;}}\n",
                               "       }\n",
                               "  }//WaveformTable\n",
                              "}//Timing\n"},tck_half_period*2,tck_half_period,tck_half_period/2+tck_half_period,tck_half_period/2+tck_half_period/4);
         $fdisplay(stil_fd,stil_str);

         //PatternBurst
         stil_str = $sformatf({"PatternBurst \"%s\" {\n",
                               "    PatList { \" test_sequence\"; }\n",
                               "    }\n",
                               "}\n"},stil_file_name);
         $fdisplay(stil_fd,stil_str);
         
         //PatternExec
         stil_str = $sformatf({"PatternExec {\n",
                               "    Timing  \" TCK_DOMAIN\";\n",
                               "    PatternBurst \" %s\";\n",
                               "}\n"},stil_file_name);
         $fdisplay(stil_fd,stil_str);

         //Pattern
         stil_str = $sformatf({"Pattern test_sequence {\n",
                               "   //Reset DUT \n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 0; BP_TDO = X;}\n",
                               "   V { BP_TCK = 0; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n",
                               "   //Out of reset DUT \n"});
         $fdisplay(stil_fd,stil_str);
      end //if(gen_stil_file == `ON)

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
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into run_test_idle state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end
         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_dr_scan state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end
         //take jtag fsm into select_ir_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_ir_scan state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_ir_scan state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end

         //take jtag fsm into capture_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_ir state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into capture_ir state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end

         //take jtag fsm into shift_ir state
         for(int i = 0; i < `IR_WIDTH; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            fsm_nstate = "take jtag fsm into shift_ir state ";
            `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[i-1];
            
            if(gen_stil_file == `ON)begin
               if(jtag_tx.chk_ir_tdo) 
                  if(i != 0)
                     if(jtag_tx.exp_tdo_ir_queue[i-1])  chk_tdo_value = "H";
                     else chk_tdo_value = "L";
                  else chk_tdo_value = "X";
               else chk_tdo_value = "X";
               stil_str = $sformatf({"   //take jtag fsm into shift_ir state\n",
                                     "   V { BP_TCK = P; BP_TDI = %b; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = %s;}\n" }, (i != 0) ? jtag_tx.o_ir[i-1] : 1'b0,chk_tdo_value);
               $fdisplay(stil_fd,stil_str);
            end// if(gen_stil_file == `ON)
         end //for(int i = 0; i < `IR_WIDTH; i ++) begin

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[`IR_WIDTH-1];
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_ir_tdo) 
              if(jtag_tx.exp_tdo_ir_queue[`IR_WIDTH-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            stil_str = $sformatf({"   //take jtag fsm into exit1_ir state\n",
                                  "   V { BP_TCK = P; BP_TDI = %b; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = %s;}\n" }, jtag_tx.o_ir[`IR_WIDTH-1],chk_tdo_value);
            $fdisplay(stil_fd,stil_str);
         end// if(gen_stil_file == `ON)

         //take jtag fsm into update_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_ir state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into update_ir state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       
         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into select_dr_scan state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       
         
         //take jtag fsm into capture_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_dr state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into capture_dr state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end       

         //take jtag fsm into shift_dr state
         for(int i = 0; i < jtag_tx.o_dr_length; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            fsm_nstate = "take jtag fsm into shift_dr state ";
            `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );

            @jtag_vi.master_mp.negedge_cb;
            if (i!=0) jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[i-1];
            if(gen_stil_file == `ON)begin
               if(jtag_tx.chk_dr_tdo) 
                  if(i != 0)
                     if(jtag_tx.exp_tdo_dr_queue[i-1])  chk_tdo_value = "H";
                     else chk_tdo_value = "L";
                  else chk_tdo_value = "X";
               else chk_tdo_value = "X";
               stil_str = $sformatf({"   //take jtag fsm into shift_dr state\n",
                                     "   V { BP_TCK = P; BP_TDI = %b; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = %s;}\n" }, (i != 0) ? jtag_tx.o_dr[i-1] : 1'b0,chk_tdo_value);
               $fdisplay(stil_fd,stil_str);
            end// if(gen_stil_file == `ON)

         end

         //take jtag fsm into exit1_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[jtag_tx.o_dr_length-1];
         
         fsm_nstate = "take jtag fsm into exit1_dr state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
 
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_dr_tdo) 
              if(jtag_tx.exp_tdo_dr_queue[jtag_tx.o_dr_length-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            stil_str = $sformatf({"   //take jtag fsm into exit1_dr state\n",
                                  "   V { BP_TCK = P; BP_TDI = %b; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = %s;}\n" }, jtag_tx.o_dr[jtag_tx.o_dr_length-1],chk_tdo_value);
            $fdisplay(stil_fd,stil_str);
         end// if(gen_stil_file == `ON)

       
         //take jtag fsm into update_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_dr state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
          
         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into update_dr state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = X;}\n" });
            $fdisplay(stil_fd,stil_str);
         end        
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );

         if(gen_stil_file == `ON)begin
            stil_str = $sformatf({"   //take jtag fsm into run_test_idle state\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n",
                                  "   V { BP_TCK = P; BP_TDI = 0; BP_TMS = 0; BP_TRST_L = 1; BP_TDO = X;}\n"});
            $fdisplay(stil_fd,stil_str);
         end        
         repeat (2) @jtag_vi.master_mp.posedge_cb;
	     seq_item_port.item_done();

      end
   endtask: run_phase
endclass: jtag_driver_atpg



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
      bus_reg_ext             extension;
      uvm_reg_item            item = get_item();

      jtag_transaction        jtag_tx = jtag_transaction::type_id::create("jtag_tx");

      
      if(!$cast(extension,item.extension))
         `uvm_error("reg2bus", "Extension casting failed.");

      if( extension != null ) begin
         jtag_tx.chk_ir_tdo = extension.chk_ir_tdo;
         jtag_tx.chk_dr_tdo = extension.chk_dr_tdo;

         foreach(extension.exp_tdo_ir[i])
            jtag_tx.exp_tdo_ir_queue = {jtag_tx.exp_tdo_ir_queue,extension.exp_tdo_ir[i]};
         
         foreach(extension.exp_tdo_dr[i])
            jtag_tx.exp_tdo_dr_queue = {jtag_tx.exp_tdo_dr_queue,extension.exp_tdo_dr[i]};
      end

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
      //agent.drv.jtag_vi = cfg.jtag_vi;
      cfg.jtag_reg_block.reg_map.set_sequencer( .sequencer( agent.sqr ),
                                                .adapter( agent.jtag_reg_adapter ) );
      reg_predictor.map     = cfg.jtag_reg_block.reg_map;
      reg_predictor.adapter = agent.jtag_reg_adapter;
      agent.jtag_ap.connect( reg_predictor.bus_in );
   endfunction: connect_phase

endclass:jtag_env

//---------------------------------------------------------------------------
// Class: sib_node 
//---------------------------------------------------------------------------
class sib_node extends uvm_object;
   `uvm_object_utils(sib_node)
   bit    in0; 
   bit    in1; 
   bit    value = value ? in1 : in0;
   bit    out = value; 
   
   function new(string name = "sib_node");
     super.new(name);
   endfunction : new
    
endclass : sib_node

//---------------------------------------------------------------------------
// Class: reg_node 
//---------------------------------------------------------------------------
class reg_node extends uvm_object;
   `uvm_object_utils(reg_node)
   bit    in; 
   bit    is_selwir; 
   bit    value = in;
   bit    out = value;
   
   function new(string name = "reg_node");
     super.new(name);
   endfunction : new
    
endclass : reg_node

virtual function void node_initialize(void);
   //sel_wir node initialize.
   foreach (sel_wir[i]) begin
      sel_wir[i].is_selwir = 1;
      sel_wir[i].value = 1;
   end
endfunction :node_initialize

virtual function unsigned int dft_tdr_network (viod); 
   sib_node                      sib[4];
   reg_node                      sel_wir[4];
   reg_node                      wir[`IEEE1500_IR_WIDTH], wdr_dynmc[]; 
   reg_node                      cascd_wir[`IEEE1500_IR_WIDTH], cascd_wdr_dynmc[];
   unsigned int                  chain_length = 2;
   bit                           tdi, tdo; 
   bit[`IEEE1500_IR_WIDTH-1:0]   wir_data;
   
   //calculate current chain_length
   case({sib[1].value, sib[0].value, sib[3].value, sib[2].value})
      4'b0001: begin
         chain_length = ((sel_wir[2].value == 1) ? chain_length + `IEEE1500_IR_WIDTH : chain_length ) + 1;    
      end
      4'b0010: begin
         chain_length = ((sel_wir[3].value == 1) ? chain_length + `IEEE1500_IR_WIDTH : chain_length ) + 1;    
      end
      4'b0101: begin
         chain_length = ((sel_wir[0].value == 1) ? chain_length + `IEEE1500_IR_WIDTH : chain_length ) + 2;    
      end
      4'b1001: begin
         chain_length = ((sel_wir[1].value == 1) ? chain_length + `IEEE1500_IR_WIDTH : chain_length ) + 2;    
      end
   endcase
   tdo = sib[2].out;
  
   //sib2 connection
   sib[2].in0 = sib[3].out;
   sib[2].in1 = sel_wir[2].out;

   //sib3 connection
   sib[3].in0 = tdi;
   sib[3].in1 = sel_wir[3].out;

   //sel_wir[3] connection
   sel_wir[3].in = (sel_wir[3].value == 1 ) ? wir[0].out : wdr_dynmc[0].out;
   
   //wir/wdr_dynmc connection
   if(sib[3].value == 1 ) begin
      if(sel_wir[3].value == 1) begin
         wir[`IEEE1500_IR_WIDTH - 1].in = tdi;
         for(i=0; i<`IEEE1500_IR_WIDTH - 1; i++)
            wir[i].in = wir[i+1].out;
      end
      else begin
         wdr_dynmc[wdr_dynmc.size - 1].in = tdi;
         for(i=0; i<wdr_dynmc.size - 1; i++)
            wdr_dynmc[i].in = wdr_dynmc[i+1].out;
      end
   end
   
   //----------------------------
   //sel_wir[2] connection
   //----------------------------
   if(sib[2].value == 1 ) begin
      //connect wir to chain
      if(sel_wir[2].value == 1) begin
         wir[`IEEE1500_IR_WIDTH - 1].in = sib3.out;
         for(i=0; i<`IEEE1500_IR_WIDTH - 1; i++)
            wir[i].in = wir[i+1].out;
         //sel_wir[2] connection branch3
         sel_wir[2].in = wir[0].out;
      end
      else begin
         //get current ir opecode
         foreach(wir[i]) wir_data[i] = wir[i].value;
         if(wir_data == `TILE0_SIB) begin
            //sel_wir[2] connection branch2
            sel_wir[2].in = sib[0].out;
            
            //----------------------------
            //sib0 connection
            //----------------------------
            sib0.in0 = sib1.out;
            sib0.in1 = sel_wir[0].out;

            //----------------------------
            //sel_wir[0] connection
            //----------------------------
            sel_wir[0].in = (sel_wir[0].value) ? cascd_wir[0].out ? cascd_wdr_dynmc[0].out;
            if(sel_wir[0].value == 1) begin
               cascd_wir[`IEEE1500_IR_WIDTH-1].in = sib1.out;
               for(i=0; i < `IEEE1500_IR_WIDTH - 1; i++) cascd_wir[i].in = cascd_wir[i+1].out;
            end
            else begin
               cascd_wdr_dynmc[cascd_wdr_dynmc.size-1].in = sib1.out;
               for(i=0; i < cascd_wdr_dynmc.size - 1; i++) cascd_wdr_dynmc[i].in = cascd_wdr_dynmc[i+1].out;
            end
            //----------------------------
            //sib1 connection
            //----------------------------
            sib1.in0 = sib3.out;
            sib1.in1 = sel_wir[1].out;

            //----------------------------
            //sel_wir[1] connection
            //----------------------------
            sel_wir[1].in = (sel_wir[1].value) ? cascd_wir[0].out ? cascd_wdr_dynmc[0].out;
            if(sel_wir[1].value == 1) begin
               cascd_wir[`IEEE1500_IR_WIDTH-1].in = sib3.out;
               for(i=0; i < `IEEE1500_IR_WIDTH - 1; i++) cascd_wir[i].in = cascd_wir[i+1].out;
            end
            else begin
               cascd_wdr_dynmc[cascd_wdr_dynmc.size-1].in = sib3.out;
               for(i=0; i < cascd_wdr_dynmc.size - 1; i++) cascd_wdr_dynmc[i].in = cascd_wdr_dynmc[i+1].out;
            end
         end// if(wir_data == `TILE0_SIB) begin
         else begin
            wdr_dynmc[wdr_dynmc.size - 1].in = sib3.out;
            for(i=0; i<wdr_dynmc.size - 1; i++)
            wdr_dynmc[i].in = wdr_dynmc[i+1].out;
            //sel_wir[2] connection branch1
            sel_wir[2].in = wdr_dynmc[0].out;
         end// !if(wir_data == `TILE0_SIB) begin
      end //!if(sel_wir[2].value == 1) begin
   end //if(sib[2].value == 1 ) begin
endfunction: dft_tdr_network