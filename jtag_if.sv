//------------------------------------------------------------------------------
// Interface: pad_if 
//------------------------------------------------------------------------------

interface pad_if( input bit clk);
    logic [`PAD_GRP0_IN_NUM-1:0]      pad_grp0_in;
    logic [`PAD_GRP0_OUT_NUM-1:0]     pad_grp0_out;
    logic [`PAD_GRP0_INOUT_NUM-1:0]   pad_grp0_inout;
    
    logic [`PAD_GRP1_IN_NUM-1:0]      pad_grp1_in;
    logic [`PAD_GRP1_OUT_NUM-1:0]     pad_grp1_out;
    logic [`PAD_GRP1_INOUT_NUM-1:0]   pad_grp1_inout;
    modport driver_mp(input pad_grp0_out, output  pad_grp0_in, inout  pad_grp0_inout,input  pad_grp1_out, output  pad_grp1_in, inout  pad_grp1_inout);    
    modport dut_mp(output pad_grp0_out, input  pad_grp0_in, inout  pad_grp0_inout,output pad_grp1_out, input  pad_grp1_in, inout  pad_grp1_inout);    
 endinterface: pad_if

//------------------------------------------------------------------------------
// Interface: jtag_if 
//------------------------------------------------------------------------------

interface jtag_if( input bit tck, input bit trst);
    logic tdi;
    logic tdo;
    logic tms;
    logic read_not_write;

    clocking negedge_cb @ ( negedge tck);
        default output #3ns;
       output tdi;
       output tms;
       output read_not_write;
    endclocking: negedge_cb 

    clocking posedge_cb @ ( posedge tck);
       input  tdo;
    endclocking: posedge_cb 

    clocking monitor_cb @ ( posedge tck );
        input tdi;
        input tdo;
        input tms;
        input read_not_write;
    endclocking: monitor_cb
    modport master_mp( input trst, clocking negedge_cb, clocking posedge_cb );
    modport slave_mp ( input tdi, tms, output tdo);
    modport monitor_mp ( input trst, clocking monitor_cb);
    
 endinterface: jtag_if

//------------------------------------------------------------------------------
// Interface: clk_if 
//------------------------------------------------------------------------------

interface clk_if( );
   logic clk;
   modport driver_mp(output clk); 
   modport dut_mp(input clk); 
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


