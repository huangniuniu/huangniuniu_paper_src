typedef class clk_wave_description;

//---------------------------------------------------------------------------
// Class: jtag_configuration
//---------------------------------------------------------------------------

class jtag_configuration extends uvm_object;
   `uvm_object_utils( jtag_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual jtag_if          jtag_vi;

   dft_register_block       reg_block;

   bit                      gen_stil_file;
   string                   stil_file_name;
   int                      tck_half_period;

   string                   pad_name[3];
   int unsigned             pad_dir[3]; //0: input; 1: output; 2: inout
   
   function void pad_info_init();
      pad_name[0] = "TDI";
      pad_dir[0] = 0;
   
      pad_name[1] = "TMS";
      pad_dir[1] = 0;
   
      pad_name[2] = "TDO";
      pad_dir[2] = 1;
   
   endfunction: pad_info_init

   function string convert2string();
      string       s;
      $sformat(s, "%s\n ********************jtag_configuration*****",s );
      $sformat(s, "%s\n gen_stil_file = \t%b \n stil_file_name = \t%s \n tck_half_period = \t%0d",s, gen_stil_file, stil_file_name, tck_half_period);
      $sformat(s, "%s\n ********************jtag_configuration*****",s );
      return s;
   endfunction: convert2string
endclass: jtag_configuration

//---------------------------------------------------------------------------
// Class: clk_configuration_base
//---------------------------------------------------------------------------

class clk_configuration_base #(string name = "")extends uvm_object;
   //typedef clk_configuration_base#(name) this_type;
   `uvm_object_utils( clk_configuration_base )
   //`uvm_object_utils( this_type )


   bit                      gen_stil_file;
   bit                      stop_clk,free_running;
   int                      half_period;
   
   string                   pad_name[1];
   int unsigned             pad_dir[1]; //0: input; 1: output; 2: inout
   
   virtual clk_if           clk_vi;
   clk_wave_description     clk_wave_desc;

   virtual function void pad_info_init();
      pad_name[0] = name;
      pad_dir[0] = 0;
   endfunction: pad_info_init 
  
   function new( string name = "" );
      super.new( name );
      clk_wave_desc = new("clk_wave_desc");
   endfunction: new

   function string convert2string();
      string       s;

      $sformat(s, "%s\n gen_stil_file = %b \n stop_clk = %b \n free_running = %s \n pad_name = %s, \n pad_dir = %s",s, gen_stil_file,stop_clk, free_running, pad_name[0], pad_dir[0] ? "input" : "output");
      foreach(clk_wave_desc.wave_desc[i]) $sformat(s, "%s\n wave_desc[%0d] = %s",s, i, clk_wave_desc.wave_desc[i]);
      return s;
   endfunction: convert2string

endclass: clk_configuration_base



//---------------------------------------------------------------------------
// Class: TCK_clk_configuration
//---------------------------------------------------------------------------
class TCK_clk_configuration extends clk_configuration_base#("TCK");
   `uvm_object_utils( TCK_clk_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

endclass: TCK_clk_configuration
//typedef clk_configuration_base#("TCK") TCK_clk_configuration;



//---------------------------------------------------------------------------
// Class: SYSCLK_clk_configuration
//---------------------------------------------------------------------------
class SYSCLK_clk_configuration extends clk_configuration_base#("SYSCLK");
   `uvm_object_utils( SYSCLK_clk_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

endclass: SYSCLK_clk_configuration

//typedef clk_configuration_base#("SYSCLK") SYSCLK_clk_configuration;

//---------------------------------------------------------------------------
// Class: reset_configuration
//---------------------------------------------------------------------------

class reset_configuration extends uvm_object;
   `uvm_object_utils( reset_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual reset_if          reset_vi;

   bit                       gen_stil_file;
   
   string                   pad_name[2];
   int unsigned             pad_dir[2]; //0: input; 1: output; 2: inout
   
   function void pad_info_init();
      pad_name[0] = "TRST";
      pad_dir[0] = 0;
   
      pad_name[1] = "RESET_L";
      pad_dir[1] = 0;
   endfunction: pad_info_init 

endclass: reset_configuration

//---------------------------------------------------------------------------
// Class: pad_configuration
//---------------------------------------------------------------------------

class pad_configuration extends uvm_object;
   `uvm_object_utils( pad_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual pad_if          pad_vi;

   bit                       gen_stil_file;
endclass: pad_configuration


