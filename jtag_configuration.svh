//---------------------------------------------------------------------------
// Class: jtag_configuration
//---------------------------------------------------------------------------

class jtag_configuration extends uvm_object;
   `uvm_object_utils( jtag_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual jtag_if          jtag_vi;

   dft_reg_block            reg_block;

   bit                      gen_stil_file;
   string                   stil_file_name;
   int                      tck_half_period;
endclass: jtag_configuration

//---------------------------------------------------------------------------
// Class: clk_configuration
//---------------------------------------------------------------------------

class clk_configuration extends uvm_object;
   `uvm_object_utils( clk_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual clk_if          clk_vi;

   bit                      gen_stil_file;
   bit                      stop_tck,stop_sysclk;
   //string                   stil_file_name;
   int                      tck_half_period;
   int                      sysclk_half_period;
endclass: clk_configuration

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


