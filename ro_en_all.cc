/********************************************************************-*- C++ -*-
* AMD Internal Use Only
* Copyright 2012 Advanced Micro Devices - All Rights Reserved
*
* Description: Verify 1687 1st level SIB bit connection  
* Revision :   $Revision: $
* Date :       $Date:  $
* Submitter:   $Author: ruhuang$
*
* This file is protected by Federal Copyright Law, with all rights
* reserved. No part of this file may be reproduced, stored in a
* retrieval system, translated, transcribed, or transmitted, in any
* form, or by any means manual, electric, electronic, mechanical,
* electro-magnetic, chemical, optical, or otherwise, without prior
* explicit written permission from AMD, Inc.
*
*******************************************************************************/
/*******************************************************************************
* This Test Verify 1687 1st level SIB bit connection.
*******************************************************************************/
// ****************************************************************************
// ***********************TEST CASE FLOW **************************************
// *****************************************************************************
// --> 1. loop test all posibble 1st level 1687 sib bit combination
// -->    1.1. write 2nd level sib bits to all zero to check shift out value.
// -->    1.2. Write random data to 2nd level sib bits to check chain connection.
// *****************************************************************************
#include "util_twi.h"
#include "dfx_utils.h"
#include "ext_pin_drv.h"

TESTCASE_BEGIN(dfx_jtag_sib_connection_cov)
int ThreadMethod(void) {
    TWI_BEGIN();
    INFO("TWI TEST: TWI Test Started");

    // Creating the instances for JTAG Request manager and Driver
    // cJtagDrv handles only five IEEE compatible TAP pins
    cJtagReqMgr* jtagReqMgr    = dynamic_cast<cJtagReqMgr *>(TestControl->GetComponentPointer("JTAG_REQ_MGR"));
    
    cRandNumGen* RG;
    RG = Env->NewRandNumGen("TWI Testcase");
    
    cDfxUtils* DfxUtils;
// ------------------------------------------------------------------------
// reset sequence
    ThreadWaitOnPwrOkAsserted(MAX_WAIT_ON_PWROK_ASSERTED);
    INFO("TWI TEST: PWROK Asserted");
    jtagReqMgr->reset(); //try real gnb mc x problem
    
    INFO("TWI TEST: halts CPU Core");  
    DfxUtils = cDfxUtils::Instance();
    DfxUtils->CpuHalt() ; // halts both CPUs

    ThreadWaitOnColdResetDone(MAX_WAIT_ON_COLD_RESET_DONE);
    INFO("TWI TEST: Cold Reset Done");   
// ------------------------------------------------------------------------


    
    void prepare_bf_load_ir(void);
    void load_ir(cReg ir_opcode,cReg mc_en);
    cReg load_tdr_brd (cReg tdr,  cReg sel_wir);
    cReg load_tdr_daisy (cReg tdr,  cReg sel_wir, cReg tile_location, cReg mc_en);
    cReg read_tdr_daisy (cReg tdr,  cReg sel_wir, cReg tile_location, cReg mc_en);
    cReg get_ros_lctn (void);
    void config_mc(cReg p1500_mc, cReg sel_wir);
    void start_ro(cReg start_pattern,cReg sel_wir,cReg mc_en);
    
    cReg vdci_p1500_setup_instr(9,0); //TILE 167
    cReg vdci_p1500_setup_data(2,0);
    
    cReg rosen_instr(9,0); //TILE 169
    
    cReg rossetup_instr(9,0); //TILE 169
    cReg rossetup_data(59,0);
    
    cReg pfh_common_ros_setup_instr(9,0);
    cReg pfh_common_ros_setup_data(7,0);

    cReg pfh_common_ros_status_instr(9,0);
    cReg pfh_common_ros_status_data(29,0);
    
    cReg daisy_mode_instr(9,0);
    cReg daisy_mode_data(0,0);

    cReg ros_lctn(169,0);
    cReg p1500_mc(169,0);
    cReg all_ones(169,0);
    cReg result(4,0);
    cReg sel_wir(0,0);
    cReg mc_en(0,0);
    
    cReg en_ro_pattern(168,0);

    for (int i = 0; i < 170; i++) all_ones(i) = 1;

    ros_lctn = get_ros_lctn();
    INFO("TWI TEST: ros_lctn = %s.",ros_lctn.toHex().c_str());   
    
    pfh_common_ros_status_instr = 0x41;
    
    rosen_instr = 0x1cb;

    rossetup_instr = 0x1ca; 
    rossetup_data(1,0) = 0x2;

    pfh_common_ros_setup_instr = 0x40;
    pfh_common_ros_setup_data(5,4) = 0x3; //ros_size = 0x3
   
    vdci_p1500_setup_instr = 0x26f;
    vdci_p1500_setup_data(2) = 1;

    daisy_mode_instr = 0x1;
    daisy_mode_data = 0x1;
    
    prepare_bf_load_ir();
    INFO("TWI TEST: Part 0:Select daisy mode to config TDR....");   
    mc_en = 0;
    load_ir(daisy_mode_instr,mc_en);
    
    sel_wir = 1; 
    result.resizeAndCopy(load_tdr_brd(daisy_mode_data,sel_wir));
    INFO("TWI TEST: daisy_mode_data = %s, result = %s",daisy_mode_data.toHex().c_str(),result.toHex().c_str());
    if (result != daisy_mode_data) {
        ERROR("TWI TEST: read data mismatch.");
        //INFO("TWI TEST: read data mismatch.");
    }

    INFO("TWI TEST: load vdci_setup_instr....");   
    mc_en = 1;
    load_ir(vdci_p1500_setup_instr,mc_en); //this step change mc_en to 1.
    
    INFO("TWI TEST: only enable dfttr_vdci tile(tile 167)....");   
    p1500_mc  = 0;
    p1500_mc(167) = 1;
    sel_wir = 0; 
    config_mc(p1500_mc,sel_wir); //this step will change mc_en to 0.
    
    INFO("TWI TEST: load vdci_setup_data....");  
    sel_wir = 1;
    mc_en = 1;
    result.resizeAndCopy(load_tdr_daisy(vdci_p1500_setup_data,sel_wir,p1500_mc,mc_en));
    result = result >> 167;
    if (result != vdci_p1500_setup_data) {
        INFO("TWI TEST:ERROR vdci_p1500_setup_data cfg error.");
    }

    INFO("TWI TEST: Enable all tiles....");  
    p1500_mc = all_ones;
    sel_wir = 1;
    config_mc(p1500_mc,sel_wir); //this step will change mc_en to 0.

    INFO("TWI TEST: Part I:load pfh_common_ros_setup_instr....");   
    mc_en = 1;
    load_ir(pfh_common_ros_setup_instr,mc_en); //this step change mc_en to 1.

    
    INFO("TWI TEST: Part II:configure pfh_common_ros_setup_data....");   
    sel_wir = 1; 
    //for(int tile_num = 169; tile_num >= 0; tile_num-- ) {
        //if(ros_lctn(tile_num) == 0x1){
            //p1500_mc(169,tile_num+1) = 0x0;        
            //p1500_mc(tile_num,0) = ros_lctn(tile_num,0);
            p1500_mc = ros_lctn;
            
            sel_wir = 0;
            config_mc(p1500_mc,sel_wir); //this step will change mc_en to 0.
            mc_en = 1;
            result.resizeAndCopy(load_tdr_daisy(pfh_common_ros_setup_data,sel_wir,p1500_mc,mc_en));

            INFO("TWI TEST: p1500_mc = %s",p1500_mc.toHex().c_str());
            INFO("TWI TEST: pfh_common_ros_setup_data = %s, result = %s",pfh_common_ros_setup_data.toHex().c_str(),result.toHex().c_str());
            

            for (int i = 0; i < 170; i++) {
                INFO("TWI TEST: check tile %d.",i);
                INFO("TWI TEST: result = %s,p1500_mc[%d] = %s ",result.toHex().c_str(),i,p1500_mc(i).toHex().c_str());

                if(p1500_mc(i) == 0x1){
                    if (result((pfh_common_ros_setup_data.getWidth()-1),0) != pfh_common_ros_setup_data) {
                        //ERROR("TWI TEST: tile %d read data mismatch.",i);
                        INFO("TWI TEST ERROR: tile %d read data mismatch.",i);
                        INFO("TWI TEST: result[%d:0] = %s",(pfh_common_ros_setup_data.getWidth()-1),result((pfh_common_ros_setup_data.getWidth()-1),0).toHex().c_str());
                    }
                    result = result >> pfh_common_ros_setup_data.getWidth();
                }
                else {
                    result = result >> 1;
                }
            }


        //}
    //}

    INFO("TWI TEST: Enable all tiles again to configrue ros_control register in dft tile....");  
    p1500_mc = all_ones;
    sel_wir = 1;
    config_mc(p1500_mc,sel_wir); //this step will change mc_en to 0.
    
   // INFO("TWI TEST: Select broadcast mode to config TDR....");   
   // mc_en = 0;
   // load_ir(daisy_mode_instr,mc_en);
   // 
   // sel_wir = 1; 
   // daisy_mode_data = 0;
   // result.resizeAndCopy(load_tdr_brd(daisy_mode_data,sel_wir));
   // INFO("TWI TEST: daisy_mode_data = %s, result = %s",daisy_mode_data.toHex().c_str(),result.toHex().c_str());
   // if (result != daisy_mode_data) {
   //     ERROR("TWI TEST: read data mismatch.");
   //     //INFO("TWI TEST: read data mismatch.");
   // }
    
    INFO("TWI TEST: load rossetup instr....");  
    mc_en = 0;
    load_ir(rossetup_instr,mc_en); 
    
    
    INFO("TWI TEST: load rossetup data....");  
    p1500_mc = 0;
    p1500_mc(169) = 1;
    sel_wir = 1; 
    mc_en = 0;
    
    result.resizeAndCopy(load_tdr_daisy(rossetup_data,sel_wir,p1500_mc,mc_en));
    INFO("TWI TEST: rossetup_data= %s, result = %s",rossetup_data.toHex().c_str(),result.toHex().c_str());
    result = result >> 169;
    if (result != rossetup_data) {
        //ERROR("TWI TEST: read data mismatch.");
        INFO("TWI TEST: read data mismatch.");
    }

    INFO("TWI TEST: load rosen instr....");  
    mc_en = 0;
    load_ir(rosen_instr,mc_en); //this step change mc_en to 1.

    INFO("TWI TEST: enable ro and disable it....");  
    en_ro_pattern = 0x1f;
    mc_en = 0;
    sel_wir = 1; 
    start_ro(en_ro_pattern,sel_wir,mc_en);
    
    INFO("TWI TEST: load rosstatusinstr....");  
    mc_en = 1;
    load_ir(pfh_common_ros_status_instr,mc_en); //this step change mc_en to 1.

   
    INFO("TWI TEST: set mc bit in tiles have ro....");  
    p1500_mc = ros_lctn;
    sel_wir = 0; 
    config_mc(p1500_mc,sel_wir); //this step will change mc_en to 0.
    
    INFO("TWI TEST: read rosstatus data....");  
    mc_en = 0;
    result.resizeAndCopy(read_tdr_daisy(pfh_common_ros_status_data,sel_wir,p1500_mc,mc_en));

    INFO("TWI TEST: p1500_mc = %s",p1500_mc.toHex().c_str());
    INFO("TWI TEST: result = %s",result.toHex().c_str());
    

    for (int i = 0; i < 170; i++) {
        INFO("TWI TEST: check tile %d.",i);
        INFO("TWI TEST: result = %s,p1500_mc[%d] = %s ",result.toHex().c_str(),i,p1500_mc(i).toHex().c_str());

        if(p1500_mc(i) == 0x1){
            if (result((pfh_common_ros_status_data.getWidth()-2),0) <= 0) {
                ERROR("TWI TEST ERROR: tile %d counter value is 0.",i);
                INFO("TWI TEST: result[%d:0] = %s",(pfh_common_ros_status_data.getWidth()-1),result((pfh_common_ros_status_data.getWidth()-1),0).toHex().c_str());
            }
            result = result >> pfh_common_ros_status_data.getWidth();
        }
        else {
            result = result >> 1;
        }
    }
    ThreadWait(100);
    INFO("TWI TEST: TWI Test Finished");
    TWI_FINISH();
}
TESTCASE_END(dfx_jtag_sib_connection_cov)
    void prepare_bf_load_ir(void) {

        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        
        cReg wr_data;
        cReg sel_wir(0,0);
        cReg mc_en(0,0);
        cReg MC_BIT(0,0);
        cReg soc_lvl2(1,0);
         
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: Section 1:Select TCK as TAP clock.");
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: Step1:Set SOC SIB in LVL1 1687.");
        sib_en = 0x2;
        uint id = jtagReqMgr->submit(p1687_instr,sib_en);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        
        INFO("TWI TEST: step2:Set refclk mux in soc level2");
        soc_lvl2 = 0x1;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(4,2);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());

        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: Section 2:Set MC_EN bit and enable tiles %s");
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: Step1: Set GNB SIB in LVL1 1687");
        sib_en = 0xa;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(4,2);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);

        INFO("TWI TEST: Step2: Set SELWIR and MC_EN in GNB SIB LVL2");
        sib_en = 0xa;
        mc_en = 0x1;
        sel_wir = 0x1;
        MC_BIT = 0x1;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        //wr_data >>= mc_data;
        for (int i=0;i<170;i++) wr_data >>= MC_BIT;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        
        INFO("TWI TEST: Step3: enable all tiles");
        sib_en = 0xa;
        mc_en = 0x0;
        sel_wir = 0x1;
        MC_BIT = 0x1;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        //wr_data >>= mc_data;
        for (int i=0;i<170;i++) wr_data >>= MC_BIT;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
    }


    void load_ir(cReg ir_opcode = 0x0, cReg mc_en = 0x0) {

        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        
        cReg wr_data;
        cReg sel_wir(0,0);
        //cReg mc_en(0,0);
        cReg MC_BIT(0,0);
        cReg soc_lvl2(1,0);
         
        sib_en = 0xa;
        soc_lvl2 = 0x1;
        //mc_en = 0;
       
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: load OPCODE %s",ir_opcode.toHex().c_str());
        INFO("TWI TEST: --------------------------------------------------------.");
        sel_wir = 0x0;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        wr_data >>= ir_opcode;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());

        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
    }

     cReg load_tdr_brd (cReg tdr = 0x0, cReg sel_wir = 0x1) {
        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        cReg soc_lvl2(1,0);
        
        cReg wr_data;
        cReg rd_data;
        cReg mc_en(0,0);
        cReg sel_wir_local(0,0);
        
        soc_lvl2 = 0x1;
        sib_en = 0xa;
        mc_en = 0x0;
        sel_wir_local = 0;
        INFO("TWI TEST: Write TDR = %s",tdr.toHex().c_str());
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        wr_data >>= tdr;
        wr_data >>= mc_en;
        wr_data >>= sel_wir_local;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        wr_data >>= tdr;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: Second write to shift out to read");
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        rd_data.resizeAndCopy(jtagReqMgr->result(id));
        return rd_data((tdr.getWidth()+6-1),6);
    }
    cReg load_tdr_daisy (cReg tdr = 0x0,  cReg sel_wir = 0x1, cReg tile_location = 0x0, cReg mc_en = 0x0) {
//update log:
//2011/6/10: change tile_location from int type to cReg type, each bit indicate whether this tile will be configured.
//2011/6/13: added mc_en argument 
        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        cReg soc_lvl2(1,0);
        
        cReg wr_data;
        cReg rd_data;
        cReg mc_en_local(0,0);
        cReg sel_wir_local(0,0);
        cReg bypass_bit(0,0);
        
        int all_shift_tdr_length = 0;
        sel_wir_local = 0;
        soc_lvl2 = 0x1;
        sib_en = 0xa;
        mc_en_local = 0x0;
        bypass_bit = 0x0;

        INFO("TWI TEST: Write TDR = %s",tdr.toHex().c_str());
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        //When in daisy mode, tile 0 is closest to TDO, while in broad cast mode tile 169 is cloest to TDO.
        for (int i=0;i < 170;i++){
            if(tile_location(i) == 0x1) {
                wr_data >>= tdr;
                all_shift_tdr_length = all_shift_tdr_length + tdr.getWidth(); 
            }
            else {
                wr_data >>= bypass_bit;
                all_shift_tdr_length ++;
            }
        }
        wr_data >>= mc_en_local;
        wr_data >>= sel_wir_local;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        for (int i=0;i < 170;i++){
            if(tile_location(i) == 0x1) {
                wr_data >>= tdr;
            }
            else {
                wr_data >>= bypass_bit;
            }
        }
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: Second write to shift out to read");
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        

        id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        rd_data.resizeAndCopy(jtagReqMgr->result(id));
        return rd_data((6 + all_shift_tdr_length -1),6); //6:the sib bits width before tdr;
    }


    cReg get_ros_lctn(void) {

        cReg ros_location(169,0);
        
        ros_location = 0;
        ros_location(1     ) = 1;
        ros_location(2 ) = 1;
        ros_location(4 ) = 1;
        ros_location(5 ) = 1;
        ros_location(6 ) = 1;
        ros_location(7 ) = 1;
        ros_location(8 ) = 1;
        ros_location(9 ) = 1;
        ros_location(10) = 1;
        ros_location(11) = 1;
        ros_location(13) = 1;
        ros_location(15) = 1;
        ros_location(16) = 1;
        ros_location(17) = 1;
        ros_location(18) = 1;
        ros_location(19) = 1;
        ros_location(21) = 1;
        ros_location(22) = 1;
        ros_location(23) = 1;
        ros_location(24) = 1;
        ros_location(25) = 1;
        ros_location(26) = 1;
        ros_location(27) = 1;
        ros_location(28) = 1;
        ros_location(29) = 1;
        ros_location(30) = 1;
        ros_location(31) = 1;
        ros_location(32) = 1;
        ros_location(33) = 1;
        ros_location(35) = 1;
        ros_location(36) = 1;
        ros_location(37) = 1;
        ros_location(38) = 1;
        ros_location(39) = 1;
        ros_location(40) = 1;
        ros_location(41) = 1;
        ros_location(42) = 1;
        ros_location(43) = 1;
        ros_location(45) = 1;
        ros_location(46) = 1;
        ros_location(47) = 1;
        ros_location(48) = 1;
        ros_location(49) = 1;
        ros_location(50) = 1;
        ros_location(51) = 1;
        ros_location(52) = 1;
        ros_location(53) = 1;
        ros_location(54) = 1;
        ros_location(55) = 1;
        ros_location(56) = 1;
        ros_location(58) = 1;
        ros_location(59) = 1;
        ros_location(60) = 1;
        ros_location(61) = 1;
        ros_location(62) = 1;
        ros_location(63) = 1;
        ros_location(64) = 1;
        ros_location(65) = 1;
        ros_location(66) = 1;
        ros_location(67) = 1;
        ros_location(68) = 1;
        ros_location(69) = 1;
        ros_location(70) = 1;
        ros_location(71) = 1;
        ros_location(72) = 1;
        ros_location(73) = 1;
        ros_location(74) = 1;
        ros_location(75) = 1;
        ros_location(76) = 1;
        ros_location(78) = 1;
        ros_location(79) = 1;
        ros_location(81) = 1;
        ros_location(82) = 1;
        ros_location(84) = 1;
        ros_location(85) = 1;
        ros_location(87) = 1;
        ros_location(88) = 1;
        ros_location(89) = 1;
        ros_location(90) = 1;
        ros_location(91) = 1;
        ros_location(93) = 1;
        ros_location(94) = 1;
        ros_location(96) = 1;
        ros_location(97) = 1;
        ros_location(98) = 1;
        ros_location(99) = 1;
        ros_location(100 ) = 1;
        ros_location(104 ) = 1;
        ros_location(105 ) = 1;
        ros_location(106     ) = 1;
        ros_location(107 ) = 1;
        ros_location(108 ) = 1;
        ros_location(109 ) = 1;
        ros_location(110 ) = 1;
        ros_location(111 ) = 1;
        ros_location(112 ) = 1;
        ros_location(114 ) = 1;
        ros_location(115 ) = 1;
        ros_location(116 ) = 1;
        ros_location(117 ) = 1;
        ros_location(119 ) = 1;
        ros_location(120 ) = 1;
        ros_location(122 ) = 1;
        ros_location(123 ) = 1;
        ros_location(125 ) = 1;
        ros_location(126 ) = 1;
        ros_location(127 ) = 1;
        ros_location(128 ) = 1;
        ros_location(129 ) = 1;
        ros_location(130 ) = 1;
        ros_location(132 ) = 1;
        ros_location(133 ) = 1;
        ros_location(134 ) = 1;
        ros_location(135 ) = 1;
        ros_location(136 ) = 1;
        ros_location(138 ) = 1;
        ros_location(139 ) = 1;
        ros_location(140 ) = 1;
        ros_location(141 ) = 1;
        ros_location(142 ) = 1;
        ros_location(143 ) = 1;
        ros_location(144 ) = 1;
        ros_location(145 ) = 1;
        ros_location(146 ) = 1;
        ros_location(147 ) = 1;
        ros_location(148 ) = 1;
        ros_location(149 ) = 1;
        ros_location(150 ) = 1;
        ros_location(151 ) = 1;
        ros_location(152 ) = 1;
        ros_location(153 ) = 1;
        ros_location(154 ) = 1;
        ros_location(156 ) = 1;
        ros_location(157 ) = 1;
        ros_location(159 ) = 1;
        ros_location(160 ) = 1;
        ros_location(162 ) = 1;
        ros_location(163 ) = 1;
        ros_location(165 ) = 1;
        ros_location(166) = 1;
        
        return ros_location;
        INFO("TWI TEST: ros_location = %s",ros_location.toHex().c_str());
      }

    void config_mc(cReg p1500_mc,cReg sel_wir) {

        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        
        cReg wr_data;
        //cReg sel_wir(0,0);
        cReg mc_en(0,0);
        cReg MC_BIT(0,0);
        cReg soc_lvl2(1,0);
         
        sib_en = 0xa;
        soc_lvl2 = 0x1;
        mc_en = 0;
       
        INFO("TWI TEST: --------------------------------------------------------.");
        INFO("TWI TEST: load p1500_mc = %s",p1500_mc.toHex().c_str());
        INFO("TWI TEST: --------------------------------------------------------.");
        //sel_wir = 0x0;
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        wr_data >>= p1500_mc;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());

        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
    }

    cReg read_tdr_daisy (cReg tdr = 0x0,  cReg sel_wir = 0x1, cReg tile_location = 0x0, cReg mc_en = 0x0) {
//update log:
//2011/6/10: change tile_location from int type to cReg type, each bit indicate whether this tile will be configured.
//2011/6/13: added mc_en argument 
        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        cReg soc_lvl2(1,0);
        
        cReg wr_data;
        cReg rd_data;
        cReg mc_en_local(0,0);
        cReg sel_wir_local(0,0);
        cReg bypass_bit(0,0);
        
        int all_shift_tdr_length = 0;
        sel_wir_local = 0;
        soc_lvl2 = 0x1;
        sib_en = 0xa;
        mc_en_local = 0x0;
        bypass_bit = 0x0;

        INFO("TWI TEST: Write TDR = %s",tdr.toHex().c_str());
        
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        for (int i=0;i < 170;i++){
            if(tile_location(i) == 0x1) {
                wr_data >>= tdr;
                all_shift_tdr_length = all_shift_tdr_length + tdr.getWidth(); 
            }
            else {
                wr_data >>= bypass_bit;
                all_shift_tdr_length ++;
            }
        }
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: shift out data");
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        

        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
        rd_data.resizeAndCopy(jtagReqMgr->result(id));
        return rd_data((6 + all_shift_tdr_length -1),6); //6:the sib bits width before tdr;
    }
    
    void start_ro(cReg start_pattern = 0xf,cReg sel_wir = 0x1,cReg mc_en = 0x0) {
        cJtagReqMgr* jtagReqMgr = cTestControl::GetTypedComponentPointer<cJtagReqMgr>("JTAG_REQ_MGR");
        
        cReg p1687_instr(7,0);
        p1687_instr =0xf0;
        
        cReg sib_en(4,0);
        cReg soc_lvl2(1,0);
        
        cReg wr_data;
        cReg rd_data;
        
        soc_lvl2 = 0x1;
        sib_en = 0xa;
        
        INFO("TWI TEST: start_pattern = %s",start_pattern.toHex().c_str());
        wr_data.resizeAndCopy(sib_en(1,0));
        wr_data >>= soc_lvl2;
        wr_data >>= sib_en(3,2);
        wr_data >>= start_pattern;
        wr_data >>= mc_en;
        wr_data >>= sel_wir;
        wr_data >>= sib_en(4);
        INFO("TWI TEST: wr_data = %s",wr_data.toHex().c_str());
        
        uint id = jtagReqMgr->submit(p1687_instr,wr_data);
        ThreadWaitOnJtagReq(jtagReqMgr, id);
    }

