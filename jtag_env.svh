
`uvm_analysis_imp_decl(_jtag_drv)
`uvm_analysis_imp_decl(_TCK_clk_drv)
`uvm_analysis_imp_decl(_SYSCLK_clk_drv)
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

//---------------------------------------------------------------------------
// Class: clk_wave_description 
//---------------------------------------------------------------------------
class clk_wave_description extends uvm_object;
   `uvm_object_utils(clk_wave_description)
   string         wave_desc[]; 
   int unsigned   array_size;

   function new(string name = "clk_wave_description");
     super.new(name);
   endfunction : new
   
   virtual function void do_copy( uvm_object rhs );
      clk_wave_description    that;

      if ( ! $cast( that, rhs ) ) begin
         `uvm_error( get_name(), "rhs is not a clk_wave_description" )
         return;
      end

      super.do_copy( rhs );
      this.array_size = that.array_size;
      this.wave_desc = new[this.array_size];
      foreach(that.wave_desc[i]) this.wave_desc[i] = that.wave_desc[i];
   endfunction: do_copy

   function string convert2string();
      string s;
      $sformat(s,"%s\n array_size = %0d",s, array_size);
      foreach(wave_desc[i]) $sformat(s,"%s\n wave_desc[%0d] = %s",s, i, wave_desc[i]);

      return s;
   endfunction: convert2string
endclass : clk_wave_description


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
        s = {s, print_queue()};
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
    string     report_id;

    function new(string name = "stil_info_transaction");
        super.new(name);
        report_id = name;
    endfunction

    function string convert2string();
        string       s;
        $sformat(s, "%s*********%s*********\n",s,report_id);
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
         //`uvm_info("reset_drv",stil_info_tx.convert2string,UVM_NONE);
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
// Class: clk_driver_base
//---------------------------------------------------------------------------
//class clk_driver_base #(type configuration = clk_configuration_base, string clk_name) extends uvm_driver#( jtag_transaction );
class clk_driver_base #(type configuration = clk_configuration_base) extends uvm_driver;
    
   typedef clk_driver_base #(configuration) this_type;

   typedef configuration     cfg_type;

   virtual clk_if            clk_vi;

   bit                       gen_stil_file;
   bit                       free_running;
   bit                       stop_clk;
   bit                       clk_is_high;
   int                       half_period;
   cfg_type                  clk_cfg; 
  
   int unsigned              total_time,lcm,tck_cycle_cnt,delta;
   clk_wave_description      clk_wave_desc;

   `uvm_component_utils( this_type )
   
   uvm_analysis_port #(stil_info_transaction) clk_drv_ap;
   stil_info_transaction     stil_info_tx;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      
      clk_drv_ap = new({"clk_drv_ap"}, this);
      clk_wave_desc = new("clk_wave_desc");
      clk_cfg = cfg_type::type_id::create(.name("clk_cfg"));
      assert(uvm_config_db#(cfg_type)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg"), .value( this.clk_cfg) ));
      
      gen_stil_file = clk_cfg.gen_stil_file;
      half_period = clk_cfg.half_period;
      free_running = clk_cfg.free_running;
      clk_vi = clk_cfg.clk_vi;
   endfunction: build_phase
   
   virtual function void call_stil_gen (bit gen_stil_file, int wave_char, string comment_str = {""});
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"%s = %0d;"},clk_cfg.pad_name, wave_char);
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         //`uvm_info("clk_drv",stil_info_tx.convert2string,UVM_NONE);
         clk_drv_ap.write(stil_info_tx);
      end

   endfunction :call_stil_gen

   function int unsigned lcm_cal(int unsigned a, int unsigned b);
      int unsigned c,temp;
      temp = a*b;
      while(a!=0) begin
         c = a;
         a = b%a;
         b = c;
      end
      return temp/b;
   endfunction: lcm_cal
   
   task run_phase( uvm_phase phase );
      assert(uvm_config_db#(cfg_type)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg"), .value( this.clk_cfg) ));
      clk_vi = clk_cfg.clk_vi;

      lcm = lcm_cal(half_period,`TCK_HALF_PERIOD);
      
      //`uvm_info("clk_driver_base",$sformatf("lcm = %0d",lcm),UVM_NONE);
      
      clk_wave_desc.array_size = (lcm / `TCK_HALF_PERIOD)+1;
      clk_wave_desc.wave_desc = new[clk_wave_desc.array_size];
      clk_wave_desc.wave_desc[0] = "'0ns' D;";
      
      //`uvm_info("clk_driver_base",clk_wave_desc.convert2string,UVM_NONE);
      //generate clk wave description
      clk_wave_desc_init();

      //store clk_wave_desc 
      clk_cfg.clk_wave_desc = clk_wave_desc;
      //$cast(clk_cfg.clk_wave_desc, clk_wave_desc.clone());
      
      uvm_config_db#(cfg_type)::set ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg"), .value( this.clk_cfg) );
      clk_vi.clk = 0;
      
      forever begin
         if(free_running) begin
            generate_clk;
         end
         else begin
            assert(uvm_config_db#(cfg_type)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg"), .value( this.clk_cfg) ));
            stop_clk = clk_cfg.stop_clk;
            if(stop_clk) begin
               #half_period; 
               #half_period; 
            end
            else begin
               generate_clk;
            end
         end
      end
   endtask: run_phase 
   
   function void clk_wave_desc_init();
      total_time = 0;
      tck_cycle_cnt = 0;
      clk_is_high = 0;

      $sformat(clk_wave_desc.wave_desc[tck_cycle_cnt+1],"%s '%0dns' %s;", clk_wave_desc.wave_desc[tck_cycle_cnt+1], (total_time % (`TCK_HALF_PERIOD * 2)), (clk_is_high == 0) ? "D" : "U");
      while(total_time < lcm*2) begin
         

         if(total_time + half_period >= (`TCK_HALF_PERIOD * 2 * (tck_cycle_cnt + 1))) begin
            delta = `TCK_HALF_PERIOD*2*(tck_cycle_cnt+1) - total_time;
            
            tck_cycle_cnt = tck_cycle_cnt + 1;
            total_time = total_time + delta;
            
            //`uvm_info("clk_driver_base",$sformatf("total_time = %0d, tck_cycle_cnt = %0d", total_time, tck_cycle_cnt),UVM_NONE);
            
            $sformat(clk_wave_desc.wave_desc[tck_cycle_cnt+1],"%s '%0dns' %s;", clk_wave_desc.wave_desc[tck_cycle_cnt+1], (total_time % (`TCK_HALF_PERIOD * 2)), (clk_is_high == 0) ? "D" : "U");
            if(delta != 0) begin
               clk_is_high = ~clk_is_high;
               total_time = total_time + half_period - delta;
            
               //`uvm_info("clk_driver_base",$sformatf("total_time = %0d, tck_cycle_cnt = %0d", total_time, tck_cycle_cnt),UVM_NONE);
               $sformat(clk_wave_desc.wave_desc[tck_cycle_cnt+1],"%s '%0dns' %s;", clk_wave_desc.wave_desc[tck_cycle_cnt+1], (total_time % (`TCK_HALF_PERIOD * 2)), (clk_is_high == 0) ? "D" : "U");
            end
            //`uvm_info("clk_driver_base",clk_wave_desc.convert2string,UVM_NONE);
         end// if(total_time + half_period <= (`TCK_HALF_PERIOD * 2 * tck_cycle_cnt)) begin
         else begin
            clk_is_high = ~clk_is_high;
            total_time = total_time + half_period;
            
            //`uvm_info("clk_driver_base",$sformatf("total_time = %0d, tck_cycle_cnt = %0d", total_time, tck_cycle_cnt),UVM_NONE);
            $sformat(clk_wave_desc.wave_desc[tck_cycle_cnt+1],"%s '%0dns' %s;", clk_wave_desc.wave_desc[tck_cycle_cnt+1], (total_time % (`TCK_HALF_PERIOD * 2)), (clk_is_high == 0) ? "D" : "U");

            //`uvm_info("clk_driver_base",clk_wave_desc.convert2string,UVM_NONE);
         end// !if(total_time + half_period <= (`TCK_HALF_PERIOD * 2 * tck_cycle_cnt)) begin
      end// while(total_time < lcm*2) begin

   endfunction: clk_wave_desc_init

   task generate_clk;
      total_time = 0;
      tck_cycle_cnt = 0;

      //call_stil_gen(gen_stil_file,tck_cycle_cnt);

      while(total_time < lcm*2) begin
         
         if(total_time + half_period >= (`TCK_HALF_PERIOD * 2 * (tck_cycle_cnt + 1))) begin
            delta = `TCK_HALF_PERIOD*2*(tck_cycle_cnt + 1) - total_time;
            
            tck_cycle_cnt = tck_cycle_cnt + 1;
            call_stil_gen(gen_stil_file,tck_cycle_cnt);

            if(delta != 0) begin
               #half_period;
               clk_vi.clk = ~clk_vi.clk;
               total_time = total_time + half_period;
            end
         end// if(total_time + half_period <= (`TCK_HALF_PERIOD * 2 * tck_cycle_cnt)) begin
         else begin
            #half_period clk_vi.clk = ~clk_vi.clk;
            total_time = total_time + half_period;
         end// !if(total_time + half_period <= (`TCK_HALF_PERIOD * 2 * tck_cycle_cnt)) begin
      end// while(total_time < lcm*2) begin
   endtask: generate_clk
endclass: clk_driver_base

//---------------------------------------------------------------------------
// Class: TCK_clk_driver
//---------------------------------------------------------------------------
class TCK_clk_driver extends uvm_driver;
   `uvm_component_utils( TCK_clk_driver )
   
   virtual clk_if          clk_vi;

   bit                       gen_stil_file;
   bit                       stop_tck;
   int                       tck_half_period;
   TCK_clk_configuration     clk_cfg; 

   clk_wave_description      clk_wave_desc;
   uvm_analysis_port #(stil_info_transaction) clk_drv_ap;
   stil_info_transaction     stil_info_tx;
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      
      clk_drv_ap = new("clk_drv_ap ", this);
      clk_cfg = TCK_clk_configuration::type_id::create(.name("clk_cfg"));
      clk_wave_desc = new("clk_wave_desc");
      assert(uvm_config_db#(TCK_clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.clk_cfg) ));
      
      gen_stil_file = clk_cfg.gen_stil_file;
      tck_half_period = clk_cfg.half_period;
      clk_vi = clk_cfg.clk_vi;
   endfunction: build_phase
   
   function void call_stil_gen (bit gen_stil_file, string comment_str = {""});
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"TCK = %0b; "},clk_vi.clk);
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         //`uvm_info("clk_drv",stil_info_tx.convert2string,UVM_NONE);
         clk_drv_ap.write(stil_info_tx);
      end
   endfunction :call_stil_gen


   task run_phase( uvm_phase phase );
      clk_wave_desc.wave_desc = new[2];
      clk_wave_desc.wave_desc[0] = "{'0ns' D;}"; 
      clk_wave_desc.wave_desc[1] = "{'0ns' U;}"; 
      clk_cfg.clk_wave_desc = clk_wave_desc;
      uvm_config_db#(TCK_clk_configuration)::set ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg"), .value( this.clk_cfg) );
      
      clk_vi.clk = 0;
      call_stil_gen(gen_stil_file);
      //#tck_half_period;
      forever begin
        #tck_half_period;
        clk_vi.clk = ~clk_vi.clk; 
        call_stil_gen(gen_stil_file);
      end
   endtask: run_phase
endclass: TCK_clk_driver

//---------------------------------------------------------------------------
// Class: SYSCLK_clk_driver
//---------------------------------------------------------------------------

//typedef clk_driver_base#(SYSCLK_clk_configuration) SYSCLK_clk_driver; 
class SYSCLK_clk_driver extends clk_driver_base #(SYSCLK_clk_configuration);
   `uvm_component_utils( SYSCLK_clk_driver)
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
  
   virtual function void call_stil_gen (bit gen_stil_file, int wave_char, string comment_str = {""});
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         if(wave_char == `CLK_STOP_LOW)
            stil_info_tx.stil_info = $sformatf({"%s = 0;"},clk_cfg.pad_name);
         else
            stil_info_tx.stil_info = $sformatf({"%s = %0d;"},clk_cfg.pad_name,wave_char);
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         //`uvm_info("clk_drv",stil_info_tx.convert2string,UVM_NONE);
         clk_drv_ap.write(stil_info_tx);
      end

   endfunction :call_stil_gen


endclass: SYSCLK_clk_driver 

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
  
   function void call_stil_gen (bit gen_stil_file, bit tms = 1'bx, bit tdi = 1'bx, bit tdo = "X",string comment_str = {""});
      if(gen_stil_file == `ON) begin
         stil_info_tx = stil_info_transaction::type_id::create("stil_info_tx");
         stil_info_tx.stil_info = $sformatf({"TMS = %0b; TDI = %0b; TDO = %b;"},tms,tdi,tdo);;
         stil_info_tx.comment_info = comment_str;
         stil_info_tx.time_stamp = $time;
         //`uvm_info("jtag_drv",stil_info_tx.convert2string,UVM_NONE);
         
         jtag_drv_ap.write(stil_info_tx);
      end
   endfunction :call_stil_gen

   task run_phase( uvm_phase phase );
      jtag_transaction  jtag_tx;

      string            fsm_nstate;
      string            stil_str;
      string            comment_str;
      //int               stil_fd;
      logic             stil_tms = 1'b1, stil_tdi = 1'bz, stil_tdo = 1'bx;
      jtag_vi.master_mp.negedge_cb.tms <= 1;
      
      stil_tms = 1'b1;
      call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo);
     
      @(negedge jtag_vi.master_mp.trst);
      forever begin
         seq_item_port.get_next_item( jtag_tx );
         `uvm_info( "jtag_tx", { "\n",jtag_tx.convert2string() }, UVM_LOW );
         ////take jtag fsm into test_logic_reset state
         //for(int i = 0; i < 5; i ++) begin
         //   @jtag_vi.master_mp.posedge_cb;
         //   jtag_vi.master_mp.negedge_cb.tms <= 1;
         //end
     
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 0;

         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );

         stil_tms = 0;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         //read_not_write is used for monitor only
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.read_not_write <= jtag_tx.read_not_write;


         //take jtag fsm into select_dr_scan state
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         //take jtag fsm into select_ir_scan state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         
         fsm_nstate = "take jtag fsm into select_ir_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
                  
         //take jtag fsm into capture_ir state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 0;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);

         //take jtag fsm into shift_ir state
         @jtag_vi.master_mp.negedge_cb;
         fsm_nstate = $sformatf("take jtag fsm into shift_ir state");
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         jtag_vi.master_mp.negedge_cb.tms <= 0; 

         stil_tms = 0;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
 
         for(int i = 0; i < jtag_tx.o_ir_length-1; i ++) begin
            @jtag_vi.master_mp.negedge_cb;
            
            fsm_nstate = $sformatf("shift_count = %0d", i);
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
            
            //stimulus part
            jtag_vi.master_mp.negedge_cb.tms <= 0;
            jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[i];
           

            //STIL part
            stil_tms = 0;
            stil_tdi = jtag_tx.o_ir[i];
            call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
            
            @jtag_vi.master_mp.posedge_cb;
            if(jtag_tx.chk_ir_tdo)begin
               if(jtag_tx.exp_tdo_ir_queue[i] != jtag_vi.master_mp.posedge_cb.tdo) 
                  `uvm_error("jtag_driver",$sformatf("jtag_tx.exp_tdo_ir_queue[%0d] = %0b differs with current tdo[%b]",i,jtag_tx.exp_tdo_ir_queue[i],jtag_vi.master_mp.posedge_cb.tdo))
               if(jtag_tx.exp_tdo_ir_queue[i])  stil_tdo = 1;
               else stil_tdo = 0;
            end
            else stil_tdo = 1'bx;
           
            call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo);

         end //for(int i = 0; i < jtag_tx.o_ir_length-1; i ++) begin

         //take jtag fsm into exit1_ir state
         @jtag_vi.master_mp.negedge_cb;
         
         fsm_nstate = "take jtag fsm into exit1_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         //stimulus part
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_ir[jtag_tx.o_ir_length-1];
         
         //STIL part
         stil_tms = 1;
         stil_tdi = jtag_tx.o_ir[jtag_tx.o_ir_length-1];
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         @jtag_vi.master_mp.posedge_cb;
         if(jtag_tx.chk_ir_tdo)begin
            if(jtag_tx.exp_tdo_ir_queue[jtag_tx.o_ir_length-1] != jtag_vi.master_mp.posedge_cb.tdo) 
               `uvm_error("jtag_driver",$sformatf("jtag_tx.exp_tdo_ir_queue[%0d] = %0b differs with current tdo[%b]",jtag_tx.o_ir_length-1,jtag_tx.exp_tdo_ir_queue[jtag_tx.o_ir_length-1],jtag_vi.master_mp.posedge_cb.tdo))
            if(jtag_tx.exp_tdo_ir_queue[jtag_tx.o_ir_length-1])  stil_tdo = 1;
            else stil_tdo = 0;
         end
         else stil_tdo = 1'bx;
         
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo);

         //take jtag fsm into update_ir state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_ir state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);

         //take jtag fsm into select_dr_scan state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into select_dr_scan state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         //take jtag fsm into capture_dr state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into capture_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 0;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);

          //take jtag fsm into shift_dr state
         @jtag_vi.master_mp.negedge_cb;
         fsm_nstate = $sformatf("take jtag fsm into shift_dr state");
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         jtag_vi.master_mp.negedge_cb.tms <= 0; 

         stil_tms = 0;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
 
         for(int i = 0; i < jtag_tx.o_dr_length-1; i ++) begin
            @jtag_vi.master_mp.negedge_cb;
            
            fsm_nstate = $sformatf("shift_count = %0d", i);
            `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
            
            //stimulus part
            jtag_vi.master_mp.negedge_cb.tms <= 0;
            jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[i];
           

            //STIL part
            stil_tms = 0;
            stil_tdi = jtag_tx.o_dr[i];
            call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
            
            @jtag_vi.master_mp.posedge_cb;
            if(jtag_tx.chk_dr_tdo)begin
               if(jtag_tx.exp_tdo_dr_queue[i] != jtag_vi.master_mp.posedge_cb.tdo) 
                  `uvm_error("jtag_driver",$sformatf("jtag_tx.exp_tdo_dr_queue[%0d] = %0b differs with current tdo[%b]",i,jtag_tx.exp_tdo_dr_queue[i],jtag_vi.master_mp.posedge_cb.tdo))
               if(jtag_tx.exp_tdo_dr_queue[i])  stil_tdo = 1;
               else stil_tdo = 0;
            end
            else stil_tdo = 1'bx;
           
            call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo);

         end //for(int i = 0; i < jtag_tx.o_dr_length-1; i ++) begin

         //take jtag fsm into exit1_dr state
         @jtag_vi.master_mp.negedge_cb;
         
         fsm_nstate = "take jtag fsm into exit1_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         //stimulus part
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         jtag_vi.master_mp.negedge_cb.tdi <= jtag_tx.o_dr[jtag_tx.o_dr_length-1];
         
         //STIL part
         stil_tms = 1;
         stil_tdi = jtag_tx.o_dr[jtag_tx.o_dr_length-1];
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         @jtag_vi.master_mp.posedge_cb;
         if(jtag_tx.chk_dr_tdo)begin
            if(jtag_tx.exp_tdo_dr_queue[jtag_tx.o_dr_length-1] != jtag_vi.master_mp.posedge_cb.tdo) 
               `uvm_error("jtag_driver",$sformatf("jtag_tx.exp_tdo_dr_queue[%0d] = %0b differs with current tdo[%b]",jtag_tx.o_dr_length-1,jtag_tx.exp_tdo_dr_queue[jtag_tx.o_dr_length-1],jtag_vi.master_mp.posedge_cb.tdo))
            if(jtag_tx.exp_tdo_dr_queue[jtag_tx.o_dr_length-1])  stil_tdo = 1;
            else stil_tdo = 0;
         end
         else stil_tdo = 1'bx;
         
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo);

     
         //take jtag fsm into update_dr state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 1;
         fsm_nstate = "take jtag fsm into update_dr state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
          
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
 
         //take jtag fsm into run_test_idle state
         @jtag_vi.master_mp.negedge_cb;
         jtag_vi.master_mp.negedge_cb.tms <= 0;
         fsm_nstate = "take jtag fsm into run_test_idle state ";
         `uvm_info( "jtag_driver", { fsm_nstate }, UVM_DEBUG );
         
         stil_tms = 1;
         call_stil_gen(gen_stil_file,stil_tms,stil_tdi,stil_tdo,fsm_nstate);
         
         repeat (2) @jtag_vi.master_mp.posedge_cb;
	      seq_item_port.item_done();

      end
   endtask: run_phase
endclass: jtag_driver


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
         `uvm_error("reg2bus", "Extension casting failed.")

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
         `uvm_error("reg2bus", "Extension casting failed.")

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

   uvm_analysis_imp_jtag_drv        #(stil_info_transaction, stil_generator) jtag_drv_imp_export;
   uvm_analysis_imp_TCK_clk_drv     #(stil_info_transaction, stil_generator) TCK_clk_drv_imp_export;
   uvm_analysis_imp_SYSCLK_clk_drv  #(stil_info_transaction, stil_generator) SYSCLK_clk_drv_imp_export;
   uvm_analysis_imp_pad_drv         #(stil_info_transaction, stil_generator) pad_drv_imp_export;
   
   bit                        write_to_file; 
   string                     jtag_drv_info;
   string                     clk_drv_info;
   string                     reset_drv_info;
   string                     pad_drv_info;
   
   jtag_configuration         jtag_cfg;
   TCK_clk_configuration      TCK_clk_cfg;
   SYSCLK_clk_configuration   SYSCLK_clk_cfg;
   reset_configuration        reset_cfg;
   
   string                     stil_file_name;
   int                        stil_fd;
   bit                        gen_stil_file; 
   int                        timing_window;
   clk_wave_description       TCK_clk_wave_des;
   clk_wave_description       SYSCLK_clk_wave_des;
   
   stil_info_transaction      pad_stil_info_tx_ping,pad_stil_info_tx_pong;
   stil_info_transaction      reset_stil_info_tx_ping,reset_stil_info_tx_pong;
   stil_info_transaction      TCK_stil_info_tx_ping,TCK_stil_info_tx_pong;
   stil_info_transaction      SYSCLK_stil_info_tx_ping,SYSCLK_stil_info_tx_pong;
   stil_info_transaction      jtag_stil_info_tx_ping,jtag_stil_info_tx_pong;
  
   bit                        pad_ping_data_rdy, pad_pong_data_rdy;
   bit                        jtag_ping_data_rdy, jtag_pong_data_rdy;
   bit                        SYSCLK_ping_data_rdy, SYSCLK_pong_data_rdy;
   bit                        TCK_ping_data_rdy, TCK_pong_data_rdy;
   bit                        reset_ping_data_rdy, reset_pong_data_rdy;
  
   string                     stil_str;
   string                     comment_str;
   semaphore                  pad_sem, jtag_sem, SYSCLK_sem, TCK_sem, reset_sem;
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
   
   function void build_phase(uvm_phase phase);
      super.build_phase( phase );
      
      jtag_drv_imp_export = new("jtag_drv_imp_export", this);
      TCK_clk_drv_imp_export = new("TCK_clk_drv_imp_export", this);
      SYSCLK_clk_drv_imp_export = new("SYSCLK_clk_drv_imp_export", this);
      pad_drv_imp_export = new("pad_drv_imp_export", this);
     
      TCK_clk_wave_des = clk_wave_description::type_id::create( .name("TCK_clk_wave_des"));
      SYSCLK_clk_wave_des = clk_wave_description::type_id::create( .name("SYSCLK_clk_wave_des"));
      
      jtag_cfg = jtag_configuration::type_id::create( .name( "jtag_cfg" ) );
      assert(uvm_config_db#(jtag_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "jtag_cfg" ), .value( this.jtag_cfg) ));

      TCK_clk_cfg = TCK_clk_configuration::type_id::create( .name( "TCK_clk_cfg" ) );
      assert(uvm_config_db#(TCK_clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.TCK_clk_cfg) ));

      SYSCLK_clk_cfg = SYSCLK_clk_configuration::type_id::create( .name( "SYSCLK_clk_cfg" ) );
      assert(uvm_config_db#(SYSCLK_clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.SYSCLK_clk_cfg) ));
      
      reset_cfg = reset_configuration::type_id::create( .name( "reset_cfg" ) );
      assert(uvm_config_db#(reset_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "reset_cfg" ), .value( this.reset_cfg) ));

      gen_stil_file = jtag_cfg.gen_stil_file;
      stil_file_name = jtag_cfg.stil_file_name;
      timing_window = TCK_clk_cfg.half_period * 2;
      
      pad_sem = new(1);
      jtag_sem = new(1);
      SYSCLK_sem = new(1);
      TCK_sem = new(1);
      reset_sem = new(1);
   endfunction: build_phase
   
   function void write( stil_info_transaction t);
      while(!reset_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);
      case({reset_ping_data_rdy, reset_pong_data_rdy})
         2'b00: begin
            reset_stil_info_tx_ping = t; 
            reset_ping_data_rdy = 1;
         end
         2'b10: begin
            reset_stil_info_tx_pong = t; 
            reset_pong_data_rdy = 1;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
         2'b11: `uvm_error("stil_generator","Reset ping-pong buffer is full.")
      endcase
      reset_sem.put(1);
   endfunction: write
 
   function void write_jtag_drv( stil_info_transaction t);
      while(!jtag_sem.try_get(1))`uvm_info("stil_generator","try get semafore",UVM_DEBUG);
      case({jtag_ping_data_rdy, jtag_pong_data_rdy})
         2'b00: begin
            jtag_stil_info_tx_ping = t; 
            jtag_ping_data_rdy = 1;
         end
         2'b10: begin
            jtag_stil_info_tx_pong = t; 
            jtag_pong_data_rdy = 1;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
         2'b11: `uvm_error("stil_generator","jtag ping-pong buffer is full.")
      endcase
      jtag_sem.put(1);
   endfunction: write_jtag_drv
   
   function void write_TCK_clk_drv( stil_info_transaction t);
      while(!TCK_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);
      case({TCK_ping_data_rdy, TCK_pong_data_rdy})
         2'b00: begin
            TCK_stil_info_tx_ping = t; 
            TCK_ping_data_rdy = 1;
         end
         2'b10: begin
            TCK_stil_info_tx_pong = t; 
            TCK_pong_data_rdy = 1;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
         2'b11: `uvm_error("stil_generator","TCK ping-pong buffer is full.")
      endcase
      TCK_sem.put(1);
   endfunction: write_TCK_clk_drv
   
   function void write_SYSCLK_clk_drv( stil_info_transaction t);
      while(!SYSCLK_sem.try_get(1))`uvm_info("stil_generator","try get semafore",UVM_DEBUG);
      case({SYSCLK_ping_data_rdy, SYSCLK_pong_data_rdy})
         2'b00: begin
            SYSCLK_stil_info_tx_ping = t; 
            SYSCLK_ping_data_rdy = 1;
         end
         2'b10: begin
            SYSCLK_stil_info_tx_pong = t; 
            SYSCLK_pong_data_rdy = 1;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
         2'b11: `uvm_error("stil_generator","SYSCLK ping-pong buffer is full.")
      endcase
      SYSCLK_sem.put(1);
   endfunction: write_SYSCLK_clk_drv
   
   function void write_pad_drv( stil_info_transaction t);
      while(!pad_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);
      case({pad_ping_data_rdy, pad_pong_data_rdy})
         2'b00: begin
            pad_stil_info_tx_ping = t; 
            pad_ping_data_rdy = 1;
         end
         2'b10: begin
            pad_stil_info_tx_pong = t; 
            pad_pong_data_rdy = 1;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
         2'b11: `uvm_error("stil_generator","pad ping-pong buffer is full.")
      endcase
      pad_sem.put(1);
   endfunction: write_pad_drv
  
   function void print_stil_header(int stil_fd);
      string            s;
      
      assert(uvm_config_db#(TCK_clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.TCK_clk_cfg) ));
      assert(uvm_config_db#(SYSCLK_clk_configuration)::get ( .cntxt( this ), .inst_name( "*" ), .field_name( "clk_cfg" ), .value( this.SYSCLK_clk_cfg) ));
 
      //`uvm_info("stil_generator",TCK_clk_cfg.convert2string,UVM_NONE);
      $cast(TCK_clk_wave_des, TCK_clk_cfg.clk_wave_desc.clone());
      SYSCLK_clk_wave_des = SYSCLK_clk_cfg.clk_wave_desc;
      
      $sformat(s,"%s STIL 1.0;\n",s);

      //Print Signals block
      $sformat(s,"%s Signals {\n",s);

      foreach(jtag_cfg.pad_name[i]) $sformat(s,"%s \t%s\t%s;\n",s,jtag_cfg.pad_name[i],(jtag_cfg.pad_dir[i] ? (jtag_cfg.pad_dir[i] == 1 ? "Out" : "InOut") : "In"));
      
      foreach(reset_cfg.pad_name[i]) $sformat(s,"%s \t%s\t%s;\n",s,reset_cfg.pad_name[i],(reset_cfg.pad_dir[i] ? (reset_cfg.pad_dir[i] == 1 ? "Out" : "InOut") : "In"));
      
      foreach(TCK_clk_cfg.pad_name[i]) $sformat(s,"%s \t%s\t%s;\n",s,TCK_clk_cfg.pad_name[i],(TCK_clk_cfg.pad_dir[i] ? (TCK_clk_cfg.pad_dir[i] == 1 ? "Out" : "InOut") : "In"));
      foreach(SYSCLK_clk_cfg.pad_name[i]) $sformat(s,"%s \t%s\t%s;\n",s,SYSCLK_clk_cfg.pad_name[i],(SYSCLK_clk_cfg.pad_dir[i] ? (SYSCLK_clk_cfg.pad_dir[i] == 1 ? "Out" : "InOut") : "In"));
      $sformat(s,"%s}\n",s);
      
      //Print WaveformTable block
      $sformat(s,"%s Timing basic {\n",s);
      $sformat(s,"%s \t WaveformTable wave_form_table{\n",s);
      $sformat(s,"%s \t\t Period '%dns';\n",s,timing_window);
      $sformat(s,"%s \t\t Waveforms {\n",s);
      
      //Print TCK description
      $sformat(s,"%s \t\t %s {\n",s, TCK_clk_cfg.pad_name[0]);
      foreach(TCK_clk_wave_des.wave_desc[i]) 
         $sformat(s,"%s \t\t\t %0d {%s}\n",s,i,TCK_clk_wave_des.wave_desc[i]);
      $sformat(s,"%s \t\t }\n",s);

     // //Print SYSCLK description
     // $sformat(s,"%s \t\t %s {\n",s, SYSCLK_clk_cfg.pad_name[0]);
     // foreach(SYSCLK_clk_wave_des.wave_desc[i]) 
     //    $sformat(s,"%s \t\t\t %0d {%s}\n",s,i,SYSCLK_clk_wave_des.wave_desc[i]);
     // $sformat(s,"%s \t\t }\n",s);

      foreach(jtag_cfg.pad_name[i]) begin
         if(jtag_cfg.pad_dir[i] == 0)
            $sformat(s,"%s \t\t %s {01x {'0ns' D/U/Z;}}\n",s, jtag_cfg.pad_name[i]);
         else if(jtag_cfg.pad_dir[i] == 1)
            $sformat(s,"%s \t\t %s {LHx {'0ns' L/H/X;}}\n",s, jtag_cfg.pad_name[i]);
         else begin 
            $sformat(s,"%s \t\t %s {01x {'0ns' D/U/Z;}}\n",s, jtag_cfg.pad_name[i]);
            $sformat(s,"%s \t\t {LHX {'0ns'Z; '1ns' L/H/X;}}\n",s);
         end
      end

      foreach(reset_cfg.pad_name[i]) begin
         if(reset_cfg.pad_dir[i] == 0)
            $sformat(s,"%s \t\t %s {01x {'0ns' D/U/Z;}}\n",s, reset_cfg.pad_name[i]);
         else if(reset_cfg.pad_dir[i] == 1)
            $sformat(s,"%s \t\t %s {LHx {'0ns' L/H/X;}}\n",s, reset_cfg.pad_name[i]);
         else begin 
            $sformat(s,"%s \t\t %s {01x {'0ns' D/U/Z;}\n",s, reset_cfg.pad_name[i]);
            $sformat(s,"%s \t\t LHX {'0ns'Z; '1ns' L/H/X;}}\n",s);
         end
      end
      $sformat(s,"%s \t\t}\n",s);
      $sformat(s,"%s \t}\n",s);
      $sformat(s,"%s }\n",s);

      //Print PatternBurst block
      $sformat(s,"%s PatternBurst basic_burst {\n",s);
      $sformat(s,"%s \t PatList { basic; }\n",s);
      $sformat(s,"%s }\n",s);
      
      //Print PatternExec block
      $sformat(s,"%s PatternExec {\n",s);
      $sformat(s,"%s \t Timing  basic;\n",s);
      $sformat(s,"%s \t PatternBurst basic_burst;\n",s);
      $sformat(s,"%s }\n",s);

      //Print Patternblock
      $sformat(s,"%s Pattern basic{\n",s);
      $sformat(s,"%s \t W wave_form_table;\n",s);
      $fdisplay(stil_fd,s);
   endfunction: print_stil_header

   function void update_ping_pong_buffer(ref bit ping_data_rdy, pong_data_rdy, ref stil_info_transaction ping_stil_info_tx, pong_stil_info_tx);
      //`uvm_info("stil_generator","before proces... ",UVM_NONE);
      //`uvm_info("stil_generator",$sformatf("ping_data_rdy = %0b, pong_data_rdy = %0b",ping_data_rdy, pong_data_rdy),UVM_NONE);
      
      case({ping_data_rdy,pong_data_rdy})
         //2'b00:
         2'b10: begin
            if(ping_stil_info_tx.comment_info.len() != 0) comment_str = {comment_str, ping_stil_info_tx.comment_info};
            stil_str = {stil_str, ping_stil_info_tx.stil_info};
            ping_data_rdy = 1'b0;
         end
         2'b11: begin
            if(ping_stil_info_tx.comment_info.len() != 0) comment_str = {comment_str, ping_stil_info_tx.comment_info};
            stil_str = {stil_str, ping_stil_info_tx.stil_info};
            ping_data_rdy = 1'b1;
            pong_data_rdy = 1'b0;
            ping_stil_info_tx = pong_stil_info_tx;
         end
         2'b01: `uvm_error("stil_generator","Illegal data reday combination.")
      endcase
      
      //`uvm_info("stil_generator","after proces... ",UVM_NONE);
      //`uvm_info("stil_generator",$sformatf("ping_data_rdy = %0b, pong_data_rdy = %0b",ping_data_rdy, pong_data_rdy),UVM_NONE);
      //`uvm_info("stil_generator",$sformatf("stil_str = %s, comment_str = %s",stil_str, comment_str),UVM_NONE);

   endfunction: update_ping_pong_buffer

   task run_phase(uvm_phase phase);
      
      stil_fd = $fopen(stil_file_name, "w");
      if(gen_stil_file) #1 print_stil_header(stil_fd);
      forever begin
         if(TCK_ping_data_rdy && TCK_pong_data_rdy || SYSCLK_ping_data_rdy && SYSCLK_pong_data_rdy ||
            jtag_pong_data_rdy && jtag_ping_data_rdy || pad_ping_data_rdy && pad_pong_data_rdy ||
            reset_ping_data_rdy && reset_pong_data_rdy)begin
               
               while(!pad_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);
               while(!TCK_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);
               while(!SYSCLK_sem.try_get(1))`uvm_info("stil_generator","try get semafore",UVM_DEBUG);
               while(!jtag_sem.try_get(1))`uvm_info("stil_generator","try get semafore",UVM_DEBUG);
               while(!reset_sem.try_get(1)) `uvm_info("stil_generator","try get semafore",UVM_DEBUG);

               //`uvm_info("stil_generator","check TCK stil_info_transaction",UVM_NONE);
               update_ping_pong_buffer(TCK_ping_data_rdy,TCK_pong_data_rdy,TCK_stil_info_tx_ping,TCK_stil_info_tx_pong);
               
               //`uvm_info("stil_generator","check pad stil_info_transaction",UVM_NONE);
               update_ping_pong_buffer(pad_ping_data_rdy,pad_pong_data_rdy,pad_stil_info_tx_ping,pad_stil_info_tx_pong);
               
               //`uvm_info("stil_generator","check reset stil_info_transaction",UVM_NONE);
               update_ping_pong_buffer(reset_ping_data_rdy,reset_pong_data_rdy,reset_stil_info_tx_ping,reset_stil_info_tx_pong);
               
               //`uvm_info("stil_generator","check jtag stil_info_transaction",UVM_NONE);
               update_ping_pong_buffer(jtag_ping_data_rdy,jtag_pong_data_rdy,jtag_stil_info_tx_ping,jtag_stil_info_tx_pong);
               
               //`uvm_info("stil_generator","check SYSCLK stil_info_transaction",UVM_NONE);
               update_ping_pong_buffer(SYSCLK_ping_data_rdy,SYSCLK_pong_data_rdy,SYSCLK_stil_info_tx_ping,SYSCLK_stil_info_tx_pong);

               TCK_sem.put(1);   
               SYSCLK_sem.put(1);   
               jtag_sem.put(1);   
               pad_sem.put(1);   
               reset_sem.put(1);   

               write_to_file = 1;
         end
         
         if(write_to_file) begin
            //`uvm_info("stil_generator",comment_str,UVM_NONE);
            //`uvm_info("stil_generator",stil_str,UVM_NONE);
            if(comment_str.len() != 0) $fdisplay(stil_fd,{"//",comment_str});
            $fdisplay(stil_fd,{"\t V { ",stil_str, " }"});
            //`uvm_info("stil_generator",stil_str,UVM_NONE);
            write_to_file = 0;
            stil_str = "";
            comment_str= "";
            #1;
         end 
         else #1;
      end
   endtask: run_phase


   function void final_phase( uvm_phase phase );
      super.final_phase( phase );
      if(gen_stil_file)$fdisplay(stil_fd,"\}");
   endfunction: final_phase
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
   TCK_clk_driver       TCK_clk_drv;
   SYSCLK_clk_driver    SYSCLK_clk_drv;
   reset_driver         reset_drv;
   pad_driver           pad_drv;

   stil_generator       stil_gen;
   dft_register_layering     reg_layering;

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
	   
      agent = jtag_agent::type_id::create           (.name( "agent"      ), .parent(this));
      scoreboard = jtag_scoreboard::type_id::create (.name( "scoreboard" ), .parent(this));
      //reg_predictor = jtag_reg_predictor::type_id::create(.name( "reg_predictor" ), .parent(this));
      
      TCK_clk_drv = TCK_clk_driver::type_id::create(.name( "TCK_clk_drv" ), .parent(this));
      SYSCLK_clk_drv = SYSCLK_clk_driver::type_id::create(.name( "SYSCLK_clk_drv" ), .parent(this));
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
      TCK_clk_drv.clk_drv_ap.connect(stil_gen.TCK_clk_drv_imp_export); 
      SYSCLK_clk_drv.clk_drv_ap.connect(stil_gen.SYSCLK_clk_drv_imp_export); 
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

