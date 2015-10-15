
`uvm_analysis_imp_decl(_jtag_drv)
`uvm_analysis_imp_decl(_clk_drv)
`uvm_analysis_imp_decl(_pad_drv)
//---------------------------------------------------------------------------
// Class: sib_node 
//---------------------------------------------------------------------------
class sib_node extends uvm_object;
   `uvm_object_utils(sib_node)
   bit    in0; 
   bit    in1; 
   bit    value;
   bit    out;
  
   function new(string name = "sib_node");
     super.new(name);
   endfunction : new
   
   function void out_update ();
      out = value ? in1 : in0;
   endfunction: out_update
   
   function void value_update ();
      value = out;
   endfunction: value_update
endclass : sib_node

//---------------------------------------------------------------------------
// Class: reg_node 
//---------------------------------------------------------------------------
class reg_node extends uvm_object;
   `uvm_object_utils(reg_node)
   bit    in; 
   bit    is_selwir; 
   bit    value;
   bit    out;
  
   function new(string name = "reg_node");
     super.new(name);
   endfunction : new
    
   function void out_update ();
      out = in;
   endfunction: out_update
    
   function void value_update ();
      value = out;
   endfunction: value_update
endclass : reg_node

//------------------------------------------------------------------------------
// class:caught_data 
//------------------------------------------------------------------------------
//This class is used to store information genrated by 1687 network maintainer.
class caught_data extends uvm_object;
   `uvm_object_utils(caught_data)
   //bit                              caught_1149_reg; 
   bit                              caught_1500_reg; 
   bit[`DFT_REG_ADDR_WIDTH-1: 0]    reg_addr; 
   bit                              reg_data_q[$];
  
   function new(string name = "caught_data");
     super.new(name);
   endfunction : new
    
   function string convert2string();
       string       s;
       $sformat(s, "%s\n***************caught_data begin**********",s);
       $sformat(s, "%s\n caught_1500_reg = %0d \n reg_addr = %h ",s,  caught_1500_reg, reg_addr);
       $sformat(s, "%s\n reg_data_q = ",s );
       foreach( reg_data_q[i] )
            $sformat(s, "%s%0b",s,reg_data_q[$-i] );
         $sformat(s, "%s\n***************caught_data end**********",s);
       return s;
   endfunction: convert2string
endclass : caught_data


//------------------------------------------------------------------------------
// class:bus_reg_ext 
//------------------------------------------------------------------------------
//This class is used to send information from a sequence to the adapter
class bus_reg_ext extends uvm_object;
   `uvm_object_utils(bus_reg_ext)
   bit    chk_ir_tdo; 
   bit    chk_dr_tdo; 
   bit    exp_tdo_dr_q[$];
   bit    exp_tdo_ir_q[$];
  
   //store regsiter wr data which larger than 64bits.
   bit    wr_data_q[$];
   function new(string name = "bus_reg_ext");
     super.new(name);
   endfunction : new
    
endclass : bus_reg_ext

//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;
    bit                              o_ir[];

    rand  int unsigned               o_dr_length;
    rand  int unsigned               o_ir_length;
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
    bit                              exp_tdo_dr_mask_queue[$];
    bit                              exp_tdo_ir_queue[$];
    
    rand  bit                        read_not_write;
    `uvm_object_utils( jtag_transaction )
    
    function new(string name = "jtag_transaction");
        super.new(name);
        o_dr = new[ o_dr_length ];
        o_ir = new[ o_ir_length ];

    endfunction
    
    constraint o_dr_length_c { 
       o_dr_length >= 8;
       o_dr_length <= 64;
    }
    
    constraint o_ir_length_c { 
       o_ir_length == 8;
    }

    function void post_randomize;
        o_dr = new[ o_dr_length ];
        o_ir = new[ o_ir_length ];
        
        foreach( o_dr[i] )
            o_dr[i] = $urandom;
        foreach( o_ir[i] )
            o_ir[i] = $urandom;
    endfunction: post_randomize
    
    function string convert2string();
        string       s;
        int unsigned hex_value;
        int unsigned four_bits_num = o_ir_length / 4;
        int unsigned remainder = o_ir_length % 4;

        s = super.convert2string();
        
        $sformat(s, "%s\n ********************jtag_transaction begin*****",s );
        $sformat(s, "%s\n o_ir = %0d'h",s, o_ir_length);
         
       
        if (remainder != 0) begin
            if (remainder == 1)
                hex_value = o_ir[four_bits_num*4];
            else if (remainder == 2)
                hex_value = o_ir[four_bits_num*4 + 1] *2 + o_ir[four_bits_num*4];
            else if (remainder == 3)
                hex_value = o_ir[four_bits_num*4 + 2] *4 + o_ir[four_bits_num*4 + 1] *2 + o_ir[four_bits_num*4];
            $sformat(s, "%s%0h",s,hex_value);
        end 
        
        for ( int i = four_bits_num-1; i >= 0; i--) begin
            hex_value = o_ir[i*4+3] *8 + o_ir[i*4+2] *4 + o_ir[i*4+1] *2 + o_ir[i*4];
            $sformat(s, "%s%0h",s,hex_value);
        end
        
        $sformat(s, "%s\n o_dr = %0d'h",s, o_dr_length);

        four_bits_num = o_dr_length / 4;
        remainder = o_dr_length % 4;
        if (remainder != 0) begin
            if (remainder == 1)
                hex_value = o_dr[four_bits_num*4];
            else if (remainder == 2)
                hex_value = o_dr[four_bits_num*4 + 1] *2 + o_dr[four_bits_num*4];
            else if (remainder == 3)
                hex_value = o_dr[four_bits_num*4 + 2] *4 + o_dr[four_bits_num*4 + 1] *2 + o_dr[four_bits_num*4];
            $sformat(s, "%s%0h",s,hex_value);
        end 
        
        for ( int i = four_bits_num-1; i >= 0; i--) begin
            hex_value = o_dr[i*4+3] *8 + o_dr[i*4+2] *4 + o_dr[i*4+1] *2 + o_dr[i*4];
            $sformat(s, "%s%0h",s,hex_value);
        end
 
        $sformat(s, "%s\n chk_ir_tdo = \t%d\n chk_dr_tdo = \t%d\n",s,  chk_ir_tdo, chk_dr_tdo);
        $sformat(s, "%s\n ********************jtag_transaction end*****",s );
        return s;
    endfunction: convert2string

    function string print_queue();
       string     s;

       $sformat(s, "%s\n tdi_ir_queue = ",s );
       foreach( tdi_ir_queue[i] )
            //$sformat(s, "%s%0b",s,tdi_ir_queue[$-i] );
            $sformat(s, "%s%0b",s,tdi_ir_queue[i] );

       $sformat(s, "%s\n tdi_dr_queue = ",s );
       foreach( tdi_dr_queue[i] )
            //$sformat(s, "%s%0b",s,tdi_dr_queue[$-i] );
            $sformat(s, "%s%0b",s,tdi_dr_queue[i] );

       $sformat(s, "%s\n tdo_ir_queue = ",s );
       foreach( tdo_ir_queue[i] )
            //$sformat(s, "%s%0b",s,tdo_ir_queue[$-i] );
            $sformat(s, "%s%0b",s,tdo_ir_queue[i] );

       $sformat(s, "%s\n tdo_dr_queue = ",s );
       foreach( tdo_dr_queue[i] )
            //$sformat(s, "%s%0b",s,tdo_dr_queue[$-i] );
            $sformat(s, "%s%0b",s,tdo_dr_queue[i] );
       if(chk_ir_tdo) begin
          $sformat(s, "%s\n exp_tdo_ir_queue = ",s);
          foreach( exp_tdo_ir_queue[i] )
               //$sformat(s, "%s%0b",s,exp_tdo_ir_queue[$-i] );
               $sformat(s, "%s%0b",s,exp_tdo_ir_queue[i] );
       end
       if(chk_dr_tdo) begin
          $sformat(s, "%s\n exp_tdo_dr_queue = ",s);
          foreach( exp_tdo_dr_queue[i] )
               //$sformat(s, "%s%0b",s,exp_tdo_dr_queue[$-i] );
               $sformat(s, "%s%0b",s,exp_tdo_dr_queue[i] );
       end
       return s;
    endfunction: print_queue

    virtual function void do_copy( uvm_object rhs );
       jtag_transaction       that;

       if ( ! $cast( that, rhs ) ) begin
          `uvm_error( get_name(), "rhs is not a jtag_transaction" )
          return;
       end

       super.do_copy( rhs );
       this.o_ir                    = that.o_ir                   ;            
       this.o_dr_length             = that.o_dr_length            ; 
       this.o_ir_length             = that.o_ir_length            ; 
       this.o_dr                    = that.o_dr                   ; 
       this.tdo_dr_queue            = that.tdo_dr_queue           ; 
       this.tdo_ir_queue            = that.tdo_ir_queue           ; 
       this.tdi_dr_queue            = that.tdi_dr_queue           ; 
       this.tdi_ir_queue            = that.tdi_ir_queue           ; 
       this.chk_ir_tdo              = that.chk_ir_tdo             ; 
       this.chk_dr_tdo              = that.chk_dr_tdo             ; 
       this.exp_tdo_dr_queue        = that.exp_tdo_dr_queue       ; 
       this.exp_tdo_dr_mask_queue   = that.exp_tdo_dr_mask_queue  ; 
       this.exp_tdo_ir_queue        = that.exp_tdo_ir_queue       ; 
       this.read_not_write          = that.read_not_write         ; 

    endfunction: do_copy


endclass:jtag_transaction

//------------------------------------------------------------------------------
// class: stil_info_transaction
//------------------------------------------------------------------------------
class stil_info_transaction extends uvm_sequence_item;
    string     stil_info;
    string     comment_info;
    int unsigned     time_stamp;
    `uvm_object_utils( stil_info_transaction )
    
    function new(string name = "stil_info_transaction");
        super.new(name);
    endfunction

    function string convert2string();
        string       s;
        $sformat(s, "%s\n comment_info = %s\n stil_info = %s \n time_stamp = %d ",s, comment_info, stil_info, time_stamp);
        return s;
    endfunction

    virtual function void do_copy( uvm_object rhs );
       stil_info_transaction        that;

       if ( ! $cast( that, rhs ) ) begin
          `uvm_error( get_name(), "rhs is not a stil_info_transaction" )
          return;
       end

       super.do_copy( rhs );
       this.stil_info  = that.stil_info;            
       this.comment_info  = that.comment_info;            
       this.time_stamp = that.time_stamp;            
    endfunction: do_copy


 endclass: stil_info_transaction    

//------------------------------------------------------------------------------
// class: dft_register_transaction
//------------------------------------------------------------------------------
class dft_register_transaction extends uvm_sequence_item;
    `uvm_object_utils( dft_register_transaction )
      
    bit                                read_not_write;
    bit[`DFT_REG_ADDR_WIDTH-1:0]       address;
    bit                                wr_data_q[$];
    bit                                rd_data_q[$];
    bus_reg_ext                        extension;
    int unsigned                       reg_length;
    function new(string name = "dft_register_transaction");
        super.new(name);
        extension = new("extension");
    endfunction

    function string convert2string();
        string       s;
        $sformat(s, "%s\n ********************dft_register_transaction*****\n",s );
        $sformat(s, "%s\n read_not_write = %0d \n address = %h \n reg_length = %0d\n",s, read_not_write, address, reg_length);
        
        $sformat(s, "%s\n ///////////////wr_data_q//////////////////////////\n",s );
        foreach( wr_data_q[i] )
            $sformat(s, "%s%0b",s,wr_data_q[$-i] );
        $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);
        
        $sformat(s, "%s\n ///////////////rd_data_q//////////////////////////\n",s );
        foreach( rd_data_q[i] )
            $sformat(s, "%s%0b",s,rd_data_q[$-i] );
        $sformat(s, "%s\n /////////////////////////////////////////////////////\n",s);
        $sformat(s, "%s\n ********************dft_register_transaction*****\n",s );
      
      
        return s;
    endfunction: convert2string


endclass: dft_register_transaction    

//------------------------------------------------------------------------------
// class: dft_register_monitor
//------------------------------------------------------------------------------
class dft_register_monitor extends uvm_subscriber #(jtag_transaction);
   `uvm_component_utils( dft_register_monitor )
   
   uvm_analysis_port #(dft_register_transaction) dft_reg_ap;
  
   dft_register_transaction         dft_reg_tx;
   bit[`DFT_REG_ADDR_WIDTH-1:0]     temp_ir;
   bit                              temp_dr_q[$];
   sib_node                         sib[`SIB_WIDTH];
   reg_node                         sel_wir[`SIB_WIDTH];
   reg_node                         wir[`IEEE_1500_IR_WIDTH], wdr_dynmc[]; 
   reg_node                         cascd_wir[`IEEE_1500_IR_WIDTH], cascd_wdr_dynmc[];
   string                           temp_name;
   string                           report_id = "dft_register_monitor"; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      dft_reg_ap = new( .name("dft_reg_ap"), .parent(this) );


      for(int i=0; i<`SIB_WIDTH; i++) begin
         temp_name = $sformatf("sib[%0d]",i);
         sib[i] = new(temp_name);
         temp_name = $sformatf("sel_wir[%0d]",i);
         sel_wir[i] = new(temp_name);
      end
      
      for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) begin
         temp_name = $sformatf("wir[%0d]",i);
         wir[i] = new(temp_name);
         temp_name = $sformatf("cascd_wir[%0d]",i);
         cascd_wir[i] = new(temp_name);
      end
      
      node_initialize();
      node_value_print();
   endfunction: build_phase

   function void write( jtag_transaction t);
      caught_data          cght_data;
      if(t.read_not_write)begin
         foreach(t.tdo_ir_queue[i]) begin
            temp_ir[i] = t.tdo_ir_queue[i]; 
            temp_dr_q  = t.tdo_dr_queue;
         end
      end
      else begin
         foreach(t.tdi_ir_queue[i]) begin
            temp_ir[i] = t.tdi_ir_queue[i]; 
            temp_dr_q  = t.tdi_dr_queue;
         end
      end
      
      if(temp_ir == `I1687_OPCODE) begin

         //cght_data = new("cght_data"); 
         
         cght_data = dft_tdr_network(t); 

         `uvm_info( report_id,{ cght_data.convert2string }, UVM_MEDIUM);
         if(cght_data.caught_1500_reg) begin
            dft_reg_tx = dft_register_transaction::type_id::create("dft_reg_tx");
            
            dft_reg_tx.read_not_write = t.read_not_write;
            dft_reg_tx.address = cght_data.reg_addr;
            
            if(t.read_not_write) begin
               dft_reg_tx.rd_data_q = cght_data.reg_data_q;
               dft_reg_tx.reg_length = cght_data.reg_data_q.size();
            end
            else begin
               dft_reg_tx.wr_data_q = cght_data.reg_data_q;
               dft_reg_tx.reg_length = cght_data.reg_data_q.size();
            end
            dft_reg_ap.write(dft_reg_tx);
         end// if(cght_data.caught_1500_reg) begin
      end// if(temp_ir == `I1687_OPCODE) begin
      else begin
         dft_reg_tx = dft_register_transaction::type_id::create("dft_reg_tx");
         dft_reg_tx.read_not_write = t.read_not_write;
         dft_reg_tx.address = {temp_ir[`IEEE_1149_IR_WIDTH-1:0],`SIB_WIDTH'b0};
         if(t.read_not_write) begin
            dft_reg_tx.rd_data_q = t.tdo_dr_queue;
            dft_reg_tx.reg_length = t.tdo_dr_queue.size();
         end
         else begin
            dft_reg_tx.wr_data_q = t.tdi_dr_queue;
            dft_reg_tx.reg_length = t.tdi_dr_queue.size();
         end
         dft_reg_ap.write(dft_reg_tx);
      end
   endfunction: write
  
   virtual function void node_initialize();
      //sel_wir node initialize.
      foreach (sel_wir[i]) begin
         sel_wir[i].is_selwir = 1;
         sel_wir[i].value = 1;
      end
   endfunction :node_initialize
   
   virtual function void node_out_update();
      foreach (sel_wir[i]) sel_wir[i].out_update();
      foreach (sib[i]) sib[i].out_update();
      foreach (cascd_wir[i]) cascd_wir[i].out_update();
      foreach (wir[i]) wir[i].out_update();
      if(wdr_dynmc.size() >= 1)
         foreach (wdr_dynmc[i]) wdr_dynmc[i].out_update();
      if(cascd_wdr_dynmc.size() >= 1)
         foreach (cascd_wdr_dynmc[i]) cascd_wdr_dynmc[i].out_update();
   endfunction :node_out_update
   
   virtual function void node_value_update();
      foreach (sel_wir[i]) if(sib[i].value) sel_wir[i].value_update();
      foreach (sib[i]) sib[i].value_update();
      foreach (cascd_wir[i]) cascd_wir[i].value_update();
      foreach (wir[i]) wir[i].value_update();
      if(wdr_dynmc.size() >= 1)
         foreach (wdr_dynmc[i]) wdr_dynmc[i].value_update();
      if(cascd_wdr_dynmc.size() >= 1)
         foreach (cascd_wdr_dynmc[i]) cascd_wdr_dynmc[i].value_update();
   endfunction :node_value_update
   
   virtual function void node_value_print();
      string s; 
      
      $sformat(s, "%s\n sib = %0d'",s, `SIB_WIDTH);
      for(int i=`SIB_WIDTH-1; i>=0; i--) $sformat(s, "%s%0b",s,sib[i].value);
      
      $sformat(s, "%s\n sel_wir = %0d'",s, `SIB_WIDTH);
      for(int i=`SIB_WIDTH-1; i>=0; i--) $sformat(s, "%s%0b",s,sel_wir[i].value);

      $sformat(s, "%s\n wir = %0d'",s, `IEEE_1500_IR_WIDTH);
      for(int i=`IEEE_1500_IR_WIDTH-1; i>=0; i--) $sformat(s, "%s%0b",s,wir[i].value);
      
      $sformat(s, "%s\n cascd_wir = %0d'",s, `IEEE_1500_IR_WIDTH);
      for(int i=`IEEE_1500_IR_WIDTH-1; i>=0; i--) $sformat(s, "%s%0b",s,cascd_wir[i].value);
      
      $sformat(s, "%s\n wdr_dynmc = %0d'",s, wdr_dynmc.size());
      for(int i=wdr_dynmc.size()-1; i>=0; i--) $sformat(s, "%s%0b",s,wdr_dynmc[i].value);

      $sformat(s, "%s\n cascd_wdr_dynmc = %0d'",s, cascd_wdr_dynmc.size());
      for(int i=cascd_wdr_dynmc.size()-1; i>=0; i--) $sformat(s, "%s%0b",s,cascd_wdr_dynmc[i].value);

      `uvm_info("node_value_print",s,UVM_DEBUG);
   endfunction :node_value_print
   


   virtual function caught_data dft_tdr_network (jtag_transaction jtag_tx); 
      int unsigned                  chain_length;
      int unsigned                  wdr_length;
      bit[`IEEE_1500_IR_WIDTH-1:0]  wir_data;
      bit                           tdi, tdo; 
      caught_data                   cght_data; 

      cght_data = caught_data::type_id::create("cght_data");
      
      //`uvm_info("dft_tdr_network ",$sformatf("{sib[1],sib[0],sib[3],sib[2]} = %0b%0b%0b%0b",sib[1].value,sib[0].value,sib[3].value,sib[2].value),UVM_NONE);
      case({sib[1].value, sib[0].value, sib[3].value, sib[2].value})
         4'b0000: begin
            chain_length = `I1687_LENGTH;
            wdr_dynmc = new[1]; //It's not really being used, just to avoid Null object operation when connecting sel_wir[3].
            wdr_dynmc[0] = new("wdr_dynmc");
         end
         4'b0001: begin
            chain_length = ((sel_wir[2].value == 1) ? chain_length + `IEEE_1500_IR_WIDTH : `I1687_LENGTH) + 1;    
            if((sel_wir[2].value == 0))begin
               wdr_length = jtag_tx.o_dr_length - chain_length;
               wdr_dynmc = new[wdr_length];
               foreach(wdr_dynmc[i]) wdr_dynmc[i] = new("wdr_dynmc");
            end
         end
         4'b0010: begin
            chain_length = ((sel_wir[3].value == 1) ? chain_length + `IEEE_1500_IR_WIDTH : `I1687_LENGTH) + 1;    
            if((sel_wir[3].value == 0))begin
               wdr_length = jtag_tx.o_dr_length - chain_length;
               wdr_dynmc = new[wdr_length];
               foreach(wdr_dynmc[i]) wdr_dynmc[i] = new("wdr_dynmc");
            end
         end
         4'b0101: begin
            chain_length = ((sel_wir[0].value == 1) ? `SIB_WIDTH + `IEEE_1500_IR_WIDTH : `SIB_WIDTH) + 2;    
            if((sel_wir[0].value == 0))begin
               wdr_length = jtag_tx.o_dr_length - chain_length;
               cascd_wdr_dynmc = new[wdr_length];
               foreach(cascd_wdr_dynmc[i]) cascd_wdr_dynmc[i] = new("cascd_wdr_dynmc");
            end
         end
         4'b1001: begin
            chain_length = ((sel_wir[1].value == 1) ? `SIB_WIDTH + `IEEE_1500_IR_WIDTH : `SIB_WIDTH) + 2;    
            if((sel_wir[1].value == 0))begin
               wdr_length = jtag_tx.o_dr_length - chain_length;
               cascd_wdr_dynmc = new[wdr_length];
               foreach(cascd_wdr_dynmc[i]) cascd_wdr_dynmc[i] = new("cascd_wdr_dynmc");
            end
         end
      endcase
       
      //`uvm_info("dft_tdr_network ",$sformatf("chain_length = %0d, wdr_length = %0d",chain_length, wdr_length),UVM_NONE);
      
      for(int shift_cycle = 0; shift_cycle < jtag_tx.o_dr_length; shift_cycle++) begin
         tdi = jtag_tx.read_not_write ? jtag_tx.tdo_dr_queue[shift_cycle] : jtag_tx.tdi_dr_queue[shift_cycle];
         //calculate current chain_length
        
         tdo = sib[2].out;
     
         //sib[2] connection
         sib[2].in0 = sib[3].out;
         sib[2].in1 = sel_wir[2].out;
   
         //sib[3] connection
         sib[3].in0 = tdi;
         sib[3].in1 = sel_wir[3].out;
   
         //sel_wir[3] connection
         sel_wir[3].in = (sel_wir[3].value == 1 ) ? wir[0].out : wdr_dynmc[0].out;
         
         //wir/wdr_dynmc connection belong to sel_sir[3]
         if(sib[3].value == 1 ) begin
            if(sel_wir[3].value == 1) begin
               wir[`IEEE_1500_IR_WIDTH - 1].in = tdi;
               for(int i=0; i<`IEEE_1500_IR_WIDTH - 1; i++)
                  wir[i].in = wir[i+1].out;
            end
            else begin
               wdr_dynmc[wdr_dynmc.size - 1].in = tdi;
               for(int i=0; i<wdr_dynmc.size - 1; i++)
                  wdr_dynmc[i].in = wdr_dynmc[i+1].out;
   
               if(shift_cycle == jtag_tx.o_dr_length-1)begin
                  //cght_data = caught_data::type_id::create("cght_data");
                  cght_data.caught_1500_reg = 1;
                  cght_data.reg_addr[`SIB_WIDTH-1:0] = {sib[1].value,sib[0].value,sib[3].value,sib[2].value};
                  foreach(wir[i]) cght_data.reg_addr[`SIB_WIDTH+i] = wir[i].value;
                           
                  //last shift cycle,in order to store DR in caught_data, need to update out and value in advance.
                  node_out_update(); 
                  node_value_update(); 

                  foreach(wdr_dynmc[i]) cght_data.reg_data_q[i] = wdr_dynmc[i].value;
               end
            end
         end
         
         //----------------------------
         //sel_wir[2] connection
         //----------------------------
         if(sib[2].value == 1 ) begin
            //connect wir to chain
            if(sel_wir[2].value == 1) begin
               wir[`IEEE_1500_IR_WIDTH - 1].in = sib[3].out;
               for(int i=0; i<`IEEE_1500_IR_WIDTH - 1; i++)
                  wir[i].in = wir[i+1].out;
               //sel_wir[2] connection branch3
               sel_wir[2].in = wir[0].out;
            end
            else begin
               //get current ir opecode
               foreach(wir[i]) wir_data[i] = wir[i].value;
               if(wir_data == `SUB_CLIENT_SIB_OPCODE) begin
                  //sel_wir[2] connection branch2
                  sel_wir[2].in = sib[0].out;
                  
                  //----------------------------
                  //sib[0] connection
                  //----------------------------
                  sib[0].in0 = sib[1].out;
                  sib[0].in1 = sel_wir[0].out;
                  
                  if(sib[0].value == 1)begin
                     //----------------------------
                     //sel_wir[0] connection
                     //----------------------------
                     sel_wir[0].in = (sel_wir[0].value) ? cascd_wir[0].out : cascd_wdr_dynmc[0].out;
                     if(sel_wir[0].value == 1) begin
                        cascd_wir[`IEEE_1500_IR_WIDTH-1].in = sib[1].out;
                        for(int i=0; i < `IEEE_1500_IR_WIDTH - 1; i++) cascd_wir[i].in = cascd_wir[i+1].out;
                     end
                     else begin
                        cascd_wdr_dynmc[cascd_wdr_dynmc.size-1].in = sib[1].out;
                        for(int i=0; i < cascd_wdr_dynmc.size - 1; i++) cascd_wdr_dynmc[i].in = cascd_wdr_dynmc[i+1].out;
                        
                        if(shift_cycle == jtag_tx.o_dr_length-1)begin
                           //cght_data = caught_data::type_id::create("cght_data");
                           cght_data.caught_1500_reg = 1;
                           cght_data.reg_addr[`SIB_WIDTH-1:0] = {sib[1].value,sib[0].value,sib[3].value,sib[2].value};
                           foreach(cascd_wir[i]) cght_data.reg_addr[`SIB_WIDTH+i] = cascd_wir[i].value;
                           
                           //last shift cycle,in order to store DR in caught_data, need to update out and value in advance.
                           node_out_update(); 
                           node_value_update(); 

                           foreach(cascd_wdr_dynmc[i]) cght_data.reg_data_q[i] = cascd_wdr_dynmc[i].value;
                        end// if(shift_cycle == jtag_tx.o_dr_length-1)begin
                     end//! if(sel_wir[0].value == 1) begin
                  end// if(sib[0].value == 1)begin
                  
                  //----------------------------
                  //sib[1] connection
                  //----------------------------
                  sib[1].in0 = sib[3].out;
                  sib[1].in1 = sel_wir[1].out;
   
                  if(sib[1].value == 1)begin
                     //----------------------------
                     //sel_wir[1] connection
                     //----------------------------
                     sel_wir[1].in = (sel_wir[1].value) ? cascd_wir[0].out : cascd_wdr_dynmc[0].out;
                     if(sel_wir[1].value == 1) begin
                        cascd_wir[`IEEE_1500_IR_WIDTH-1].in = sib[3].out;
                        for(int i=0; i < `IEEE_1500_IR_WIDTH - 1; i++) cascd_wir[i].in = cascd_wir[i+1].out;
                     end
                     else begin
                        cascd_wdr_dynmc[cascd_wdr_dynmc.size-1].in = sib[3].out;
                        for(int i=0; i < cascd_wdr_dynmc.size - 1; i++) cascd_wdr_dynmc[i].in = cascd_wdr_dynmc[i+1].out;
                        
                        if(shift_cycle == jtag_tx.o_dr_length-1)begin
                           //cght_data = caught_data::type_id::create("cght_data");
                           cght_data.caught_1500_reg = 1;
                           cght_data.reg_addr[`SIB_WIDTH-1:0] = {sib[1].value,sib[0].value,sib[3].value,sib[2].value};
                           foreach(cascd_wir[i]) cght_data.reg_addr[`SIB_WIDTH+i] = cascd_wir[i].value;
                           
                           //last shift cycle,in order to store DR in caught_data, need to update out and value in advance.
                           node_out_update(); 
                           node_value_update(); 
                           
                           foreach(cascd_wdr_dynmc[i]) cght_data.reg_data_q[i] = cascd_wdr_dynmc[i].value;
                        end// if(shift_cycle == jtag_tx.o_dr_length-1)begin
                     end//! if(sel_wir[1].value == 1) begin
                  end//if(sib[1].value == 1)begin
               end// if(wir_data == `SUB_CLIENT_SIB_OPCODE) begin
               else begin
                  wdr_dynmc[wdr_dynmc.size - 1].in = sib[3].out;
                  for(int i=0; i<wdr_dynmc.size - 1; i++)
                  wdr_dynmc[i].in = wdr_dynmc[i+1].out;
                  //sel_wir[2] connection branch1
                  sel_wir[2].in = wdr_dynmc[0].out;
                  
                  if(shift_cycle == jtag_tx.o_dr_length-1)begin
                     //cght_data = caught_data::type_id::create("cght_data");
                     cght_data.caught_1500_reg = 1;
                     cght_data.reg_addr[`SIB_WIDTH-1:0] = {sib[1].value,sib[0].value,sib[3].value,sib[2].value};
                     foreach(wir[i]) cght_data.reg_addr[`SIB_WIDTH+i] = wir[i].value;
                     
                     //last shift cycle,in order to store DR in caught_data, need to update out and value in advance.
                     node_out_update(); 
                     node_value_update(); 

                     foreach(wdr_dynmc[i]) cght_data.reg_data_q[i] = wdr_dynmc[i].value;
               end// if(shift_cycle == jtag_tx.o_dr_length-1)begin
               end// !if(wir_data == `SUB_CLIENT_SIB_OPCODE) begin
            end //!if(sel_wir[2].value == 1) begin
         end //if(sib[2].value == 1 ) begin
         node_out_update(); 
      end//for(int shift_cycle = 0; shift_cycle < jtag_tx.o_dr_length; shift_cycle++) begin
      
      node_value_update(); 
      node_value_print(); 
      wdr_dynmc.delete();
      cascd_wdr_dynmc.delete();
      
      return cght_data;
   endfunction: dft_tdr_network
endclass:dft_register_monitor
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
// Class: pad_driver
//---------------------------------------------------------------------------
class pad_driver extends uvm_driver#( jtag_transaction );
   `uvm_component_utils( pad_driver )
   
   virtual pad_if          pad_vi;

   bit                       gen_stil_file;
   pad_configuration       pad_cfg; 
   uvm_analysis_port #(stil_info_transaction)      pad_drv_ap;
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      pad_drv_ap = new("pad_drv_ap", this );
      pad_cfg = pad_configuration::type_id::create(.name("pad_cfg"));
      assert(uvm_config_db#(pad_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "pad_cfg" ), .value( this.pad_cfg) ));
      
      gen_stil_file = pad_cfg.gen_stil_file;
      pad_vi = pad_cfg.pad_vi;
   endfunction: build_phase

   task run_phase( uvm_phase phase );
         @pad_vi.driver_mp.posedge_cb;
         pad_vi.driver_mp.posedge_cb.POWER_OK<= 1'b1;
         pad_vi.driver_mp.posedge_cb.VDD <= 1'b1;
         pad_vi.driver_mp.posedge_cb.VSS <= 1'b0;
   endtask: run_phase
endclass: pad_driver

//---------------------------------------------------------------------------
// Class: reset_driver
//---------------------------------------------------------------------------
class reset_driver extends uvm_driver#( jtag_transaction );
   `uvm_component_utils( reset_driver )
   
   virtual reset_if          reset_vi;

   bit                       gen_stil_file;
   reset_configuration       reset_cfg; 
   uvm_analysis_port #(stil_info_transaction)      reset_drv_ap;
   stil_info_transaction     stil_info_tx;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      reset_drv_ap = new("reset_drv_ap", this );
      reset_cfg = reset_configuration::type_id::create(.name("reset_cfg"));
      assert(uvm_config_db#(reset_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_cfg" ), .value( this.reset_cfg) ));
      
      gen_stil_file = reset_cfg.gen_stil_file;
      reset_vi = reset_cfg.reset_vi;
   endfunction: build_phase
   
   function void call_stil_gen (bit gen_stil_file, string comment_str = "");
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"TRST = %0b; RESET_L = %0b;"},reset_vi.trst,reset_vi.RESET_L);
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         `uvm_info("reset_drv",stil_info_tx.convert2string,UVM_NONE);
         reset_drv_ap.write(stil_info_tx);
      end
   endfunction :call_stil_gen


   task run_phase( uvm_phase phase );
         @reset_vi.driver_mp.posedge_cb;
         reset_vi.driver_mp.posedge_cb.trst <= 1'b1;
         call_stil_gen(gen_stil_file);
         
         repeat (3) @reset_vi.driver_mp.posedge_cb;
         reset_vi.driver_mp.posedge_cb.trst <= 1'b0;
         reset_vi.driver_mp.posedge_cb.RESET_L<= 1'b0;
         call_stil_gen(gen_stil_file);
         
         @reset_vi.driver_mp.posedge_cb;
         reset_vi.driver_mp.posedge_cb.RESET_L<= 1'b1;
         call_stil_gen(gen_stil_file);
   endtask: run_phase
endclass: reset_driver

//---------------------------------------------------------------------------
// Class: clk_driver
//---------------------------------------------------------------------------
class clk_driver extends uvm_driver#( jtag_transaction );
   `uvm_component_utils( clk_driver )
   
   virtual clk_if          clk_vi;

   bit                       gen_stil_file;
   bit                       stop_tck,stop_sysclk;
   int                       tck_half_period;
   int                       sysclk_half_period;
   clk_configuration         clk_cfg; 
   uvm_analysis_port #(stil_info_transaction) clk_drv_ap;
   stil_info_transaction     stil_info_tx;
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      
      clk_drv_ap = new("clk_drv_ap ", this);
      clk_cfg = clk_configuration::type_id::create(.name("clk_cfg"));
      assert(uvm_config_db#(clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.clk_cfg) ));
      
      gen_stil_file = clk_cfg.gen_stil_file;
      tck_half_period = clk_cfg.tck_half_period;
      sysclk_half_period = clk_cfg.sysclk_half_period;
      clk_vi = clk_cfg.clk_vi;
   endfunction: build_phase
   
   function void call_stil_gen (bit gen_stil_file, string comment_str = {""});
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"TCK = %0b; SYSCLK = %0b;"},clk_vi.tck,clk_vi.sysclk);
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         `uvm_info("clk_drv",stil_info_tx.convert2string,UVM_NONE);
         clk_drv_ap.write(stil_info_tx);
      end
   endfunction :call_stil_gen


   task run_phase( uvm_phase phase );
      
      clk_vi.tck = 0;
      clk_vi.sysclk = 0; 
      call_stil_gen(gen_stil_file);
      //#tck_half_period;
      forever begin
        #sysclk_half_period;
        clk_vi.sysclk = ~clk_vi.sysclk; 
        call_stil_gen(gen_stil_file);
        
        #sysclk_half_period;
        clk_vi.sysclk = ~clk_vi.sysclk; 
        clk_vi.tck = ~clk_vi.tck;
        call_stil_gen(gen_stil_file);
        
        #sysclk_half_period;
        clk_vi.sysclk = ~clk_vi.sysclk; 
        call_stil_gen(gen_stil_file);
        #sysclk_half_period;
        clk_vi.sysclk = ~clk_vi.sysclk; 
        clk_vi.tck = ~clk_vi.tck;
        call_stil_gen(gen_stil_file);
      
      end
   endtask: run_phase
endclass: clk_driver
//---------------------------------------------------------------------------
// Class: jtag_driver
//---------------------------------------------------------------------------

class jtag_driver extends uvm_driver#( jtag_transaction );
   `uvm_component_utils( jtag_driver )
   
   uvm_analysis_port #(stil_info_transaction)   jtag_drv_ap; 
   virtual jtag_if         jtag_vi;
   string                  report_id = "jtag_driver";
   bit                     gen_stil_file;
   string                  stil_file_name;
   int                     tck_half_period;
   jtag_configuration      jtag_cfg;
   stil_info_transaction      stil_info_tx;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jtag_drv_ap = new("jtag_drv_ap ", this);

      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      assert(uvm_config_db#(jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( this.jtag_cfg) ));

      `uvm_info(report_id,jtag_cfg.convert2string,UVM_DEBUG);
      gen_stil_file = jtag_cfg.gen_stil_file;
      stil_file_name = jtag_cfg.stil_file_name;
      tck_half_period = jtag_cfg.tck_half_period;
      jtag_vi = jtag_cfg.jtag_vi;
   endfunction: build_phase
  
   function void call_stil_gen (bit gen_stil_file, string comment_str = {""}, string tdo = "X");
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"TMS = %0b; TDI = %0b; TDO = %s;"},jtag_vi.tms,jtag_vi.tdi,tdo);;
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         `uvm_info("jtag_drv",stil_info_tx.convert2string,UVM_NONE);
         
         jtag_drv_ap.write(stil_info_tx);
      end
   endfunction :call_stil_gen

   task run_phase( uvm_phase phase );
      jtag_transaction  jtag_tx;

      string            fsm_nstate;
      string            stil_str;
      string            comment_str;
      //int               stil_fd;
      string            chk_tdo_value;
      jtag_vi.master_mp.posedge_cb.tms <= 1;
      
      //stil_str = "tms = 1;";
      call_stil_gen(gen_stil_file);
     
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

         //stil_str = "tms = 0;";
         //comment_str = $sformatf({"#",fsm_nstate});
         call_stil_gen(gen_stil_file,fsm_nstate);
         
         //read_not_write is used for monitor only
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.read_not_write <= jtag_tx.read_not_write;


         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);
         
         //take jtag fsm into select_ir_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_ir_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);
                  
         //take jtag fsm into capture_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);

         //take jtag fsm into shift_ir state
         for(int i = 0; i < jtag_tx.o_ir_length; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            fsm_nstate = $sformatf("take jtag fsm into shift_ir state, shift_count = %0d", i);
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
               
               call_stil_gen(gen_stil_file,fsm_nstate,chk_tdo_value);

            end// if(gen_stil_file == `ON)
         end //for(int i = 0; i < jtag_tx.o_ir_length; i ++) begin

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[jtag_tx.o_ir_length-1];
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_ir_tdo) 
              if(jtag_tx.exp_tdo_ir_queue[jtag_tx.o_ir_length-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            call_stil_gen(gen_stil_file,fsm_nstate,chk_tdo_value);
         end// if(gen_stil_file == `ON)

         //take jtag fsm into update_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);

         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);
         
         //take jtag fsm into capture_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         call_stil_gen(gen_stil_file,fsm_nstate);

         //take jtag fsm into shift_dr state
         for(int i = 0; i < jtag_tx.o_dr_length; i ++) begin
            @jtag_vi.master_mp.posedge_cb;
            jtag_vi.master_mp.posedge_cb.tms <= 0;
            
            fsm_nstate = $sformatf("take jtag fsm into shift_dr state, shift_count = %0d",i);
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
               call_stil_gen(gen_stil_file,fsm_nstate,chk_tdo_value);
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
            call_stil_gen(gen_stil_file,fsm_nstate);

         end// if(gen_stil_file == `ON)

       
         //take jtag fsm into update_dr state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
          
         call_stil_gen(gen_stil_file,fsm_nstate);
 
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         call_stil_gen(gen_stil_file,fsm_nstate);
         
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
         for(int i = 0; i < jtag_tx.o_ir_length; i ++) begin
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
         end //for(int i = 0; i < jtag_tx.o_ir_length; i ++) begin

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.posedge_cb;
         jtag_vi.master_mp.posedge_cb.tms <= 1;
         
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[jtag_tx.o_ir_length-1];
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver_atpg", { fsm_nstate }, UVM_DEBUG );
         
         if(gen_stil_file == `ON)begin
            if(jtag_tx.chk_ir_tdo) 
              if(jtag_tx.exp_tdo_ir_queue[jtag_tx.o_ir_length-1])  chk_tdo_value = "H";
              else chk_tdo_value = "L";
            else chk_tdo_value = "X";
            stil_str = $sformatf({"   //take jtag fsm into exit1_ir state\n",
                                  "   V { BP_TCK = P; BP_TDI = %b; BP_TMS = 1; BP_TRST_L = 1; BP_TDO = %s;}\n" }, jtag_tx.o_ir[jtag_tx.o_ir_length-1],chk_tdo_value);
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

//---------------------------------------------------------------------------
// Class: dft_register_sequencer
//---------------------------------------------------------------------------
typedef uvm_sequencer #(dft_register_transaction) dft_register_sequencer;

//------------------------------------------------------------------------------
// Class: dft_register_adapter
//------------------------------------------------------------------------------

class dft_register_adapter extends uvm_reg_adapter;
   `uvm_object_utils( dft_register_adapter )
   const string      report_id;
   function new( string name = "" );
      super.new( name );
      supports_byte_enable = 0;
      provides_responses   = 0;
      report_id = name;
   endfunction: new

   virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
      bus_reg_ext                   extension;
      uvm_reg_item                  item = get_item();
      dft_register_transaction      dft_reg_tx = dft_register_transaction::type_id::create("dft_reg_tx");
      int unsigned                  ext_wr_data_length;
      
      ext_wr_data_length = 0;

      if(!$cast(extension,item.extension))
         `uvm_error("reg2bus", "Extension casting failed.");

      if( extension != null ) begin
         dft_reg_tx.extension = extension;
         ext_wr_data_length = extension.wr_data_q.size();
      end
    
      dft_reg_tx.address = rw.addr;
      dft_reg_tx.read_not_write = (rw.kind == UVM_READ);

      if(ext_wr_data_length == 0) begin
         for(int i=0; i<rw.n_bits; i++)  dft_reg_tx.wr_data_q = {dft_reg_tx.wr_data_q, rw.data[i]}; 
         dft_reg_tx.reg_length = rw.n_bits;
      end 
      else begin
         for(int i=0; i<rw.n_bits; i++)  dft_reg_tx.wr_data_q = {dft_reg_tx.wr_data_q, rw.data[i]}; 
         dft_reg_tx.wr_data_q = {dft_reg_tx.wr_data_q, extension.wr_data_q};
         dft_reg_tx.reg_length = rw.n_bits + ext_wr_data_length;
      end

      `uvm_info( "dft_reg_adapter",{dft_reg_tx.convert2string}, UVM_MEDIUM);
      return dft_reg_tx;
   endfunction: reg2bus
   
   virtual function void bus2reg( uvm_sequence_item bus_item, ref uvm_reg_bus_op rw );
      dft_register_transaction  dft_reg_tx;
      
      if ( ! $cast( dft_reg_tx, bus_item ) ) begin
         `uvm_fatal( get_name(), "bus_item is not of the dft_register_transaction type." )
         return;
      end
     
      rw.kind = (dft_reg_tx.read_not_write == 1) ? UVM_READ : UVM_WRITE;
      rw.addr = dft_reg_tx.address;

      if(dft_reg_tx.read_not_write == 1) begin
         //currently only consider register lenght <= 64
         if(dft_reg_tx.reg_length <= 64)begin
            foreach(dft_reg_tx.rd_data_q[i]) rw.data[i] = dft_reg_tx.rd_data_q[i];
         end
      end
      else begin
         //currently only consider register lenght <= 64
         if(dft_reg_tx.reg_length <= 64)begin
            foreach(dft_reg_tx.wr_data_q[i]) rw.data[i] = dft_reg_tx.wr_data_q[i];
         end
      end
   endfunction: bus2reg
endclass: dft_register_adapter



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

         foreach(extension.exp_tdo_ir_q[i])
            jtag_tx.exp_tdo_ir_queue = {jtag_tx.exp_tdo_ir_queue,extension.exp_tdo_ir_q[i]};
         
         foreach(extension.exp_tdo_dr_q[i])
            jtag_tx.exp_tdo_dr_queue = {jtag_tx.exp_tdo_dr_queue,extension.exp_tdo_dr_q[i]};
      end

      //jtag_tx.protocol = IEEE_1149_1;
      jtag_tx.o_ir_length = `IEEE_1149_IR_WIDTH;
      jtag_tx.o_ir = new[jtag_tx.o_ir_length];
      foreach(jtag_tx.o_ir[i]) jtag_tx.o_ir[i] = rw.addr[i];

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
// Class: stil_generator
//---------------------------------------------------------------------------
class stil_generator extends uvm_subscriber #( stil_info_transaction );
   `uvm_component_utils( stil_generator )

   uvm_analysis_imp_jtag_drv  #(stil_info_transaction, stil_generator) jtag_drv_imp_export;
   uvm_analysis_imp_clk_drv   #(stil_info_transaction, stil_generator) clk_drv_imp_export;
   uvm_analysis_imp_pad_drv   #(stil_info_transaction, stil_generator) pad_drv_imp_export;
   
   bit         write_to_file; 
   string      jtag_drv_info;
   string      clk_drv_info;
   string      reset_drv_info;
   string      pad_drv_info;
   
   stil_info_transaction      pad_stil_info_tx,pad_stil_info_tx_pre;
   stil_info_transaction      reset_stil_info_tx,reset_stil_info_tx_pre;
   stil_info_transaction      clk_stil_info_tx,clk_stil_info_tx_pre;
   stil_info_transaction      jtag_stil_info_tx,jtag_stil_info_tx_pre;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase(uvm_phase phase);
      super.build_phase( phase );
      
      jtag_drv_imp_export = new("jtag_drv_imp_export", this);
      clk_drv_imp_export = new("clk_drv_imp_export", this);
      pad_drv_imp_export = new("pad_drv_imp_export", this);
   endfunction: build_phase
   
   function void write( stil_info_transaction t);
      reset_stil_info_tx = t; 
   endfunction: write
 
   function void write_jtag_drv( stil_info_transaction t);
      jtag_stil_info_tx = t; 
   endfunction: write_jtag_drv
   
   function void write_clk_drv( stil_info_transaction t);
      clk_stil_info_tx = t; 
   endfunction: write_clk_drv
   
   function void write_pad_drv( stil_info_transaction t);
      pad_stil_info_tx = t; 
   endfunction: write_pad_drv
   
   task run_phase(uvm_phase phase);
      string            stil_str;
      string            comment_str;
      int               stil_fd;
      
      stil_fd = $fopen("jtag_1149_1_test.stil", "w");
      forever begin
         if(jtag_stil_info_tx != null) begin
            `uvm_info("stil_generator",jtag_stil_info_tx.convert2string,UVM_NONE);

            if(jtag_stil_info_tx_pre == null) begin
               jtag_stil_info_tx_pre = stil_info_transaction::type_id::create("jtag_stil_info_tx_pre");
               $cast(jtag_stil_info_tx_pre, jtag_stil_info_tx.clone());
               stil_str = {stil_str,jtag_stil_info_tx_pre.stil_info};

               if(!jtag_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,jtag_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
            else if(jtag_stil_info_tx_pre.time_stamp != jtag_stil_info_tx.time_stamp) begin
               //`uvm_info("stil_generator",jtag_stil_info_tx_pre.convert2string,UVM_NONE);
               $cast(jtag_stil_info_tx_pre, jtag_stil_info_tx.clone());
               stil_str = {stil_str,jtag_stil_info_tx_pre.stil_info};
               if(!jtag_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,jtag_stil_info_tx_pre.comment_info};
               write_to_file = 1;
               `uvm_info("stil_generator",jtag_stil_info_tx_pre.convert2string,UVM_NONE);
            end
         end
         if(clk_stil_info_tx != null) begin
            `uvm_info("stil_generator",clk_stil_info_tx.convert2string,UVM_NONE);
            if(clk_stil_info_tx_pre == null) begin
               clk_stil_info_tx_pre = stil_info_transaction::type_id::create("clk_stil_info_tx_pre");
               $cast(clk_stil_info_tx_pre, clk_stil_info_tx.clone());
               stil_str = {stil_str,clk_stil_info_tx_pre.stil_info};
               if(!clk_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,clk_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
            else if(clk_stil_info_tx_pre.time_stamp != clk_stil_info_tx.time_stamp) begin
               //`uvm_info("stil_generator",clk_stil_info_tx_pre.convert2string,UVM_NONE);
               $cast(clk_stil_info_tx_pre, clk_stil_info_tx.clone());
               stil_str = {stil_str,clk_stil_info_tx_pre.stil_info};
               if(!clk_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,clk_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
         end

         if(pad_stil_info_tx != null) begin
            `uvm_info("stil_generator",pad_stil_info_tx.convert2string,UVM_NONE);
            if(pad_stil_info_tx_pre == null) begin
               pad_stil_info_tx_pre = stil_info_transaction::type_id::create("pad_stil_info_tx_pre");
               $cast(pad_stil_info_tx_pre, pad_stil_info_tx.clone());
               stil_str = {stil_str,pad_stil_info_tx_pre.stil_info};
               if(!pad_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,pad_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
            else if(pad_stil_info_tx_pre.time_stamp != pad_stil_info_tx.time_stamp) begin
               //`uvm_info("stil_generator",pad_stil_info_tx_pre.convert2string,UVM_NONE);
               $cast(pad_stil_info_tx_pre, pad_stil_info_tx.clone());
               stil_str = {stil_str,pad_stil_info_tx_pre.stil_info};
               if(!pad_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,pad_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
         end

         if(reset_stil_info_tx != null) begin
            `uvm_info("stil_generator",reset_stil_info_tx.convert2string,UVM_NONE);
            if(reset_stil_info_tx_pre == null) begin
               reset_stil_info_tx_pre = stil_info_transaction::type_id::create("reset_stil_info_tx_pre");
               $cast(reset_stil_info_tx_pre, reset_stil_info_tx.clone());
               stil_str = {stil_str,reset_stil_info_tx_pre.stil_info};
               if(!reset_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,reset_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
            else if(reset_stil_info_tx_pre.time_stamp != reset_stil_info_tx.time_stamp) begin
               //`uvm_info("stil_generator",reset_stil_info_tx_pre.convert2string,UVM_NONE);
               $cast(reset_stil_info_tx_pre, reset_stil_info_tx.clone());
               stil_str = {stil_str,reset_stil_info_tx_pre.stil_info};
               if(!reset_stil_info_tx_pre.comment_info.len() == 0) comment_str = {comment_str,reset_stil_info_tx_pre.comment_info};
               write_to_file = 1;
            end
         end

         if(write_to_file) begin
            `uvm_info("stil_generator",comment_str,UVM_NONE);
            `uvm_info("stil_generator",stil_str,UVM_NONE);
            if(comment_str.len() != 0) $fdisplay(stil_fd,{"#",comment_str});
            $fdisplay(stil_fd,{"V { ",stil_str, " }"});
            write_to_file = 0;
            stil_str = "";
            comment_str= "";
            #1;
         end 
         else #1;
      end
   endtask: run_phase
endclass:stil_generator

   
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

//------------------------------------------------------------------------------
// Class: dft_register_predictor
//------------------------------------------------------------------------------

typedef uvm_reg_predictor#( dft_register_transaction ) dft_register_predictor;

//---------------------------------------------------------------------------
// Class: dft_register_map
//---------------------------------------------------------------------------

class dft_register_map extends uvm_subscriber#( dft_register_transaction );
   `uvm_component_utils( dft_register_map )
   
   dft_register_transaction     dft_reg_tx;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      dft_reg_tx = dft_register_transaction::type_id::create(.name("dft_reg_tx"));
   endfunction: build_phase

   function void write( dft_register_transaction t);
       dft_reg_tx = t;
       //`uvm_info("dft_register_map",{"\n",t.sprint(p)},UVM_LOW);
   endfunction: write

endclass:dft_register_map

//---------------------------------------------------------------------------
// Class: dft_reg_tx_to_jtag_tx_sequence
//---------------------------------------------------------------------------
   
class dft_reg_tx_to_jtag_tx_sequence extends uvm_sequence#( jtag_transaction);
   `uvm_object_utils( dft_reg_tx_to_jtag_tx_sequence )
   const string          report_id;

   function new( string name = "" );
      super.new( name );
      report_id = name;
   endfunction: new

   uvm_sequencer  #(dft_register_transaction)   up_sequencer;
   dft_register_transaction                     dft_reg_tx;
   jtag_transaction                             jtag_tx_q[$];
   
   //Currently does not consider keep sib status after each register r/w. It will be enhanced later to save test times.
   //support check function has not implemented.
   function void dft_reg_tx_to_jtag_tx (dft_register_transaction dft_reg_tx, ref jtag_transaction jtag_tx_q[$]);
       
      bit[`SIB_WIDTH-1:0]                          sib; 
      bit[`LVL1SIB_WIDTH-1:0]                      lvl1_sib; 
      bit[`LVL2SIB_WIDTH-1:0]                      lvl2_sib; 
      bit[`IEEE_1500_IR_WIDTH-1:0]                 wir = `SUB_CLIENT_SIB_OPCODE; 
      bit[`IEEE_1500_IR_WIDTH-1:0]                 sub_client_sib_opcode = `SUB_CLIENT_SIB_OPCODE; 
      bit[`IEEE_1149_IR_WIDTH-1:0]                 ir = `I1687_OPCODE; 
      bit                                          sel_wir,sel_wir_2nd; 
      bit                                          temp_dr_q[$]; 
      jtag_transaction                             jtag_tx;

      jtag_tx = jtag_transaction::type_id::create( .name("jtag_tx") );
      sib = dft_reg_tx.address[`SIB_WIDTH-1:0];
      lvl1_sib = sib[`LVL1SIB_WIDTH-1:0]; 
      lvl2_sib = sib[`LVL2SIB_WIDTH-1+`LVL1SIB_WIDTH:`LVL1SIB_WIDTH]; 
      //-----------------------------------
      //1149 TDR
      //-----------------------------------
      if(sib == `SIB_WIDTH'h0) begin
         jtag_tx_q[0] = jtag_transaction::type_id::create( .name("jtag_tx_q[0]") );
         jtag_tx_q[0].read_not_write = dft_reg_tx.read_not_write;
         jtag_tx_q[0].o_ir_length = `IEEE_1149_IR_WIDTH;
         jtag_tx_q[0].o_ir = new[jtag_tx_q[0].o_ir_length];
         foreach(jtag_tx_q[0].o_ir[i])jtag_tx_q[0].o_ir[i] = dft_reg_tx.address[`SIB_WIDTH+i];

         jtag_tx_q[0].o_dr_length = dft_reg_tx.reg_length;
         jtag_tx_q[0].o_dr = new[jtag_tx_q[0].o_dr_length];
         foreach(jtag_tx_q[0].o_dr[i])jtag_tx_q[0].o_dr[i] = dft_reg_tx.wr_data_q[i];

         jtag_tx_q[0].chk_ir_tdo       = dft_reg_tx.extension.chk_ir_tdo;
         jtag_tx_q[0].chk_dr_tdo       = dft_reg_tx.extension.chk_dr_tdo;
         jtag_tx_q[0].exp_tdo_dr_queue = dft_reg_tx.extension.exp_tdo_dr_q; 
         foreach(jtag_tx_q[0].exp_tdo_dr_queue[i]) jtag_tx_q[0].exp_tdo_dr_mask_queue[i] = 1'b1;
         jtag_tx_q[0].exp_tdo_ir_queue = dft_reg_tx.extension.exp_tdo_ir_q; 
      end//if(sib == `SIB_WIDTH'h0) begin
      //-----------------------------------
      //1500 TDR 
      //-----------------------------------
      else begin
         //step1 open sib
         jtag_tx.o_ir_length = `IEEE_1149_IR_WIDTH;
         jtag_tx.o_ir = new[jtag_tx.o_ir_length];
         foreach(jtag_tx.o_ir[i]) jtag_tx.o_ir[i] = ir[i];

         jtag_tx.o_dr_length = `I1687_LENGTH;
         jtag_tx.o_dr = new[jtag_tx.o_dr_length];
         for(int i=0; i<`LVL1SIB_WIDTH; i++) jtag_tx.o_dr[i] = lvl1_sib[i];
         
         jtag_tx_q[0] = jtag_transaction::type_id::create("jtag_tx_q[0]");
         $cast(jtag_tx_q[0], jtag_tx.clone()); 
         
         jtag_tx.o_dr.delete(); 

         //step2: load user wir or `SUB_CLIENT_SIB_OPCODE
         sel_wir = 1'b0;
         
         jtag_tx.o_dr_length = `I1687_LENGTH + `IEEE_1500_IR_WIDTH + 1;
         jtag_tx.o_dr = new[jtag_tx.o_dr_length];
         case(lvl1_sib)
            `LVL1SIB_WIDTH'b01:begin
               temp_dr_q = {lvl1_sib[0],sel_wir};
               //load SUB_CLIENT_SIB_OPCODE WIR
               if(lvl2_sib!=0) begin
                  for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) temp_dr_q.push_back(sub_client_sib_opcode[i]);
                  temp_dr_q.push_back(lvl1_sib[1]);
                  //foreach(temp_dr_q[i]) $display( "temp_dr_q[%0d] = %0b",i,temp_dr_q[$-i] );
               end
               //load user WIR
               else begin
                  for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) temp_dr_q.push_back(dft_reg_tx.address[`SIB_WIDTH+i]);
                  temp_dr_q.push_back(lvl1_sib[1]);
               end
            end
            `LVL1SIB_WIDTH'b10:begin
               //load user WIR
               temp_dr_q = {lvl1_sib,sel_wir};
               for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) temp_dr_q.push_back(dft_reg_tx.address[`SIB_WIDTH+i]);
            end
         endcase
         foreach(temp_dr_q[i])jtag_tx.o_dr[i] = temp_dr_q[i];
         jtag_tx_q[1] = jtag_transaction::type_id::create("jtag_tx_q[1]");
         $cast(jtag_tx_q[1], jtag_tx.clone()); 
         
         jtag_tx.o_dr.delete(); 
         temp_dr_q.delete(); 
         
         //step3: load wdr or  2nd level sib
         if(lvl2_sib!=0)begin
            jtag_tx.o_dr_length = `I1687_LENGTH + `LVL2SIB_WIDTH + 1;
            jtag_tx.o_dr = new[jtag_tx.o_dr_length];

            sel_wir = 0;
            temp_dr_q = {lvl1_sib[0],sel_wir,lvl2_sib[0],lvl2_sib[1],lvl1_sib[1]};
         end
         else begin
            jtag_tx.o_dr_length = `I1687_LENGTH + dft_reg_tx.reg_length + 1;
            jtag_tx.o_dr = new[jtag_tx.o_dr_length];
            
            sel_wir = 1'b1;
            case(lvl1_sib)
               `LVL1SIB_WIDTH'b01:temp_dr_q = {1'b0,sel_wir,dft_reg_tx.wr_data_q,1'b0};
               `LVL1SIB_WIDTH'b10:temp_dr_q = {2'b0,sel_wir,dft_reg_tx.wr_data_q};
            endcase
         end

         foreach(temp_dr_q[i])jtag_tx.o_dr[i] = temp_dr_q[i];
         jtag_tx_q[2] = jtag_transaction::type_id::create("jtag_tx_q[2]");
         $cast(jtag_tx_q[2], jtag_tx.clone()); 
         
         temp_dr_q.delete(); 
         jtag_tx.o_dr.delete(); 
         
         //step4 write 2nd level user WIR then WDR
         if(lvl2_sib!=0)begin
            //load 2nd levle WIR
            jtag_tx.o_dr_length = `I1687_LENGTH + `IEEE_1500_IR_WIDTH + 1 + 1 +`LVL2SIB_WIDTH;
            jtag_tx.o_dr = new[jtag_tx.o_dr_length];

            sel_wir = 0;
            sel_wir_2nd = 0;
            case(lvl2_sib)
               `LVL2SIB_WIDTH'b01: begin
                  temp_dr_q = {lvl1_sib[0],sel_wir,lvl2_sib[0],sel_wir_2nd};
                  for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) temp_dr_q.push_back(dft_reg_tx.address[`SIB_WIDTH+i]);
                  temp_dr_q = {temp_dr_q,lvl2_sib[1],lvl1_sib[1]};
               end
               `LVL2SIB_WIDTH'b10: begin
                  temp_dr_q = {lvl1_sib[0],sel_wir,lvl2_sib,sel_wir_2nd};
                  for(int i=0; i<`IEEE_1500_IR_WIDTH; i++) temp_dr_q.push_back(dft_reg_tx.address[`SIB_WIDTH+i]);
                  temp_dr_q = {temp_dr_q,lvl1_sib[1]};
               end
            endcase
            foreach(temp_dr_q[i])jtag_tx.o_dr[i] = temp_dr_q[i];
            jtag_tx_q[3] = jtag_transaction::type_id::create("jtag_tx_q[3]");
            $cast(jtag_tx_q[3], jtag_tx.clone()); 
            
            temp_dr_q.delete(); 
            jtag_tx.o_dr.delete(); 
            
            //load 2nd levle WDR
            jtag_tx.o_dr_length = `I1687_LENGTH + dft_reg_tx.reg_length + 1 + 1 +`LVL2SIB_WIDTH;
            jtag_tx.o_dr = new[jtag_tx.o_dr_length];
            
            sel_wir = 1;
            sel_wir_2nd = 1;
            case(lvl2_sib)
               `LVL2SIB_WIDTH'b01: temp_dr_q = {1'b0,sel_wir,1'b0,sel_wir_2nd,dft_reg_tx.wr_data_q,1'b0,1'b0};
               `LVL2SIB_WIDTH'b10: temp_dr_q = {1'b0,sel_wir,1'b0,1'b0,sel_wir_2nd,dft_reg_tx.wr_data_q,1'b0};
            endcase
            foreach(temp_dr_q[i])jtag_tx.o_dr[i] = temp_dr_q[i];
            jtag_tx_q[4] = jtag_transaction::type_id::create("jtag_tx_q[4]");
            $cast(jtag_tx_q[4], jtag_tx.clone()); 
            
            temp_dr_q.delete(); 
            jtag_tx.o_dr.delete(); 
         end//2nd level WIR or WDR write
      end//if!(dft_reg_tx.address[`SIB_WIDTH-1:0] == `SIB_WIDTH'h0) begin
      
      foreach(jtag_tx_q[i]) jtag_tx_q[i].read_not_write = dft_reg_tx.read_not_write;
   endfunction: dft_reg_tx_to_jtag_tx 
  
   task body();
      up_sequencer.get_next_item(dft_reg_tx);
      `uvm_info( report_id,{dft_reg_tx.convert2string}, UVM_MEDIUM);
      
      dft_reg_tx_to_jtag_tx(dft_reg_tx,jtag_tx_q);
      foreach(jtag_tx_q[i]) begin
         start_item( jtag_tx_q[i] );
         finish_item( jtag_tx_q[i]);
         `uvm_info( report_id, { "\n",jtag_tx_q[i].convert2string() }, UVM_LOW );
      end
      up_sequencer.item_done();
      jtag_tx_q.delete();
   endtask: body

endclass: dft_reg_tx_to_jtag_tx_sequence



//---------------------------------------------------------------------------
// Class: dft_register_layering
//---------------------------------------------------------------------------

class dft_register_layering extends uvm_scoreboard;
   `uvm_component_utils( dft_register_layering )
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   uvm_analysis_port #(jtag_transaction) jtag_ap;
   
   dft_register_predictor    dft_reg_prdctr;
   dft_register_map          dft_reg_map;
   dft_register_monitor      dft_reg_mon;
   dft_register_adapter      dft_reg_adptr;
   dft_register_sequencer    dft_reg_sqr;
   jtag_configuration        jtag_cfg;
   jtag_agent                agent;
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jtag_ap = new( .name("jtag_ap"), .parent(this) );
      dft_reg_prdctr = dft_register_predictor::type_id::create(.name( "dft_reg_prdctr" ), .parent(this));
      dft_reg_map = dft_register_map::type_id::create(.name( "dft_reg_map" ), .parent(this));
      dft_reg_mon = dft_register_monitor::type_id::create(.name( "dft_reg_mon" ), .parent(this));
      dft_reg_adptr = dft_register_adapter::type_id::create(.name( "dft_reg_adptr" ), .parent(this));
      dft_reg_sqr = dft_register_sequencer::type_id::create(.name( "dft_reg_sqr" ), .parent(this));
      
      assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( jtag_cfg) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );

      this.jtag_ap.connect(dft_reg_mon.analysis_export);

      dft_reg_mon.dft_reg_ap.connect(dft_reg_map.analysis_export);
      
      //dft_reg_prdctr connection
      dft_reg_mon.dft_reg_ap.connect(dft_reg_prdctr.bus_in);
      dft_reg_prdctr.adapter = dft_reg_adptr;
      dft_reg_prdctr.map = jtag_cfg.reg_block.reg_map;
      jtag_cfg.reg_block.reg_map.set_sequencer( .sequencer( dft_reg_sqr ), .adapter( dft_reg_adptr) );
   endfunction: connect_phase
   
   virtual task run_phase(uvm_phase phase);
      dft_reg_tx_to_jtag_tx_sequence         dft_reg_tx_to_jtag_tx_seq;

      dft_reg_tx_to_jtag_tx_seq = dft_reg_tx_to_jtag_tx_sequence::type_id::create("dft_reg_tx_to_jtag_tx_seq");

      // connect translation sequences to their respective upstream sequencers
      dft_reg_tx_to_jtag_tx_seq.up_sequencer = dft_reg_sqr;
      
      // start the translation sequences
      fork
        dft_reg_tx_to_jtag_tx_seq.start(agent.sqr);
      join_none
   endtask

endclass:dft_register_layering

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
   //jtag_reg_predictor   reg_predictor;
   clk_driver           clk_drv;
   reset_driver         reset_drv;
   pad_driver           pad_drv;

   stil_generator       stil_gen;
   dft_register_layering     reg_layering;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      agent = jtag_agent::type_id::create           (.name( "agent"      ), .parent(this));
      scoreboard = jtag_scoreboard::type_id::create (.name( "scoreboard" ), .parent(this));
      //reg_predictor = jtag_reg_predictor::type_id::create(.name( "reg_predictor" ), .parent(this));
      
      clk_drv = clk_driver::type_id::create(.name( "clk_drv" ), .parent(this));
      reset_drv = reset_driver::type_id::create(.name( "reset_drv" ), .parent(this));
      pad_drv = pad_driver::type_id::create(.name( "pad_drv" ), .parent(this));
      stil_gen = stil_generator::type_id::create(.name( "stil_gen" ), .parent(this));
      reg_layering = dft_register_layering::type_id::create(.name( "reg_layering" ), .parent(this));
      
      assert(uvm_config_db#( jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( cfg) ))
      else `uvm_fatal("NOVIF", "Failed to get virtual interfaces form uvm_config_db.\n");
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      agent.jtag_ap.connect(scoreboard.analysis_export);
      agent.drv.jtag_drv_ap.connect(stil_gen.jtag_drv_imp_export); 
      clk_drv.clk_drv_ap.connect(stil_gen.clk_drv_imp_export); 
      pad_drv.pad_drv_ap.connect(stil_gen.pad_drv_imp_export); 
      reset_drv.reset_drv_ap.connect(stil_gen.analysis_export); 

      agent.mon.jtag_vi = cfg.jtag_vi;
      //agent.drv.jtag_vi = cfg.jtag_vi;
      //cfg.reg_block.reg_map.set_sequencer( .sequencer( agent.sqr ), .adapter( agent.jtag_reg_adapter ) );
      //reg_predictor.map     = cfg.reg_block.reg_map;
      //reg_predictor.adapter = agent.jtag_reg_adapter;
      //agent.jtag_ap.connect( reg_predictor.bus_in );
      
      reg_layering.agent = agent;
      agent.jtag_ap.connect(reg_layering.jtag_ap);

   endfunction: connect_phase

endclass:jtag_env

