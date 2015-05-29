//------------------------------------------------------------------------------
// class: jtag_transaction
//------------------------------------------------------------------------------
class jtag_transaction extends uvm_sequence_item;

    rand  protocol_e                 portocol;

    rand  bit [`IR_WIDTH-1:0]        o_ir;

    rand  bit [`MAX_DR_WIDTH-1:0]    o_dr_length;
    rand  bit [o_dr_length-1:0]      o_dr;
    
    //i_dr_queue/i_ir_queue  store tdo data
    bit                              i_dr_queue[$];
    bit                              i_ir_quene[$];

    //o_dr_queue/o_dr_queue  store tdi data
    bit                              o_dr_queue[$];
    bit                              o_ir_quene[$];
    
    function new (string name = "jtag_transaction");
        super.new(name); 
    endfunction

endclass:jtag_transaction

