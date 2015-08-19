//------------------------------------------------------------------------------
// Interface: jtag_if 
//------------------------------------------------------------------------------

interface jtag_if( input bit tck, input bit trst);
    logic tdi;
    logic tdo;
    logic tms;

    clocking negedge_cb @ ( negedge tck);
        default output #3ns;
       output tdi;
    endclocking: negedge_cb 

    clocking posedge_cb @ ( posedge tck);
       input  tdo;
       output tms;
    endclocking: posedge_cb 

    clocking monitor_cb @ ( posedge tck );
        input tdi;
        input tdo;
        input tms;
    endclocking: monitor_cb
    modport master_mp( input trst, clocking negedge_cb, clocking posedge_cb );
    modport slave_mp ( input trst, tdi, tms, output tdo);
    modport monitor_mp ( input trst, clocking monitor_cb);
endinterface: jtag_if

//------------------------------------------------------------------------------
// Interface: clock_if 
//------------------------------------------------------------------------------

interface clock_if( output bit tck, sysclk);
    logic tck;
    logic sysclk;

endinterface: clock_if


