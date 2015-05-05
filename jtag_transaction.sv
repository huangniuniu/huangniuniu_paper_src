//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;
    typedef enum bit[1:0] { 1149.1, 1500, 1687} protocol_e;

    rand  protocol_e                 portocol;

    rand  bit [`IR_WIDTH-1:0]        o_ir;

    rand  bit [`MAX_DR_WIDTH-1:0]    o_dr_length;
    rand  bit [o_dr_length-1:0]      o_dr;

    bit                              i_dr_queue[$];
    bit                              i_ir_quene[$];

    function new (string name = "jtag_transaction");
        super.new(name); 
    endfunction

endclass:jtag_transaction

