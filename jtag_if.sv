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
    modport monitor_mp ( input tck, trst, tdi, tms, tdo);
endinterface: jtag_if


