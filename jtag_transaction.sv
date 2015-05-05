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

interface jtag_if( input bit tck, input bit trst);
    logic tdi;
    logic tdo;
    logic tms;

    //clocking negedge_cb @ ( negedge tck);
    //   output tdo;
    //endclocking: master_cb

    //clocking posedge_cb @ ( posedge tck);
    //   input  tdi;
    //   output tms;
    //endclocking: slave_cb

    modport master_mp( input tck, trst, tdo, output tdi, tms);
    modport slave_mp ( input tck, trst, tdi, tms, output tdo);
endinterface: jtag_if


