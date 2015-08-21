//---------------------------------------------------------------------------
// Class: jtag_configuration
//---------------------------------------------------------------------------

class jtag_configuration extends uvm_object;
   `uvm_object_utils( jtag_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual jtag_if          jtag_vi;

   ieee1149_1_reg_block     jtag_reg_block;

   bit                      gen_stil_file;
   string                   stil_file_name;
   int                      tck_half_period;
endclass: jtag_configuration

//---------------------------------------------------------------------------
// Class: clock_configuration
//---------------------------------------------------------------------------

class clock_configuration extends uvm_object;
   `uvm_object_utils( clock_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual clock_if          clock_vi;

   bit                      gen_stil_file;
   bit                      stop_tck,stop_sysclk;
   //string                   stil_file_name;
   int                      tck_half_period;
   int                      sysclk_half_period;
endclass: clock_configuration


