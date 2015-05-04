class jtag_transaction extends uvm_sequence_item;
    typedef enum bit[1:0] { 1149.1, 1500, 1687} protocol_e;

    rand  protocol_e                 portocol;
    rand  bit [`IR_WIDTH-1:0]        o_ir;
    rand  bit [`MAX_DR_WIDTH-1:0]    o_dr_length;
    bit                              o_tdi_queue[$];
    bit                              i_tdi_queue[$];
    bit                              i_tdo_queue[$];

    function new (string name = "jtag_transaction");
        super.new(name); 
    endfunction

endclass:jtag_transaction


//------------------------------------------------------------------------------
// Interface: jtag_if 
//------------------------------------------------------------------------------

interface jtag_if ( input bit tck);
    logic :0] flavor;
   logic [1:0] color;
   logic       sugar_free;
   logic       sour;
   logic [1:0] taste;

   clocking master_cb @ ( posedge clk );
      default input #1step output #1ns;
      output flavor, color, sugar_free, sour;
      input  taste;
   endclocking: master_cb

   clocking slave_cb @ ( posedge clk );
      default input #1step output #1ns;
      input  flavor, color, sugar_free, sour;
      output taste;
   endclocking: slave_cb

   modport master_mp( input clk, taste, output flavor, color, sugar_free, sour );
   modport slave_mp ( input clk, flavor, color, sugar_free, sour, output taste );
   modport master_sync_mp( clocking master_cb );
   modport slave_sync_mp ( clocking slave_cb  );
endinterface: jelly_bean_if


