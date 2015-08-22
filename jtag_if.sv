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
    modport slave_mp ( input tdi, tms, output tdo);
    modport monitor_mp ( input trst, clocking monitor_cb);
endinterface: jtag_if

//------------------------------------------------------------------------------
// Interface: clk_if 
//------------------------------------------------------------------------------

interface clk_if( output bit tck, sysclk);
   
endinterface: clk_if

//------------------------------------------------------------------------------
// Interface: reset_if 
//------------------------------------------------------------------------------

interface reset_if( input bit tck);
   logic trst;
   logic RESET_L;

    clocking posedge_cb @ ( posedge tck);
       output trst;
       output RESET_L;
    endclocking: posedge_cb 
    modport dut_mp(input trst, RESET_L);
    modport driver_mp(clocking posedge_cb);
endinterface: reset_if

//------------------------------------------------------------------------------
// Interface: pad_if 
//------------------------------------------------------------------------------

interface pad_if( input bit tck );

endinterface: pad_if


