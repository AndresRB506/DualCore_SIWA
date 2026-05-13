/************************************************************************************ 
 *
 *   1.r8 32M-BIT CMOS Serial Flash Memory Verilog Model
 *
 ************************************************************************************
 *	File Name 		: IS25WP032D.v
 * 	Ref. Datasheet	: IS25WP032D REV.A1,MAY.31,2017
 * 	Creation Date	: Aug.08.2017
 * 	Version			: Rev.0.0, Aug.08.2017 
 * 	Simulator		: Cadence NC-Verilog
 *	Description		: module IS25WP032D is behavior model for the 32M-bit 1.8V serial flash.
 ************************************************************************************
 * 	Note 1:Users can initialize memory array using "Init_Mem_File" parameter. 
 *         If it is not set, all the memory bits are set to '1'.
 * 	Note 2:after power up, chip can not be enable during tVCE(300000) time.
 * 	Note 3:more than one values (min. typ. max.) are defined for some AC parameters
 *         in the datasheet, but only one of them is selected in the behavior model,
 *         e.g. program and erase cycle time is typical value. For the detailed
 *         information of the parameters, please refer to datasheet and contact ISSI
 ************************************************************************************                           
*/
/************************************************************************************ 
 * 	Revision History
 * 	Aug.08.2017		Initial Release
 ************************************************************************************
*/

// ********************************************************************************** 
// * timescale define
// ********************************************************************************** 
`timescale 1ns / 100ps

// ********************************************************************************** 
// * product parameter define
//	`define HWRST_PART 1
//	`define EON_COMMAND 1
// ********************************************************************************** 
    //////////////////////////////////////////////////////////////////////////
    // all of parameters users may need to change                          //
    //////////////////////////////////////////////////////////////////////////
        `define Tclqv 			  	7 			// time from clock low to data valid
       	`define Init_Mem_File      	"mem_model.txt"	// Initial Flash data file name for normal array
        `define Init_Mem_File_SIR  	"none"     	// Initial Flash data file name for SIR region
        `define File_Name_SG   		"none"     	// Initial SG data file name 
        `define File_Name_SFDP    	"none"     	// Initial SFDP data file is not customizable
        `define VStatus_Reg7_2    	6'b00_0000		// status register[7:2] are non-volatile bits
        `define FR_Default7_0     	8'b0000_0001	// function register default value
        `define RP_Default7_0     	8'b0000_0000	// read parameter default value
        `define ERP_Default7_5     	3'b111     		// extended read parameter default value
//		`define VAB_Reg				32'h0001_0001	// AutoBoot register value(StartAB=0001_0000) 
  		`define VAB_Reg				32'h0000_0000	// AutoBoot register value

    //////////////////////////////////////////////////////////////////////////
    // Define controller STATE						    					//
    //////////////////////////////////////////////////////////////////////////
		`define	STANDBY_STATE		0
		`define	CMD_STATE			1
		`define	BAD_CMD_STATE		2
		`define	AUTO_BOOT_STATE		3

  
module IS25WP032D( SCLK, 
					CS, 
		    		SI, 
		    		SO, 
		    		WP, 
		    		SIO3 );

// ********************************************************************************** 
// * Information of ports (input, inout)
// ********************************************************************************** 
    input  SCLK;    // Serial Clock Input
    input  CS;	    // Chip select (Low active)
    inout  SI;	    // Serial Input/Output SIO0
    inout  SO;	    // Serial Input/Output SIO1
    inout  WP;	    // Hardware write protection or Serial Input/Output SIO2
    inout  SIO3;    // Hold/HWRST or Serial Input/Output SIO3


// ********************************************************************************** 
// * Information of parameter 
// ********************************************************************************** 
    //////////////////////////////////////////////////////////////////////////
    // Density STATE parameter												//  		
    //////////////////////////////////////////////////////////////////////////
		parameter	
		A_MSB			= 21,		
		TOP_Add			= 22'h3FFFFF,
		A_MSB_SIR		= 7,		
		SIR_TOP_Add   	= 8'hFF,
		A_MSB_SG		= 6,		
		SG_TOP_Add 		= 7'h7F,
		Sector_MSB		= 9, 		// 2^(9+1)=1024, No of sectors
		A_MSB_SFDP      = 8,
		SFDP_TOP_Add    = 9'h1FF,
		A_MSB_UNIQ      = 3,
		UNIQ_TOP_Add    = 4'hF,
		Buffer_Num      = 256,
		Block_MSB		= 5,		// 2^(5+1)=64, 
		Block_NUM		= 64;		// No of 64KB-blocks
  
    //////////////////////////////////////////////////////////////////////////
    // Define ID Parameter													//
    //////////////////////////////////////////////////////////////////////////
    parameter	
		MID_ISSI		= 8'h9D,
		Device_ID		= 8'h15,
		Memory_Type		= 8'h70,
		Memory_Density	= 8'h16;

    //////////////////////////////////////////////////////////////////////////
    // Define Initial Memory File Name										//
    //////////////////////////////////////////////////////////////////////////
    parameter   Init_File		= `Init_Mem_File;      	// initial flash data
    parameter   Init_File_SIR	= `Init_Mem_File_SIR; 	// initial flash data for security
    parameter   Init_File_SG	= `File_Name_SG; 	// initial flash data for SafeGuard
    parameter   Init_File_SFDP	= `File_Name_SFDP;  // initial flash data for SFDP

    //////////////////////////////////////////////////////////////////////////
    // AC Characters Parameter												//
    //////////////////////////////////////////////////////////////////////////
		parameter	
		tDIS		= 8,	    	// CS High to SO Float Time [ns]
		tV			= `Tclqv,	   	// Clock Low to Output Valid
		tOH    		= 2,        	// Output hold time
		tBP  		= 8_000,      	// Byte program time
		tECS		= 70_000_000,  	// Sector erase time  
		tECB64		= 150_000_000, 	// Block erase time
		tECB32 		= 100_000_000,  // Block 32KB erase time
		tECC		= 9_600_000,   	// Chip erase time unit is us instead of ns  
		tPP			= 200_000,    	// Page Program time
		tW 			= 2_000_000,    // Write Status time 
		tWP_SRAM 	= 1_000,    	// Write register sram time 

		tWRABR		= 2_000_000,	// Write Auto boot register time

		tVCE		= 300_000; 		// Time delay from power up to chip select allowed

		parameter	
		tPGM_CHK	= 2_000,	// 2 us
		tERS_CHK	= 100_000;	// 100 us

		parameter   
		tSUS        = 100_000,    // delay after suspend command
		tRESU2SUSP  = 400_000;    // time interval between resume and next suspend

    //////////////////////////////////////////////////////////////////////////
    // Internal counter parameter                                           //
    //////////////////////////////////////////////////////////////////////////
		parameter  
		Clock             = 50,      // Internal clock cycle = 100ns
		ERS_Count_BE32K   = tECB32 / (Clock*2) / 500,   // Internal clock cycle = 50us
		ERS_Count_SE      = tECS / (Clock*2) / 500,     // Internal clock cycle = 50us
		ERS_Count_BE      = tECB64 / (Clock*2) / 500,   // Internal clock cycle = 50us
		Echip_Count       = tECC  / (Clock*2) / 500; 


		specify
		specparam   
		tSCLK   	= 7.5,    	// Clock Cycle Time [ns]
		fCT   		= 133,      // Clock Frequence except normal READ instruction
		tSCLK_NOR	= 20.0,   	// Clock Cycle Time for normal READ instruction
		fC  		= 50,   	// Clock Frequence for normal READ instruction
//		tSCLK_DTR	= 15,   	// Clock Cycle Time for DTR READ instruction
//		fC2  		= 66,   	// Clock Frequence for DTR READ instruction

		tTSCLK		= 8.6,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK1		= 16.6,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK2		= 11.9,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK3		= 9.6,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK4		= 8.6,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK5		= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK6		= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK7		= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK8		= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK9		= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK10	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK11	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK12	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK13	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK14	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		tTSCLK15	= 7.5,		//Clock Cycle Time for 2XIO READ instruction
		fTSCLK		= 115,		//Clock Frequence for 2XIO READ 
		fTSCLK1		= 60, 		//Clock Frequence for 2XIO READ 
		fTSCLK2		= 84, 		//Clock Frequence for 2XIO READ 
		fTSCLK3		= 104,		//Clock Frequence for 2XIO READ 
		fTSCLK4		= 115,		//Clock Frequence for 2XIO READ 
		fTSCLK5		= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK6		= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK7		= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK8		= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK9		= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK10	= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK11	= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK12	= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK13	= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK14	= 133,		//Clock Frequence for 2XIO READ 
		fTSCLK15	= 133,		//Clock Frequence for 2XIO READ 

		tQSCLK		= 9.6,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK1		= 30.3,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK2		= 20.0,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK3		= 16.6,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK4		= 14.2,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK5		= 11.9,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK6		= 9.6,		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK7		= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK8		= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK9		= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK10	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK11	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK12	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK13	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK14	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		tQSCLK15	= 9.6, 		//Clock Cycle Time for 4XIO READ instruction
		fQSCLK		= 104, 		//Clock Frequence for 4XIO READ 
		fQSCLK1		= 33, 		//Clock Frequence for 4XIO READ 
		fQSCLK2		= 50, 		//Clock Frequence for 4XIO READ 
		fQSCLK3		= 60, 		//Clock Frequence for 4XIO READ 
		fQSCLK4		= 70, 		//Clock Frequence for 4XIO READ 
		fQSCLK5		= 84, 		//Clock Frequence for 4XIO READ 
		fQSCLK6		= 104, 		//Clock Frequence for 4XIO READ 
		fQSCLK7		= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK8		= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK9		= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK10	= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK11	= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK12	= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK13	= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK14	= 104,		//Clock Frequence for 4XIO READ 
		fQSCLK15	= 104,		//Clock Frequence for 4XIO READ 

		tFSCLK		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK1		= 11.9,		//Clock Cycle Time for FASTREAD instruction
		tFSCLK2		= 9.6, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK3		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK4		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK5		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK6		= 7.5,		//Clock Cycle Time for FASTREAD instruction
		tFSCLK7		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK8		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK9		= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK10	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK11	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK12	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK13	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK14	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		tFSCLK15	= 7.5, 		//Clock Cycle Time for FASTREAD instruction
		fFSCLK		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK1		= 84 ,		//Clock Frequence for FASTREAD 
		fFSCLK2		= 104,		//Clock Frequence for FASTREAD 
		fFSCLK3		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK4		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK5		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK6		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK7		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK8		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK9		= 133,		//Clock Frequence for FASTREAD 
		fFSCLK10	= 133,		//Clock Frequence for FASTREAD 
		fFSCLK11	= 133,		//Clock Frequence for FASTREAD 
		fFSCLK12	= 133,		//Clock Frequence for FASTREAD 
		fFSCLK13	= 133,		//Clock Frequence for FASTREAD 
		fFSCLK14	= 133,		//Clock Frequence for FASTREAD 
		fFSCLK15	= 133,		//Clock Frequence for FASTREAD 

		tFDSCLK		= 7.5, 		//Clock Cycle Time for FRDO instruction
		tFDSCLK1	= 11.9,		//Clock Cycle Time for FRDO instruction
		tFDSCLK2	= 9.6 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK3	= 8.6 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK4	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK5	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK6	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK7	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK8	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK9	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK10	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK11	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK12	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK13	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK14	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		tFDSCLK15	= 7.5 ,		//Clock Cycle Time for FRDO instruction
		fFDSCLK		= 133,		//Clock Frequence for FRDO 
		fFDSCLK1	= 84 ,		//Clock Frequence for FRDO 
		fFDSCLK2	= 104,		//Clock Frequence for FRDO 
		fFDSCLK3	= 115,		//Clock Frequence for FRDO 
		fFDSCLK4	= 133,		//Clock Frequence for FRDO 
		fFDSCLK5	= 133,		//Clock Frequence for FRDO 
		fFDSCLK6	= 133,		//Clock Frequence for FRDO 
		fFDSCLK7	= 133,		//Clock Frequence for FRDO 
		fFDSCLK8	= 133,		//Clock Frequence for FRDO 
		fFDSCLK9	= 133,		//Clock Frequence for FRDO 
		fFDSCLK10	= 133,		//Clock Frequence for FRDO 
		fFDSCLK11	= 133,		//Clock Frequence for FRDO 
		fFDSCLK12	= 133,		//Clock Frequence for FRDO 
		fFDSCLK13	= 133,		//Clock Frequence for FRDO 
		fFDSCLK14	= 133,		//Clock Frequence for FRDO 
		fFDSCLK15	= 133,		//Clock Frequence for FRDO 

		tFQSCLK		= 7.5 ,		//Clock Cycle Time for FRQO instruction
		tFQSCLK1	= 15.1,		//Clock Cycle Time for FRQO instruction
		tFQSCLK2	= 12.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK3	= 11.1,		//Clock Cycle Time for FRQO instruction
		tFQSCLK4	= 9.6,		//Clock Cycle Time for FRQO instruction
		tFQSCLK5	= 8.6,		//Clock Cycle Time for FRQO instruction
		tFQSCLK6	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK7	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK8	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK9	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK10	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK11	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK12	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK13	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK14	= 7.5,		//Clock Cycle Time for FRQO instruction
		tFQSCLK15	= 7.5,		//Clock Cycle Time for FRQO instruction
		fFQSCLK		= 133,		//Clock Frequence for FRQO 
		fFQSCLK1	= 66 ,		//Clock Frequence for FRQO 
		fFQSCLK2	= 80 ,		//Clock Frequence for FRQO 
		fFQSCLK3	= 90 ,		//Clock Frequence for FRQO 
		fFQSCLK4	= 104,		//Clock Frequence for FRQO 
		fFQSCLK5	= 115,		//Clock Frequence for FRQO 
		fFQSCLK6	= 133,		//Clock Frequence for FRQO 
		fFQSCLK7	= 133,		//Clock Frequence for FRQO 
		fFQSCLK8	= 133,		//Clock Frequence for FRQO 
		fFQSCLK9	= 133,		//Clock Frequence for FRQO 
		fFQSCLK10	= 133,		//Clock Frequence for FRQO 
		fFQSCLK11	= 133,		//Clock Frequence for FRQO 
		fFQSCLK12	= 133,		//Clock Frequence for FRQO 
		fFQSCLK13	= 133,		//Clock Frequence for FRQO 
		fFQSCLK14	= 133,		//Clock Frequence for FRQO 
		fFQSCLK15	= 133,		//Clock Frequence for FRQO 

        tFDTRSCLK   = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK1  = 20.0,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK2  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK3  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK4  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK5  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK6  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK7  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK8  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK9  = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK10 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK11 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK12 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK13 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK14 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        tFDTRSCLK15 = 15.1,     // Clock Cycle Time for FASTDTRREAD instruction
        fFDTRSCLK   = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK1  = 50,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK2  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK3  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK4  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK5  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK6  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK7  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK8  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK9  = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK10 = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK11 = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK12 = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK13 = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK14 = 66,       // Clock Frequence for FASTDTRREAD instruction
        fFDTRSCLK15 = 66,       // Clock Frequence for FASTDTRREAD instruction

        tTDTRSCLK   = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK1  = 30.3,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK2  = 20.0,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK3  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK4  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK5  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK6  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK7  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK8  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK9  = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK10 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK11 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK12 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK13 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK14 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        tTDTRSCLK15 = 15.1,     // Clock Cycle Time for FASTDTR2READ instruction
        fTDTRSCLK   = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK1  = 33,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK2  = 50,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK3  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK4  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK5  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK6  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK7  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK8  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK9  = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK10 = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK11 = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK12 = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK13 = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK14 = 66,       // Clock Frequence for FASTDTR2READ instruction
        fTDTRSCLK15 = 66,       // Clock Frequence for FASTDTR2READ instruction

        tQDTRSCLK   = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK1  = 50.0,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK2  = 30.3,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK3  = 21.7,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK4  = 16.6,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK5  = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK6  = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK7  = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK8  = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK9  = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK10 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK11 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK12 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK13 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK14 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        tQDTRSCLK15 = 15.1,     // Clock Cycle Time for FASTDTR4READ instruction
        fQDTRSCLK   = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK1  = 20,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK2  = 33,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK3  = 46,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK4  = 60,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK5  = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK6  = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK7  = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK8  = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK9  = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK10 = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK11 = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK12 = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK13 = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK14 = 66,       // Clock Frequence for FASTDTR4READ instruction
        fQDTRSCLK15 = 66,       // Clock Frequence for FASTDTR4READ instruction

        tABSCLK     = 9.6,      // Clock Cycle Time for Auto Boot Read 
        tABSCLK1    = 30.3,     // Clock Cycle Time for Auto Boot Read 
        tABSCLK2    = 20.0,     // Clock Cycle Time for Auto Boot Read 
        tABSCLK3    = 16.6,     // Clock Cycle Time for Auto Boot Read
        tABSCLK4    = 14.2,     // Clock Cycle Time for Auto Boot Read
        tABSCLK5    = 11.9,     // Clock Cycle Time for Auto Boot Read
        tABSCLK6    = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK7    = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK8    = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK9    = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK10   = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK11   = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK12   = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK13   = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK14   = 9.6,      // Clock Cycle Time for Auto Boot Read
        tABSCLK15   = 9.6,      // Clock Cycle Time for Auto Boot Read
        fABSCLK     = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK1    = 33 ,      // Clock Frequence for Auto Boot Read 
        fABSCLK2    = 50 ,      // Clock Frequence for Auto Boot Read 
        fABSCLK3    = 60 ,      // Clock Frequence for Auto Boot Read 
        fABSCLK4    = 70 ,      // Clock Frequence for Auto Boot Read 
        fABSCLK5    = 84 ,      // Clock Frequence for Auto Boot Read 
        fABSCLK6    = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK7    = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK8    = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK9    = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK10   = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK11   = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK12   = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK13   = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK14   = 104 ,     // Clock Frequence for Auto Boot Read 
        fABSCLK15   = 104 ,     // Clock Frequence for Auto Boot Read 


		tCKH    	= 4.3,	    // Clock High Time (min) [ns]
		tCKL	  	= 4.3,	    // Clock Low  Time (min) [ns]
		tCKH_R    	= 9.00,	    // Clock High Time (min) [ns]
		tCKL_R	  	= 9.00,	    // Clock Low  Time (min) [ns]
		tCKH_4PP   	= 4.3,	    // Clock High Time (min) [ns]
		tCKL_4PP  	= 4.3,	    // Clock Low  Time (min) [ns]
		tCS   		= 5,    	// CS# Active Setup Time (relative to SCLK) (min) [ns]
		tCH			= 5,    	// CS# Not Active Hold Time (relative to SCLK)(min) [ns]
		tCEH_R		= 7,    	// CS High Time for read instruction (min) [ns]
		tCEH_W		= 7,    	// CS High Time for write instruction (min) [ns]
		tDS			= 2,    	// SI Setup Time (min) [ns]
		tDH			= 2,    	// SI Hold	Time (min) [ns]
		tRESET   	= 1_000,    // hardware reset min. pulse 
		tHWRST   	= 35_000, 	// RESET# high before CS# low to accept another instruction
		tSRST    	= 35_000, 	// Software Reset recovery time 
		tDP      	= 3_000, 	// DP command to DP mode
		tRES1    	= 5_000,	// DP release command to STD mode
		tRES2    	= 5_000,	// 
		tLZ	    	= 12,			// HOLD to Output Low-z
		tHZ	    	= 12,			// HOLD to Output High-z
		tHLCH		= 2,			// HOLD Active Setup Time (relative to SCLK) (min) [ns]
		tCHHH		= 2,			// HOLD Active Hold Time (relative to SCLK) (min) [ns]
		tHHCH		= 2,			// HOLD Not Active Setup Time (relative to SCLK) (min) [ns]
		tCHHL		= 2;			// HOLD Not Active Hold Time (relative to SCLK) (min) [ns]

		endspecify

    //////////////////////////////////////////////////////////////////////////
    // Define Command Parameter												//
    //////////////////////////////////////////////////////////////////////////
		parameter	
		WREN	    	= 8'h06, // WriteEnable   
		WRDI	    	= 8'h04, // WriteDisable  
		RDSR	    	= 8'h05, // ReadStatus
		RDFR      		= 8'h48, // read function register
		RDRP      		= 8'h61, // read Read Parameter   
		RDERP      		= 8'h81, // read Extended Read Parameter   
		WRSR	    	= 8'h01, // WriteStatus
		WRFR	    	= 8'h42, // WriteFunction register
		RDJDID    		= 8'h9F, // Read Jedec ID
		RDESID	  		= 8'hAB, // ReadElectricID
		RDMDID			= 8'h90, // ReadElectricManufacturerDeviceID
		QPIID	    	= 8'hAF, // QPI ID read
		RDSFDP    		= 8'h5A, // Read SFDP mode
		RDUNIQ    		= 8'h4B, // Read UniqID mode
		IRRD      		= 8'h68, // Read SIR
		SGRD      		= 8'h2F, // Read SafeGuard 
		NORREAD1X 		= 8'h03, // NormalReadData
		FASTREAD1X  	= 8'h0B, // FastReadData
		DTRREAD1X		= 8'h0D, // FastReadData DTR
		DTRREAD2X		= 8'hBD, // DualReadData DTR
		DTRREAD4X		= 8'hED, // QuadReadData DTR

		READ2X      	= 8'hBB, // 2XI/O Read
		DREAD       	= 8'h3B, // Fastread dual output;
		QREAD       	= 8'h6B, // Fastread quad output;
		READ4X	  		= 8'hEB, // 4XI/O Read;
		PP	    		= 8'h02, // PageProgram
		IRPP    		= 8'h62, // PageProgram on SIR
		SGPP    		= 8'h23, // PageProgram on SG 
		QPP1		   	= 8'h38, // Quad PageProgram
		QPP2		   	= 8'h32, // Quad PageProgram (for EON command only)
		SE1			   	= 8'h20, // SectorErase
		SE2	  		  	= 8'hD7, // SectorErase
		IRER	  	  	= 8'h64, // SectorErase on SIR
		SGER	  	  	= 8'h2B, // SectorErase on SG 
		SGPER_55		= 8'h55, // Write Enable1 on SG 
		SGPER_AA	  	= 8'hAA, // Write Enable Confirm on SG 
		SGPPEN3		  	= 8'hA0, // Write Enable on SGPP
		SGEREN3	  	 	= 8'h80, // Write Enable on SGER
		BE32K       	= 8'h52, // 32k block erase
		BE64K    		= 8'hD8, // 64k BlockErase
		CE1	    		= 8'h60, // ChipErase
		CE2	    		= 8'hC7, // ChipErase
		EQIO	    	= 8'h35, // enable quad I/O
		RSTQIO	  		= 8'hF5, // reset quad I/O
		SRPNV    		= 8'h65, // set read parameter for Non-Volatile
		SERPNV    		= 8'h85, // set extended read parameter for Non-Volatile
		SRPV1   		= 8'hC0, // set read parameter for Volatile
		SRPV2   		= 8'h63, // set read parameter for Volatile
		SERPV    		= 8'h83, // set extended read parameter for Volatile
		SEUNLOCK 		= 8'h26, // Sector Unlock
		SEUNLOCK_DIS	= 8'h24, // disable Sector Unlock

		RSTEN	    	= 8'h66, // reset enable
		RST	    		= 8'h99, // reset memory
		NOP	    		= 8'h00, // no operation
		DP	    		= 8'hB9, // DeepPowerDown
		RDP	    		= 8'hAB, // ReleaseFromDeepPowerDown 
		CLERP			= 8'h82, // Clear Extended Read Parameter PROT_E,P_ERR,E_ERR bits

		RDABR			= 8'h14, // read auto boot register
		WRABR			= 8'h15, // write auto boot register

		SUSP1	    	= 8'hB0, // write suspend
		RESU1	    	= 8'h30, // write resume
		SUSP2	    	= 8'h75, // write suspend
		RESU2	    	= 8'h7A; // write resume


// pragma protect
// pragma protect begin

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-signal                                       */
    /*----------------------------------------------------------------------*/
    reg  [7:0]	 		ARRAY[0:TOP_Add];  // memory array
    reg  [7:0]	 		SIR0_ARRAY[0:SIR_TOP_Add]; // SIR Row0
    reg  [7:0]	 		SIR1_ARRAY[0:SIR_TOP_Add]; // SIR Row1
    reg  [7:0]			SIR2_ARRAY[0:SIR_TOP_Add]; // SIR Row2
    reg  [7:0]			SIR3_ARRAY[0:SIR_TOP_Add]; // SIR Row3
    reg  [7:0]     		SG_ARRAY[0:SG_TOP_Add];			// SG
    reg  [7:0]     		SFDP_ARRAY[0:SFDP_TOP_Add];
    reg  [7:0]     		UNIQ_ARRAY[0:UNIQ_TOP_Add];
    reg  [7:0]			Status_Reg;	    // Status Register
    reg  [7:0]   		FR_Reg;			// Function Register
    reg  [7:0]			CMD_BUS;
    reg  [31:0]    		SI_Reg;	    	// temp reg to store serial in
    reg  [31:0]    		SI_Reg_DTR; 
    reg  [7:0]      	Dummy_A[0:255];    // page size
    reg  [A_MSB:0]		Address;	    
    reg  [Sector_MSB:0]	Sector;	  
    reg  [Block_MSB:0]	Block;	  
    reg  [Block_MSB+1:0]	Block2;	  
    reg  [2:0]			STATE;


	reg	 [7:0]			BAR;			// Bank Address Register
	reg	 [7:0]			BAR_V;			// Bank Address Register for volatile
	reg	 [7:0]			BAR_NV;			// Bank Address Register for non-volatile

	reg	 [15:0]			ASP_Reg;		// ASP register    
	reg	 [63:0]			Pwd_Reg;		// password register    
	reg	 [7:0]			PPBL_Reg;		// PPB lock register    
	reg	 [31:0]			AB_Reg;			// Auto Boot register    

	reg	 [15:0]				PPB_Reg_BOT0;			// Persistent Protect Bit register Block0
	reg	 [15:0]				PPB_Reg_BOT1;			// Persistent Protect Bit register Block1
	reg	 [15:0]				PPB_Reg_TOP511;			// Persistent Protect Bit register Block511
	reg	 [15:0]				PPB_Reg_TOP510;			// Persistent Protect Bit register Block510
	reg	 [Block_NUM-1:0]	PPB_Reg;				// Persistent Protect Bit register other blocks
	reg	 [15:0]				DYB_Reg_BOT0;			// Dynamic Protect Bit register Block0
	reg	 [15:0]				DYB_Reg_BOT1;			// Dynamic Protect Bit register Block1
	reg	 [15:0]				DYB_Reg_TOP511;			// Dynamic Protect Bit register Block511
	reg	 [15:0]				DYB_Reg_TOP510;			// Dynamic Protect Bit register Block510
	reg	 [Block_NUM-1:0]	DYB_Reg;				// Dynamic Protect Bit register other blocks

	wire [15:0] 			SEC_Pro_Reg_BOT0;
	wire [15:0] 			SEC_Pro_Reg_BOT1;
	wire [15:0] 			SEC_Pro_Reg_TOP511;
	wire [15:0] 			SEC_Pro_Reg_TOP510;
	wire [Block_NUM-1:0] 	SEC_Pro_Reg;
	reg		bp_write_protect;
	reg		asp_write_protect;

    reg     SIO1_Reg;
    
    reg     Chip_EN;
    reg     DP_Mode;	    // deep power down mode
    reg     Read_Mode;
    reg     Read_1XIO_Mode;
    reg     Read_1XIO_Chk;

	reg		AUTO_BOOT_Mode;
	reg		AUTO_BOOT_Chk;

    reg     tDP_Chk;
    reg     tRES1_Chk;
    reg     tRES2_Chk;

    reg     RDJDID_Mode;
    reg     RDSR_Mode;

	reg		RDBAR_Mode;
	reg		RDASP_Mode;
	reg		RDABR_Mode;
	reg		RDPPBLK_Mode;
	reg		RDPASS_Mode;
	reg		RDPPB_Mode;

	reg		RDDYB_Mode;

    reg     FastRD_1XIO_Mode;	
    reg     FastRD_1XIO_Chk;	
    reg     PP_1XIO_Mode;
    reg     SER_Mode;
    reg     BE_Mode;
    reg     BE32K_Mode;
    reg     BE64K_Mode;
    reg     CE_Mode;
    reg     WRSR_Mode;
    reg     WRFR_Mode;
    reg     SRPNV_Mode;
    reg     SERPNV_Mode;
    reg     WRSR2_Mode;
    reg     RDESID_Mode;
    reg     RDMDID_Mode;
    reg     RDFR_Mode;
    reg     RDRP_Mode;
    reg     RDERP_Mode;

	reg		WRASP_Mode;
	reg		WRPASS_Mode;
	reg		WRABR_Mode;
	reg		PASSULK_Mode;
	reg		WRPPB_Mode;
	reg		WRDYB_Mode;
	reg		SFRZ_Mode;
	reg		PPBLK_Mode;
	reg		ERPPB_Mode;

    reg     EN4B_Mode;

    reg     ENDTR2XIO_Read_Mode;
    reg     ENDTR4XIO_Read_Mode;
    reg     DTRRead_1XIO_Mode;
    reg     DTRRead_2XIO_Mode;
    reg     DTRRead_4XIO_Mode;
    reg     DTRRead_4XIO_ModeX;
    reg     DTRRead_4XIO_Mode_4B;
	reg		DTR_Read_Mode_IN;
    reg     Set_4XIO_DTR_Enhance_Mode;
    reg     Set_2XIO_DTR_Enhance_Mode;

    reg	    SCLK_EN;
    reg	    SO_OUT_EN;   // for SO
    reg	    SI_IN_EN;    // for SI
    reg     RDSFDP_Mode;
    reg     RDUNIQ_Mode;
    reg     RST_CMD_EN;
    reg     SGEN_55CMD_EN;
    reg     SGEN_AACMD_EN;
    reg     SGPPEN3_CMD_EN;
    reg     SGEREN3_CMD_EN;
    reg     SGPPEN4_CMD_EN;
    reg     SGEREN4_CMD_EN;
    reg     WREN_06CMD;
    reg     WRBAR_Mode;
    reg     WR_WPSEL_Mode;
    reg     EN_Burst;
    reg 	[7:0] RPARAM;
    reg 	[7:0] RPARAM_V;
    reg 	[7:0] RPARAM_NV;
    reg 	[7:0] exRPARAM;
    reg 	[7:0] exRPARAM_V;
    reg 	[7:0] exRPARAM_NV;
    reg 	[A_MSB:0] A_Unlock;
    reg 	EN_SEUnlock;
	reg		sg_protect; 	
    reg     Susp_Ready;
    reg     Susp_Trig;
    reg     Susp_Start;
    reg     ERS_CLK;                  // internal clock register for erase timer
    reg     PGM_CLK;                  // internal clock register for program timer
    reg     WR2Susp;
    reg    	SCLK_DTR; 

    reg     EN_Boot;
    reg     ADD_4B_Mode;	// Address 4-byte(32bit) mode

    wire    CS_INT;
    wire    SCLK_INT;
    wire    WP_B_INT;
    wire    RESETB_INT;
    wire    HOLD_B_INT;
    wire    WIP;
    wire    ESB;			// Erase Suspend Bit
    wire    PSB;			// Program Suspend Bit
    wire    EPSUSP;
    wire    WEL;
    wire    SRWD;
	wire	TBPARAM;
    wire    PWDMLB; 	// Password Protection Mode Lock Bit
    wire    PSTMLB; 	// Persistent Protection Mode Lock Bit
    wire    PPBLB;		// PPB lock bit
    wire    FRZB;		// FREEZE bit
	wire	ABE;			// AutoBoot Enable bit
    wire    Dis_CE, Dis_WRSR;  
    wire    WPSEL_Mode;
    wire    Norm_Array_Mode;
	wire	DTR_Read_Mode;

    event   Resume_Event; 
    event   Susp_Event; 
    event   Susp_EXE_Event; 
    event   WRSR_Event; 
    event   WRFR_Event; 
    event   SRPNV_Event; 
    event   SERPNV_Event; 

	event	WRASP_Event;
	event	WRPASS_Event;
	event	WRABR_Event;
	event	PASSULK_Event;
	event	WRPPB_Event;
	event	WRDYB_Event;
	event	SFRZ_Event;
	event	PPBLK_Event;
	event	ERPPB_Event;

    event   BE_Event;
    event   SER_Event;
    event   CE_Event;
    event   PP_Event;
    event   BE32K_Event;

    event   GBLK_Event;
    event   GBULK_Event;
    event   RST_Event;
    event   RST_EN_Event;
    event   HDRST_Event;
	event	SGPER_EN1_Event;
	event	SGPER_EN2_Event;
	event	SGPP_EN3_Event;
	event	SGER_EN3_Event;
	event	SGPP_EN4_Event;
	event	SGER_EN4_Event;
	event	SGPP_EN4DIS_Event;
	event	SGER_EN4DIS_Event;


    integer i;
    integer j;
    integer Bit; 
    integer Bit_Tmp; 
    integer Start_Add;
    integer End_Add;
    integer tWRSR;
    integer Burst_Length;
//  time    tRES;
    time    ERS_Time;
    reg 		Read_SHSL;
    wire 		Write_SHSL;


    reg     SIR_Mode;	    	// enter SIR mode
    reg     SG_Mode;	    	// enter SafeGuard mode 	
    reg     Read_2XIO_Mode;
    reg     Read_2XIO_Chk;
    reg     Byte_PGM_Mode;	    
    reg	    SI_OUT_EN;   // for SI
    reg	    SO_IN_EN;    // for SO
    reg     SIO0_Reg;
	
	event	WRBAR_Event;
   
    reg     SIO2_Reg;
    reg     SIO3_Reg;
    reg     Read_4XIO_Mode;
    reg     RDQIO_Mode;
    reg     RDDIO_Mode;
    reg     DTR_Mode;
    reg     READ4X_TOP_Mode;
    reg     READ4X_BOT_Mode;
    reg     READ4X4B_Mode;
    reg     Read_4XIO_Chk;
    reg     FastRD_2XIO_Mode;
    reg     FastRD_2XIO_Chk;
    reg     FastRD_4XIO_Mode;
    reg     FastRD_4XIO_Chk;
    reg     PP_4XIO_Mode;
    reg     PP_4XIO_Load;
    reg     PP_4XIO_Chk;
    reg     EN4XIO_Read_Mode;
    reg     EN2XIO_Read_Mode;
    reg     Set_4XIO_Enhance_Mode;   
    reg     Set_2XIO_Enhance_Mode;   
    reg	    WP_OUT_EN;   // for WP pin
    reg	    SIO3_OUT_EN; // for SIO3 pin
    reg	    WP_IN_EN;    // for WP pin
    reg	    SIO3_IN_EN;  // for SIO3 pin
    reg     ENQUAD;
    reg     During_RST_REC;
    reg     HOLD_EN;
    reg     HOLD_OUT_B;
    wire    HPM_RD;
  	wire    SIO3;
  	wire    RP_0000;
  	wire    RP_0001;
  	wire    RP_0010;
  	wire    RP_0011;
  	wire    RP_0100;
  	wire    RP_0101;
  	wire    RP_0110;
  	wire    RP_0111;
  	wire    RP_1000;
  	wire    RP_1001;
  	wire    RP_1010;
  	wire    RP_1011;
  	wire    RP_1100;
  	wire    RP_1101;
  	wire    RP_1110;
  	wire    RP_1111;
	assign	RP_0000 = !RPARAM[6] && !RPARAM[5] && !RPARAM[4] && !RPARAM[3];
	assign	RP_0001 = !RPARAM[6] && !RPARAM[5] && !RPARAM[4] && RPARAM[3];
	assign	RP_0010 = !RPARAM[6] && !RPARAM[5] && RPARAM[4] && !RPARAM[3];
	assign	RP_0011 = !RPARAM[6] && !RPARAM[5] && RPARAM[4] && RPARAM[3];
	assign	RP_0100 = !RPARAM[6] && RPARAM[5] && !RPARAM[4] && !RPARAM[3];
	assign	RP_0101 = !RPARAM[6] && RPARAM[5] && !RPARAM[4] && RPARAM[3];
	assign	RP_0110 = !RPARAM[6] && RPARAM[5] && RPARAM[4] && !RPARAM[3];
	assign	RP_0111 = !RPARAM[6] && RPARAM[5] && RPARAM[4] && RPARAM[3];
	assign	RP_1000 = RPARAM[6] && !RPARAM[5] && !RPARAM[4] && !RPARAM[3];
	assign	RP_1001 = RPARAM[6] && !RPARAM[5] && !RPARAM[4] && RPARAM[3];
	assign	RP_1010 = RPARAM[6] && !RPARAM[5] && RPARAM[4] && !RPARAM[3];
	assign	RP_1011 = RPARAM[6] && !RPARAM[5] && RPARAM[4] && RPARAM[3];
	assign	RP_1100 = RPARAM[6] && RPARAM[5] && !RPARAM[4] && !RPARAM[3];
	assign	RP_1101 = RPARAM[6] && RPARAM[5] && !RPARAM[4] && RPARAM[3];
	assign	RP_1110 = RPARAM[6] && RPARAM[5] && RPARAM[4] && !RPARAM[3];
	assign	RP_1111 = RPARAM[6] && RPARAM[5] && RPARAM[4] && RPARAM[3];

    /*----------------------------------------------------------------------*/
    /* initial variable value						    */
    /*----------------------------------------------------------------------*/
		initial 
			begin
				Chip_EN         = 1'b0;
				Status_Reg      = {`VStatus_Reg7_2,2'b00};
				FR_Reg          = {`FR_Default7_0};
				RPARAM_NV       = {`RP_Default7_0};
				exRPARAM_NV     = {`ERP_Default7_5,1'b1,3'b000,Status_Reg[0]};
				BAR_NV			= 8'h00;
//				BAR_NV			= {`BAR_Default7_0};
//				EN_Boot	     	= 1'b1;

				ASP_Reg			= 16'hFFFF;
				AB_Reg			= `VAB_Reg;
				Pwd_Reg			= 64'hFFFF_FFFF_FFFF_FFFF;
				PPBL_Reg		= ASP_Reg[2] ? 8'b0111_1111 : 8'b0111_1110;
				PPB_Reg_BOT0[15:0]		= 16'hffff;
				PPB_Reg_BOT1[15:0]		= 16'hffff;
				PPB_Reg_TOP511[15:0]	= 16'hffff;
				PPB_Reg_TOP510[15:0]	= 16'hffff;
				PPB_Reg					= ~1'b0;
				reset_sm;
			end   

		task reset_sm; 
			begin
				HOLD_EN			= 1'b1;
				HOLD_OUT_B		= 1'b1;
				During_RST_REC  = 1'b0;
				WRBAR_Mode		= 1'b0;
				WR_WPSEL_Mode   = 1'b0;
				SIO0_Reg        = 1'bx;
				SIO1_Reg        = 1'bx;
				SIO2_Reg        = 1'bx;
				SIO3_Reg        = 1'bx;
				RST_CMD_EN      = 1'b0;
				SGEN_55CMD_EN	= 1'b0;
				SGEN_AACMD_EN	= 1'b0;
				SGPPEN3_CMD_EN	= 1'b0;
				SGPPEN4_CMD_EN	= 1'b0;
				SGEREN3_CMD_EN	= 1'b0;
				SGEREN4_CMD_EN	= 1'b0;
				WREN_06CMD			= 1'b0;

				ENQUAD          = 1'b0;
				SO_OUT_EN	    = 1'b0; // SO output enable
				SI_IN_EN	    = 1'b0; // SI input enable
				CMD_BUS	    = 8'b0000_0000;
				Address	    = 0;
				i		    = 0;
				j		    = 0;
				Bit		    = 0;
				Bit_Tmp	    = 0;
				Start_Add	= 0;
				End_Add	    = 0;
				DP_Mode	    = 1'b0;
				SCLK_EN	    = 1'b1;
      
				DTR_Mode    	= 1'b0;
				Read_Mode	    = 1'b0;
				Read_1XIO_Mode  = 1'b0;
				Read_1XIO_Chk   = 1'b0;
				tDP_Chk         = 1'b0;
				tRES1_Chk       = 1'b0;
				tRES2_Chk       = 1'b0;

				AUTO_BOOT_Mode	= 1'b0;
				AUTO_BOOT_Chk	= 1'b0;

				RDJDID_Mode     = 1'b0;
				RDSR_Mode       = 1'b0;
				RDFR_Mode       = 1'b0;
				RDRP_Mode       = 1'b0;
				RDERP_Mode       = 1'b0;

				RDBAR_Mode		= 1'b0;
				RDASP_Mode		= 1'b0;
				RDABR_Mode		= 1'b0;

				RDPPBLK_Mode 	= 1'b0;
				RDPASS_Mode 	= 1'b0;
				RDPPB_Mode 		= 1'b0;
				RDDYB_Mode 		= 1'b0;

				EN4B_Mode 		= 1'b0;

				PP_1XIO_Mode    = 1'b0;
				SER_Mode	    = 1'b0;
				BE_Mode	    	= 1'b0;
				BE32K_Mode      = 1'b0;
				BE64K_Mode      = 1'b0;
				CE_Mode	    	= 1'b0;
				WRSR_Mode	    = 1'b0;
				WRFR_Mode	    = 1'b0;
				SRPNV_Mode	    = 1'b0;
				SERPNV_Mode	    = 1'b0;
				WRSR2_Mode      = 1'b0;

				WRASP_Mode		= 1'b0;
				WRPASS_Mode		= 1'b0;
				WRABR_Mode		= 1'b0;
				PASSULK_Mode	= 1'b0;
				WRPPB_Mode		= 1'b0;
				WRDYB_Mode		= 1'b0;
				SFRZ_Mode		= 1'b0;
				PPBLK_Mode		= 1'b0;
				ERPPB_Mode		= 1'b0;

				RDESID_Mode	    = 1'b0;
				RDMDID_Mode	    = 1'b0;
				Read_SHSL 	    = 1'b0;
				FastRD_1XIO_Mode  = 1'b0;
				FastRD_1XIO_Chk   = 1'b0;
				FastRD_2XIO_Mode  = 1'b0;
				FastRD_2XIO_Chk   = 1'b0;
				FastRD_4XIO_Mode  = 1'b0;
				FastRD_4XIO_Chk   = 1'b0;
				SI_OUT_EN	    = 1'b0; // SI output enable
				SO_IN_EN	    = 1'b0; // SO input enable
				SIR_Mode	    = 1'b0;
				SG_Mode		    = 1'b0;
				Read_2XIO_Mode  = 1'b0;
				Read_2XIO_Chk   = 1'b0;
				Byte_PGM_Mode   = 1'b0;
				WP_OUT_EN	    = 1'b0; // for WP pin output enable
				SIO3_OUT_EN	    = 1'b0; // for HOLD pin output enable
				WP_IN_EN	    = 1'b0; // for WP pin input enable
				SIO3_IN_EN	    = 1'b0; // for HOLD pin input enable
				Read_4XIO_Mode  = 1'b0;

				READ4X4B_Mode   = 1'b0;
				RDQIO_Mode    	= 1'b0;
				RDDIO_Mode    	= 1'b0;
				READ4X_TOP_Mode	= 1'b0;
				READ4X_BOT_Mode	= 1'b0;

				Read_4XIO_Chk   = 1'b0;
				PP_4XIO_Mode    = 1'b0;
				PP_4XIO_Load    = 1'b0;
				PP_4XIO_Chk     = 1'b0;
				EN4XIO_Read_Mode  = 1'b0;
				EN2XIO_Read_Mode  = 1'b0;
				Set_4XIO_Enhance_Mode = 1'b0;
				Set_2XIO_Enhance_Mode = 1'b0;
				RDSFDP_Mode = 1'b0;
				RDUNIQ_Mode = 1'b0;
				EN_Burst        = 1'b0;
				RPARAM         	= RPARAM_NV;
				exRPARAM       	= exRPARAM_NV;
				BAR         	= BAR_NV;
				A_Unlock		= 0;
				EN_SEUnlock		= 1'b0;
				sg_protect		= 1'b0;
				Burst_Length    = 8;
				Susp_Ready      = 1'b1;
				Susp_Trig       = 1'b0;
				Susp_Start      = 1'b0;
				ERS_CLK         = 1'b0;
				PGM_CLK         = 1'b0;
				WR2Susp         = 1'b0;
				EN_Boot	     	= 1'b1;

				ADD_4B_Mode = 1'b0;

				DYB_Reg_BOT0[15:0]		= 16'hffff;
				DYB_Reg_BOT1[15:0]		= 16'hffff;
				DYB_Reg_TOP511[15:0]	= 16'hffff;
				DYB_Reg_TOP510[15:0]	= 16'hffff;
				DYB_Reg					= ~1'b0;

  				ENDTR2XIO_Read_Mode = 1'b0;
  				ENDTR4XIO_Read_Mode = 1'b0;
  				DTRRead_1XIO_Mode   = 1'b0;
  				DTRRead_2XIO_Mode   = 1'b0;
  				DTRRead_4XIO_Mode   = 1'b0;
  				DTRRead_4XIO_ModeX  = 1'b0;
  				DTRRead_4XIO_Mode_4B = 1'b0;
  				DTR_Read_Mode_IN    = 1'b0;
  				Set_4XIO_DTR_Enhance_Mode = 1'b0;
  				Set_2XIO_DTR_Enhance_Mode = 1'b0;

			end
		endtask // reset_sm
    
    /*----------------------------------------------------------------------*/
    /* initial flash data    						    */
    /*----------------------------------------------------------------------*/
    initial 
    	begin : memory_initialize
				for ( i = 0; i <=  TOP_Add; i = i + 1 ) ARRAY[i] = 8'hff; 
				if ( Init_File != "none" ) $readmemh(Init_File,ARRAY) ;
				for( i = 0; i <=  SIR_TOP_Add; i = i + 1 ) SIR0_ARRAY[i]=8'hff;
        		if ( Init_File_SIR != "none" ) $readmemh(Init_File_SIR,SIR0_ARRAY) ;
				for( i = 0; i <=  SIR_TOP_Add; i = i + 1 ) SIR1_ARRAY[i]=8'hff;
        		if ( Init_File_SIR != "none" ) $readmemh(Init_File_SIR,SIR1_ARRAY) ;
				for( i = 0; i <=  SIR_TOP_Add; i = i + 1 ) SIR2_ARRAY[i]=8'hff;
        		if ( Init_File_SIR != "none" ) $readmemh(Init_File_SIR,SIR2_ARRAY) ;
				for( i = 0; i <=  SIR_TOP_Add; i = i + 1 ) SIR3_ARRAY[i]=8'hff;
        		if ( Init_File_SIR != "none" ) $readmemh(Init_File_SIR,SIR3_ARRAY) ;
				for( i = 0; i <=  SG_TOP_Add; i = i + 1 ) SG_ARRAY[i]=8'hff;
        		if ( Init_File_SG != "none" ) $readmemh(Init_File_SG,SG_ARRAY) ;
        for( i = 0; i <=  SFDP_TOP_Add; i = i + 1 ) SFDP_ARRAY[i] = 8'hff;

        // define SFDP code
        SFDP_ARRAY[8'h00] =  8'h53;
        SFDP_ARRAY[8'h01] =  8'h46;
        SFDP_ARRAY[8'h02] =  8'h44;
        SFDP_ARRAY[8'h03] =  8'h50;
        SFDP_ARRAY[8'h04] =  8'h06;
        SFDP_ARRAY[8'h05] =  8'h01;
        SFDP_ARRAY[8'h06] =  8'h01;
        SFDP_ARRAY[8'h07] =  8'hFF;
        SFDP_ARRAY[8'h08] =  8'h00;
        SFDP_ARRAY[8'h09] =  8'h06;
        SFDP_ARRAY[8'h0a] =  8'h01;
        SFDP_ARRAY[8'h0b] =  8'h10;
        SFDP_ARRAY[8'h0c] =  8'h30;
        SFDP_ARRAY[8'h0d] =  8'h00;
        SFDP_ARRAY[8'h0e] =  8'h00;
        SFDP_ARRAY[8'h0f] =  8'hff;
        SFDP_ARRAY[8'h10] =  8'h9d; // Manufacturer ID
        SFDP_ARRAY[8'h11] =  8'h05;
        SFDP_ARRAY[8'h12] =  8'h01;
        SFDP_ARRAY[8'h13] =  8'h03;
        SFDP_ARRAY[8'h14] =  8'h80;
        SFDP_ARRAY[8'h15] =  8'h00;
        SFDP_ARRAY[8'h16] =  8'h00;
        SFDP_ARRAY[8'h17] =  8'h02;
        SFDP_ARRAY[8'h18] =  8'hff;
        SFDP_ARRAY[8'h19] =  8'hff;
        SFDP_ARRAY[8'h1a] =  8'hff;
        SFDP_ARRAY[8'h1b] =  8'hff;
        SFDP_ARRAY[8'h1c] =  8'hff;
        SFDP_ARRAY[8'h1d] =  8'hff;
        SFDP_ARRAY[8'h1e] =  8'hff;
        SFDP_ARRAY[8'h1f] =  8'hff;
        SFDP_ARRAY[8'h20] =  8'hff;
        SFDP_ARRAY[8'h21] =  8'hff;
        SFDP_ARRAY[8'h22] =  8'hff;
        SFDP_ARRAY[8'h23] =  8'hff;
        SFDP_ARRAY[8'h24] =  8'hff;
        SFDP_ARRAY[8'h25] =  8'hff;
        SFDP_ARRAY[8'h26] =  8'hff;
        SFDP_ARRAY[8'h27] =  8'hff;
        SFDP_ARRAY[8'h28] =  8'hff;
        SFDP_ARRAY[8'h29] =  8'hff;
        SFDP_ARRAY[8'h2a] =  8'hff;
        SFDP_ARRAY[8'h2b] =  8'hff;
        SFDP_ARRAY[8'h2c] =  8'hff;
        SFDP_ARRAY[8'h2d] =  8'hff;
        SFDP_ARRAY[8'h2e] =  8'hff;
        SFDP_ARRAY[8'h2f] =  8'hff;
        SFDP_ARRAY[8'h30] =  8'hE5;
        SFDP_ARRAY[8'h31] =  8'h20;
        SFDP_ARRAY[8'h32] =  8'hF9;
        SFDP_ARRAY[8'h33] =  8'hff;
        SFDP_ARRAY[8'h34] =  8'hFF;	// Memory density
        SFDP_ARRAY[8'h35] =  8'hFF;	// Memory density
        SFDP_ARRAY[8'h36] =  8'hFF;	// Memory density
        SFDP_ARRAY[8'h37] =  8'h01;	// Memory density
        SFDP_ARRAY[8'h38] =  8'h44;
        SFDP_ARRAY[8'h39] =  8'hEB;
        SFDP_ARRAY[8'h3a] =  8'h08;
        SFDP_ARRAY[8'h3b] =  8'h6B;
        SFDP_ARRAY[8'h3c] =  8'h08;
        SFDP_ARRAY[8'h3d] =  8'h3B;
        SFDP_ARRAY[8'h3e] =  8'h80;
        SFDP_ARRAY[8'h3f] =  8'hBB;
        SFDP_ARRAY[8'h40] =  8'hFE;
        SFDP_ARRAY[8'h41] =  8'hff;
        SFDP_ARRAY[8'h42] =  8'hff;
        SFDP_ARRAY[8'h43] =  8'hff;
        SFDP_ARRAY[8'h44] =  8'hff;
        SFDP_ARRAY[8'h45] =  8'hff;
        SFDP_ARRAY[8'h46] =  8'h00;
        SFDP_ARRAY[8'h47] =  8'hff;
        SFDP_ARRAY[8'h48] =  8'hff;
        SFDP_ARRAY[8'h49] =  8'hff;
        SFDP_ARRAY[8'h4a] =  8'h44;
        SFDP_ARRAY[8'h4b] =  8'heb;
        SFDP_ARRAY[8'h4c] =  8'h0c;
        SFDP_ARRAY[8'h4d] =  8'h20;
        SFDP_ARRAY[8'h4e] =  8'h0f;
        SFDP_ARRAY[8'h4f] =  8'h52;
        SFDP_ARRAY[8'h50] =  8'h10;
        SFDP_ARRAY[8'h51] =  8'hd8;
        SFDP_ARRAY[8'h52] =  8'h00;
        SFDP_ARRAY[8'h53] =  8'hff;
        SFDP_ARRAY[8'h54] =  8'h43;
        SFDP_ARRAY[8'h55] =  8'h32;
        SFDP_ARRAY[8'h56] =  8'hA5;
        SFDP_ARRAY[8'h57] =  8'h00;
        SFDP_ARRAY[8'h58] =  8'h82;
        SFDP_ARRAY[8'h59] =  8'hD8;
        SFDP_ARRAY[8'h5a] =  8'h01;
        SFDP_ARRAY[8'h5b] =  8'hC1;	// Chip erase time
        SFDP_ARRAY[8'h5c] =  8'hEC;
        SFDP_ARRAY[8'h5d] =  8'h8D;
        SFDP_ARRAY[8'h5e] =  8'h69;
        SFDP_ARRAY[8'h5f] =  8'h4C;
        SFDP_ARRAY[8'h60] =  8'h7A;
        SFDP_ARRAY[8'h61] =  8'h75;
        SFDP_ARRAY[8'h62] =  8'h7A;
        SFDP_ARRAY[8'h63] =  8'h75;
        SFDP_ARRAY[8'h64] =  8'hF7;
        SFDP_ARRAY[8'h65] =  8'hA4;
        SFDP_ARRAY[8'h66] =  8'hD5;
        SFDP_ARRAY[8'h67] =  8'h5C;
        SFDP_ARRAY[8'h68] =  8'h4A;
        SFDP_ARRAY[8'h69] =  8'hC2;
        SFDP_ARRAY[8'h6a] =  8'h2C;
        SFDP_ARRAY[8'h6b] =  8'hff;
        SFDP_ARRAY[8'h6c] =  8'hE1;
        SFDP_ARRAY[8'h6d] =  8'h30;
        SFDP_ARRAY[8'h6e] =  8'h60;
        SFDP_ARRAY[8'h6f] =  8'h80;
        SFDP_ARRAY[8'h70] =  8'hFF;
        SFDP_ARRAY[8'h71] =  8'hFF;
        SFDP_ARRAY[8'h72] =  8'hFF;
        SFDP_ARRAY[8'h73] =  8'hFF;
        SFDP_ARRAY[8'h74] =  8'hFF;
        SFDP_ARRAY[8'h75] =  8'hFF;
        SFDP_ARRAY[8'h76] =  8'hFF;
        SFDP_ARRAY[8'h77] =  8'hFF;
        SFDP_ARRAY[8'h78] =  8'hFF;
        SFDP_ARRAY[8'h79] =  8'hFF;
        SFDP_ARRAY[8'h7a] =  8'hFF;
        SFDP_ARRAY[8'h7b] =  8'hFF;
        SFDP_ARRAY[8'h7c] =  8'hFF;
        SFDP_ARRAY[8'h7d] =  8'hFF;
        SFDP_ARRAY[8'h7e] =  8'hFF;
        SFDP_ARRAY[8'h7f] =  8'hFF;
        SFDP_ARRAY[8'h80] =  8'h50;	// Vcc max
        SFDP_ARRAY[8'h81] =  8'h19;	// Vcc max
        SFDP_ARRAY[8'h82] =  8'h50;	// Vcc min
        SFDP_ARRAY[8'h83] =  8'h16; // Vcc min
        SFDP_ARRAY[8'h84] =  8'h9F;
        SFDP_ARRAY[8'h85] =  8'hF9;
        SFDP_ARRAY[8'h86] =  8'hC0;
        SFDP_ARRAY[8'h87] =  8'h64;
        SFDP_ARRAY[8'h88] =  8'h8F;
        SFDP_ARRAY[8'h89] =  8'hEC;
        SFDP_ARRAY[8'h8a] =  8'hFF;
        SFDP_ARRAY[8'h8b] =  8'hFF;

// pragma protect end

        // define UNIQID code: NEED to be updated later !!!
        UNIQ_ARRAY[4'h0] =  8'hFF; 
        UNIQ_ARRAY[4'h1] =  8'hFF;
        UNIQ_ARRAY[4'h2] =  8'hFF;
        UNIQ_ARRAY[4'h3] =  8'hFF;
        UNIQ_ARRAY[4'h4] =  8'hFF;
        UNIQ_ARRAY[4'h5] =  8'hFF;
        UNIQ_ARRAY[4'h6] =  8'hFF;
        UNIQ_ARRAY[4'h7] =  8'hFF;
        UNIQ_ARRAY[4'h8] =  8'hFF;
        UNIQ_ARRAY[4'h9] =  8'hFF;
        UNIQ_ARRAY[4'hA] =  8'hFF;
        UNIQ_ARRAY[4'hB] =  8'hFF;
        UNIQ_ARRAY[4'hC] =  8'hFF;
        UNIQ_ARRAY[4'hD] =  8'hFF;
        UNIQ_ARRAY[4'hE] =  8'hFF;
        UNIQ_ARRAY[4'hF] =  8'hFF;

// pragma protect    
// pragma protect begin
  
    end

// *============================================================================================== 
// * Input/Output bus operation 
// *============================================================================================== 
    assign   CS_INT   = ( During_RST_REC == 1'b0 && RESETB_INT == 1'b1 ) ? CS : 1'b1;
    assign   WP_B_INT = (Status_Reg[6] == 1'b0 && ENQUAD == 1'b0) ? WP : 1'b1;
    assign   HOLD_B_INT = (RPARAM[7] == 1'b0 && Status_Reg[6] == 1'b0 && ENQUAD == 1'b0 && CS_INT == 1'b0 && DTR_Mode == 1'b0) ? (SIO3===1'bz ? 1'b1 : SIO3) : 1'b1;
    assign   RESETB_INT = (RPARAM[7] == 1'b1 && Status_Reg[6] == 1'b0 && ENQUAD == 1'b0) ? (SIO3===1'bz ? 1'b1 : SIO3) : 1'b1;
    assign   SO	    = (SO_OUT_EN && HOLD_OUT_B) ? SIO1_Reg : 1'bz ;
    assign   SI	    = (SI_OUT_EN && HOLD_OUT_B) ? SIO0_Reg : 1'bz ;
    assign   WP	    = (WP_OUT_EN && HOLD_OUT_B)   ? SIO2_Reg : 1'bz ;
    assign   SIO3   = (SIO3_OUT_EN && HOLD_OUT_B) ? SIO3_Reg : 1'bz ;

/*
`ifdef HWRST_PART
    assign   RESETB_INT = (SIO3 === 1'b1 || SIO3 === 1'b0) ? SIO3 : 1'b1;
`else
    assign   RESETB_INT = 1'b1;
`endif
*/

// *============================================================================================== 
// * Hold Condition opearation 
// *============================================================================================== 
	always @( HOLD_B_INT or negedge SCLK )
		begin
			if ( HOLD_B_INT == 1'b0 && SCLK == 1'b0)
				begin
					SCLK_EN = 1'b0;
				end
		  else if ( HOLD_B_INT == 1'b1 && SCLK == 1'b0 )
				begin
					SCLK_EN = 1'b1;
				end
		end

	always @( negedge HOLD_B_INT )		
		begin
			HOLD_OUT_B <= #tHZ 1'b0;
		end

	always @( posedge HOLD_B_INT )		
		begin
			HOLD_OUT_B <= #tLZ 1'b1;
		end
		

		always @(SCLK) begin
			SCLK_DTR = 1'b1;
			#3 SCLK_DTR = 1'b0;
		end
		assign SCLK_INT = DTR_Mode ? SCLK_DTR : (SCLK_EN == 1'b1 ? SCLK : 1'b0) ;

// *============================================================================================== 
// * Finite State machine to control Flash operation
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* power on              						    */
    /*----------------------------------------------------------------------*/
    initial begin 
	Chip_EN   <= #tVCE 1'b1;// Time delay to chip select allowed 
	@(posedge Chip_EN)
	reset_sm;
    end
    
    /*----------------------------------------------------------------------*/
    /* Command Decode        						    */
    /*----------------------------------------------------------------------*/
    assign ESB	    = FR_Reg[3] ;   	// ER Suspend
    assign PSB	    = FR_Reg[2] ;		// PGM Suspend
    assign EPSUSP   = ESB | PSB ;
    assign WIP	    = Status_Reg[0] ;
    assign WEL	    = Status_Reg[1] ;
    assign SRWD     = Status_Reg[7] ;
    assign Dis_CE   = Status_Reg[5] == 1'b1 || Status_Reg[4] == 1'b1 ||
                      Status_Reg[3] == 1'b1 || Status_Reg[2] == 1'b1;
    assign HPM_RD   = (EN4XIO_Read_Mode || EN2XIO_Read_Mode || ENDTR4XIO_Read_Mode || ENDTR2XIO_Read_Mode) ;  
    assign Norm_Array_Mode = ~SIR_Mode;
    assign Dis_WRSR = (WP_B_INT == 1'b0 && Status_Reg[7] == 1'b1);
    assign WPSEL_Mode = 1'b0; // need to rm
	assign DTR_Read_Mode = DTRRead_1XIO_Mode || DTRRead_2XIO_Mode || DTRRead_4XIO_Mode ;

    assign TBPARAM  = ASP_Reg[15] ; 	// Configures Parameter Sectors Location
    assign PWDMLB   = ASP_Reg[2] ; 		// Password Protection Mode Lock Bit
    assign PSTMLB   = ASP_Reg[1] ; 		// Persistent Protection Mode Lock Bit
    assign PPBLB    = PPBL_Reg[0]; 		// PPB lock Bit
    assign FRZB		= PPBL_Reg[7]; 		// FREEZE Bit

	assign ABE		= AB_Reg[0];

	assign SEC_Pro_Reg_TOP511	= PPB_Reg_TOP511 & DYB_Reg_TOP511 ;
	assign SEC_Pro_Reg_TOP510	= PPB_Reg_TOP510 & DYB_Reg_TOP510 ;
	assign SEC_Pro_Reg_BOT0		= PPB_Reg_BOT0 & DYB_Reg_BOT0 ;
	assign SEC_Pro_Reg_BOT1		= PPB_Reg_BOT1 & DYB_Reg_BOT1 ;
	assign SEC_Pro_Reg			= PPB_Reg & DYB_Reg ;


  always @ ( negedge CS_INT ) begin
		if ( !EN_Boot || !ABE ) begin
    	SI_IN_EN = 1'b1;
		end 
    if ( ENQUAD ) begin
      SO_IN_EN    = 1'b1;
      SI_IN_EN    = 1'b1;
      WP_IN_EN    = 1'b1;
      SIO3_IN_EN  = 1'b1;
		end
		if ( EN4XIO_Read_Mode == 1'b1 ) begin
	    //$display( $time, " Enter READX4 Function ..." );
      Read_SHSL = 1'b1;
	    STATE   <= `CMD_STATE;
	    Read_4XIO_Mode = 1'b1; 
		end

	if ( ENDTR4XIO_Read_Mode == 1'b1 ) 
	  begin
    	//$display( $time, " Enter DTR READX4 Function ..." );
        Read_SHSL = 1'b1;
    	STATE   <= `CMD_STATE;
    	DTRRead_4XIO_Mode = 1'b1;
        #1 DTR_Read_Mode_IN = 1'b1;
	  end

		if ( EN2XIO_Read_Mode == 1'b1 ) begin
	    //$display( $time, " Enter READX2 Function ..." );
      Read_SHSL = 1'b1;
	    STATE   <= `CMD_STATE;
	    Read_2XIO_Mode = 1'b1; 
		end

	if ( ENDTR2XIO_Read_Mode == 1'b1 ) 
	  begin
    	//$display( $time, " Enter DTR READX2 Function ..." );
        Read_SHSL = 1'b1;
    	STATE   <= `CMD_STATE;
    	DTRRead_2XIO_Mode = 1'b1;
        #1 DTR_Read_Mode_IN = 1'b1;
	  end

		if ( HPM_RD == 1'b0 ) begin
      Read_SHSL <= #1 1'b0;   
		end
    #1;
    //tDP_Chk = 1'b0;
    //tRES1_Chk = 1'b0;
    tRES2_Chk = 1'b0;
 	end // always

	always @ ( negedge SCLK or posedge CS_INT ) 
	  begin
    	if ( CS_INT == 1'b0 && DTR_Read_Mode == 1'b1 ) 
		  begin
        	#1 DTR_Read_Mode_IN = 1'b1;
    	  end
    	else 
		  begin
        	DTR_Read_Mode_IN = 1'b0;
    	  end
	  end

	always @ ( negedge SCLK or posedge CS_INT ) 
	  begin
		if ( CS_INT == 1'b0 && DTR_Read_Mode_IN == 1'b1 ) 
		  begin
			if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) 
			  begin
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[27:0], SIO3, WP, SO, SI} : {8'b0, SI_Reg[19:0], SIO3, WP, SO, SI};
			  end
			else  if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 ) 
			  begin
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[29:0], SO, SI} : {8'b0, SI_Reg[21:0], SO, SI};
			  end
			else 
			  begin
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[30:0], SI} : {8'b0, SI_Reg[22:0], SI};
			  end
			if ((( (ENDTR4XIO_Read_Mode == 1'b1 && Bit == 2 && !ENQUAD) ||
			       (ENDTR4XIO_Read_Mode == 1'b1 && Bit == 11 && ENQUAD) ||
				   (ENDTR2XIO_Read_Mode == 1'b1 && Bit == 5 ) ||
			       (DTRRead_1XIO_Mode == 1'b1 && Bit == 19 ) ||
			       (DTRRead_2XIO_Mode == 1'b1 && Bit == 13 && ENDTR2XIO_Read_Mode == 1'b0) ||
			       (DTRRead_4XIO_Mode == 1'b1 && Bit == 10 && ENDTR4XIO_Read_Mode == 1'b0 && !ENQUAD) ||
			       (DTRRead_4XIO_Mode == 1'b1 && Bit == 19 && ENDTR4XIO_Read_Mode == 1'b0 && ENQUAD)) && !BAR[7] && !ADD_4B_Mode) ||
			    (( (ENDTR4XIO_Read_Mode == 1'b1 && Bit == 3 && !ENQUAD) ||
			       (ENDTR4XIO_Read_Mode == 1'b1 && Bit == 15 && ENQUAD) ||
			       (ENDTR2XIO_Read_Mode == 1'b1 && Bit == 7 ) ||
			       (DTRRead_1XIO_Mode == 1'b1 && Bit == 23 ) ||
			       (DTRRead_2XIO_Mode == 1'b1 && Bit == 15 && ENDTR2XIO_Read_Mode == 1'b0 ) ||
			       (DTRRead_4XIO_Mode == 1'b1 && Bit == 11 && ENDTR4XIO_Read_Mode == 1'b0 && !ENQUAD) ||
			       (DTRRead_4XIO_Mode == 1'b1 && Bit == 23 && ENDTR4XIO_Read_Mode == 1'b0 && ENQUAD)) && (BAR[7] || ADD_4B_Mode)) ) 
			  begin
				Address = SI_Reg [A_MSB:0];
				if ( !BAR[7] && !ADD_4B_Mode ) 
				  begin
					//Address [24] = BAR[0];
				  end
				load_address(Address);
			  end
		  end
	  end

	always @ ( posedge SCLK or posedge CS_INT ) 
	  begin
		if ( CS_INT == 1'b0 && DTR_Read_Mode_IN == 1'b1 && ENDTR4XIO_Read_Mode == 1'b1 ) 
		  begin
			if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) 
			  begin
				SI_Reg_DTR[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg_DTR[27:0], SIO3, WP, SO, SI} : {8'b0, SI_Reg_DTR[19:0], SIO3, WP, SO, SI};
			  end
		  end
		else 
		  begin
			SI_Reg_DTR[31:0] = 32'h0000_0000;
		  end
	  end


	always @ ( posedge SCLK or posedge CS_INT ) 
	  begin
		if ( CS_INT == 1'b0 && DTR_Read_Mode_IN == 1'b1 && ENDTR2XIO_Read_Mode == 1'b1 ) 
		  begin
			if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b0 && SIO3_IN_EN == 1'b0 ) 
			  begin
				SI_Reg_DTR[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg_DTR[29:0], SO, SI} : {8'b0, SI_Reg_DTR[21:0], SO, SI};
			  end
		  end
		else 
		  begin
			SI_Reg_DTR[31:0] = 32'h0000_0000;
		  end
	  end


	always @ ( posedge SCLK_INT or posedge CS_INT ) 
	  begin
  		#0;  
		if ( CS_INT == 1'b0 ) 
		  begin
    		if ( ENQUAD ) 
			  begin
      			Bit_Tmp = Bit_Tmp + 4;
      			Bit     = Bit_Tmp - 1;
      		  end // ENQUAD
      		else 
			  begin
        		Bit_Tmp = Bit_Tmp + 1;
        		Bit     = Bit_Tmp - 1;
      		  end // else
	    	if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 && WP_IN_EN == 1'b1 && SIO3_IN_EN == 1'b1 ) 
			  begin
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[27:0], SIO3, WP, SO, SI} : {8'b0, SI_Reg[19:0], SIO3, WP, SO, SI};
	   		  end 
	    	else  if ( SI_IN_EN == 1'b1 && SO_IN_EN == 1'b1 ) 
			  begin
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[29:0], SO, SI} : {8'b0, SI_Reg[21:0], SO, SI};
	    	  end
	    	else if ( SI_IN_EN == 1'b1 ) 
			  begin 
				SI_Reg[31:0] = ( BAR[7] || ADD_4B_Mode ) ? {SI_Reg[30:0], SI} : {8'b0, SI_Reg[22:0], SI};
	    	  end

	    	if ( (EN4XIO_Read_Mode == 1'b1 && ((Bit == 5 && !ENQUAD && !BAR[7] && !ADD_4B_Mode ) || (Bit == 23 && ENQUAD && !BAR[7] && !ADD_4B_Mode ))) ) 
			  begin
          		Address = SI_Reg[A_MSB:0];
				//Address[24] = BAR[0];
         		load_address(Address);
	   		  end
	    	else if ( (EN4XIO_Read_Mode == 1'b1 && ((Bit == 7 && !ENQUAD && ( BAR[7] || ADD_4B_Mode )) || (Bit == 31 && ENQUAD && ( BAR[7] || ADD_4B_Mode )))) ) 
			  begin
      			Address = SI_Reg[A_MSB:0];
      			load_address(Address);
	    	  end  

	    	if ( (EN2XIO_Read_Mode == 1'b1) && ((Bit == 11 && !ENQUAD && !BAR[7] && !ADD_4B_Mode )) ) 
			  begin
          		Address = SI_Reg[A_MSB:0];
          		//Address[24] = BAR[0];
         		load_address(Address);
	   		  end
			else if ( (EN2XIO_Read_Mode == 1'b1) && ((Bit == 15 && !ENQUAD && ( BAR[7] || ADD_4B_Mode ))) )
			  begin
          		Address = SI_Reg[A_MSB:0];
         		load_address(Address);
			  end
		  end	// CS_INT == 1'b0
  
		if ( Bit == 7 && CS_INT == 1'b0 && ~HPM_RD && ( !EN_Boot || !ABE ) ) 
		  begin
	    	STATE = `CMD_STATE;
	    	CMD_BUS = SI_Reg[7:0];
	    	//$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
      		if ( During_RST_REC ) 
			  $display ($time," During reset recovery time, there is command. \n");
		  end

		if ( CS_INT == 1'b0 && ~HPM_RD && ( EN_Boot && ABE ) )
		  begin
			STATE = `AUTO_BOOT_STATE;
			if ( During_RST_REC )
			  $display ($time," During reset recovery time, there is command. \n");
		  end			

        if ( (EN4XIO_Read_Mode && (Bit == 1 || (ENQUAD && Bit==7))) && CS_INT == 1'b0
             && HPM_RD && (SI_Reg[7:0]== RSTEN || SI_Reg[7:0]== RST)) 
		  begin
            CMD_BUS = SI_Reg[7:0];
            //$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
          end

        if ( (ENDTR4XIO_Read_Mode && (Bit == 1 || (ENQUAD && Bit==7))) && CS_INT == 1'b0
             && HPM_RD && (SI_Reg_DTR[7:0]== RSTEN || SI_Reg_DTR[7:0]== RST)) 
		  begin
            CMD_BUS = SI_Reg_DTR[7:0];
            //$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
          end

        if ( CS == 1'b1 && RST_CMD_EN &&
             ( (Bit+1)%8 == 0 || ((EN4XIO_Read_Mode||ENDTR4XIO_Read_Mode) && !ENQUAD && (Bit+1)%2 == 0) ) ) 
		  begin
            RST_CMD_EN <= #1 1'b0;
    	  end

        if ( (ENDTR4XIO_Read_Mode && (Bit == 7 )) && CS_INT == 1'b0
             && HPM_RD && (SI_Reg_DTR[7:0]== RSTEN || SI_Reg_DTR[7:0]== RST)) 
		  begin
            CMD_BUS = SI_Reg_DTR[7:0];
            //$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
          end

        if ( CS == 1'b1 && RST_CMD_EN &&
             ( (Bit+1)%8 == 0 || ((EN2XIO_Read_Mode||ENDTR2XIO_Read_Mode) && !ENQUAD && (Bit+1)%4 == 0) ) ) 
		  begin
            RST_CMD_EN <= #1 1'b0;
    	  end




		case ( STATE )
	    `STANDBY_STATE: 
	        begin
	        end

		`AUTO_BOOT_STATE:
		  begin
			Read_SHSL = 1'b1;
			AUTO_BOOT_Mode = 1'b1;
		  end

	    `CMD_STATE: 
	      begin
			if ( (CS_INT == 1'b1) && (Bit == 7) && RST_CMD_EN ) 
			  begin
              	RST_CMD_EN <= #1 1'b0;
	   	  	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGEN_55CMD_EN ) 
			  begin
              	SGEN_55CMD_EN <= #1 1'b0;
	    	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGEN_AACMD_EN ) 
			  begin
              	SGEN_AACMD_EN <= #1 1'b0;
	    	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGPPEN3_CMD_EN ) 
			  begin
              	SGPPEN3_CMD_EN <= #1 1'b0;
	    	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGEREN3_CMD_EN ) 
			  begin
              	SGEREN3_CMD_EN <= #1 1'b0;
	    	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGPPEN4_CMD_EN ) 
			  begin
              	SGPPEN4_CMD_EN <= #1 1'b0;
	    	  end
	        else if ( (CS_INT == 1'b1) && (Bit == 7) && SGEREN4_CMD_EN ) 
			  begin
            	SGEREN4_CMD_EN <= #1 1'b0;
	    	  end


			case ( CMD_BUS ) 
  				WREN: 
	    		  begin
	    		 	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
	    			if ( CS_INT == 1'b1 && Bit == 7 ) begin	
	    				// $display( $time, " Enter Write Enable Function ..." );
	    			   	write_enable;
						WREN_06CMD = 1'b1;
	    			end
	    			else if ( Bit > 7 ) STATE <= `BAD_CMD_STATE; 
	    		   	end 
	    		   	else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE; 
	    			end
		     
	    	    		WRDI:   
	    						begin
	                  if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
	                  	if ( CS_INT == 1'b1 && Bit == 7 ) begin	
	    			    				// $display( $time, " Enter Write Disable Function ..." );
	    			    				write_disable;
												WREN_06CMD = 1'b0;
	                    end
	                    else if ( Bit > 7 ) STATE <= `BAD_CMD_STATE; 
	    		    			end 
	                  else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE; 
	    						end 

                RDJDID:
                	begin
                  	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
                  	//if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                    	//$display( $time, " Enter Read ID Function ..." );
                      Read_SHSL = 1'b1;
                      RDJDID_Mode = 1'b1;
                    end
                    else if ( Bit == 7 )
                    STATE <= `BAD_CMD_STATE;
                  end

/*
					EN4B:
					  begin
						if ( !DP_Mode && !WIP && Chip_EN )
						  begin
							if ( CS_INT == 1'b1 && Bit == 7 )
							  begin
								//$display( $time, " Enter 4-byte mode ..." );
								BAR[7] <= 1'b1;
								EN4B_Mode <= 1'b1;
						  	  end
							else if ( Bit > 7 )
								STATE <= `BAD_CMD_STATE;
						  end
						else if ( Bit == 7 )
							STATE <= `BAD_CMD_STATE;
					  end 		
*/
/*
					EX4B:
					  begin
						if ( !DP_Mode && !WIP && Chip_EN )
						  begin
							if ( CS_INT == 1'b1 && Bit == 7 )
							  begin
								//$display( $time, " Exit 4-byte mode ..." );
								BAR[7] <= 1'b0;
								EN4B_Mode <= 1'b0;
						  	  end
							else if ( Bit > 7 )
								STATE <= `BAD_CMD_STATE;
						  end
						else if ( Bit == 7 )
							STATE <= `BAD_CMD_STATE;
					  end 		
*/

                   QPIID:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && ENQUAD ) begin
                                //$display( $time, " Enter Read ID Function ..." );
                                Read_SHSL = 1'b1;
                                RDJDID_Mode = 1'b1;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

                      
	            RDSR:
	    						begin 
	    		    			if ( !DP_Mode && Chip_EN && ~HPM_RD) begin 
	    								//$display( $time, " Enter Read Status Function ..." );
                      Read_SHSL = 1'b1;
	    								RDSR_Mode = 1'b1 ;
                    end
	    		    			else if ( Bit == 7 )
	    								STATE <= `BAD_CMD_STATE; 	
	    						end

              RDFR:
                  begin
                  	if ( !DP_Mode && Chip_EN && ~HPM_RD) begin
                    //$display( $time, " Enter Read Function Register..." );
                    Read_SHSL = 1'b1;
                    RDFR_Mode = 1'b1 ;
                    end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
           
				RDRP:
                  begin
              		if ( !DP_Mode && Chip_EN && ~HPM_RD) 
					  begin
                    	//$display( $time, " Enter Read Function Register..." );
                    	Read_SHSL = 1'b1;
                    	RDRP_Mode = 1'b1 ;
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
           
				RDERP:
                  begin
              		if ( !DP_Mode && Chip_EN && ~HPM_RD) 
					  begin
                    	//$display( $time, " Enter Read Function Register..." );
                    	Read_SHSL = 1'b1;
                    	RDERP_Mode = 1'b1 ;
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
           
	            WRSR:
	    					begin
	    		    		if ( !DP_Mode && !WIP && (WEL && WREN_06CMD) && Chip_EN && ~HPM_RD && !EPSUSP ) begin
	    							if ( CS_INT == 1'b1 && Bit == 15 ) begin
                    	if ( Dis_WRSR ) begin 
	    			    				$display( $time, " SR is protected and no entry to Write Status Function ..." ); 
                      	//Status_Reg[1] = 1'b0; 
				    					end
				    					else begin
	    			    				//$display( $time, " Enter Write Status Function ..." ); 
	    			    				->WRSR_Event;
	    			    				WRSR_Mode = 1'b1;
		                  end	
	    							end    
                    else if ( CS_INT == 1'b1 && (Bit != 15) ) STATE <= `BAD_CMD_STATE;
	    		    			end
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    					end 
           
	            WRFR:
	    					begin
	    		    		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) begin
	    							if ( CS_INT == 1'b1 && Bit == 15 ) begin
	    			  				//$display( $time, " Enter Write Function Register Function ..." ); 
	    			    			->WRFR_Event;
	    			    			WRFR_Mode = 1'b1;
	    							end    
                    else if ( CS_INT == 1'b1 && (Bit != 15) ) STATE <= `BAD_CMD_STATE;
	    		    			end
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    					end 
                      
				SRPNV:
	    		  begin
	    		 	if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
	    				if ( CS_INT == 1'b1 && Bit == 15 ) 
						  begin
	    			  		//$display( $time, " Enter Write Function Register Function ..." ); 
	    			   		->SRPNV_Event;
	    			   		SRPNV_Mode = 1'b1;
	    				  end    
                    	else if ( CS_INT == 1'b1 && (Bit != 15) ) 
							STATE <= `BAD_CMD_STATE;
	    		   	  end
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end 
                      
				SERPNV:
	    		  begin
	    		 	if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
	    				if ( CS_INT == 1'b1 && Bit == 15 ) 
						  begin
	    			  		//$display( $time, " Enter Write Function Register Function ..." ); 
	    			   		->SERPNV_Event;
	    			   		SERPNV_Mode = 1'b1;
	    				  end    
                    	else if ( CS_INT == 1'b1 && (Bit != 15) ) 
							STATE <= `BAD_CMD_STATE;
	    		   	  end
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end 
                      
			SRPV1, SRPV2:
           	  begin
               	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) // no WEL required
				  begin 
                  	if ( CS_INT == 1'b1 && Bit == 15 ) 
					  begin
                    	//$display( $time, " Enter Set Read Parameter Function ..." );
                      	RPARAM_V[7:0] = SI_Reg[7:0];
                      	RPARAM[7:0] = RPARAM_V[7:0];
					  end
                    else if ( CS_INT == 1'b1 && Bit < 15 || Bit > 15 ) 
						STATE <= `BAD_CMD_STATE;
                  end
				else if ( Bit == 7 ) 
					STATE <= `BAD_CMD_STATE;
			  end
                      
			SERPV:
			  begin
				if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) // no WEL required
				  begin
                  	if ( CS_INT == 1'b1 && Bit == 15 ) 
					  begin
                    	//$display( $time, " Enter Set Extended Read Parameter Function ..." );
                      	exRPARAM_V[7:5] = SI_Reg[7:5];
                      	exRPARAM[7:5] = exRPARAM_V[7:5];
					  end
                    else if ( CS_INT == 1'b1 && Bit < 15 || Bit > 15 ) 
						STATE <= `BAD_CMD_STATE;
                  end
				else if ( Bit == 7 ) 
					STATE <= `BAD_CMD_STATE;
			  end
                      
			SEUNLOCK_DIS:
			  begin
              	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
				  begin 
                  	if ( CS_INT == 1'b1 && Bit == 7 ) 
					  begin
                    	//$display( $time, " Disable Sector Unlock ..." );
                      	EN_SEUnlock = 1'b0;
					  end
                    else if ( CS_INT == 1'b1 && Bit != 7 ) 
						STATE <= `BAD_CMD_STATE;
                  end
				else if ( Bit == 7 ) 
					STATE <= `BAD_CMD_STATE;
			  end
                      
			SEUNLOCK:
           	  begin
               	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
				  begin 
	    			if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
					  begin
                    	A_Unlock = SI_Reg [A_MSB:0];
						if ( !BAR[7] )
						  begin
							//A_Unlock[24] = BAR[0];
						  end	
						else
						  begin
							ADD_4B_Mode = 1'b1 ;
						  end
					  end
                  	if ( CS_INT == 1'b1 && ((Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7])) ) 
					  begin
                    	//$display( $time, " Enable Sector Unlock ..." );
                      	EN_SEUnlock = 1'b1;
					  end
                    else if ( (CS_INT == 1'b1) && ((Bit != 31 && !BAR[7]) || (Bit != 39 && BAR[7])) ) 
						STATE <= `BAD_CMD_STATE;
                  end
				else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
			  end

/*
			SEUNLOCK4B:
           	  begin
               	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
				  begin 
					ADD_4B_Mode = 1'b1;
	    			if ( Bit == 39 ) 
					  begin
                    	A_Unlock = SI_Reg [A_MSB:0];
					  end
                  	if ( CS_INT == 1'b1 && Bit == 39 ) 
					  begin
                    	//$display( $time, " Enable Sector Unlock ..." );
                      	EN_SEUnlock = 1'b1;
					  end
                    else if ( CS_INT == 1'b1 && Bit != 39 ) 
						STATE <= `BAD_CMD_STATE;
                  end
				else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
			  end
*/

	            NORREAD1X: 
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
						//$display( $time, " Enter Normal Read Data Function ..." );
						Read_SHSL = 1'b1;
						if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
	                  		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] ) 
							  begin
								//Address [24] = BAR[0];
							  end
	                  		load_address(Address);
						  end
						Read_1XIO_Mode = 1'b1;
					  end	
					else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;				
				  end

/*
				READ4B:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD )
					  begin
						//$display( $time, " Enter Read Data Function ..." );
						Read_SHSL = 1'b1;
						if  ( Bit == 39 ) 
						  begin
							Address = SI_Reg [A_MSB:0];
							load_address(Address);
						  end
						Read_1XIO_Mode = 1'b1;
						ADD_4B_Mode = 1'b1;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/

	            FASTREAD1X:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
					  begin
						//$display( $time, " Enter Fast Read Data Function ..." );
						Read_SHSL = 1'b1;
						if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] )
							  begin
								//Address [24] = BAR[0];
							  end
                    		load_address(Address);
						  end
                    	if (ENQUAD) begin Read_4XIO_Mode = 1'b1; end
                    	else begin FastRD_1XIO_Mode = 1'b1; end
					  end	
					else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;				
				  end

/*
				FASTREAD4B:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD )
					  begin
						//$display( $time, " Enter Fast Read Data Function ..." );
						Read_SHSL = 1'b1;
						if ( Bit == 39 )
						  begin
							Address = SI_Reg [A_MSB:0];
							load_address(Address);
						  end
                    	if (ENQUAD) begin Read_4XIO_Mode = 1'b1; end
                    	else begin FastRD_1XIO_Mode = 1'b1; end
						ADD_4B_Mode = 1'b1;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/

/*
	            FASTREAD1X_DTR:
	    					begin
	    		    		if ( (CS_INT == 1'b0) && !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
										begin
	    								//$display( $time, " Enter Fast Read Data Function ..." );
                    	Read_SHSL = 1'b1;
	    								if ( Bit == 31 ) 
												begin
                    			Address = SI_Reg [A_MSB:0];
                    			load_address(Address);
	    									end
											wait (~SCLK) ; 
											DTR_Mode = 1'b1;
                    	if (ENQUAD) 
												begin 
													Read_4XIO_Mode = 1'b1; 
												end
                    	else 
												begin 
													FastRD_1XIO_Mode = 1'b1; 
												end
	    		    			end	
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;				
	    					end
*/

	            SE1,SE2: 
	  			  begin
	    		 	if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
	    				if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] ) 
							  begin
								//Address[24] = BAR[0];
							  end
						  end
	    				if ( CS_INT == 1'b1 && ((Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7])) ) 
						  begin
	    			   		//$display( $time, " Enter Sector Erase Function ..." );
	    			   		->SER_Event;
	    			   		SER_Mode = 1'b1;
	    				  end
	    				else if ( CS_INT == 1'b1 && ((Bit != 31 && !BAR[7]) || (Bit != 39 && BAR[7])) )
	                  		STATE <= `BAD_CMD_STATE;
	    		   	  end
	    			else if ( Bit == 7 )
	    				STATE <= `BAD_CMD_STATE;
	    		  end

/*
				SE4B:
				  begin
					if ( !DP_Mode && !WIP && WEL && WREN_06CMD &&  Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
						ADD_4B_Mode = 1'b1;
						if ( Bit == 39 ) 
						  begin
							Address = SI_Reg [A_MSB:0];
						  end
						if ( CS_INT == 1'b1 && Bit == 39 ) 
						  begin
							//$display( $time, " Enter Sector Erase Function ..." );
							->SER_Event;
							SER_Mode = 1'b1;
						  end
						else if ( CS_INT == 1'b1 && Bit != 39 )
							STATE <= `BAD_CMD_STATE;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/


	            IRER: 
	    					begin
	    		    		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) begin
	    							if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
										end
	    							if ( CS_INT == 1'b1 && (Bit == 31) ) begin
	    			    			//$display( $time, " Enter Sector Erase Function ..." );
	    			    			->SER_Event;
	    			    			SER_Mode = 1'b1;
											SIR_Mode = 1'b1;
	    							end
	    							else if ( CS_INT == 1'b1 && (Bit != 31) )
	                  	STATE <= `BAD_CMD_STATE;
	    		    		end
	    		    		else if ( Bit == 7 )
	    							STATE <= `BAD_CMD_STATE;
	    					end

  
	            SGER: 
				  begin
	    		 	if ( !DP_Mode && !WIP && ((WEL && WREN_06CMD) ||SGEREN4_CMD_EN) && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
//	    				if ( Bit == 31 ) 
//						  begin
//                   		Address = SI_Reg [A_MSB:0];
//						  end
	    				if ( CS_INT == 1'b1 && (Bit == 7) ) 
						  begin
							SGEREN4_CMD_EN = 1'b0 ;
	    			   		Address = 24'h000000;
	    			   		//$display( $time, " Enter SafeGuard Erase Function ..." );
	    			   		->SER_Event;
	    			   		SER_Mode = 1'b1;
							SG_Mode = 1'b1;
	    				  end
	    				else if ( Bit > 7 )
	                  		STATE <= `BAD_CMD_STATE;
	    		   	  end
	    		   	else if ( Bit == 7 )
	    				STATE <= `BAD_CMD_STATE;
	    		  end
  
			SGPER_55:
			  begin
              	if ( !DP_Mode && Chip_EN && ~HPM_RD ) 
				  begin
                 	if ( CS_INT == 1'b1 && Bit == 31 ) 
					  begin
                   		//$display( $time, " SR write enable 1st..." );
				   		->SGPER_EN1_Event;
                   	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
              	  end
				else if ( Bit == 7 )
               		STATE <= `BAD_CMD_STATE;
          	  end

			SGPER_AA:
           	  begin
              	if ( !DP_Mode && Chip_EN && ~HPM_RD && SGEN_55CMD_EN ) 
				  begin
                 	if ( CS_INT == 1'b1 && Bit == 31 ) 
					  begin
                   		//$display( $time, " SR write enable 2nd..." );
				   		->SGPER_EN2_Event;
                   	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
               	  end
               	else if ( !DP_Mode && Chip_EN && ~HPM_RD && SGPPEN3_CMD_EN ) 
				  begin
                	if ( CS_INT == 1'b1 && Bit == 31 ) 
			 		  begin
                    	//$display( $time, " SGPP enable ..." );
				 		->SGPP_EN4_Event;
                	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
              	  end
               	else if ( !DP_Mode && Chip_EN && ~HPM_RD && SGEREN3_CMD_EN ) 
				  begin
               		if ( CS_INT == 1'b1 && Bit == 31 ) 
					  begin
                 		//$display( $time, " SGER enable ..." );
				   		->SGER_EN4_Event;
                   	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
              	  end
                else if ( Bit == 7 )
               		STATE <= `BAD_CMD_STATE;
           	  end

			SGPPEN3:
           	  begin
               	if ( !DP_Mode && Chip_EN && ~HPM_RD && SGEN_AACMD_EN ) 
				  begin
                 	if ( CS_INT == 1'b1 && Bit == 31 ) 
					  begin
                   		//$display( $time, " SR write enable 1st..." );
				   		->SGPP_EN3_Event;
                   	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
              	  end
                else if ( Bit == 7 )
               		STATE <= `BAD_CMD_STATE;
          	  end

            SGEREN3:
           	  begin
              	if ( !DP_Mode && Chip_EN && ~HPM_RD && SGEN_AACMD_EN ) 
				  begin
                 	if ( CS_INT == 1'b1 && Bit == 31 ) 
					  begin
                  		//$display( $time, " SR write enable 1st..." );
				   		->SGER_EN3_Event;
                   	  end
                   	else if ( CS_INT == 1'b1 && Bit != 31 )
                   		STATE <= `BAD_CMD_STATE;
              	  end
                else if ( Bit == 7 )
               		STATE <= `BAD_CMD_STATE;
         	  end


	            BE64K: 
	    		  begin
	    	   		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
	    				if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] ) 
							  begin
								//Address [24] = BAR[0];
							  end
						  end
	    				if ( (CS_INT == 1'b1) && ((Bit == 31 && !BAR[7]) || (Bit ==39 && BAR[7])) ) 
						  begin
	    			   		//$display( $time, " Enter Block Erase Function ..." );
	    			   		->BE_Event;
	    	    			BE_Mode = 1'b1;
                      		BE64K_Mode = 1'b1;
	    				  end
	    				else if ( (CS_INT == 1'b1) && ((Bit != 31 && !BAR[7]) || (Bit != 39 && BAR[7])) ) 
							STATE <= `BAD_CMD_STATE;
	    		   	  end 
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end

/*
	            BE64K4B: 
	    		  begin
	    	   		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
					  begin
						ADD_4B_Mode = 1'b1;
	    				if ( Bit == 39 ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
						  end
	    				if ( CS_INT == 1'b1 && Bit == 39 ) 
						  begin
	    			   		//$display( $time, " Enter Block Erase Function ..." );
	    			   		->BE_Event;
	    	    			BE_Mode = 1'b1;
                      		BE64K_Mode = 1'b1;
	    				  end
	    				else if ( (CS_INT == 1'b1) && (Bit != 39 ) ) 
							STATE <= `BAD_CMD_STATE;
	    		   	  end 
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end
*/

					BE32K:
					  begin
               			if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
						  begin
	    					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
							  begin 
								Address = SI_Reg [A_MSB:0]; 
								if ( !BAR[7] )
								  begin
									//Address[24] = BAR[0];
								  end
							  end
	    					if ( (CS_INT == 1'b1) && ((Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7])) ) 
							  begin
                    			//$display( $time, " Enter Block 32K Erase Function ..." );
                    			->BE32K_Event;
                   				BE_Mode = 1'b1;
                    			BE32K_Mode = 1'b1;
                  			  end
	    					else if ( CS_INT == 1'b1 && ((Bit != 31 && !BAR[7]) || (Bit != 39 && BAR[7])) ) 
								STATE <= `BAD_CMD_STATE;
						  end
                    	else if ( Bit == 7 ) 
							STATE <= `BAD_CMD_STATE;
					  end

/*
					BE32K4B:
					  begin
               			if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
						  begin
							ADD_4B_Mode = 1'b1;
	    					if ( Bit == 39 ) 
							  begin 
								Address = SI_Reg [A_MSB:0]; 
							  end
	    					if ( (CS_INT == 1'b1) && (Bit == 39 ) ) 
							  begin
                    			//$display( $time, " Enter Block 32K Erase Function ..." );
                    			->BE32K_Event;
                   				BE_Mode = 1'b1;
                    			BE32K_Mode = 1'b1;
                  			  end
	    					else if ( CS_INT == 1'b1 && Bit != 39 ) 
								STATE <= `BAD_CMD_STATE;
						  end
                    	else if ( Bit == 7 ) 
							STATE <= `BAD_CMD_STATE;
					  end
*/

                    SUSP1, SUSP2:
                        begin
                        	if ( !DP_Mode && Chip_EN && ~HPM_RD && !EPSUSP && !SG_Mode ) 
														begin
                            	if ( CS_INT == 1'b1 && Bit == 7 && Susp_Ready == 1'b1 ) 
																begin
                                	//$display( $time, " Enter Suspend Function ..." );
                                  Susp_Trig = 1'b1;
                                end
                              else if ( Bit > 7 )
                              STATE <= `BAD_CMD_STATE;
                            end
                          else if ( Bit == 7 )
                          STATE <= `BAD_CMD_STATE;
                        end

                    RESU1, RESU2:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 ) begin
                                    //$display( $time, " Enter Resume Function ..." );
                                    Susp_Ready = 1'b0;
                                    ->Resume_Event;
                                end
                                else if ( Bit > 7 )
                                    STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

	            CE1, CE2:
	    					begin
	    		    		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP ) 
										begin
	    								if ( CS_INT == 1'b1 && Bit == 7 ) 
												begin
	    			    					//$display( $time, " Enter Chip Erase Function ..." );
	    			    					->CE_Event;
	    			    					CE_Mode = 1'b1 ;
	    									end 
	    								else if ( Bit > 7 )
	    			    				STATE <= `BAD_CMD_STATE;
	    		    			end
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    					end
                      
	            PP: 
	    		  begin
	    			if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP) 
					  begin
	    				if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] )
							  begin
								//Address[24] = BAR[0];
							  end
                    		load_address(Address);
						  end
						if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) )
						  begin
	    			   		//$display( $time, " Enter Page Program Function ..." );
                    		if ( CS_INT == 1'b0 ) 
							  begin
								->PP_Event;
								PP_1XIO_Mode = 1'b1;
                      		  end  
	    				  end
	    				else if ( CS_INT == 1 &&( ( ((Bit < 39) || ((Bit + 1) % 8 !== 0))) ) && !BAR[7] ) 
						  begin
	    			   		STATE <= `BAD_CMD_STATE;
	    				  end
	    				else if ( CS_INT == 1 &&( ( ((Bit < 47) || ((Bit + 1) % 8 !== 0))) ) && BAR[7] ) 
						  begin
	    			   		STATE <= `BAD_CMD_STATE;
	    				  end
			   		  end
	    	   		else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end
                      
/*
	            PP4B: 
	    		  begin
	    			if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP) 
					  begin
						ADD_4B_Mode = 1'b1;
	    				if ( Bit == 39 ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
                    		load_address(Address);
						  end
						if ( Bit == 39 )
						  begin
	    			   		//$display( $time, " Enter Page Program Function ..." );
                    		if ( CS_INT == 1'b0 ) 
							  begin
								->PP_Event;
								PP_1XIO_Mode = 1'b1;
                      		  end  
	    				  end
	    				else if ( CS_INT == 1 &&( ( ((Bit < 47) || ((Bit + 1) % 8 !== 0))) ) ) 
						  begin
	    			   		STATE <= `BAD_CMD_STATE;
	    				  end
			   		  end
	    	   		else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end
*/

	            IRPP: 
	    					begin
	    		    		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Chip_EN && ~HPM_RD && !EPSUSP) begin
	    							if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
                    	load_address(Address);
	    			    			//$display( $time, " Enter Page Program Function ..." );
                    	if ( CS_INT == 1'b0 ) begin
												->PP_Event;
												PP_1XIO_Mode = 1'b1;
												SIR_Mode = 1'b1;
                      end  
	    							end
	    							else if ( CS_INT == 1 &&( ( ((Bit < 39) || ((Bit + 1) % 8 !== 0))) ) ) begin
	    			    			STATE <= `BAD_CMD_STATE;
	    							end
			    				end
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    					end
                      
				SGPP: 
				  begin
	    			if ( !DP_Mode && !WIP && ((WEL && WREN_06CMD)||SGPPEN4_CMD_EN) && Chip_EN && ~HPM_RD && !EPSUSP) 
					  begin
	    				if ( Bit == 31 ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
                    		load_address(Address);
	    			    	//$display( $time, " Enter SG Program Function ..." );
                    		if ( CS_INT == 1'b0 ) 
							  begin
								SGPPEN4_CMD_EN = 1'b0 ;
								->PP_Event;
								PP_1XIO_Mode = 1'b1;
								SG_Mode = 1'b1;
                      		  end  
	    				  end
	    				else if ( CS_INT == 1 &&( ( ((Bit < 39) || ((Bit + 1) % 8 !== 0))) ) ) 
						  begin
	    			 		STATE <= `BAD_CMD_STATE;
	    				  end
			   		  end
	    		  	else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    		  end
  

              RDSFDP:
              	begin
                	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                  	//$display( $time, " Enter SFDP read mode ..." );
                    if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
                      load_address(Address);
                    end
                   	if ( Bit == 7 ) begin
                     	RDSFDP_Mode = 1;
                     	if (ENQUAD) begin Read_4XIO_Mode = 1'b1; end
                       else begin FastRD_1XIO_Mode = 1'b1; end
                       Read_SHSL = 1'b1;
                    end
                  end
                  else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
                end

			RDABR:
			  begin
				if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD  )	
				  begin
					//$display( $time, " Enter Read Auto Boot Register Function ..." );
					Read_SHSL  = 1'b1;
					RDABR_Mode = 1'b1;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end

			WRABR:
			  begin
				if ( !DP_Mode && !WIP && WEL && Chip_EN && ~HPM_RD && !EPSUSP )
				  begin
					if ( CS_INT == 1'b0 && Bit == 7 )
					  begin
						//$display( $time, " Enter Write Fast Boot Register Function ..." );
						->WRABR_Event;
						WRABR_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && (Bit < 39 || Bit > 39) )
						STATE <= `BAD_CMD_STATE;
				  end
			  	else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end

/*
			WRASP:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP )
				  begin
					if ( CS_INT == 1'b1 && Bit == 23 )
					  begin
						//$display( $time, " Enter Write ASP Register Function ..." );
						-> WRASP_Event;
						WRASP_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && (Bit < 23 || Bit > 23) )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
            RDASP:
              begin
                if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD ) 
				  begin
                	//$display( $time, " Enter Read ASP Register Function ..." );
                    Read_SHSL = 1'b1;
                	RDASP_Mode = 1'b1 ;
                  end
                else if ( Bit == 7 )
                	STATE <= `BAD_CMD_STATE;
              end
*/
/*
			WRPASS:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP && PWDMLB )
				  begin
					if ( CS_INT == 1'b0 && Bit == 7 )
					  begin
						//$display( $time, " Enter Write Password Register Function ..." );
						->WRPASS_Event;
						WRPASS_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && (Bit < 71 || Bit > 71) )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			PASSULK:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP && !PWDMLB )
				  begin
					if ( CS_INT == 1'b0 && Bit == 7 )
					  begin
						//$display( $time, " Enter Unlock Password Function ..." );
						->PASSULK_Event;
						PASSULK_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && (Bit < 71 || Bit > 71) )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDPASS:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && PWDMLB )
				  begin
					//$display( $time, " Enter Read Password Register Function ..." );
					Read_SHSL = 1'b1;
					RDPASS_Mode = 1'b1;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			WRPPB:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) 
				  begin
					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
						if ( !BAR[7] )
						  begin
							Address[24] = BAR[0];
						  end
						else 
						  begin
							ADD_4B_Mode = 1'b1;
						  end
					  end
					if ( CS_INT == 1'b1 && ((Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7])) ) 
					  begin
						//$display( $time, " Enter Write PPB Function ..." );
						->WRPPB_Event;
						WRPPB_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && ((Bit < 31 || Bit > 31) && !BAR[7]) )
						STATE <= `BAD_CMD_STATE;
					else if ( CS_INT == 1'b1 && ((Bit < 39 || Bit > 39) && BAR[7]) )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			WRPPB4B:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) 
				  begin
					ADD_4B_Mode = 1'b1;
					if ( Bit == 39 ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
					  end
					if ( CS_INT == 1'b1 && Bit == 39 ) 
					  begin
						//$display( $time, " Enter Write PPB Function ..." );
						->WRPPB_Event;
						WRPPB_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && Bit < 39 || Bit > 39 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDPPB:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && !ENQUAD ) 
				  begin
    				//$display( $time, " Enter Read PPB Register Function ..." );
                   	Read_SHSL = 1'b1;
					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) )
					  begin
						Address = SI_Reg[A_MSB:0] ;
						if ( !BAR[7] )
						  begin
							Address [24] = BAR[0] ;
						  end
						else
						  begin
							ADD_4B_Mode = 1'b1 ;
						  end
					  end
					if ( Bit == 7 )
					  begin
						RDPPB_Mode = 1'b1 ;
					  end
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDPPB4B:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && !ENQUAD ) 
				  begin
					ADD_4B_Mode = 1'b1;
					if ( Bit == 39 ) 
					  begin
                    	Address = SI_Reg[A_MSB:0] ;
                	  end
    				//$display( $time, " Enter Read PPB Register Function ..." );
					if ( Bit == 7 ) 
					  begin
                    	Read_SHSL = 1'b1;
        				RDPPB_Mode = 1'b1 ;
					  end
            	  end
    			else if ( Bit == 7 )
    				STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			ERPPB:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) 
				  begin
					if ( CS_INT == 1'b1 && Bit == 7 ) 
					  begin
    					//$display( $time, " Enter Erase PPB Function ..." );
    					->ERPPB_Event;
						ERPPB_Mode = 1'b1;
                	  end
					else if ( Bit > 7 ) 
    					STATE <= `BAD_CMD_STATE;
            	  end
    			else if ( Bit == 7 )
    				STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			SFRZ:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP )
				  begin
					if ( CS_INT == 1'b1 && Bit == 7 )
					  begin
						//$display( $time, " Enter Set FREEZE bit Function ..." );
						->SFRZ_Event;
						SFRZ_Mode = 1'b1;
					  end
					else if ( Bit > 7 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			PPBLK:
			  begin
				if ( !DP_Mode && !WIP && WEL && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP )
				  begin
					if ( CS_INT == 1'b1 && Bit == 7 )
					  begin
						//$display( $time, " Enter Set PPB Lock bit Function ..." );
						->PPBLK_Event;
						PPBLK_Mode = 1'b1;
					  end
					else if ( Bit > 7 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDPPBLK:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD )
				  begin
					//$display( $time, " Enter Read PPB Lock Register Function ...");
					Read_SHSL = 1'b1;
					RDPPBLK_Mode = 1'b1;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			WRDYB:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) 
				  begin
					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
						if ( !BAR[7] )
						  begin
							Address[24] = BAR[0];
						  end
						else
						  begin
							ADD_4B_Mode = 1'b1;
						  end
					  end
					if ( CS_INT == 1'b1 && ((Bit == 39 && !BAR[7]) || (Bit == 47 && BAR[7])) ) 
					  begin
						//$display( $time, " Enter Write DYB Function ..." );
						->WRDYB_Event;
						WRDYB_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && ((Bit < 39 || Bit > 39) && !BAR[7]) )
						STATE <= `BAD_CMD_STATE;
					else if ( CS_INT == 1'b1 && ((Bit < 47 || Bit > 47) && BAR[7]) )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			WRDYB4B:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD && !EPSUSP ) 
				  begin
					ADD_4B_Mode = 1'b1;
					if ( Bit == 39 ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
					  end
					if ( CS_INT == 1'b1 && Bit == 47 ) 
					  begin
						//$display( $time, " Enter Write DYB Function ..." );
						->WRDYB_Event;
						WRDYB_Mode = 1'b1;
					  end
					else if ( CS_INT == 1'b1 && Bit < 47 || Bit > 47 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDDYB:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD ) 
				  begin
					//$display( $time, " Enter Read DYB Register Function ..." );
					Read_SHSL = 1'b1;
					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
						if ( !BAR[7] )
						  begin
							Address [24] = BAR[0];
						  end
						else
						  begin
							ADD_4B_Mode = 1'b1 ;
						  end
					  end
					if ( Bit == 7 ) 
					  begin
						RDDYB_Mode = 1'b1 ;
					  end
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			RDDYB4B:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && ~HPM_RD ) 
				  begin
					ADD_4B_Mode = 1'b1;
					if ( (Bit == 39 && !ENQUAD) || (Bit == 39 && ENQUAD) ) 
					  begin
						Address = SI_Reg[A_MSB:0] ;
					  end
					//$display( $time, " Enter Read DYB Register Function ..." );
					if ( Bit == 7 ) 
					  begin
						Read_SHSL = 1'b1;
						RDDYB_Mode = 1'b1 ;
					  end
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			GBLK:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && !EPSUSP)
				  begin
					if ( CS_INT == 1'b1 && Bit == 7 )
					  begin
						//$display( $time, " Enter Chip Protection Function ..." );
						->GBLK_Event;
					  end
					else if ( CS_INT == 1'b1 && Bit > 7 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/
/*
			GBULK:
			  begin
				if ( !DP_Mode && !WIP && Norm_Array_Mode && Chip_EN && !EPSUSP )
				  begin
					if ( CS_INT == 1'b1 && Bit == 7 )
					  begin
						//$display( $time, " Enter Chip Unprotection Function ..." );
						->GBULK_Event;
					  end
					else if ( CS_INT == 1'b1 && Bit > 7 )
						STATE <= `BAD_CMD_STATE;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/

              RDUNIQ:
              	begin
                	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                  	//$display( $time, " Enter UniqID read mode ..." );
                    if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
                      load_address(Address);
                    end
                   	if ( Bit == 7 ) begin
                     	RDUNIQ_Mode = 1;
                     	if (ENQUAD) begin Read_4XIO_Mode = 1'b1; end
                       else begin FastRD_1XIO_Mode = 1'b1; end
                       Read_SHSL = 1'b1;
                    end
                  end
                  else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
                end

              IRRD:
              	begin
                	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
                  	//$display( $time, " Enter SIR read mode ..." );
                    if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
                      load_address(Address);
                    end
                   	if ( Bit == 7 ) begin
                     	SIR_Mode = 1;
                     	if (ENQUAD) begin Read_4XIO_Mode = 1'b1; end
                       else begin FastRD_1XIO_Mode = 1'b1; end
                       Read_SHSL = 1'b1;
                    end
                  end
                  else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
                end

  
			SGRD:
           	  begin
               	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
				  begin
                  	//$display( $time, " Enter SG read mode ..." );
                    if ( Bit == 31 ) 
					  begin
                    	Address = SI_Reg [A_MSB:0];
                      	load_address(Address);
                      end
                   	if ( Bit == 7 ) 
					  begin
                     	SG_Mode = 1;
                     	if (ENQUAD) 
						  begin 
							Read_4XIO_Mode = 1'b1; 
						  end
                       	else 
						  begin 
							FastRD_1XIO_Mode = 1'b1; 
						  end
                       	Read_SHSL = 1'b1;
                      end
                  end
                else if ( Bit == 7 ) 
					STATE <= `BAD_CMD_STATE;
              end

						DP:
                        begin
                            if ( !WIP && Chip_EN && ~HPM_RD && !EPSUSP ) begin
                                if ( CS_INT == 1'b1 && Bit == 7 && DP_Mode == 1'b0 ) begin
                                    //$display( $time, " Enter Deep Power Dwon Function ..." );
                                    tDP_Chk = 1'b1;
                                    DP_Mode = 1'b1;
																		#tDP tDP_Chk = 1'b0;
                                end
                                else if ( Bit > 7 ) STATE <= `BAD_CMD_STATE;
                            end
                            else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
                        end

						RDP, RDESID:
                          begin
                            if ( !WIP && Chip_EN && ~HPM_RD ) 
							  begin
                                // $display( $time, " Enter Release from Deep Power Dwon Function ..." );
                                if ( !BAR[7] )
								  begin
									RDESID_Mode = 1'b1; 
								  end
                              	Read_SHSL = 1'b1;
                                if ( CS_INT == 1'b1 && Bit > 0 && DP_Mode ) 
								  begin
                                    tRES1_Chk = 1'b1;
									#tRES1	tRES1_Chk = 1'b0;
                                    DP_Mode = 1'b0;
                                  end
                              end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                          end

						CLERP:
						  begin
							if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD )
							  begin
								if ( CS_INT == 1'b1 && Bit == 7 )
								  begin
									//$display( $time, " Enter Clear Extended Read Parameter Function ..." );
									clr_extended_read_parameter;
								  end
								else if ( Bit > 7 )
									STATE <= `BAD_CMD_STATE;
							  end
							else if ( Bit == 7 )
								STATE <= `BAD_CMD_STATE;
						  end


						RDMDID:
							begin
								//if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD && !FR_Reg[5] ) begin
								if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) begin
									if ( Bit == 31 ) begin
	   								Address = SI_Reg[A_MSB:0] ;
	   							end
	   							//$display( $time, " Enter Read Electronic Manufacturer & ID Function ..." );
      						Read_SHSL = 1'b1;
	    						RDMDID_Mode = 1'b1;
	  						end
	  						else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;			    
							end

				READ2X: 
				  begin 
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
	    				//$display( $time, " Enter READX2 Function ..." );
                    	Read_SHSL = 1'b1;
	    				if ( (Bit == 19 && !BAR[7]) || (Bit == 23 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] )
							  begin
								//Address [24] = BAR[0];
							  end
                    		load_address(Address);
	    				  end
	    				Read_2XIO_Mode = 1'b1;
						RDDIO_Mode = 1'b1;
	    		 	  end	
	    	   		else if ( (Bit == 7) && ~HPM_RD ) 
						STATE <= `BAD_CMD_STATE;				
	    		  end

/*
			READ2X4B:
			  begin
				if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD )
				  begin
					//$display( $time, " Enter READX2 Function ..." );
					Read_SHSL = 1'b1;
					if ( Bit == 23 )
					  begin
						Address = SI_Reg [A_MSB:0];
						load_address(Address);
					  end
					Read_2XIO_Mode = 1'b1;
					ADD_4B_Mode = 1'b1;
				  end
				else if ( Bit == 7 )
					STATE <= `BAD_CMD_STATE;
			  end
*/

/*
			READ2X_DTR: 
	    					begin 
	    		    		if ( (CS_INT == 1'b0) && !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) 
										begin
	    								//$display( $time, " Enter READX2 Function ..." );
                    	Read_SHSL = 1'b1;
	    								if ( Bit == 19 ) 
												begin
                    			Address = SI_Reg [A_MSB:0];
                    			load_address(Address);
	    									end
											wait(~SCLK) ;
											DTR_Mode = 1'b1;
	    								Read_2XIO_Mode = 1'b1;
											RDDIO_Mode = 1'b1;
	    		    			end	
	    		    		else if ( (Bit == 7) && ~HPM_RD ) STATE <= `BAD_CMD_STATE;				
	    					end
*/
/*
				RDBAR1, RDBAR2:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD )
					  begin
						//$display( $time, " Enter Read Bank Address Register Function ..." );
						Read_SHSL = 1'b1;
						RDBAR_Mode = 1'b1;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/
/*
				WRBARV1, WRBARV2:
              	  begin
                	if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !PSB ) // no WEL required
					  begin
                  		if ( CS_INT == 1'b1 && Bit == 15 ) 
						  begin
                    		//$display( $time, " Enter WRBARV Bank_Address_Register Function ..." );
                      		BAR_V[0] = SI_Reg[0];
                      		BAR_V[7] = SI_Reg[7];
                      		BAR[0] = BAR_V[0];
                      		BAR[7] = BAR_V[7];
						  end
                    	else if ( CS_INT == 1'b1 && Bit < 15 || Bit > 15 ) 
							STATE <= `BAD_CMD_STATE;
                  	  end
                  	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
                  end
*/
/*                      
                WRBARNV:
                  begin
                    if ( !DP_Mode && !WIP && WEL && Chip_EN && ~HPM_RD && !PSB ) 
					  begin
                    	if ( CS_INT == 1'b1 && Bit == 15 ) 
						  begin
                        	//$display( $time, " Enter WRBARNV Bank_Address_Register Function ..." );
                        	->WRBAR_Event;
                    	  end
                    	else if ( CS_INT == 1'b1 && (Bit > 15 || Bit < 15) )
                        	STATE <= `BAD_CMD_STATE;
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
*/

	            READ4X:
	   			  begin
	       			if ( !DP_Mode && !WIP && (Status_Reg[6]|ENQUAD) && Chip_EN && ~HPM_RD ) 
					  begin
	    				//$display( $time, " Enter READX4 Function ..." );
                  		Read_SHSL = 1'b1;
                  		if ( (Bit == 13 && !BAR[7] && !ENQUAD) || (Bit == 31 && !BAR[7] && ENQUAD) || (Bit == 15 && BAR[5] && !ENQUAD) || (Bit == 39 && BAR[5] && ENQUAD) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] ) 
							  begin
								//Address [24] = BAR[0];
							  end
                    		load_address(Address);
	    				  end
	    				Read_4XIO_Mode = 1'b1;
                    	RDQIO_Mode    = 1'b1;
                    	READ4X_BOT_Mode    = 1'b1;
	    		  	  end
	    		  	else if ( (Bit == 7) && ~HPM_RD ) 
						STATE <= `BAD_CMD_STATE;			    
	    		  end

/*
				READ4X4B:
				  begin
					if ( !DP_Mode && !WIP && (Status_Reg[6]|ENQUAD) && Chip_EN && ~HPM_RD )
					  begin
						//$display( $time, " Enter READ4X4B Function ..." );
						Read_SHSL = 1'b1;
						if ( (Bit == 15 && !ENQUAD) || (Bit == 39 && ENQUAD) )
						  begin
							Address = SI_Reg [A_MSB:0];
							load_address(Address);
						  end
						Read_4XIO_Mode = 1'b1;
						READ4X4B_Mode = 1'b1;
						ADD_4B_Mode = 1'b1;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/
/*
	            READ4X_DTR:
	    					begin
	    		    		if ( (CS_INT == 1'b0) && !DP_Mode && !WIP && (Status_Reg[6]|ENQUAD) && Chip_EN && ~HPM_RD ) begin
	    							//$display( $time, " Enter READX4 Function ..." );
                  	Read_SHSL = 1'b1;
                  	if ( (Bit == 13 && !ENQUAD) || (Bit == 31 && ENQUAD) ) begin
                    	Address = SI_Reg [A_MSB:0];
                    	load_address(Address);
	    							end
										wait(~SCLK) ;
										DTR_Mode = 1'b1;
	    							Read_4XIO_Mode = 1'b1;
                    RDQIO_Mode    = 1'b1;
                    READ4X_BOT_Mode    = 1'b1;
	    		    		end
	    		    		else if ( (Bit == 7) && ~HPM_RD ) STATE <= `BAD_CMD_STATE;			    
	    					end
*/

	            DREAD:
	    		  begin
	    			if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
	    				//$display( $time, " Enter Fast Read dual output Function ..." );
                    	Read_SHSL = 1'b1;
	   					if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] ) 
							  begin
								//Address [24] = BAR[0];
							  end
                    		load_address(Address);
	    				  end
	    				FastRD_2XIO_Mode =1'b1;
	    		   	  end
	    		  	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;			    
	    		  end

/*
				DREAD4B:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD )
					  begin
						//$display( $time, " Enter Fast Read dual output Function ..." );
						Read_SHSL = 1'b1;
						if ( Bit == 39 ) 
						  begin
							Address = SI_Reg [A_MSB:0];
							load_address(Address);
						  end
						FastRD_2XIO_Mode = 1'b1;
						ADD_4B_Mode = 1'b1;
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/

	            QREAD:
	    		  begin
	        		if ( !DP_Mode && !WIP && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
	    				//$display( $time, " Enter Fast Read quad output Function ..." );
                    	Read_SHSL = 1'b1;
	    				if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] )
							  begin
								//Address [24] = BAR[0];
							  end
                    		load_address(Address);
	    				  end
	    				FastRD_4XIO_Mode = 1'b1;
	    		   	  end
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;			    
	    		  end

/*
	            QREAD4B:
	    		  begin
	        		if ( !DP_Mode && !WIP && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
	    				//$display( $time, " Enter Fast Read quad output Function ..." );
                    	Read_SHSL = 1'b1;
	    				if ( Bit == 39 ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
                    		load_address(Address);
	    				  end
	    				FastRD_4XIO_Mode = 1'b1;
						ADD_4B_Mode = 1'b1;
	    		   	  end
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;			    
	    		  end
*/

                DTRREAD1X:
               	  begin
                    if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD ) 
					  begin
                    	//$display( $time, " Enter DTR READX1 Function ..." );
                    	if ( Bit == 7 && !ENQUAD ) 
						  begin
                        	DTRRead_1XIO_Mode = 1'b1;
                        	Read_SHSL = 1'b1;
                    	  end
						else if ( Bit == 7 && ENQUAD )
						  begin
							DTRRead_4XIO_Mode = 1'b1;
							Read_SHSL = 1'b1;
						  end
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end

                DTRREAD2X:
                  begin
                    if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) 
					  begin
                    	//$display( $time, " Enter DTR READX2 Function ..." );
                    	if ( Bit == 7 ) 
						  begin
                        	DTRRead_2XIO_Mode = 1'b1;
							RDDIO_Mode = 1'b1;
                        	Read_SHSL = 1'b1;
                    	  end
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end

                DTRREAD4X:
                  begin
                    if ( !DP_Mode && !WIP && (Status_Reg[6] | ENQUAD) && Chip_EN && ~HPM_RD ) 
					  begin
                    	//$display( $time, " Enter DTR READX4 Function ..." );
                    	if ( Bit == 7 ) 
						  begin
                        	DTRRead_4XIO_Mode = 1'b1;
                            DTRRead_4XIO_ModeX = 1'b1;
							RDQIO_Mode = 1'b1;
                        	Read_SHSL = 1'b1;
                    	  end
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end

/*
				DTRREAD1X4B:
				  begin
					if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD )
					  begin
						//$display( $time, " Enter DTR READX1 Function ..." );
						if ( Bit == 7 && !ENQUAD )
						  begin
							DTRRead_1XIO_Mode = 1'b1;
							ADD_4B_Mode = 1'b1;
							Read_SHSL = 1'b1;
						  end
						else if ( Bit == 7 && ENQUAD )
						  begin
							DTRRead_4XIO_Mode = 1'b1;
							DTRRead_4XIO_Mode_4B = 1'b1;
							ADD_4B_Mode = 1'b1;
							Read_SHSL = 1'b1;
						  end
					  end
					else if ( Bit == 7 )
						STATE <= `BAD_CMD_STATE;
				  end
*/
/*
                DTRREAD2X4B:
                  begin
                    if ( !DP_Mode && !WIP && Chip_EN && !ENQUAD && ~HPM_RD ) 
					  begin
                    	//$display( $time, " Enter DTR READX2 Function ..." );
                    	if ( Bit == 7 ) 
						  begin
                        	DTRRead_2XIO_Mode = 1'b1;
                            ADD_4B_Mode = 1'b1;
							RDDIO_Mode = 1'b1;
                        	Read_SHSL = 1'b1;
                    	  end
                      end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
*/
/*
                DTRREAD4X4B:
                  begin
                    if ( !DP_Mode && !WIP && (Status_Reg[6] | ENQUAD) && Chip_EN && ~HPM_RD ) 
					  begin
                    	//$display( $time, " Enter DTR READX4 Function ..." );
                    	if ( Bit == 7 ) 
						  begin
                        	DTRRead_4XIO_Mode = 1'b1;
                            DTRRead_4XIO_Mode_4B = 1'b1;
                            ADD_4B_Mode = 1'b1;
							RDQIO_Mode = 1'b1;
                        	Read_SHSL = 1'b1;
                    	  end
                   	  end
                    else if ( Bit == 7 )
                    	STATE <= `BAD_CMD_STATE;
                  end
*/


			`ifdef EON_COMMAND
	            QPP2: 
	    					begin
	    		    		if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD && !EPSUSP) begin
	    							if ( Bit == 31 ) begin
                    	Address = SI_Reg [A_MSB:0];
                     	load_address(Address);
	    							end
	    							if ( CS_INT == 0 && (Bit == 31)) begin
	                  	//$display( $time, " Enter 4io Page Program Function ..." );
	                  	->PP_Event;
	    								PP_4XIO_Load= 1'b1;
											SI_OUT_EN   = 1'b0;
        							SO_OUT_EN   = 1'b0;
        							WP_OUT_EN   = 1'b0;
        							SIO3_OUT_EN = 1'b0;
        							SI_IN_EN    = 1'b1;
        							SO_IN_EN    = 1'b1;
        							WP_IN_EN    = 1'b1;
        							SIO3_IN_EN  = 1'b1;
	                 		PP_4XIO_Mode= 1'b1;
	    							end
	    							else if ( CS_INT == 1 && (Bit < 33 || (Bit + 1)%2 !== 0 ))begin
	    			    			STATE <= `BAD_CMD_STATE;
	    							end
	    						end    
	    		    		else if ( Bit == 7 ) STATE <= `BAD_CMD_STATE;
	    					end
			`else
	            QPP1,QPP2: 
	    		  begin
	    		 	if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD && !EPSUSP) 
					  begin
	    				if ( (Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7]) ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
							if ( !BAR[7] )
							  begin
								//Address [24] = BAR[0];
							  end
                     		load_address(Address);
	    				  end
	    				if ( CS_INT == 0 && ((Bit == 31 && !BAR[7]) || (Bit == 39 && BAR[7])) ) 
						  begin
	                  		//$display( $time, " Enter 4io Page Program Function ..." );
	                  		->PP_Event;
							PP_4XIO_Load = 1'b1;
	    					PP_4XIO_Mode = 1'b1;
							SI_OUT_EN   = 1'b0;
        					SO_OUT_EN   = 1'b0;
        					WP_OUT_EN   = 1'b0;
        					SIO3_OUT_EN = 1'b0;
        					SI_IN_EN    = 1'b1;
        					SO_IN_EN    = 1'b1;
        					WP_IN_EN    = 1'b1;
        					SIO3_IN_EN  = 1'b1;
	    				  end
	    				else if ( CS_INT == 1 && (Bit < 33 || (Bit + 1)%2 !== 0 ) && !BAR[7])
						  begin
	    			    	STATE <= `BAD_CMD_STATE;
	    				  end
	    				else if ( CS_INT == 1 && (Bit < 41 || (Bit + 1)%2 !== 0 ) && BAR[7])
						  begin
	    			    	STATE <= `BAD_CMD_STATE;
	    				  end
	    			  end    
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end
			`endif

/*
	            QPP4B1,QPP4B2: 
	    		  begin
	    		 	if ( !DP_Mode && !WIP && WEL && WREN_06CMD && Status_Reg[6] && Chip_EN && ~HPM_RD && !ENQUAD && !EPSUSP) 
					  begin
						ADD_4B_Mode = 1'b1;
	    				if ( Bit == 39 ) 
						  begin
                    		Address = SI_Reg [A_MSB:0];
                     		load_address(Address);
	    				  end
	    				if ( CS_INT == 0 && Bit == 39 ) 
						  begin
	                  		//$display( $time, " Enter 4io Page Program Function ..." );
	                  		->PP_Event;
							PP_4XIO_Load = 1'b1;
	    					PP_4XIO_Mode = 1'b1;
							SI_OUT_EN   = 1'b0;
   							SO_OUT_EN   = 1'b0;
   							WP_OUT_EN   = 1'b0;
   							SIO3_OUT_EN = 1'b0;
   							SI_IN_EN    = 1'b1;
   							SO_IN_EN    = 1'b1;
   							WP_IN_EN    = 1'b1;
   							SIO3_IN_EN  = 1'b1;
	    				  end
	    				else if ( CS_INT == 1 && (Bit < 41 || (Bit + 1)%2 !== 0 ) )
						  begin
	    			    	STATE <= `BAD_CMD_STATE;
	    				  end
	    			  end    
	    		   	else if ( Bit == 7 ) 
						STATE <= `BAD_CMD_STATE;
	    		  end
*/

							EQIO:
  							begin
 									if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && !ENQUAD ) begin
    								if ( CS_INT == 1'b1 && Bit == 7 ) begin
      								//$display( $time, " Enable Quad I/O Function ..." );
        							ENQUAD = 1'b1;
      							end
      							else if ( Bit > 7 )
      								STATE <= `BAD_CMD_STATE;
    							end
    							else if ( Bit == 7 )
    									STATE <= `BAD_CMD_STATE;
								end

      				RSTQIO:
              	begin
               		if ( !DP_Mode && !WIP && Chip_EN && ~HPM_RD && ENQUAD ) begin
                 		if ( CS_INT == 1'b1 && Bit == 7 ) begin
                   		//$display( $time, " Exiting QPI mode ..." );
                      ENQUAD = 1'b0;
                    end
                    else if ( Bit > 7 )
                    	STATE <= `BAD_CMD_STATE;
                	end
                 	else if ( Bit == 7 )
                 		STATE <= `BAD_CMD_STATE;
               	end

             RSTEN:
               begin
             	if ( !DP_Mode && Chip_EN && ~HPM_RD ) 
				  begin
             		if ( CS_INT == 1'b1 && (Bit == 7 || (EN4XIO_Read_Mode && Bit == 1) || (ENDTR4XIO_Read_Mode && Bit == 1) ||
														(EN2XIO_Read_Mode && Bit == 7) || (ENDTR2XIO_Read_Mode && Bit == 7)) ) 
					  begin
                    	//$display( $time, " Reset enable ..." );
				    	->RST_EN_Event;
                      end
                    else if ( Bit > 7 )
                    	STATE <= `BAD_CMD_STATE;
               	  end
                else if ( Bit == 7 )
               		STATE <= `BAD_CMD_STATE;
              end

          	RST:
           	  begin
            	if ( Chip_EN && RST_CMD_EN ) 
				  begin
                	if ( CS_INT == 1'b1 && (Bit == 7 || (EN4XIO_Read_Mode && Bit == 1) || (ENDTR4XIO_Read_Mode && Bit == 1) ||
														(EN2XIO_Read_Mode && Bit == 7) || (ENDTR2XIO_Read_Mode && Bit == 7)) ) 
					  begin
                    	//$display( $time, " Reset memory ..." );
                    	->RST_Event;
                      end
                    else if ( Bit > 7 )
                    	STATE <= `BAD_CMD_STATE;
               	  end
                else if ( Bit == 7 )
                  	STATE <= `BAD_CMD_STATE;
              end

              NOP:
              	begin
             		end

	            default: 
	    					begin
	    		    		STATE <= `BAD_CMD_STATE;
	    					end
		    	endcase
	        end
                 
		`BAD_CMD_STATE: 
	      begin
			if (SGPPEN4_CMD_EN)
			  begin
				->SGPP_EN4DIS_Event;
			  end
			else if (SGEREN4_CMD_EN)
			  begin
				->SGER_EN4DIS_Event;
			  end
			else
				SGEN_55CMD_EN	= 1'b0;
				SGEN_AACMD_EN	= 1'b0;
				SGPPEN3_CMD_EN	= 1'b0;
				SGPPEN4_CMD_EN	= 1'b0;
				SGEREN3_CMD_EN	= 1'b0;
				SGEREN4_CMD_EN	= 1'b0;
	      end
            
	    default: 
	        begin
	    	STATE =  `STANDBY_STATE;
	        end
	endcase

        if ( CS_INT == 1'b1 ) begin end
    end

    always @ (posedge CS_INT) begin
            SIO0_Reg <= #tDIS 1'bx;
            SIO1_Reg <= #tDIS 1'bx;
            SIO2_Reg <= #tDIS 1'bx;
            SIO3_Reg <= #tDIS 1'bx;
           
	    SO_OUT_EN    <= #tDIS 1'b0;
	    SI_OUT_EN    <= #tDIS 1'b0;
	    WP_OUT_EN    <= #tDIS 1'b0;
	    SIO3_OUT_EN  <= #tDIS 1'b0;

            #1;
            Bit         = 1'b0;
            Bit_Tmp     = 1'b0;
           
            SO_IN_EN    = 1'b0;
            SI_IN_EN    = 1'b0;
            WP_IN_EN    = 1'b0;
            SIO3_IN_EN  = 1'b0;
						
            RDJDID_Mode = 1'b0;
            RDSR_Mode   = 1'b0;
            RDFR_Mode   = 1'b0;
            RDRP_Mode	= 1'b0;
            RDERP_Mode	= 1'b0;
			RDASP_Mode	= 1'b0;
			RDABR_Mode	= 1'b0;
			RDPPBLK_Mode	= 1'b0;
			RDPASS_Mode	= 1'b0;
			RDPPB_Mode	= 1'b0;
			RDDYB_Mode	= 1'b0;
			RDBAR_Mode	= 1'b0;
	    Read_Mode	= 1'b0;
	    RDESID_Mode	= 1'b0;
	    RDMDID_Mode	= 1'b0;
            RDSFDP_Mode    = 1'b0;
            RDUNIQ_Mode    = 1'b0;
	    Read_1XIO_Mode  = 1'b0;
	    Read_2XIO_Mode  = 1'b0;
	    Read_4XIO_Mode  = 1'b0;
	    Read_1XIO_Chk   = 1'b0;
	    Read_2XIO_Chk   = 1'b0;
	    Read_4XIO_Chk   = 1'b0;
	    FastRD_1XIO_Mode= 1'b0;
	    FastRD_1XIO_Chk = 1'b0;
	    FastRD_2XIO_Mode= 1'b0;
	    FastRD_2XIO_Chk = 1'b0;
	    FastRD_4XIO_Mode= 1'b0;
	    FastRD_4XIO_Chk = 1'b0;
	    PP_4XIO_Load    = 1'b0;
            PP_4XIO_Chk     = 1'b0;
			DTRRead_1XIO_Mode 	= 1'b0;
			DTRRead_2XIO_Mode 	= 1'b0;
			DTRRead_4XIO_Mode 	= 1'b0;
			DTR_Read_Mode_IN 	= 1'b0;
	    STATE <=  `STANDBY_STATE;

	    EN_Boot	    = 1'b0;
		AUTO_BOOT_Mode	= 1'b0;
		AUTO_BOOT_Chk	= 1'b0;

	    ADD_4B_Mode = 1'b0;

            disable read_jedecid;
            disable read_status;

			disable read_BA_Register;
		disable	read_ASP_register;
		disable	read_AB_register;
		disable	read_ppblk_register;
		disable	read_password_register;
		disable	read_ppb_register;
		disable	read_dyb_register;
            disable read_1xio;
            disable read_2xio;
            disable read_4xio;
            disable dtrread_1xio;
            disable dtrread_2xio;
            disable dtrread_4xio;
            disable fastread_1xio;
            disable fastread_2xio;
            disable fastread_4xio;
            disable read_esid;
            disable read_mdid;
	    disable read_function;
	    disable dummy_cycle;
            disable read_fr;
		disable auto_boot_read;
	end

    always @ (posedge CS_INT) 
	  begin 
		if ( Set_4XIO_Enhance_Mode) 
		  begin
	    	EN4XIO_Read_Mode = 1'b1;
      	  end
		else if ( Set_4XIO_DTR_Enhance_Mode )
		  begin
			ENDTR4XIO_Read_Mode = 1'b1;
		  end
		else 
		  begin
			#1;
	    	EN4XIO_Read_Mode = 1'b0;
			ENDTR4XIO_Read_Mode = 1'b0;
			DTRRead_4XIO_Mode = 1'b0;
			DTRRead_4XIO_ModeX = 1'b0;
			DTRRead_4XIO_Mode_4B = 1'b0;
        	READ4X4B_Mode    = 1'b0;
        	RDQIO_Mode    = 1'b0;
        	READ4X_TOP_Mode    = 1'b0;
        	READ4X_BOT_Mode    = 1'b0;
      	  end
	  end

    always @ (posedge CS_INT) 
	  begin 
		if ( Set_2XIO_Enhance_Mode) 
		  begin
	    	EN2XIO_Read_Mode 	= 1'b1;
      	  end
		else if ( Set_2XIO_DTR_Enhance_Mode) 
		  begin
	    	ENDTR2XIO_Read_Mode = 1'b1;
      	  end
		else 
		  begin
			#1;
	    	EN2XIO_Read_Mode 	= 1'b0;
			ENDTR2XIO_Read_Mode = 1'b0;
        	RDDIO_Mode    		= 1'b0;
      	  end
      end 

		always @ (posedge CS_INT) begin
			if ( !Set_4XIO_Enhance_Mode && !Set_2XIO_Enhance_Mode)
				#1 DTR_Mode = 0;
		end

	always @ (posedge CS_INT) 
	  begin
		#1;
		if ( WIP == 1'b0 ) 
		  begin
	 		SIR_Mode = 0;
	 		SG_Mode = 0;
		  end
	  end

	always @ ( posedge DTRRead_4XIO_Mode_4B ) 
	  begin
		DTRRead_4XIO_ModeX = 1'b0;
	  end

    /*----------------------------------------------------------------------*/
    /*	ALL function trig action            				    */
    /*----------------------------------------------------------------------*/
    always @ ( posedge Read_1XIO_Mode
	    or posedge FastRD_1XIO_Mode
	    or posedge RDMDID_Mode
	    or posedge RDESID_Mode
	    or posedge Read_2XIO_Mode
	    or posedge Read_4XIO_Mode 
	    or posedge PP_4XIO_Load
	    or posedge FastRD_2XIO_Mode
	    or posedge FastRD_4XIO_Mode
	   ) begin:read_function 
        wait ( SCLK_INT == 1'b0 );
				if ( Read_1XIO_Mode == 1'b1 ) begin
	    		Read_1XIO_Chk = 1'b1;
	    		read_1xio;
				end
				else if ( FastRD_1XIO_Mode == 1'b1 ) begin
	    		FastRD_1XIO_Chk = 1'b1;
	    		fastread_1xio;
				end
				else if ( FastRD_2XIO_Mode == 1'b1 ) begin
	    		FastRD_2XIO_Chk = 1'b1;
	    		fastread_2xio;
				end
				else if ( FastRD_4XIO_Mode == 1'b1 ) begin
	    		FastRD_4XIO_Chk = 1'b1;
	    		fastread_4xio;
				end
				else if ( RDMDID_Mode == 1'b1 ) begin
	    		read_mdid;
				end 
				else if ( RDESID_Mode == 1'b1 ) begin
	    		read_esid;
				end
				else if ( Read_2XIO_Mode == 1'b1 ) begin
	    		Read_2XIO_Chk = 1'b1;
	    		read_2xio;
				end
				else if ( Read_4XIO_Mode == 1'b1 ) begin
	    		Read_4XIO_Chk = 1'b1;
	    		read_4xio;
				end   
        else if ( PP_4XIO_Load == 1'b1 ) begin
            PP_4XIO_Chk = 1'b1;
        end
    end

  	always @ ( Status_Reg[0] ) 
	  begin
		exRPARAM[0] = Status_Reg[0] ;
 	  end
    
    always @ ( SGPER_EN1_Event ) 
	  begin
		SGEN_55CMD_EN = #2 1'b1;
   	  end
    
    always @ ( SGPER_EN2_Event ) 
	  begin
		SGEN_55CMD_EN =  	 1'b0;
		SGEN_AACMD_EN = #2 1'b1;
   	  end
    
    always @ ( SGPP_EN3_Event ) 
	  begin
		SGEN_AACMD_EN =    1'b0;
		SGPPEN3_CMD_EN = #2 1'b1;
   	  end
    
    always @ ( SGER_EN3_Event ) 
	  begin
		SGEN_AACMD_EN =    1'b0;
		SGEREN3_CMD_EN = #2 1'b1;
   	  end
    
    always @ ( SGPP_EN4_Event ) 
	  begin
		SGPPEN3_CMD_EN =    1'b0;
		SGPPEN4_CMD_EN = #2 1'b1;
		Status_Reg[1]		=		1'b1;
   	  end
    
    always @ ( SGER_EN4_Event ) 
	  begin
		SGEREN3_CMD_EN =    1'b0;
		SGEREN4_CMD_EN = #2 1'b1;
		Status_Reg[1]		=		1'b1;
   	  end
    
    always @ ( SGPP_EN4DIS_Event ) 
	  begin
		SGPPEN4_CMD_EN = #2 1'b0;
		Status_Reg[1]		=		1'b0;
   	  end
    
    always @ ( SGER_EN4DIS_Event ) 
	  begin
		SGEREN4_CMD_EN = #2 1'b0;
		Status_Reg[1]		=		1'b0;
   	  end
    
	always @ ( posedge DTRRead_1XIO_Mode ) 
	  begin
		dtrread_1xio;
	  end

	always @ ( posedge DTRRead_2XIO_Mode ) 
	  begin
		dtrread_2xio;
	  end

	always @ ( posedge DTRRead_4XIO_Mode ) 
	  begin
		dtrread_4xio;
	  end

	always @ ( posedge AUTO_BOOT_Mode ) 
	  begin
		AUTO_BOOT_Chk = 1'b1;
		auto_boot_read;
	  end

    always @ ( RST_EN_Event ) 
	  begin
		RST_CMD_EN = #2 1'b1;
   	  end
    
    always @ ( RST_Event ) begin
        During_RST_REC = 1;

/*
		if ((WRSR_Mode||WRSR2_Mode) && tWRSR==tW) 
		  begin
			#(tREADY2_W);
          end
		else if ((WRSR_Mode||WRSR2_Mode) && tWRSR==tBP) 
		  begin
            #(tREADY2_W);
          end
		else if ( WRASP_Mode || WRPASS_Mode || WRABR_Mode || PASSULK_Mode || WRPPB_Mode || WRSCUR_Mode ||  PP_4XIO_Mode || PP_1XIO_Mode ) 
		  begin
             #(tREADY2_P);
          end
     	else if ( SE_4K_Mode || ERPPB_Mode ) 
		  begin
         	#(tREADY2_SE);
     	  end
     	else if ( BE64K_Mode || BE32K_Mode ) 
		  begin
         	#(tREADY2_BE);
     	  end
     	else if ( CE_Mode ) 
		  begin
         	#(tREADY2_CE);
     	  end
     	else if ( DP_Mode == 1'b1 ) 
		  begin
            #(tRES2);
          end
     	else if ( Read_SHSL == 1'b1 ) 
		  begin
        	#(tREADY2_R);
     	  end
		else 
		  begin
            #(tREADY2_D);
          end
*/


        #tSRST;
        disable write_status;
//	disable	write_ASP_register;
//	disable	write_password_register;
	disable	write_AB_register;
//	disable	password_unlock;
//	disable	program_ppb_register;
//	disable	write_dyb_register;
//	disable	erase_ppb_register;

//	disable	lock_ppb_register;

        disable write_function_register;
        disable block_erase_32k;
	disable	chip_lock;
	disable	chip_unlock;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; // can deleted
        disable update_array;

		disable read_BA_Register;

        disable read_jedecid;
        disable read_status;
	disable	read_ASP_register;
	disable	read_AB_register;
	disable	read_ppblk_register;
	disable	read_password_register;
	disable	read_ppb_register;
	disable	read_dyb_register;

        disable suspend_erase;
        disable suspend_sir_erase;
//        disable suspend_sg_erase;
        disable suspend_program;
        disable suspend_sir_program;
//        disable suspend_sg_program;
        disable er_timer;
        disable pg_timer;
        disable Susp_Ready_cnt;
        disable stimeout_cnt;

        disable read_1xio;
        disable read_2xio;
        disable read_4xio;
        disable dtrread_1xio;
        disable dtrread_2xio;
        disable dtrread_4xio;
        disable fastread_1xio;
        disable fastread_2xio;
        disable fastread_4xio;
        disable read_esid;
        disable read_mdid;
        disable read_function;
        disable dummy_cycle;
        disable read_fr;

		disable auto_boot_read;

        reset_sm;
		Status_Reg[1:0] = 2'b0;
		FR_Reg[3:2] = 2'b0;

		BAR_V[0]		= 1'b0;
		BAR_V[7]		= 1'b0;
		RPARAM_V[7:0]	= 8'h00;
//		exRPARAM_V[7:5]	= 3'b111;
		exRPARAM_V[7:5]	= exRPARAM_NV[7:5];
		exRPARAM[3:0]	= 4'b0000;

    end

// *==============================================================================================
// * Hardware Reset Function description
// * ============================================================================================
    always @ ( negedge RESETB_INT ) 
	  begin
      	if (RESETB_INT == 1'b0) 
		  begin
			disable hd_reset;
			#0;
            -> HDRST_Event;
          end
	  end
	always @ ( HDRST_Event ) 
	  begin: hd_reset
       	if (RESETB_INT == 1'b0) 
		  begin
        	During_RST_REC = 1;
/*
         	if ((WRSR_Mode||WRSR2_Mode) && tWRSR==tW) 
			  begin
             	#(tREADY2_W);
         	  end
         	else if ((WRSR_Mode||WRSR2_Mode) && tWRSR==tBP) 
			  begin
             	#(tREADY2_W);
         	  end
         	else if ( WRASP_Mode || WRPASS_Mode || WRABR_Mode || PASSULK_Mode || WRPPB_Mode || WRSCUR_Mode ||  PP_4XIO_Mode || PP_1XIO_Mode ) 
			  begin
             	#(tREADY2_P);
         	  end
     		else if ( SE_4K_Mode || ERPPB_Mode ) 
			  begin
         		#(tREADY2_SE);
     		  end
     		else if ( BE64K_Mode || BE32K_Mode ) 
			  begin
         		#(tREADY2_BE);
     		  end
     		else if ( CE_Mode ) 
			  begin
         		#(tREADY2_CE);
     		  end
         	else if ( DP_Mode == 1'b1 ) 
			  begin
             	#(tRES2+tRLRH);
         	  end
     		else if ( Read_SHSL == 1'b1 ) 
			  begin
         		#(tREADY2_R);
     		  end
         	else 
			  begin
             	#(tREADY2_D);
         	  end
*/

				#tHWRST;
        disable write_status;
//	disable	write_ASP_register;
//	disable	write_password_register;
    disable	write_AB_register;
//	disable	password_unlock;
//	disable	program_ppb_register;
//	disable	write_dyb_register;
//	disable	erase_ppb_register;

//	disable	lock_ppb_register;


        disable write_function_register;
        disable block_erase_32k;
	disable	chip_lock;
	disable	chip_unlock;
        disable block_erase;
        disable sector_erase_4k;
        disable chip_erase;
        disable page_program; 
        disable update_array;

//		disable read_BA_Register;

        disable read_jedecid;
        disable read_status;
	disable	read_ASP_register;
	disable	read_AB_register;
	disable	read_ppblk_register;
	disable	read_password_register;
	disable	read_ppb_register;
	disable	read_dyb_register;

        disable suspend_erase;
        disable suspend_sir_erase;
//      disable suspend_sg_erase;
        disable suspend_program;
        disable suspend_sir_program;
//      disable suspend_sg_program;
        disable er_timer;
        disable pg_timer;
        disable Susp_Ready_cnt;
        disable stimeout_cnt;

        disable read_1xio;
        disable read_2xio;
        disable read_4xio;
        disable dtrread_1xio;
        disable dtrread_2xio;
        disable dtrread_4xio;
        disable fastread_1xio;
        disable fastread_2xio;
        disable fastread_4xio;
        disable read_esid;
        disable read_mdid;
        disable read_function;
        disable dummy_cycle;
        disable read_fr;

		disable auto_boot_read;

		PPBL_Reg = ASP_Reg[2] ? 8'b0111_1111 : 8'b0111_1110;

        reset_sm;
				Status_Reg[1:0] = 2'b0;
				FR_Reg[3:2] = 2'b0;

				BAR_V[7]	= 1'b0;
				BAR_V[0]	= 1'b0;
				RPARAM_V[7:0]	= 8'h00;
				exRPARAM_V[7:5] = exRPARAM_NV[7:5];
				exRPARAM[3:0] = 4'b0000;
      end
    end

    always @ ( negedge Susp_Ready ) begin:Susp_Ready_cnt
        #(tRESU2SUSP)  Susp_Ready = 1;
    end

    always @ ( posedge Susp_Trig ) begin:stimeout_cnt
        Susp_Trig <= #1 1'b0;
    end


    always @ ( posedge READ4X4B_Mode ) begin
        RDQIO_Mode = 1'b0;
    end

    always @ ( posedge READ4X_BOT_Mode ) begin
        READ4X_TOP_Mode = 1'b0;
    end

    always @ ( WRSR_Event ) begin
			write_status;
    end

    always @ ( WRFR_Event ) begin
			write_function_register;
    end

    always @ ( SRPNV_Event ) 
	  begin
		set_read_parameter_nv;
      end

    always @ ( SERPNV_Event ) 
	  begin
		set_extended_read_parameter_nv;
      end

//	always @ ( WRASP_Event )
//	  begin
//		write_ASP_register;
//	  end

//	always @ ( WRPASS_Event )
//	  begin
//		write_password_register;
//	  end

	always @ ( WRABR_Event )
	  begin
		write_AB_register;
	  end

//	always @ ( PASSULK_Event )
//	  begin
//		password_unlock;
//	  end

//	always @ ( WRPPB_Event )
//	  begin
//		program_ppb_register;
//	  end

//	always @ ( ERPPB_Event )
//	  begin
//		erase_ppb_register;
//	  end

//	always @ ( SFRZ_Event )
//	  begin
//		lock_freeze_register;
//	  end

//	always @ ( PPBLK_Event )
//	  begin
//		lock_ppb_register;
//	  end

//	always @ ( WRDYB_Event )
//	  begin
//		write_dyb_register;
//	  end



    always @ ( BE_Event ) begin
			block_erase;
    end

    always @ ( CE_Event ) begin
			chip_erase;
    end
    
    always @ ( PP_Event ) begin:page_program_mode
    	page_program( Address );
    end
   
    always @ ( SER_Event ) begin
			sector_erase_4k;
    end

    always @ ( posedge RDJDID_Mode ) begin
        read_jedecid;
    end

    always @ ( posedge RDSR_Mode ) begin
        read_status;
    end

    always @ ( posedge RDFR_Mode ) begin
        read_fr;
    end

    always @ ( posedge RDRP_Mode ) 
	  begin
        read_rp;
      end

    always @ ( posedge RDERP_Mode ) 
	  begin
        read_erp;
      end

	always @ ( posedge RDASP_Mode ) 
	  begin
		read_ASP_register;
	  end

	always @ ( posedge RDABR_Mode ) 
	  begin
		read_AB_register;
	  end

	always @ ( posedge RDPASS_Mode ) 
	  begin
		read_password_register;
	  end

	always @ ( posedge RDPPB_Mode ) 
	  begin
		read_ppb_register;
	  end

	always @ ( posedge RDDYB_Mode ) 
	  begin
		read_dyb_register;
	  end

	always @ ( posedge RDPPBLK_Mode ) 
	  begin
		read_ppblk_register;
	  end


	always @ ( posedge RDBAR_Mode ) 
	  begin
		read_BA_Register;
	  end

	always @ ( WRBAR_Event ) 
	  begin
		write_ba_register;
	  end


    always @ ( BE32K_Event ) begin
        block_erase_32k;
    end

	always @ ( GBLK_Event ) 
	  begin
		chip_lock;
	  end

	always @ ( GBULK_Event ) 
	  begin
		chip_unlock;
	  end

// *========================================================================================== 
// * Module Task Declaration
// *========================================================================================== 
    /*----------------------------------------------------------------------*/
    /*	Description: define a wait dummy cycle task			    */
    /*	INPUT							            */
    /*	    Cnum: cycle number						    */
    /*----------------------------------------------------------------------*/
    task dummy_cycle;
			input [31:0] Cnum;
			begin
	    	repeat( Cnum ) begin
					@ ( posedge SCLK_INT );
	    	end
			end
    endtask // dummy_cycle

    /*----------------------------------------------------------------------*/
    /*	Description: define a write enable task				    */
    /*----------------------------------------------------------------------*/
    task write_enable;
			begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    	Status_Reg[1] = 1'b1; 
	    // $display( $time, " New Status Register = %b", Status_Reg );
			end
    endtask // write_enable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a write disable task (WRDI)			    */
    /*----------------------------------------------------------------------*/
    task write_disable;
			begin
	    	//$display( $time, " Old Status Register = %b", Status_Reg );
	    		Status_Reg[1]  = 1'b0;
	    	//$display( $time, " New Status Register = %b", Status_Reg );
			end
    endtask // write_disable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read id task (RDJDID)			    */
    /*----------------------------------------------------------------------*/
    task read_jedecid;
			reg  [23:0] Dummy_ID;
			integer Dummy_Count;
			begin
				Dummy_ID = {MID_ISSI, Memory_Type, Memory_Density};
				if (ENQUAD) Dummy_Count = 6;
				else Dummy_Count = 24;
				forever begin
					@ ( negedge SCLK_INT or posedge CS_INT );
					if ( CS_INT == 1'b1 ) begin disable read_jedecid; end
					else begin // negedge SCLK_INT 
						if (ENQUAD) begin
							SI_OUT_EN   = 1'b1;
							WP_OUT_EN   = 1'b1;
							SIO3_OUT_EN = 1'b1;
						end // ENQUAD
						SO_OUT_EN = 1'b1;
						SO_IN_EN  = 1'b0;
						SI_IN_EN  = 1'b0;
						WP_IN_EN  = 1'b0;
						SIO3_IN_EN= 1'b0;
						if ( Dummy_Count ) begin
							Dummy_Count = Dummy_Count - 1;
							if (ENQUAD) begin
								if ( Dummy_Count == 5 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[23:20];
								else if ( Dummy_Count == 4 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[19:16];
								else if ( Dummy_Count == 3 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[15:12];
								else if ( Dummy_Count == 2 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[11:8];
								else if ( Dummy_Count == 1 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[7:4];
								else if ( Dummy_Count == 0 )
									{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[3:0];
							end // ENQUAD
							else begin
								SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
							end // else
						end // Dummy_Count
						else begin
							if (ENQUAD) begin
								Dummy_Count = 5;
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[23:20];
							end // ENQUAD
							else begin
								Dummy_Count = 23;
								SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
							end // else
						end // else
					end // else // negedge SCLK_INT
				end  // end forever
			end
    endtask // read_jedecid
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read status task (RDSR)			    */
    /*----------------------------------------------------------------------*/
    task read_status;
			integer Dummy_Count;
			begin
				if (ENQUAD) begin Dummy_Count = 2; end
				else begin Dummy_Count = 8; end
				forever begin
					@ ( negedge SCLK_INT or posedge CS_INT );
					if ( CS_INT == 1'b1 ) begin disable read_status; end
					else begin
						if (ENQUAD) begin
							SI_OUT_EN    = 1'b1;
							WP_OUT_EN    = 1'b1;
							SIO3_OUT_EN  = 1'b1;
						end // ENQUAD
						SO_OUT_EN = 1'b1;
						SO_IN_EN  = 1'b0;
						SI_IN_EN  = 1'b0;
						WP_IN_EN  = 1'b0;
						SIO3_IN_EN= 1'b0;
						if ( Dummy_Count ) begin
							Dummy_Count = Dummy_Count - 1;
							if (ENQUAD) begin
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? Status_Reg[7:4] : Status_Reg[3:0];
							end // ENQUAD
							else begin
								SIO1_Reg    <= #tV Status_Reg[Dummy_Count];
							end
						end
						else begin
							if (ENQUAD) begin
								Dummy_Count = 1;
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Status_Reg[7:4];
							end // ENQUAD
							else begin
								Dummy_Count = 7;
								SIO1_Reg    <= #tV Status_Reg[Dummy_Count];
							end
						end		 
					end
				end  // end forever
			end
    endtask // read_status

    /*----------------------------------------------------------------------*/
    /*	Description: define a read configuration register task (RDFR)			    */
    /*----------------------------------------------------------------------*/
    task read_fr;
			integer Dummy_Count;
			begin
      	if (ENQUAD) begin Dummy_Count = 2; end
        else begin Dummy_Count = 8; end
	    	forever begin
					@ ( negedge SCLK_INT or posedge CS_INT );
					if ( CS_INT == 1'b1 ) begin disable read_fr; end
					else begin
           	if (ENQUAD) begin
             	SI_OUT_EN    = 1'b1;
             	WP_OUT_EN    = 1'b1;
             	SIO3_OUT_EN  = 1'b1;
            end
		    		SO_OUT_EN = 1'b1;
            SO_IN_EN  = 1'b0;
            SI_IN_EN  = 1'b0;
            WP_IN_EN  = 1'b0;
            SIO3_IN_EN= 1'b0;
		    		if ( Dummy_Count ) begin
							Dummy_Count = Dummy_Count - 1;
               if (ENQUAD) begin
               	{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? FR_Reg[7:4] : FR_Reg[3:0];
               end
               else begin
			    			SIO1_Reg    <= #tV FR_Reg[Dummy_Count];
               end
		    		end
		    		else begin
             	if (ENQUAD) begin
			    			Dummy_Count = 1;
                 {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV FR_Reg[7:4];
              end
              else begin
			    			Dummy_Count = 7;
                 SIO1_Reg    <= #tV FR_Reg[Dummy_Count];
               end
		    		end // 
					end
	    	end  // end forever
			end
    endtask // read_fr

    /*----------------------------------------------------------------------*/
    /*	Description: define a read Read Parameter task (RDRP)			    */
    /*----------------------------------------------------------------------*/
    task read_rp;
	integer Dummy_Count;
	  begin
      	if (ENQUAD) 
		  begin 
			Dummy_Count = 2; 
		  end
        else 
		  begin 
			Dummy_Count = 8; 
		  end
	   	forever 
		  begin
			@ ( negedge SCLK_INT or posedge CS_INT );
			if ( CS_INT == 1'b1 ) 
			  begin 
				disable read_rp; 
			  end
			else 
			  begin
           		if (ENQUAD) 
				  begin
             		SI_OUT_EN    = 1'b1;
             		WP_OUT_EN    = 1'b1;
             		SIO3_OUT_EN  = 1'b1;
            	  end
		    	SO_OUT_EN = 1'b1;
            	SO_IN_EN  = 1'b0;
            	SI_IN_EN  = 1'b0;
            	WP_IN_EN  = 1'b0;
            	SIO3_IN_EN= 1'b0;
		   		if ( Dummy_Count ) 
				  begin
					Dummy_Count = Dummy_Count - 1;
               		if (ENQUAD) 
					  begin
               			{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? RPARAM[7:4] : RPARAM[3:0];
               		  end
               		else 
					  begin
			    		SIO1_Reg    <= #tV RPARAM[Dummy_Count];
               		  end
		    	  end
		   		else 
				  begin
             		if (ENQUAD) 
					  begin
			    		Dummy_Count = 1;
                 		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV RPARAM[7:4];
              		  end
              		else 
					  begin
			    		Dummy_Count = 7;
                 		SIO1_Reg    <= #tV RPARAM[Dummy_Count];
               		  end
		    	  end // 
			  end
	   	  end  // end forever
	  end
    endtask // read_rp

    /*----------------------------------------------------------------------*/
    /*	Description: define a read Extended Read Parameter task (RDERP)	    */
    /*----------------------------------------------------------------------*/
    task read_erp;
	integer Dummy_Count;
	  begin
      	if (ENQUAD) 
		  begin 
			Dummy_Count = 2; 
		  end
        else 
		  begin 
			Dummy_Count = 8; 
		  end
	   	forever 
		  begin
			@ ( negedge SCLK_INT or posedge CS_INT );
			if ( CS_INT == 1'b1 ) 
			  begin 
				disable read_erp; 
			  end
			else 
			  begin
           		if (ENQUAD) 
				  begin
             		SI_OUT_EN    = 1'b1;
             		WP_OUT_EN    = 1'b1;
             		SIO3_OUT_EN  = 1'b1;
            	  end
		    	SO_OUT_EN = 1'b1;
            	SO_IN_EN  = 1'b0;
            	SI_IN_EN  = 1'b0;
            	WP_IN_EN  = 1'b0;
            	SIO3_IN_EN= 1'b0;
		   		if ( Dummy_Count ) 
				  begin
					Dummy_Count = Dummy_Count - 1;
               		if (ENQUAD) 
					  begin
               			{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? exRPARAM[7:4] : exRPARAM[3:0];
               		  end
               		else 
					  begin
			    		SIO1_Reg    <= #tV exRPARAM[Dummy_Count];
               		  end
		    	  end
		   		else 
				  begin
             		if (ENQUAD) 
					  begin
			    		Dummy_Count = 1;
                 		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV exRPARAM[7:4];
              		  end
              		else 
					  begin
			    		Dummy_Count = 7;
                 		SIO1_Reg    <= #tV exRPARAM[Dummy_Count];
               		  end
		    	  end // 
			  end
	   	  end  // end forever
	  end
    endtask // read_erp

    /*----------------------------------------------------------------------*/
    /*	Description: define a write status task				    */
    /*----------------------------------------------------------------------*/

    task write_status;
   	reg [7:0] Status_Reg_Up;
	  begin
      	Status_Reg_Up = SI_Reg[7:0] ;
		tWRSR = tW;
        Status_Reg[0]   = 1'b1;
        #tWRSR;
	    Status_Reg[7:6]   =  Status_Reg_Up[7:6];
	    Status_Reg[6:2] =  FRZB ? Status_Reg[6:2] : Status_Reg_Up[6:2];
		  
		//WIP : write in process Bit
		Status_Reg[0]   = 1'b0;
	    //WEL:Write Enable Latch
	    Status_Reg[1]   = 1'b0;
	    WRSR_Mode       = 1'b0;
	    WREN_06CMD      = 1'b0;
	  end 
    endtask // write_status
  
    /*----------------------------------------------------------------------*/
    /*	Description: define a write function register task				    */
    /*----------------------------------------------------------------------*/

    task write_function_register;
   	reg [7:0] Function_Reg_Up;
	  begin
      	Function_Reg_Up = SI_Reg[7:0] ;
        Status_Reg[0]   = 1'b1;
//      #tBP;
        #tW;
	    FR_Reg[7:4]	=  FR_Reg[7:4] | Function_Reg_Up[7:4];
//	    FR_Reg[1] 	=  FRZB ? FR_Reg[1] : (FR_Reg[1] | Function_Reg_Up[1]);
	    //WIP : write in process Bit
	    Status_Reg[0]   = 1'b0;
	    //WEL:Write Enable Latch
	    Status_Reg[1]   = 1'b0;
	    WRFR_Mode       = 1'b0;
	    WREN_06CMD      = 1'b0;
	  end 
    endtask // write_function_register
  
    /*----------------------------------------------------------------------*/
    /*	Description: define a set read parameter for non-volatile			*/
    /*----------------------------------------------------------------------*/

    task set_read_parameter_nv;
   	reg [7:0] Set_RD_Param_Up;
	  begin
      	Set_RD_Param_Up = SI_Reg[7:0] ;
        Status_Reg[0]   = 1'b1;
//      #tBP;
        #tW;
	    RPARAM_NV[7:0]	=  Set_RD_Param_Up[7:0];
	    RPARAM[7:0]	=  RPARAM_NV[7:0];
	    //WIP : write in process Bit
	    Status_Reg[0] = 1'b0;
	    //WEL:Write Enable Latch
	    Status_Reg[1] = 1'b0;
	    SRPNV_Mode    = 1'b0;
	    WREN_06CMD    = 1'b0;
	  end 
    endtask // set_read_parameter_nv  
  
    /*----------------------------------------------------------------------*/
    /*	Description: define a set extended read parameter for non-volatile	*/
    /*----------------------------------------------------------------------*/

    task set_extended_read_parameter_nv;
   	reg [7:0] Set_exRD_Param_Up;
	  begin
      	Set_exRD_Param_Up = SI_Reg[7:0] ;
        Status_Reg[0]   = 1'b1;
//      #tBP;
        #tW;
	    exRPARAM_NV[7:5]	=  Set_exRD_Param_Up[7:5];
	    exRPARAM[7:5]	=  exRPARAM_NV[7:5];
	    //WIP : write in process Bit
	    Status_Reg[0] = 1'b0;
	    //WEL:Write Enable Latch
	    Status_Reg[1] = 1'b0;
	    SERPNV_Mode    = 1'b0;
	    WREN_06CMD    = 1'b0;
	  end 
    endtask // set_extended_read_parameter_nv  
  
    /*----------------------------------------------------------------------*/
    /*	Description: define a auto boot read data task						*/
    /*----------------------------------------------------------------------*/
    task auto_boot_read;
	integer	Dummy_Count, Tmp_Int;
	reg	[7:0]	OUT_Buf;
	  begin
		Dummy_Count = Status_Reg[6] ? 2 : 8;

		if ( AB_Reg[4:1] == 4'b0000 && Status_Reg[6] == 1'b0 )
			dummy_cycle(7);
		else if ( AB_Reg[4:1] == 4'b0000 && Status_Reg[6] == 1'b1 )
			dummy_cycle(5);
		else if ( AB_Reg[4:1] == 4'b0001 )
			dummy_cycle(0);
		else if ( AB_Reg[4:1] == 4'b0010 )
			dummy_cycle(1);
		else if ( AB_Reg[4:1] == 4'b0011 )
			dummy_cycle(2);
		else if ( AB_Reg[4:1] == 4'b0100 )
			dummy_cycle(3);
		else if ( AB_Reg[4:1] == 4'b0101 )
			dummy_cycle(4);
		else if ( AB_Reg[4:1] == 4'b0110 )
			dummy_cycle(5);
		else if ( AB_Reg[4:1] == 4'b0111 )
			dummy_cycle(6);
		else if ( AB_Reg[4:1] == 4'b1000 )
			dummy_cycle(7);
		else if ( AB_Reg[4:1] == 4'b1001 )
			dummy_cycle(8);
		else if ( AB_Reg[4:1] == 4'b1010 )
			dummy_cycle(9);
		else if ( AB_Reg[4:1] == 4'b1011 )
			dummy_cycle(10);
		else if ( AB_Reg[4:1] == 4'b1100 )
			dummy_cycle(11);
		else if ( AB_Reg[4:1] == 4'b1101 )
			dummy_cycle(12);
		else if ( AB_Reg[4:1] == 4'b1110 )
			dummy_cycle(13);
		else if ( AB_Reg[4:1] == 4'b1111 )
			dummy_cycle(14);

		Address = { AB_Reg[23:5], 5'b00000 };
		read_array(Address, OUT_Buf);
		forever
		  begin
			@ ( negedge SCLK or posedge CS_INT );
			if ( CS_INT == 1'b1 ) 
			  begin
				disable auto_boot_read;
			  end
			else
			  begin
				if ( Status_Reg[6] == 1'b0 )
				  begin
					Read_Mode = 1'b1;
					SO_OUT_EN = 1'b1;
					SI_IN_EN  = 1'b0;
					if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
					  end
					else
					  begin
						Address = Address + 1;
						read_array(Address, OUT_Buf);
						Dummy_Count = 7;
						SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
					  end
				  end
				else if ( Status_Reg[6] == 1'b1 ) 
				  begin
					SO_OUT_EN 	= 1'b1;
					SI_OUT_EN 	= 1'b1;
					WP_OUT_EN 	= 1'b1;
					SIO3_OUT_EN	= 1'b1;
					SO_IN_EN 	= 1'b0;
					SI_IN_EN 	= 1'b0;
					WP_IN_EN 	= 1'b0;
					SIO3_IN_EN	= 1'b0;
					Read_Mode	= 1'b1;
					if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? OUT_Buf[7:4] : OUT_Buf[3:0];
					  end
					else
					  begin
						Address = Address + 1;
						read_array(Address, OUT_Buf);
						Dummy_Count = 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:4];
					  end
				  end
			  end
		  end // end forever
	  end
	endtask // auto_boot_read







    /*----------------------------------------------------------------------*/
    /*	Description: define a read data task				    */
    /*		     03 AD1 AD2 AD3 DAT ...								    */
    /*----------------------------------------------------------------------*/
    task read_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	  begin
	   	Dummy_Count = 8;
        if ( !BAR[7] && !ADD_4B_Mode ) dummy_cycle(24);	// 3-byte address in
        else if ( BAR[7] || ADD_4B_Mode ) dummy_cycle(32); // 4-byte address in
        #1; 
        read_array(Address, OUT_Buf);
	   	forever 
		  begin
			@ ( negedge SCLK_INT or posedge CS_INT );
			if ( CS_INT == 1'b1 ) 
			  begin 
				disable read_1xio; 
			  end 
			else  
			  begin 
		   		Read_Mode	= 1'b1;
		   		SO_OUT_EN	= 1'b1;
            	SI_IN_EN  = 1'b0;
		    	if ( Dummy_Count ) 
				  begin
					Dummy_Count = Dummy_Count - 1;
		    		SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
		    	  end
		   		else 
				  begin
            		if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              			Address = {Address[A_MSB:3], 3'b000};
              		else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              			Address = {Address[A_MSB:4], 4'b0000};
              		else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              			Address = {Address[A_MSB:4], 4'b0000};
              		else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              			Address = {Address[A_MSB:5], 5'b0_0000};
              		else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              			Address = {Address[A_MSB:6], 6'b00_0000};
              		else
              			Address = Address + 1;
            			load_address(Address);
            			read_array(Address, OUT_Buf);
						Dummy_Count = 7;
						SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
		    	  end
			  end 
	   	  end  // end forever
	  end   
    endtask // read_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read data task							*/
    /*		     0B AD1 AD2 AD3 DMY DAT DAT ...	(FRD)						*/
    /*		     5A AD1 AD2 AD3 DMY DAT DAT ...	(RDSFDP)					*/
    /*		     4B AD1 AD2 AD3 DMY DAT DAT ...	(RDUNIQ)					*/
    /*		     68 AD1 AD2 AD3 DMY DAT DAT ...	(IRRD)						*/
    /*----------------------------------------------------------------------*/
    task fastread_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	  begin
      	Dummy_Count = 8;
      	if ( (!BAR[7] && !ADD_4B_Mode) || RDSFDP_Mode || RDUNIQ_Mode || SIR_Mode ) 
			dummy_cycle(24);	// 3-byte Address In
      	else if ( (BAR[7] || ADD_4B_Mode) && !RDSFDP_Mode && !RDUNIQ_Mode && !SIR_Mode )
			dummy_cycle(32);	// 4-byte Address In
		  begin
			  fork
				  begin
					if ( RPARAM[6:3] == 4'b0000 )
					  begin
						dummy_cycle(8);
					  end
					else if ( RPARAM[6:3] == 4'b0001 )
					  begin
						dummy_cycle(1);
					  end
					else if ( RPARAM[6:3] == 4'b0010 )
					  begin
						dummy_cycle(2);
					  end
					else if ( RPARAM[6:3] == 4'b0011 )
					  begin
						dummy_cycle(3);
					  end
					else if ( RPARAM[6:3] == 4'b0100 )
					  begin
						dummy_cycle(4);
					  end
					else if ( RPARAM[6:3] == 4'b0101 )
					  begin
						dummy_cycle(5);
					  end
					else if ( RPARAM[6:3] == 4'b0110 )
					  begin
						dummy_cycle(6);
					  end
					else if ( RPARAM[6:3] == 4'b0111 )
					  begin
						dummy_cycle(7);
					  end
					else if ( RPARAM[6:3] == 4'b1000 )
					  begin
						dummy_cycle(8);
					  end
					else if ( RPARAM[6:3] == 4'b1001 )
					  begin
						dummy_cycle(9);
					  end
					else if ( RPARAM[6:3] == 4'b1010 )
					  begin
						dummy_cycle(10);
					  end
					else if ( RPARAM[6:3] == 4'b1011 )
					  begin
						dummy_cycle(11);
					  end
					else if ( RPARAM[6:3] == 4'b1100 )
					  begin
						dummy_cycle(12);
					  end
					else if ( RPARAM[6:3] == 4'b1101 )
					  begin
						dummy_cycle(13);
					  end
					else if ( RPARAM[6:3] == 4'b1110 )
					  begin
						dummy_cycle(14);
					  end
					else if ( RPARAM[6:3] == 4'b1111 )
					  begin
						dummy_cycle(15);
					  end
//					Prea_OUT_EN1 <= #tV 1'b0;
	    			#1;
       				read_array(Address, OUT_Buf);
	    			forever 
					  begin
						@ ( negedge SCLK_INT or posedge CS_INT );
						if ( CS_INT == 1'b1 ) 
						  begin 
							disable fastread_1xio; 
							SIR_Mode = 1'b0;
  							SG_Mode = 1'b0;
						  end 
						else 
						  begin 
		    				Read_Mode = 1'b1;
            				SO_OUT_EN = 1'b1;
            				SI_IN_EN  = 1'b0;
		    				if ( Dummy_Count ) 
							  begin
								Dummy_Count = Dummy_Count - 1;
//								if ( DTR_Mode )
//									SIO1_Reg <= #(tV-3) OUT_Buf[Dummy_Count]; // Compensate SCLK_INT delay(=3ns) at DTR_Mode
//								else
									SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
		    				  end
            				else 
							  begin
            					if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              						Address = {Address[A_MSB:3], 3'b000};
              					else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              						Address = {Address[A_MSB:4], 4'b0000};
              					else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              						Address = {Address[A_MSB:4], 4'b0000};
              					else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              						Address = {Address[A_MSB:5], 5'b0_0000};
              					else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              						Address = {Address[A_MSB:6], 6'b00_0000};
              					else
              						Address = Address + 1;

              					load_address(Address);
              					read_array(Address, OUT_Buf);
								Dummy_Count = 7;
//								if ( DTR_Mode )
//									SIO1_Reg <= #(tV-3) OUT_Buf[Dummy_Count]; // Compensate SCLK_INT delay(=3ns) at DTR_Mode
//								else
									SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
		    				  end
						  end
	    			  end  // end forever
				end   

//				begin
//					if ( CR[4] )
//					  begin
//						dummy_cycle_prea(2);
//						Prea_OUT_EN1 = 1'b1;
//						preamble_bit_out;
//					  end
//				end

			  join
	  	  end
	  end
    endtask // fastread_1xio



	/*----------------------------------------------------------------------*/
	/*  Description: Execute Write ASP Register								*/
	/*----------------------------------------------------------------------*/
	task write_ASP_register;
	reg [15:0] ASP_Reg_Up;
	  begin
        ASP_Reg_Up [7:0] = SI_Reg [15:8];
        ASP_Reg_Up [15:8] = SI_Reg [7:0];
    	if ( (ASP_Reg_Up[1] == 1'b0 && ASP_Reg_Up[2] == 1'b0) || ( PSTMLB == 1'b0 || PWDMLB == 1'b0) ) 
		  begin
    		//WIP : write in process Bit
    		Status_Reg[0] = 1'b0;
    		//WEL:Write Enable Latch
    		Status_Reg[1] = 1'b0;
    		exRPARAM[2] = 1'b1;
    		WRASP_Mode 	= 1'b0;
    	  end
    	else 
		  begin
    		Status_Reg[0] = 1'b1;
    		#tPP ;
//  		#tW ;
    		ASP_Reg[15] = FRZB ? ASP_Reg[15] : (ASP_Reg_Up[15] & ASP_Reg[15]);
    		ASP_Reg[2:1] = ASP_Reg_Up[2:1] & ASP_Reg[2:1];
    		if ( ASP_Reg[2] == 1'b0 ) 
			  begin
        		PPBL_Reg[0] = 1'b0;
    		  end
    		//WIP : write in process Bit
    		Status_Reg[0] = 1'b0;
    		//WEL:Write Enable Latch
    		Status_Reg[1] = 1'b0;
    		WRASP_Mode = 1'b0;
    	  end
	  end
	endtask // write_ASP_register


	/*----------------------------------------------------------------------*/
	/*  Description: Execute Write Password Register                        */
	/*----------------------------------------------------------------------*/
/*
	task write_password_register;
	reg [63:0] Pwd_Reg_Up;
	reg [63:0] Pwd_Reg_Old;
	integer Tmp_Int, i;
	  begin
    	Pwd_Reg_Up = 64'hffff_ffff_ffff_ffff;
    	Pwd_Reg_Old = Pwd_Reg;
    	Tmp_Int = 0;
    	forever 
		  begin
    		@ ( posedge SCLK or posedge CS_INT );
    		if ( CS_INT == 1'b1 ) 
			  begin
        		if ( (Tmp_Int != 64 && !ENQUAD) || (Tmp_Int != 16 && ENQUAD) ) 
				  begin
        			WRPASS_Mode = 0;
        			disable write_password_register;
        		  end
        		else 
				  begin
        			//exRPARAM[2] = 1'b0;
        			Status_Reg[0] = 1'b1;
        			#tWRPASS;
        			Pwd_Reg = Pwd_Reg_Up & Pwd_Reg_Old;
        			//WIP : write in process Bit
        			Status_Reg[0] = 1'b0;
        			//WEL:Write Enable Latch
        			Status_Reg[1] = 1'b0;
        			WRPASS_Mode = 1'b0;
        		  end
        		disable write_password_register;
    		  end
    		else if ( ENQUAD )
			  begin
        		Tmp_Int = Tmp_Int + 1;
        		if ( Tmp_Int <= 16 ) 
				  begin
        			if ( Tmp_Int % 8 == 0) 
					  begin
            			#1;
            			if ( Tmp_Int == 2 ) 
						  begin
                			Pwd_Reg_Up[7:0] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 4 ) 
						  begin
                			Pwd_Reg_Up[15:8] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 6 ) 
						  begin
                			Pwd_Reg_Up[23:16] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 8 ) 
						  begin
                			Pwd_Reg_Up[31:24] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 10 ) 
						  begin
                			Pwd_Reg_Up[39:32] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 12 ) 
						  begin
                			Pwd_Reg_Up[47:40] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 14 ) 
						  begin
                			Pwd_Reg_Up[55:48] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 16 ) 
						  begin
                			Pwd_Reg_Up[63:56] = SI_Reg[7:0];
            			  end
                   	  end
        		  end
    		  end
    		else 
			  begin
        		Tmp_Int = Tmp_Int + 1;
        		if ( Tmp_Int <= 64 ) 
				  begin
        			if ( Tmp_Int % 8 == 0) 
					  begin
            			#1;
            			if ( Tmp_Int == 8 ) 
						  begin
                			Pwd_Reg_Up[7:0] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 16 ) 
						  begin
                			Pwd_Reg_Up[15:8] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 24 ) 
						  begin
                			Pwd_Reg_Up[23:16] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 32 ) 
						  begin
                			Pwd_Reg_Up[31:24] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 40 ) 
						  begin
                			Pwd_Reg_Up[39:32] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 48 ) 
						  begin
                			Pwd_Reg_Up[47:40] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 56 ) 
						  begin
                			Pwd_Reg_Up[55:48] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 64 ) 
						  begin
                			Pwd_Reg_Up[63:56] = SI_Reg[7:0];
            			  end
                   	  end
        		  end
    		  end
    	  end  // end forever
	  end
	endtask // write_password_register
*/

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Auto Boot Register                       */
    /*----------------------------------------------------------------------*/
	task write_AB_register;
	reg [31:0] AB_Reg_Up;
	reg [31:0] AB_Reg_Old;
	integer Tmp_Int, i;
	  begin
		AB_Reg_Up = 32'hffff_ffff;
		AB_Reg_Old = AB_Reg;
		Tmp_Int = 0;
		forever
		  begin
			@ ( posedge SCLK or posedge CS_INT );
			if ( CS_INT == 1'b1 )
			  begin
				if ( (Tmp_Int != 32 && !ENQUAD) || (Tmp_Int != 8 && ENQUAD) )
				  begin
					WRABR_Mode = 0;
					disable write_AB_register;
				  end
				else
				  begin
					//exRPARAM[2] = 1'b0; 
					Status_Reg[0] = 1'b1;
					#tWRABR;
					AB_Reg = AB_Reg_Up;
					//WIP : write in process Bit
					Status_Reg[0] = 1'b0;
					//WEL : Write Enable Latch
					Status_Reg[1] = 1'b0;
				  end
				disable write_AB_register;
			  end
			else if ( ENQUAD )
			  begin
				Tmp_Int = Tmp_Int + 1;
				if ( Tmp_Int <= 8 )
				  begin
					if ( Tmp_Int % 2 == 0 )
					  begin
						#1;
						if ( Tmp_Int == 2 )
						  begin
							AB_Reg_Up[7:0] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 4 )
						  begin
							AB_Reg_Up[15:8] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 6 )
						  begin
							AB_Reg_Up[23:16] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 8 )
						  begin
							AB_Reg_Up[31:24] = 8'h00;
						  end
					  end
				  end
			  end
			else
			  begin
				Tmp_Int = Tmp_Int + 1;
				if ( Tmp_Int <= 32 )
				  begin
					if ( Tmp_Int % 8 == 0 )
					  begin
						#1;
						if ( Tmp_Int == 8 )
						  begin
							AB_Reg_Up[7:0] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 16 )
						  begin
							AB_Reg_Up[15:8] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 24 )
						  begin
							AB_Reg_Up[23:16] = SI_Reg[7:0];
						  end
						else if ( Tmp_Int == 32 )
						  begin
							AB_Reg_Up[31:24] = 8'h00;
						  end
					  end
				  end
			  end
		  end // end forever
	  end
	endtask // write_AB_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute Password Unlock								*/
	/*----------------------------------------------------------------------*/
/*
	task password_unlock;
	reg [63:0] Pwd_Reg_In;
	integer Tmp_Int, i;
	  begin
    	Tmp_Int = 0;
    	forever 
		  begin
    		@ ( posedge SCLK or posedge CS_INT );
    		if ( CS_INT == 1'b1 ) 
			  begin
        		if ( (Tmp_Int != 64 && !ENQUAD) || (Tmp_Int != 16 && ENQUAD) ) 
				  begin
        			PASSULK_Mode = 0;
        			disable password_unlock;
        		  end
        		else 
				  begin
        			//exRPARAM[2] = 1'b0;
        			Status_Reg[0] = 1'b1;

        			if ( Pwd_Reg === Pwd_Reg_In ) 
					  begin
            			#tPASSULK;
            			PPBL_Reg[0] = 1'b1;
            			//WIP : write in process Bit
            			Status_Reg[0] = 1'b0;
            			PASSULK_Mode = 1'b0;
        			  end
        			else 
					  begin
            			#tPASSULK_FAIL;
            			//WIP : write in process Bit
            			Status_Reg[0] = 1'b0;
            			exRPARAM[2] = 1'b1;
            			PASSULK_Mode = 1'b0;
        			  end
        		  end
        		disable password_unlock;
    		  end
    		else 
			  begin
        		Tmp_Int = Tmp_Int + 1;
        		if ( Tmp_Int <= 16 && ENQUAD ) 
				  begin
        			if ( Tmp_Int % 2 == 0) 
					  begin
                		#1;
            			if ( Tmp_Int == 2 ) 
						  begin
                			Pwd_Reg_In[7:0] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 4 ) 
						  begin
                			Pwd_Reg_In[15:8] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 6 ) 
						  begin
                			Pwd_Reg_In[23:16] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 8 ) 
						  begin
                			Pwd_Reg_In[31:24] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 10 ) 
						  begin
                			Pwd_Reg_In[39:32] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 12 ) 
						  begin
                			Pwd_Reg_In[47:40] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 14 ) 
						  begin
                			Pwd_Reg_In[55:48] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 16 ) 
						  begin
                			Pwd_Reg_In[63:56] = SI_Reg[7:0];
            			  end
                      end
        		  end
        		else if ( Tmp_Int <= 64 && !ENQUAD ) 
				  begin
        			if ( Tmp_Int % 8 == 0) 
					  begin
                		#1;
            			if ( Tmp_Int == 8 ) 
						  begin
                			Pwd_Reg_In[7:0] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 16 ) 
						  begin
                			Pwd_Reg_In[15:8] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 24 ) 
						  begin
                			Pwd_Reg_In[23:16] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 32 ) 
						  begin
                			Pwd_Reg_In[31:24] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 40 ) 
						  begin
                			Pwd_Reg_In[39:32] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 48 ) 
						  begin
                			Pwd_Reg_In[47:40] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 56 ) 
						  begin
                			Pwd_Reg_In[55:48] = SI_Reg[7:0];
            			  end
            			else if ( Tmp_Int == 64 ) 
						  begin
                			Pwd_Reg_In[63:56] = SI_Reg[7:0];
            			  end
                      end
        		  end
    		  end
    	  end  // end forever
	  end
	endtask // password_unlock
*/

	/*----------------------------------------------------------------------*/
	/*  Description: Execute program PPB register							*/
	/*----------------------------------------------------------------------*/
	task program_ppb_register;
      begin
    	if ( PPBLB == 1'b0 ) 
		  begin
    		//WIP : write in process Bit
    		Status_Reg[0] = 1'b0;
    		//WEL:Write Enable Latch
    		Status_Reg[1] = 1'b0;
    		exRPARAM[2] = 1'b1;
    		WRPPB_Mode = 1'b0;
    	  end
    	else 
		  begin
            Block  =  Address [A_MSB:16];
            Status_Reg[0] = 1'b1;
            #tBP;
        	if (Block[Block_MSB:0] == 0 && TBPARAM) 
			  begin
                PPB_Reg_BOT0[Address[15:12]] = 1'b0;
        	  end
        	else if (Block[Block_MSB:0] == 1 && TBPARAM) 
			  begin
                PPB_Reg_BOT1[Address[15:12]] = 1'b0;
        	  end
        	else if (Block[Block_MSB:0] == Block_NUM-1 && !TBPARAM) 
			  begin
                PPB_Reg_TOP511[Address[15:12]] = 1'b0;
        	  end
        	else if (Block[Block_MSB:0] == Block_NUM-2 && !TBPARAM) 
			  begin
                PPB_Reg_TOP510[Address[15:12]] = 1'b0;
        	  end
          	else
                PPB_Reg[Block] = 1'b0;
        	//WIP : write in process Bit
            Status_Reg[0] = 1'b0;
        	//WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
        	WRPPB_Mode = 1'b0;
    	  end
   	  end
	endtask // program_ppb_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute erase PPB register                 */
	/*----------------------------------------------------------------------*/
	task erase_ppb_register;
      begin
    	if ( PPBLB == 1'b0 ) 
		  begin
    		//WIP : write in process Bit
    		Status_Reg[0] = 1'b0;
    		//WEL:Write Enable Latch
    		Status_Reg[1] = 1'b0;
    		exRPARAM[1] = 1'b1;
    		exRPARAM[3] = 1'b1;
    		ERPPB_Mode = 1'b0;
    	  end
    	else 
		  begin
            Status_Reg[0] = 1'b1;
            #tW;
        	for ( i = 0; i <= 15; i = i + 1 ) 
			  begin
        		PPB_Reg_TOP511[i] = 1'b1;
        		PPB_Reg_TOP510[i] = 1'b1;
        		PPB_Reg_BOT0[i]	= 1'b1;
        		PPB_Reg_BOT1[i] = 1'b1;
        	  end
        	for ( i = 2; i <= Block_NUM - 2; i = i + 1 ) 
			  begin
        		PPB_Reg[i] = 1'b1;
        	  end
        	//WIP : write in process Bit
            Status_Reg[0] = 1'b0;
        	//WEL:Write Enable Latch
            Status_Reg[1] = 1'b0;
        	ERPPB_Mode = 1'b0;
    	  end
      end
	endtask // erase_ppb_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute lock FREEZE register							*/
	/*----------------------------------------------------------------------*/
	task lock_freeze_register;
	  begin
    	Status_Reg[0] = 1'b1;
        #tWP_SRAM;
    	PPBL_Reg[7] = 1'b1;
    	//WIP : write in process Bit
    	Status_Reg[0] = 1'b0;
    	//WEL:Write Enable Latch
    	Status_Reg[1] = 1'b0;
    	SFRZ_Mode = 1'b0;
	  end
 	endtask // lock_freeze_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute lock PPB register                      */
	/*----------------------------------------------------------------------*/
	task lock_ppb_register;
	  begin
    	Status_Reg[0] = 1'b1;
        #tWP_SRAM;
    	PPBL_Reg[0] = 1'b0;
    	//WIP : write in process Bit
    	Status_Reg[0] = 1'b0;
    	//WEL:Write Enable Latch
    	Status_Reg[1] = 1'b0;
    	PPBLK_Mode = 1'b0;
	  end
 	endtask // lock_ppb_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute write DYB register                 */
	/*----------------------------------------------------------------------*/
	task write_dyb_register;
	reg [7:0] DYB_Reg_Up;
	  begin
		DYB_Reg_Up = SI_Reg [7:0];
		Block  =  Address [A_MSB:16];
		Status_Reg[0] = 1'b1;
		#tWP_SRAM;
		if ( DYB_Reg_Up[7:0] === 8'h00 || DYB_Reg_Up[7:0] === 8'hff )
		  begin
			if (Block[Block_MSB:0] == 0 && TBPARAM) 
			  begin
				if ( DYB_Reg_Up[0] == 1'b1 )
					DYB_Reg_BOT0[Address[15:12]] = 1'b1;
				else
					DYB_Reg_BOT0[Address[15:12]] = 1'b0;
			  end
			else if (Block[Block_MSB:0] == 1 && TBPARAM) 
			  begin
				if ( DYB_Reg_Up[0] == 1'b1 )
					DYB_Reg_BOT1[Address[15:12]] = 1'b1;
				else
					DYB_Reg_BOT1[Address[15:12]] = 1'b0;
			  end
			else if (Block[Block_MSB:0] == Block_NUM-1 && !TBPARAM) 
			  begin
				if ( DYB_Reg_Up[0] == 1'b1 )
					DYB_Reg_TOP511[Address[15:12]] = 1'b1;
				else
					DYB_Reg_TOP511[Address[15:12]] = 1'b0;
			  end
			else if (Block[Block_MSB:0] == Block_NUM-2 && !TBPARAM) 
			  begin
				if ( DYB_Reg_Up[0] == 1'b1 )
					DYB_Reg_TOP510[Address[15:12]] = 1'b1;
				else
					DYB_Reg_TOP510[Address[15:12]] = 1'b0;
			  end
			else 
			  begin
				if ( DYB_Reg_Up[0] == 1'b1 )
					DYB_Reg[Block] = 1'b1;
				else
					DYB_Reg[Block] = 1'b0;
			  end
		  end
		//WIP : write in process Bit
		Status_Reg[0] = 1'b0;
		WRDYB_Mode = 1'b0;
	  end
	endtask // write_dyb_register 

	/*----------------------------------------------------------------------*/
	/*  Description: Execute Read ASP Register                             */
	/*----------------------------------------------------------------------*/
	task read_ASP_register;
	reg [15:0] Dummy_ASP;
	integer Dummy_Count;
	  begin
    	Dummy_Count = ENQUAD ? 4 : 16;
    	Dummy_ASP = { ASP_Reg [7:0], ASP_Reg [15:8] };
    	forever 
		  begin
        	@ ( negedge SCLK or posedge CS_INT );
        	if ( CS_INT == 1'b1 ) 
			  begin
            	disable read_ASP_register;
        	  end
        	else if ( ENQUAD )
			  begin
            	SI_OUT_EN 	=  1'b1;
            	SO_OUT_EN 	=  1'b1;
            	WP_OUT_EN 	=  1'b1;
            	SIO3_OUT_EN =  1'b1;
            	SI_IN_EN  	=  1'b0;
            	SO_IN_EN  	=  1'b0;
            	WP_IN_EN  	=  1'b0;
            	SIO3_IN_EN  =  1'b0;
            	if ( Dummy_Count ) 
				  begin
                	Dummy_Count = Dummy_Count - 1;
					if ( Dummy_Count == 3 )
                		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ASP[15:12];
					else if ( Dummy_Count == 2 )
                		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ASP[11:8];
					else if ( Dummy_Count == 1 )
                		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ASP[7:4];
					else if ( Dummy_Count == 0 )
                		{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ASP[3:0];
            	  end
            	else 
				  begin
                	Dummy_Count = 3;
                	{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ASP[15:12];
            	  end
        	  end
        	else 
			  begin
            	SO_OUT_EN =  1'b1;
            	SI_IN_EN  =  1'b0;
            	if ( Dummy_Count ) 
				  begin
                	Dummy_Count = Dummy_Count - 1;
                	SIO1_Reg <= #tV Dummy_ASP[Dummy_Count];
            	  end
            	else 
				  begin
                	Dummy_Count = 15;
                	SIO1_Reg <= #tV Dummy_ASP[Dummy_Count];
            	  end
        	  end
    	  end // end forever
	  end
	endtask // read_ASP_register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read Auto Boot Register                        */
    /*----------------------------------------------------------------------*/
	task read_AB_register;
	reg [31:0] Dummy_AB;
	integer Dummy_Count;
	  begin
		Dummy_Count = ENQUAD ? 8 : 32;
		Dummy_AB = { AB_Reg [7:0], AB_Reg [15:8], AB_Reg [23:16], AB_Reg [31:24] };
		forever
		  begin
			@ ( negedge SCLK or posedge CS_INT );
			if ( CS_INT == 1'b1 ) 
			  begin
				disable read_AB_register;
			  end
			else if ( ENQUAD )
			  begin
				SI_OUT_EN 	= 1'b1;
				WP_OUT_EN 	= 1'b1;
				SIO3_OUT_EN = 1'b1;
				SO_OUT_EN 	= 1'b1;
				SO_IN_EN  	= 1'b0;
				SI_IN_EN  	= 1'b0;
				WP_IN_EN  	= 1'b0;
				SIO3_IN_EN  = 1'b0;
				if ( Dummy_Count )
				  begin
					Dummy_Count = Dummy_Count - 1;
					if ( Dummy_Count == 7 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[31:28];
					else if ( Dummy_Count == 6 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[27:24];
					else if ( Dummy_Count == 5 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[23:20];
					else if ( Dummy_Count == 4 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[19:16];
					else if ( Dummy_Count == 3 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[15:12];
					else if ( Dummy_Count == 2 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[11:8];
					else if ( Dummy_Count == 1 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[7:4];
					else if ( Dummy_Count == 0 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[3:0];
				  end
				else
				  begin
					Dummy_Count = 7;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_AB[31:28];
				  end
			  end
			else
			  begin
				SO_OUT_EN 	= 1'b1;
				SO_IN_EN  	= 1'b0;
				if ( Dummy_Count )
				  begin
					Dummy_Count = Dummy_Count - 1;
					SIO1_Reg <= #tV Dummy_AB[Dummy_Count];
				  end
				else
				  begin
					Dummy_Count = 31;
					SIO1_Reg <= #tV Dummy_AB[Dummy_Count];
				  end
			  end
		  end // end forever
	  end
	endtask // read_AB_register

	/*----------------------------------------------------------------------*/
	/*  Description: Execute read PPB Lock Register                              */
	/*----------------------------------------------------------------------*/
	task read_ppblk_register;
	reg [7:0] Dummy_PPBL;
	integer Dummy_Count;
	  begin
    	Dummy_Count = ENQUAD ? 2 : 8;
    	Dummy_PPBL = PPBL_Reg;
    	forever 
		  begin
        	@ ( negedge SCLK or posedge CS_INT );
        	if ( CS_INT == 1'b1 ) 
			  begin
            	disable read_ppblk_register;
        	  end
			else if (ENQUAD)
			  begin
				SI_OUT_EN	= 1'b1;
				SO_OUT_EN	= 1'b1;
				WP_OUT_EN	= 1'b1;
				SIO3_OUT_EN	= 1'b1;
				SI_IN_EN	= 1'b0;
				SO_IN_EN	= 1'b0;
				WP_IN_EN	= 1'b0;
				SIO3_IN_EN	= 1'b0;
				if ( Dummy_Count )
				  begin
					Dummy_Count = Dummy_Count - 1;
					if ( Dummy_Count == 1 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PPBL[7:4];
					else if ( Dummy_Count == 0 )
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PPBL[3:0];
				  end
				else
				  begin
					Dummy_Count = 1;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PPBL[7:4];
				  end
			  end
        	else 
			  begin
            	SO_OUT_EN =  1'b1;
            	SI_IN_EN  =  1'b0;
            	if ( Dummy_Count ) 
				  begin
                	Dummy_Count = Dummy_Count - 1;
                	SIO1_Reg <= #tV Dummy_PPBL[Dummy_Count];
            	  end
            	else 
				  begin
                	Dummy_Count = 7;
                	SIO1_Reg <= #tV Dummy_PPBL[Dummy_Count];
            	  end
        	  end
    	  end // end forever
	  end
	endtask // read_ppblk_register


	/*----------------------------------------------------------------------*/
	/*  Description: Execute Read Password Register							*/
	/*----------------------------------------------------------------------*/
	task read_password_register;
	reg [63:0] Dummy_PWD;
	integer Dummy_Count;
	  begin
    	Dummy_Count = ENQUAD ? 16 : 64;
    	Dummy_PWD = { Pwd_Reg [7:0], Pwd_Reg [15:8], Pwd_Reg [23:16], Pwd_Reg [31:24],
            		Pwd_Reg [39:32], Pwd_Reg [47:40], Pwd_Reg [55:48], Pwd_Reg [63:56] };
    	forever 
		  begin
        	@ ( negedge SCLK or posedge CS_INT );
        	if ( CS_INT == 1'b1 ) 
			  begin
            	disable read_password_register;
        	  end
			else if ( ENQUAD )
			  begin
                SI_OUT_EN   =  1'b1;
                SO_OUT_EN   =  1'b1;
                WP_OUT_EN   =  1'b1;
                SIO3_OUT_EN =  1'b1;
                SI_IN_EN    =  1'b0;
                SO_IN_EN    =  1'b0;
                WP_IN_EN    =  1'b0;
                SIO3_IN_EN  =  1'b0;
                if ( Dummy_Count )
                  begin
                    Dummy_Count = Dummy_Count - 1;
                    if ( Dummy_Count == 15 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[63:60];
                    else if ( Dummy_Count == 14 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[59:56];
                    else if ( Dummy_Count == 13 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[55:52];
                    else if ( Dummy_Count == 12 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[51:48];
                    else if ( Dummy_Count == 11 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[47:44];
                    else if ( Dummy_Count == 10 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[43:40];
                    else if ( Dummy_Count == 9 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[39:36];
                    else if ( Dummy_Count == 8 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[35:32];
                    else if ( Dummy_Count == 7 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[31:28];
                    else if ( Dummy_Count == 6 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[27:24];
                    else if ( Dummy_Count == 5 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[23:20];
                    else if ( Dummy_Count == 4 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[19:16];
                    else if ( Dummy_Count == 3 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[15:12];
                    else if ( Dummy_Count == 2 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[11:8];
                    else if ( Dummy_Count == 1 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[7:4];
                    else if ( Dummy_Count == 0 )
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[3:0];
                  end
                else
                  begin
                    Dummy_Count = 15;
                    {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_PWD[63:60];
                  end
			  end
        	else 
			  begin
            	SO_OUT_EN =  1'b1;
            	SI_IN_EN  =  1'b0;
            	if ( Dummy_Count ) 
				  begin
                	Dummy_Count = Dummy_Count - 1;
                	SIO1_Reg <= #tV Dummy_PWD[Dummy_Count];
            	  end
            	else 
				  begin
                	Dummy_Count = 63;
                	SIO1_Reg <= #tV Dummy_PWD[Dummy_Count];
            	  end
        	  end
    	  end // end forever
	  end
	endtask // read_password_register





	/*----------------------------------------------------------------------*/
	/*  Description: Execute Read PPB Register                              */
	/*----------------------------------------------------------------------*/
	task read_ppb_register;
	reg [7:0] PPB_Out;
	integer Dummy_Count;
	  begin
    	Dummy_Count = ENQUAD ? 2 : 8;
		if ( (!BAR[7] && !ADD_4B_Mode) && !ENQUAD )
			dummy_cycle(24);						// SPI 3-byte address in
		else if ( (BAR[7] || ADD_4B_Mode) && !ENQUAD )
			dummy_cycle(32);						// SPI 4-byte address in
		else if ( (!BAR[7] && !ADD_4B_Mode) && ENQUAD )
			dummy_cycle(6);							// QPI 3-byte address in
		else if ( (BAR[7] || ADD_4B_Mode) && ENQUAD )
			dummy_cycle(8);							// QPI 4-byte address in
    	#1;
    	Block =  Address[A_MSB:16];
    	if (Block[Block_MSB:0] == 0 && TBPARAM) 
		  begin
        	PPB_Out =  {8{PPB_Reg_BOT0[Address[15:12]]}};
    	  end
    	else if (Block[Block_MSB:0] == 1 && TBPARAM) 
		  begin
        	PPB_Out =  {8{PPB_Reg_BOT1[Address[15:12]]}};
    	  end
    	else if (Block[Block_MSB:0] == Block_NUM-1 && !TBPARAM) 
		  begin
        	PPB_Out =  {8{PPB_Reg_TOP511[Address[15:12]]}};
    	  end
    	else if (Block[Block_MSB:0] == Block_NUM-2 && !TBPARAM) 
		  begin
        	PPB_Out =  {8{PPB_Reg_TOP510[Address[15:12]]}};
    	  end
    	else 
		  begin
        	PPB_Out =  {8{PPB_Reg[Block]}};
    	  end
    	forever 
		  begin
        	@ ( negedge SCLK or posedge CS_INT );
        	if ( CS_INT == 1'b1 ) 
			  begin
            	disable read_ppb_register;
        	  end
        	else 
			  begin
				if (ENQUAD)
				  begin
					SI_OUT_EN	= 1'b1;
					WP_OUT_EN	= 1'b1;
					SIO3_OUT_EN	= 1'b1;
				  end
            	SO_OUT_EN 	= 1'b1;
            	SI_IN_EN  	= 1'b0;
            	SO_IN_EN  	= 1'b0;
            	WP_IN_EN  	= 1'b0;
            	SIO3_IN_EN  = 1'b0;
            	if ( Dummy_Count ) 
				  begin
                	Dummy_Count = Dummy_Count - 1;
					if (ENQUAD)
					  begin
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? PPB_Out[7:4] : PPB_Out[3:0];
					  end
					else
					  begin 
                		SIO1_Reg <= #tV PPB_Out[Dummy_Count];
					  end
            	  end
            	else 
				  begin
					if (ENQUAD)
					  begin	
						Dummy_Count = 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV PPB_Out[7:4];
					  end
					else
					  begin
                		Dummy_Count = 7;
                		SIO1_Reg <= #tV PPB_Out[Dummy_Count];
					  end
            	  end
        	  end
    	  end  // end forever
	  end
 	endtask // read_ppb_register


    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read DYB Register                              */
    /*----------------------------------------------------------------------*/
    task read_dyb_register;
    reg [7:0] DYB_Out;
    integer Dummy_Count;
      begin
        Dummy_Count = ENQUAD ? 2 : 8;
		if ( (!BAR[7] && !ADD_4B_Mode) && !ENQUAD )
        	dummy_cycle(24); 						// SPI 3-byte address in
		else if ( (BAR[7] || ADD_4B_Mode) && !ENQUAD )
        	dummy_cycle(32);						// SPI 4-byte address in
		else if ( (!BAR[7] && !ADD_4B_Mode) && ENQUAD )
        	dummy_cycle(6);							// QPI 3-byte address in
		else if ( (BAR[7] || ADD_4B_Mode) && ENQUAD )
        	dummy_cycle(8);							// QPI 4-byte address in
        #1;
        Block = Address[A_MSB:16];
        if (Block[Block_MSB:0] == 0 && TBPARAM) 
		  begin
            DYB_Out =  {8{DYB_Reg_BOT0[Address[15:12]]}};
          end
        else if (Block[Block_MSB:0] == 1 && TBPARAM) 
		  begin
            DYB_Out =  {8{DYB_Reg_BOT1[Address[15:12]]}};
          end
        else if (Block[Block_MSB:0] == Block_NUM-1 && !TBPARAM) 
		  begin
            DYB_Out =  {8{DYB_Reg_TOP511[Address[15:12]]}};
          end
        else if (Block[Block_MSB:0] == Block_NUM-2 && !TBPARAM) 
		  begin
            DYB_Out =  {8{DYB_Reg_TOP510[Address[15:12]]}};
          end
        else 
		  begin
            DYB_Out =  {8{DYB_Reg[Block]}};
          end
        forever 
		  begin
            @ ( negedge SCLK or posedge CS_INT );
            if ( CS_INT == 1'b1 ) 
			  begin
                disable read_dyb_register;
              end
            else 
			  begin
				if (ENQUAD)
				  begin
					SI_OUT_EN	= 1'b1;
					WP_OUT_EN	= 1'b1;
					SIO3_OUT_EN	= 1'b1;
				  end
                SO_OUT_EN 	= 1'b1;
                SO_IN_EN  	=  1'b0;
                SI_IN_EN  	=  1'b0;
                WP_IN_EN  	=  1'b0;
                SIO3_IN_EN  =  1'b0;
                if ( Dummy_Count ) 
				  begin
                    Dummy_Count = Dummy_Count - 1;
					if (ENQUAD)
					  begin
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? DYB_Out[7:4] : DYB_Out[3:0];
					  end
					else
					  begin
                    	SIO1_Reg <= #tV DYB_Out[Dummy_Count];
					  end
                  end
                else 
				  begin
					if (ENQUAD)
					  begin
						Dummy_Count = 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV DYB_Out[7:4];
					  end
					else
					  begin
                    	Dummy_Count = 7;
                    	SIO1_Reg <= #tV DYB_Out[Dummy_Count];
					  end
                  end
              end
          end  // end forever
	  end
	endtask // read_dyb_register


    /*----------------------------------------------------------------------*/
    /*  Description: define a block erase task                              */
    /*               52 AD1 AD2 AD3                                         */
    /*----------------------------------------------------------------------*/
    task block_erase_32k;
    integer i, j;
    //time ERS_Time;
    integer Start_Add;
    integer End_Add;
   	  begin
		Block		= Address[A_MSB:15];
		Block2		= Address[A_MSB:15];
        Start_Add   = (Address[A_MSB:15]<<15) + 16'h0;
        End_Add     = (Address[A_MSB:15]<<15) + 16'h7fff;
		if ( write_protect(Address) == 1'b0 )
		
//		if ( write_protect(Address) == 1'b0 &&  
//			!(Block[Block_MSB:0] == 0 && TBPARAM && ((Address[15] && !SEC_Pro_Reg_BOT0[15:8]) || (!Address[15] && !SEC_Pro_Reg_BOT0[7:0]))) &&
//			!(Block[Block_MSB:0] == 1 && TBPARAM && ((Address[15] && !SEC_Pro_Reg_BOT1[15:8]) || (!Address[15] && !SEC_Pro_Reg_BOT1[7:0]))) && 
//			!(Block[Block_MSB:0] == 511 && !TBPARAM && ((Address[15] && !SEC_Pro_Reg_TOP511[15:8]) || (!Address[15] && !SEC_Pro_Reg_TOP511[7:0]))) &&
//			!(Block[Block_MSB:0] == 510 && !TBPARAM && ((Address[15] && !SEC_Pro_Reg_TOP510[15:8]) || (!Address[15] && !SEC_Pro_Reg_TOP510[7:0]))) )  
		  begin
          	Status_Reg[0] =  1'b1; // WIP
 			safeguard(Address, sg_protect);
			if ( sg_protect == 1'b0 )
		      begin
         		for( i = Start_Add; i <= End_Add; i = i + 1 )
               	  begin
                  	ARRAY[i] = 8'hxx;
               	  end
              	ERS_Time = ERS_Count_BE32K;
              	fork
                  er_timer;
                  begin
                    for( i = 0; i < ERS_Time; i = i + 1 ) 
					  begin
                        @ ( negedge ERS_CLK or posedge Susp_Trig );
                        if ( Susp_Trig == 1'b1 ) 
						  begin
							Susp_Trig <= #1 1'b0;
                            suspend_erase;
                            $display ( $time, " Resume BE32K Erase ..." );
                          end
                      end
                    //#tECB32 ;
                    for( i = Start_Add; i <= End_Add; i = i + 1 )
                      begin
                        ARRAY[i] = 8'hff;
                      end
                    disable er_timer;
                  end
               	join
               	//WIP : write in process Bit
               	Status_Reg[0] =  1'b0;//WIP
               	//WEL : write enable latch
               	Status_Reg[1] =  1'b0;//WEL
               	BE_Mode = 1'b0;
               	BE32K_Mode = 1'b0;
           	  end // (sg_protect == 1'b0)
          	else 
			  begin // (sg_protect == 1'b1)
           		#tERS_CHK;
				exRPARAM[3] = 1'b1; // E_ERR
				exRPARAM[1] = 1'b1; // PROT_E
			  end
			Status_Reg[1] = 1'b0; //WEL
		  end	// (write_protect(Address) == 1'b0)
		else
		  begin	// if (write_protect(Address) == 1'b1)
			#10; 
			exRPARAM[3] = 1'b1; // E_ERR
			exRPARAM[1] = 1'b1; // PROT_E
			Status_Reg[1] = 1'b0;	// WEL
		  end
		Status_Reg[0] = 1'b0; //WIP
		Status_Reg[1] = 1'b0; //WEL
		BE_Mode = 1'b0;
		BE32K_Mode = 1'b0;
   		WREN_06CMD = 1'b0;
      end
    endtask // block_erase_32k

    /*----------------------------------------------------------------------*/
    /*  Description: define an erase suspend task                           */
    /*----------------------------------------------------------------------*/
    task suspend_erase;
        begin
						WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Erase ..." );
            Status_Reg[0] =  1'b0;//WIP
            Status_Reg[1] =  1'b0;//WEL
						WREN_06CMD		=  1'b0;
            FR_Reg[3]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
            Status_Reg[0] =  1'b1;//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[3]  =  1'b0;
        end
    endtask // suspend_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define an sg erase suspend task                           */
    /*----------------------------------------------------------------------*/
    task suspend_sg_erase;
        begin
			WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Erase ..." );
			SG_Mode = 1'b0;
            Status_Reg[0] =  1'b0;	//WIP
            Status_Reg[1] =  1'b0;	//WEL
			WREN_06CMD		=  1'b0;
            FR_Reg[3]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
				SG_Mode = 1'b1;
            Status_Reg[0] =  1'b1;	//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[3]  =  1'b0;
        end
    endtask // suspend_sg_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define an sir erase suspend task                           */
    /*----------------------------------------------------------------------*/
    task suspend_sir_erase;
        begin
						WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Erase ..." );
						SIR_Mode = 1'b0;
            Status_Reg[0] =  1'b0;//WIP
            Status_Reg[1] =  1'b0;//WEL
						WREN_06CMD		=  1'b0;
            FR_Reg[3]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
						SIR_Mode = 1'b1;
            Status_Reg[0] =  1'b1;//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[3]  =  1'b0;
        end
    endtask // suspend_sir_erase

    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count erase time                     */
    /*----------------------------------------------------------------------*/
    task er_timer;
        begin
            ERS_CLK = 1'b0;
            forever
                begin
                    #(Clock*500) ERS_CLK = ~ERS_CLK;    // erase timer period is 50us
                end
        end
    endtask // er_timer

	/*----------------------------------------------------------------------*/
	/*  Description: Execute  Chip Lock                                     */
	/*----------------------------------------------------------------------*/
	task chip_lock;
      begin
        Status_Reg[0] = 1'b1;
        //#(tWP_SRAM*Block_NUM);
        #(tWP_SRAM);
    	for ( i = 0; i <= 15; i = i + 1 ) 
		  begin
    		DYB_Reg_TOP511[i] = 1'b0;
    		DYB_Reg_TOP510[i] = 1'b0;
    		DYB_Reg_BOT0[i] = 1'b0;
    		DYB_Reg_BOT1[i] = 1'b0;
    	  end
    	for ( i = 0; i <= Block_NUM - 1; i = i + 1 ) 
		  begin
    		DYB_Reg[i] = 1'b0;
    	  end
        Status_Reg[0] = 1'b0;
        Status_Reg[1] = 1'b0;
      end
	endtask // chip_lock


	/*----------------------------------------------------------------------*/
	/*  Description: Execute Chip Block Unlock                              */
	/*----------------------------------------------------------------------*/
	task chip_unlock;
      begin
        Status_Reg[0] = 1'b1;
        #(tWP_SRAM);
    	for ( i = 0; i <= 15; i = i + 1 ) 
		  begin
    		DYB_Reg_TOP511[i] = 1'b1;
    		DYB_Reg_TOP510[i] = 1'b1;
    		DYB_Reg_BOT0[i] = 1'b1;
    		DYB_Reg_BOT1[i] = 1'b1;
    	  end
    	for ( i = 0; i <= Block_NUM - 1; i = i + 1 ) 
		  begin
    		DYB_Reg[i] = 1'b1;
    	  end
        Status_Reg[0] = 1'b0;
        Status_Reg[1] = 1'b0;
      end
	endtask // chip_unlock


    /*----------------------------------------------------------------------*/
    /*	Description: define a block erase task				    */
    /*		     D8 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task block_erase;
	integer i, j;
   	//time ERS_Time;
   	integer Start_Add;
    integer End_Add;
	  begin
		Block 	= Address[A_MSB:16];
		Block2 	= Address[A_MSB:16];
	   	Start_Add	= (Address[A_MSB:16]<<16) + 16'h0;
	   	End_Add	= (Address[A_MSB:16]<<16) + 16'hffff;
		if ( write_protect(Address) == 1'b0 ) 
//		if ( write_protect(Address) == 1'b0 && 
//			!(Block[Block_MSB:0] == 0 && !SEC_Pro_Reg_BOT0 && TBPARAM) &&
//			!(Block[Block_MSB:0] == 1 && !SEC_Pro_Reg_BOT1 && TBPARAM) &&
//			!(Block[Block_MSB:0] == Block_NUM-1 && !SEC_Pro_Reg_TOP511 && !TBPARAM) &&
//			!(Block[Block_MSB:0] == Block_NUM-2 && !SEC_Pro_Reg_TOP510 && !TBPARAM) )
		  begin
	   		Status_Reg[0] =  1'b1; // WIP
  			safeguard(Address, sg_protect);
      		if ( sg_protect == 1'b0 ) 
			  begin
               	for( i = Start_Add; i <= End_Add; i = i + 1 )
             	  begin
                   	ARRAY[i] = 8'hxx;
               	  end
               	ERS_Time = ERS_Count_BE;
               	fork
                  er_timer;
                  begin
                    for( j = 0; j < ERS_Time; j = j + 1 ) 
					  begin
                        @ ( negedge ERS_CLK or posedge Susp_Trig );
                        if ( Susp_Trig == 1'b1 ) 
						  begin
                            suspend_erase;
                            $display ( $time, " Resume BE Erase ..." );
                          end
                      end
                       //#tECB64 ;
                    for( i = Start_Add; i <= End_Add; i = i + 1 )
                      begin
                        ARRAY[i] = 8'hff;
                      end
                    disable er_timer;
                  end
               	join
			  end // ( sg_protect == 1'b0 )
      		else 
  			  begin // ( sg_protect == 1'b1 )
          		#tERS_CHK;
				exRPARAM[3] = 1'b1; // E_ERR
				exRPARAM[1] = 1'b1; // PROT_E
       		  end   
			Status_Reg[1] =  1'b0;//WEL
		  end // ( write_protect(Address) == 1'b0 )
		else 
		  begin 
	       	#10;	
			Status_Reg[1] =  1'b0;//WEL
			exRPARAM[3] = 1'b1; // E_ERR
			exRPARAM[1] = 1'b1; // PROT_E
		  end
		Status_Reg[0] =  1'b0;//WIP
		BE_Mode = 1'b0;
      	BE64K_Mode = 1'b0;
		WREN_06CMD		=  1'b0;
	  end 
    endtask // block_erase

    /*----------------------------------------------------------------------*/
    /*	Description: define a sector 4k erase task			    */
    /*		     20 AD1 AD2 AD3					    */
    /*		     D7 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task sector_erase_4k;
	integer i, j;
    //time ERS_Time;
    integer Start_Add;
    integer End_Add;
	  begin
		if (SG_Mode ==1'b1) 
		  begin
			Start_Add = 8'h00;
			End_Add  =  8'hFF;
		  end
		else if (SIR_Mode == 1'b1) 
		  begin
			Start_Add = 8'h00;
			End_Add  =  8'hff;
		  end
		else 
		  begin // Main
	   		Start_Add	= (Address[A_MSB:12]<<12) + 12'h000;
	   		End_Add	= (Address[A_MSB:12]<<12) + 12'hfff;
		  end      
		if ( write_protect(Address) == 1'b0 ) 
		  begin
	    	Status_Reg[0] =  1'b1;	// WIP
  			safeguard(Address, sg_protect);
      		if ( sg_protect == 1'b0 ) 
			  begin
        		for( i = Start_Add; i <= End_Add; i = i + 1 )
          		  begin
          			if (SG_Mode == 1'b1) SG_ARRAY[i] = 8'hxx;
  					else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b00)) SIR0_ARRAY[i] = 8'hxx;
					else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b01)) SIR1_ARRAY[i] = 8'hxx;
					else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b10)) SIR2_ARRAY[i] = 8'hxx;
					else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b11)) SIR3_ARRAY[i] = 8'hxx;
					else ARRAY[i] = 8'hxx;
          		  end
          		ERS_Time = ERS_Count_SE;
         		fork 
					er_timer;
         		  begin
         			for( j = 0; j < ERS_Time; j = j + 1 ) 
					  begin
           				@ ( negedge ERS_CLK or posedge Susp_Trig );
             			if ( Susp_Trig == 1'b1 ) 
						  begin
  							if (SG_Mode == 1'b1) suspend_sg_erase;
							else if (SIR_Mode == 1'b1) suspend_sir_erase;
             				else suspend_erase;
               				$display ( $time, " Resume SE Erase ..." );
             			  end
          			  end
          			for( i = Start_Add; i <= End_Add; i = i + 1 )
         			  begin
          				if (SG_Mode == 1'b1) SG_ARRAY[i] = 8'hff;
  						else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b00)) SIR0_ARRAY[i] = 8'hff;
						else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b01)) SIR1_ARRAY[i] = 8'hff;
						else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b10)) SIR2_ARRAY[i] = 8'hff;
						else if ((SIR_Mode == 1'b1) && (Address[13:12] == 2'b11)) SIR3_ARRAY[i] = 8'hff;
						else ARRAY[i] = 8'hff;
         			  end
         			disable er_timer;
       			  end
        		join
      		  end	// ( sg_protect == 1'b0 )
  	   		else 
  			  begin // ( sg_protect == 1'b1 )
  	       		#tERS_CHK;
				exRPARAM[3] = 1'b1; // E_ERR
				exRPARAM[1] = 1'b1; // PROT_E
  	   		  end
			Status_Reg[1] = 1'b0;//WEL
		  end // ( write_protect(Address) == 1'b0 )
		else 
		  begin
			#10;
			Status_Reg[1] = 1'b0;//WEL
			exRPARAM[3] = 1'b1; // E_ERR
			exRPARAM[1] = 1'b1; // PROT_E
		  end
		Status_Reg[0] = 1'b0;//WIP
		SER_Mode = 1'b0;
  		SG_Mode = 1'b0;
		SIR_Mode = 1'b0;
		WREN_06CMD		=  1'b0;
	  end
    endtask // sector_erase_4k
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a chip erase task				    */
    /*		     60(C7)						    */
    /*----------------------------------------------------------------------*/
/*
	task chip_erase; // with ASP mode
	integer i, j, k;
      begin
        Status_Reg[0] =  1'b1;
//      Secur_Reg[5]  =  1'b0;
//      Secur_Reg[6]  =  1'b0;
        if ( (Dis_CE == 1'b1) || 
			 !(SEC_Pro_Reg_BOT0 || SEC_Pro_Reg_BOT1 || SEC_Pro_Reg_TOP511 || SEC_Pro_Reg_TOP510 || (|SEC_Pro_Reg)) ) 
		  begin
            #tERS_CHK;
//          Secur_Reg[6] = 1'b1;
          end
        else 
		  begin
            for ( i = 0;i<tECC/100;i = i + 1) 
			  begin
                #100;
              end
    		if ( Dis_CE == 1'b0 ) 
			  begin
                for( i = 0; i <Block_NUM; i = i+1 ) 
				  begin
            		if ( i == 0 ) 
					  begin: bot0_check
            			for ( k = 0; k <= 15; k = k + 1 ) 
						  begin
                			if ( SEC_Pro_Reg_BOT0[k] == 1'b0 && TBPARAM ) 
							  begin
                    			disable bot0_check;
                			  end
            			  end
            			Address = (i<<16) + 16'h0;
            			Start_Add = (i<<16) + 16'h0;
            			End_Add   = (i<<16) + 16'hffff;
            			for( j = Start_Add; j <=End_Add; j = j + 1 ) 
						  begin
                			ARRAY[j] =  8'hff;
            			  end
            		  end
            		else if ( i == 1 ) 
					  begin: bot1_check
            			for ( k = 0; k <= 15; k = k + 1 ) 
						  begin
                			if ( SEC_Pro_Reg_BOT1[k] == 1'b0 && TBPARAM ) 
							  begin
                    			disable bot1_check;
                			  end
            			  end
            			Address = (i<<16) + 16'h0;
            			Start_Add = (i<<16) + 16'h0;
            			End_Add   = (i<<16) + 16'hffff;
            			for( j = Start_Add; j <=End_Add; j = j + 1 ) 
						  begin
                			ARRAY[j] =  8'hff;
            			  end
            		  end
            		else if ( i == Block_NUM -1 ) 
					  begin: top511_check
            			for ( k = 0; k <= 15; k = k + 1 ) 
						  begin
                			if ( SEC_Pro_Reg_TOP511[k] == 1'b0 && !TBPARAM ) 
							  begin
                    			disable top511_check;
                			  end
            			  end
            			Address = (i<<16) + 16'h0;
            			Start_Add = (i<<16) + 16'h0;
            			End_Add   = (i<<16) + 16'hffff;
            			for( j = Start_Add; j <=End_Add; j = j + 1 ) 
						  begin
                			ARRAY[j] =  8'hff;
            			  end
            		  end
            		else if ( i == Block_NUM -2 ) 
					  begin: top510_check
            			for ( k = 0; k <= 15; k = k + 1 ) 
						  begin
                			if ( SEC_Pro_Reg_TOP510[k] == 1'b0 && !TBPARAM ) 
							  begin
                    			disable top510_check;
                			  end
            			  end
            			Address = (i<<16) + 16'h0;
            			Start_Add = (i<<16) + 16'h0;
            			End_Add   = (i<<16) + 16'hffff;
            			for( j = Start_Add; j <=End_Add; j = j + 1 ) 
						  begin
                			ARRAY[j] =  8'hff;
            			  end
            		  end
            		else 
					  begin
                    	Address = (i<<16) + 16'h0;
            			if ( SEC_Pro_Reg[i] == 1'b1 ) 
						  begin
                        	Start_Add = (i<<16) + 16'h0;
                        	End_Add   = (i<<16) + 16'hffff;
                        	for( j = Start_Add; j <=End_Add; j = j + 1 ) 
							  begin
                                ARRAY[j] =  8'hff;
                        	  end
            			  end
            		  end
        	  	  end
    		  end
    		else 
			  begin
        		for( i = 0; i <Block_NUM; i = i+1 ) 
				  begin
        			Address = (i<<16) + 16'h0;
        			Start_Add = (i<<16) + 16'h0;
        			End_Add   = (i<<16) + 16'hffff;
        			for( j = Start_Add; j <=End_Add; j = j + 1 ) 
					  begin
            			ARRAY[j] =  8'hff;
        			  end
        		  end
    		  end
    	  end
        //WIP : write in process Bit
        Status_Reg[0] = 1'b0;//WIP
        //WEL : write enable latch
        Status_Reg[1] = 1'b0;//WEL
    	CE_Mode = 1'b0;
      end
	endtask // chip_erase   
*/

    task chip_erase;		// with Safeguard function
	integer i, j, k;
   	integer Start_Add;
    integer End_Add;
	reg [A_MSB:0] A_tmp;
	  begin
		if (write_protect(A_tmp) == 1'b0) 
		  begin
	    	Status_Reg[0] =  1'b1;
			for(j = 0; j < Block_NUM; j = j + 1) 
			  begin
				A_tmp[A_MSB:16] = j;
				A_tmp[15:0] = 16'b0;
	    		Start_Add	= (A_tmp[A_MSB:16]<<16) + 16'h0;
	    		End_Add	= (A_tmp[A_MSB:16]<<16) + 16'hffff;
  				safeguard(A_tmp, sg_protect);
      			if ( sg_protect == 1'b0 ) 
				  begin
               		for( i = Start_Add; i <= End_Add; i = i + 1 )
               		  begin
                   		ARRAY[i] = 8'hxx;
               		  end
               		ERS_Time = Echip_Count/Block_NUM;
               		  fork
                  		er_timer;
                  		  begin
                    		for( i = 0; i < ERS_Time; i = i + 1 ) 
							  begin
                        		@ ( negedge ERS_CLK );
                      		  end
                    		//#tECB64 ;
                    		for( i = Start_Add; i <= End_Add; i = i + 1 )
                      		  begin
                        		ARRAY[i] = 8'hff;
                   	  		  end
                    		disable er_timer;
                  		  end
               		  join
	    		  end
  	   			else // sg_protect == 1'b1
  				  begin
  	       			#tERS_CHK;
       			  end
			  end // j-loop   
				Status_Reg[1] =  1'b0;//WEL
		  end	// write_protect == 0
		else 
		  begin // write_protect == 1
			#10;
			Status_Reg[1] =  1'b0;//WEL
       	  end
		Status_Reg[0] =  1'b0;	//WIP
		Status_Reg[1] =  1'b0;	// no reset WEL if write_protect	
		CE_Mode = 1'b0;
		WREN_06CMD		=  1'b0;
	  end
    endtask // chip_erase	



    /*----------------------------------------------------------------------*/
    /*	Description: define a page program task				    */
    /*		     02 AD1 AD2 AD3	DAT ...				    */
    /*----------------------------------------------------------------------*/
    task page_program;
			input  [A_MSB:0]  Address;
			reg    [7:0]	  Offset;
			integer Dummy_Count, Tmp_Int, i;
			begin
	    	Dummy_Count = Buffer_Num;    // page size
	    	Tmp_Int = 0;
        Offset  = Address[7:0];
	    /*------------------------------------------------*/
	    /*	Store 256 bytes into a temp buffer - Dummy_A  */
	    /*------------------------------------------------*/
      	for (i = 0; i < Dummy_Count ; i = i + 1 ) begin Dummy_A[i]  = 8'hff; end

	    	forever begin
					@ ( posedge SCLK_INT or posedge CS_INT );
					if ( CS_INT == 1'b1 ) begin
		    		if ( (Tmp_Int % 8 !== 0) || (Tmp_Int == 1'b0) ) begin
							PP_4XIO_Mode = 0;
							PP_1XIO_Mode = 0;
							disable page_program;		// exit for non-byte input (invalid)
		    		end
		    		else begin
		        	if ( Tmp_Int > 8 ) Byte_PGM_Mode = 1'b0;
              else Byte_PGM_Mode = 1'b1;
							update_array ( Address );
		    		end
		    		disable page_program;			// exit for successfully finished program
					end		// CS_INT == 1'b1
					else begin  // count how many Bits been shifted
		    		Tmp_Int = ( PP_4XIO_Mode | ENQUAD ) ? Tmp_Int + 4 : Tmp_Int + 1;
		    		if ( Tmp_Int % 8 == 0) begin
            	#1;
		        	Dummy_A[Offset] = SI_Reg [7:0];
		        	Offset = Offset + 1;   
            	Offset = Offset[7:0];   
            end  
					end
	    	end  // end forever
			end
    endtask // page_program

    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic signature ID (RDESID)			    */
    /*		     AB X X X						    */
    /*----------------------------------------------------------------------*/
    task read_esid;
			reg  [7:0] Dummy_ID;
			integer Dummy_Count;
			begin
				Dummy_Count = ENQUAD ? 2 : 8;
				if (ENQUAD) begin dummy_cycle(5); end
				else begin dummy_cycle(23); end
				Dummy_ID = Device_ID;
				dummy_cycle(1);

				forever begin
					@ ( negedge SCLK_INT or posedge CS_INT );
					if ( CS_INT == 1'b1 ) begin disable read_esid; end 
					else begin  
						if (ENQUAD) begin
							SI_OUT_EN    = 1'b1;
							WP_OUT_EN    = 1'b1;
							SIO3_OUT_EN  = 1'b1;
						end
						SO_OUT_EN = 1'b1;
						SO_IN_EN  = 1'b0;
						SI_IN_EN  = 1'b0;
						WP_IN_EN  = 1'b0;
						SIO3_IN_EN= 1'b0;
						if ( Dummy_Count ) begin
							Dummy_Count = Dummy_Count - 1;
							if (ENQUAD) begin
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? Dummy_ID[7:4] : Dummy_ID[3:0];
							end
							else begin
								SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
							end
						end
						else begin
							if (ENQUAD) begin
								Dummy_Count = 1;
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[7:4];
							end
							else begin
								Dummy_Count = 7;
								SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
							end
		   			end
					end
				end // end forever	 
			end
    endtask // read_esid
	    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic manufacturer & device ID	    */
    /*----------------------------------------------------------------------*/
    task read_mdid;
	reg  [15:0] Dummy_ID;
	integer Dummy_Count;
	begin
		if (ENQUAD) Dummy_Count = 4;
		else Dummy_Count = 16;
		if (ENQUAD) dummy_cycle(6);
		else dummy_cycle(24);
		#1;
		if ( Address[0] == 1'b0 ) begin
			Dummy_ID = {MID_ISSI,Device_ID};
		end
		else begin
			Dummy_ID = {Device_ID,MID_ISSI};
		end
		forever begin
			@ ( negedge SCLK_INT or posedge CS_INT );
			if ( CS_INT == 1'b1 ) begin
				disable read_mdid;
			end
			else begin
				if (ENQUAD) begin
					SI_OUT_EN    = 1'b1;
					WP_OUT_EN    = 1'b1;
					SIO3_OUT_EN  = 1'b1;
				end
				SO_OUT_EN = 1'b1;
				SO_IN_EN  = 1'b0;
				SI_IN_EN  = 1'b0;
				WP_IN_EN  = 1'b0;
				SIO3_IN_EN= 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					if (ENQUAD) begin
						if ( Dummy_Count == 3 )
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[15:12];
						else if ( Dummy_Count == 2 )
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[11:8];
						else if ( Dummy_Count == 1 )
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[7:4];
						else if ( Dummy_Count == 0 )
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[3:0];
					end
					else begin
						SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
					end
				end
				else begin
					if (ENQUAD) begin
						Dummy_Count = 3;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_ID[15:12];
					end
					else begin
						Dummy_Count = 15;
						SIO1_Reg <= #tV Dummy_ID[Dummy_Count];
					end
				end
			end
		end	// end forever
	end
    endtask // read_mdid

    /*----------------------------------------------------------------------*/
    /*	Description: define a program chip task				    */
    /*	INPUT:address                            			    */
    /*----------------------------------------------------------------------*/
    task update_array;
	input [A_MSB:0] Address;
	integer Dummy_Count, i, j;
    integer program_time;
    reg [7:0]  ori [0:Buffer_Num-1];
	reg [A_MSB:0] A_tmp;
  	reg [A_MSB_SG:0] A_SG_tmp;
	//wire [7:0] ARRAY5 = ARRAY[5];
	  begin
	   	Dummy_Count = Buffer_Num;
        A_tmp = { Address [A_MSB:8], 8'h00 };
//		A_SG_tmp = { Address [A_MSB_SG:8], 8'h00 };
  		A_SG_tmp = 8'h00 ;
        program_time = (Byte_PGM_Mode) ? tBP : tPP;
		if ( write_protect(A_tmp) == 1'b0 ) 
		  begin
	    	Status_Reg[0]= 1'b1;
  			safeguard(A_tmp, sg_protect);
  	   		if ( sg_protect == 1'b0 ) 
			  begin
        		for ( i = 0; i < Dummy_Count; i = i + 1 ) 
				  begin
          			if ( SIR_Mode == 1'b1) 
					  begin
						if (A_tmp[13:12] == 2'b00) 
						  begin
            				ori[i] = SIR0_ARRAY[i];
            				SIR0_ARRAY[i] = SIR0_ARRAY[i] & 8'bx;
						  end
						else if (A_tmp[13:12] == 2'b01) 
						  begin
            				ori[i] = SIR1_ARRAY[i];
            				SIR1_ARRAY[i] = SIR1_ARRAY[i] & 8'bx;
						  end
						else if (A_tmp[13:12] == 2'b10) 
						  begin
            				ori[i] = SIR2_ARRAY[i];
            				SIR2_ARRAY[i] = SIR2_ARRAY[i] & 8'bx;
						  end
						else if (A_tmp[13:12] == 2'b11) 
						  begin
            				ori[i] = SIR3_ARRAY[i];
            				SIR3_ARRAY[i] = SIR3_ARRAY[i] & 8'bx;
						  end
            		  end // SIR_Mode
           			else if ( SG_Mode == 1'b1 ) 
  					  begin
           				ori[i] = SG_ARRAY[A_SG_tmp + i];
           				SG_ARRAY[A_SG_tmp+ i] = SG_ARRAY[A_SG_tmp + i] & 8'bx;
           			  end // SG_Mode
            		else 
					  begin
            			ori[i] = ARRAY[A_tmp + i];
            			ARRAY[A_tmp+ i] = ARRAY[A_tmp + i] & 8'bx;
            		  end
          		  end // for loop
    	      	fork pg_timer;
				  begin
    	      		for( j = 0; j*2 < program_time; j = j + 1 ) 
					  begin
    	       			@ ( negedge PGM_CLK or posedge Susp_Trig );
    	       			if ( Susp_Trig == 1'b1 ) 
						  begin
    	       				if (SG_Mode == 1'b1) 
								suspend_sg_program;
    	       				else if (SIR_Mode == 1'b1) 
								suspend_sir_program;
							else 
								suspend_program;
    	       				$display ( $time, " Resume program ..." );
    	        		  end
    	      		  end
    	      		//#program_time ;
    	      		for ( i = 0; i < Dummy_Count; i = i + 1 ) 
					  begin
    	      			if ( SIR_Mode == 1'b1) 
						  begin
							if (A_tmp[13:12] == 2'b00) SIR0_ARRAY[i] = ori[i] & Dummy_A[i];
							else if (A_tmp[13:12] == 2'b01) SIR1_ARRAY[i] = ori[i] & Dummy_A[i];
							else if (A_tmp[13:12] == 2'b10) SIR2_ARRAY[i] = ori[i] & Dummy_A[i];
							else if (A_tmp[13:12] == 2'b11) SIR3_ARRAY[i] = ori[i] & Dummy_A[i];
						  end	// SIR_Mode
    	      			else if (SG_Mode == 1'b1) 
						  begin
    	      				SG_ARRAY[A_SG_tmp+ i] = ori[i] & Dummy_A[i];
  						  end
    	      			else 
						  begin
    	      				ARRAY[A_tmp+ i] = ori[i] & Dummy_A[i];
						  end
    	      		  end
    	      		disable pg_timer;
    	   	 	  end // begin of fork
    	      	join // fork
		   	  end // (sg_protect == 1'b0)
		   	else 
			  begin		// (sg_protect == 1'b1)
  		  		#tPGM_CHK ;
				exRPARAM[2] = 1'b1; // P_ERR
				exRPARAM[1] = 1'b1; // PROT_E
  		  	  end
		   	Status_Reg[1] = 1'b0;
		  end		// (write_protect(A_tmp) == 1'b0
		else 
		  begin 	// (write_protect(A_tmp) == 1'b1
			#10;
			exRPARAM[2] = 1'b1; // P_ERR
			exRPARAM[1] = 1'b1; // PROT_E
		  end
   		Status_Reg[0] = 1'b0;
   		Status_Reg[1] = 1'b0;
   		PP_4XIO_Mode = 1'b0;
   		PP_1XIO_Mode = 1'b0;
   		Byte_PGM_Mode = 1'b0;
		SIR_Mode = 1'b0;
  		SG_Mode = 1'b0;
		WREN_06CMD		=  1'b0;
	  end 
    endtask // update_array

    /*----------------------------------------------------------------------*/
    /*  Description: define a program suspend task                          */
    /*----------------------------------------------------------------------*/
    task suspend_program;
        begin
            WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Program ..." );
            Status_Reg[0] =  1'b0;//WIP
            Status_Reg[1] =  1'b0;//WEL
						WREN_06CMD		=  1'b0;
            FR_Reg[2]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
            Status_Reg[0] =  1'b1;//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[2]  =  1'b0;
        end
    endtask // suspend_program

    /*----------------------------------------------------------------------*/
    /*  Description: define a sir program suspend task                          */
    /*----------------------------------------------------------------------*/
    task suspend_sir_program;
        begin
            WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Program ..." );
						SIR_Mode = 1'b0;
            Status_Reg[0] =  1'b0;//WIP
            Status_Reg[1] =  1'b0;//WEL
						WREN_06CMD		=  1'b0;
            FR_Reg[2]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
						SIR_Mode = 1'b1;
            Status_Reg[0] =  1'b1;//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[2]  =  1'b0;
        end
    endtask // suspend_sir_program

    /*----------------------------------------------------------------------*/
    /*  Description: define a safeguard program suspend task                */
    /*----------------------------------------------------------------------*/
    task suspend_sg_program;
        begin
            WR2Susp = 1;
            #tSUS;
            $display ( $time, " Suspend Program ..." );
			SG_Mode = 1'b0;
            Status_Reg[0] =  1'b0;//WIP
            Status_Reg[1] =  1'b0;//WEL
			WREN_06CMD		=  1'b0;
            FR_Reg[2]  =  1'b1;
            WR2Susp = 0;
            @ ( Resume_Event );
				SG_Mode = 1'b1;
            Status_Reg[0] =  1'b1;//WIP
            //Status_Reg[1] =  1'b1;//WEL
            FR_Reg[2]  =  1'b0;
        end
    endtask // suspend_sg_program
  

    /*----------------------------------------------------------------------*/
    /*  Description: define a timer to count program time                   */
    /*----------------------------------------------------------------------*/
    task pg_timer;
        begin
            PGM_CLK = 1'b0;
            forever
                begin
                    #1 PGM_CLK = ~PGM_CLK;    // program timer period is 2ns
                end
        end
    endtask // pg_timer

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Read Bank Address Register						*/
    /*----------------------------------------------------------------------*/
    task read_BA_Register;
    integer Dummy_Count;
      begin
		if (ENQUAD) 
		  begin
            Dummy_Count = 2;
          end
        else 
		  begin
            Dummy_Count = 8;
          end
        forever @ ( negedge SCLK or posedge CS_INT ) 
		  begin // output Reading Bank Address register info
        	if ( CS_INT == 1 ) 
			  begin
            	disable read_BA_Register;
        	  end
         	else  
			  begin
                if (ENQUAD) 
				  begin
                    SI_OUT_EN    = 1'b1;
                    WP_OUT_EN    = 1'b1;
                    SIO3_OUT_EN  = 1'b1;
                  end
            	SO_OUT_EN 	= 1'b1;
                SO_IN_EN  	= 1'b0;
                SI_IN_EN  	= 1'b0;
                WP_IN_EN  	= 1'b0;
                SIO3_IN_EN	= 1'b0;
            	if ( Dummy_Count ) 
				  begin
            		Dummy_Count = Dummy_Count - 1;
                    if (ENQUAD) 
					  begin
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? BAR[7:4] : BAR[3:0];
                      end
                   	else 
					  begin
                        SIO1_Reg    <= #tV BAR[Dummy_Count];
                      end
            	  end
            	else 
				  begin
                    if (ENQUAD) 
					  begin
                        Dummy_Count = 1;
                        {SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV BAR[7:4];
                      end
                    else 
					  begin
                        Dummy_Count = 7;
                        SIO1_Reg    <= #tV BAR[Dummy_Count];
                      end
            	  end
        	  end
		  end // forever
      end
    endtask // read_BA_Register

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Write Bank Address Register					*/
    /*----------------------------------------------------------------------*/
	task write_ba_register;
    reg [7:0] BA_Reg_Up;
      begin
        WRBAR_Mode       = 1'b1;
        //$display( $time, " Old Bank Address Register = %b", BAR );
        BA_Reg_Up = SI_Reg[7:0];

        Status_Reg[0]   = 1'b1;
        #tW;
        BAR_NV[0]   =  BA_Reg_Up[0];
        BAR_NV[6:1] =  6'b000000;
        BAR_NV[7]   =  BA_Reg_Up[7];
        BAR[0]   =  BAR_NV[0];
        BAR[6:1] =  6'b000000;
        BAR[7]   =  BAR_NV[7];

        //WIP:Write Enable Latch
        Status_Reg[0]   = 1'b0;
        //WEL:Write Enable Latch
        Status_Reg[1]   = 1'b0;
        WRBAR_Mode       = 1'b0;
      end
	endtask // write_ba_register


    /*----------------------------------------------------------------------*/
    /*	Description: Execute 2X IO Read Mode				    */
    /*		     BB AD1 AD2 AD3	DMY DAT ...				    */
    /*----------------------------------------------------------------------*/
    task read_2xio;
	reg  [7:0]  OUT_Buf;
	integer     Dummy_Count;
	  begin
	   	Dummy_Count=4;
	   	SI_IN_EN = 1'b1;
	   	SO_IN_EN = 1'b1;
	   	SI_OUT_EN = 1'b0;
	   	SO_OUT_EN = 1'b0;
	   	if ( !BAR[7] && !ADD_4B_Mode ) 
			dummy_cycle(12); // for 3-byte address in
	   	else if ( BAR[7] || ADD_4B_Mode ) 
			dummy_cycle(16); // for 4-byte address in

		  begin
			fork
			  begin
				if ( RPARAM[6:3] == 4'b0000 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0001 )
				  begin
					dummy_cycle(1);
				  end
				else if ( RPARAM[6:3] == 4'b0010 )
				  begin
					dummy_cycle(2);
				  end
				else if ( RPARAM[6:3] == 4'b0011 )
				  begin
					dummy_cycle(3);
				  end
				else if ( RPARAM[6:3] == 4'b0100 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0101 )
				  begin
					dummy_cycle(5);
				  end
				else if ( RPARAM[6:3] == 4'b0110 )
				  begin
					dummy_cycle(6);
				  end
				else if ( RPARAM[6:3] == 4'b0111 )
				  begin
					dummy_cycle(7);
				  end
				else if ( RPARAM[6:3] == 4'b1000 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b1001 )
				  begin
					dummy_cycle(9);
				  end
				else if ( RPARAM[6:3] == 4'b1010 )
				  begin
					dummy_cycle(10);
				  end
				else if ( RPARAM[6:3] == 4'b1011 )
				  begin
					dummy_cycle(11);
				  end
				else if ( RPARAM[6:3] == 4'b1100 )
				  begin
					dummy_cycle(12);
				  end
				else if ( RPARAM[6:3] == 4'b1101 )
				  begin
					dummy_cycle(13);
				  end
				else if ( RPARAM[6:3] == 4'b1110 )
				  begin
					dummy_cycle(14);
				  end
				else if ( RPARAM[6:3] == 4'b1111 )
				  begin
					dummy_cycle(15);
				  end
//	    	dummy_cycle(4);		// first DMY byte: AX input for BBh command
	    		#1;
	    		if (RDDIO_Mode && (SI_Reg[7:4] == 4'hA)) 
					Set_2XIO_Enhance_Mode = 1'b1;	// RDDIO_Mode is BBh read only
	    		else	
					Set_2XIO_Enhance_Mode = 1'b0; 
				// Dummy Clock
//        if ( RPARAM[4] == 1'b1 ) dummy_cycle(4);
				#1;
//				Prea_OUT_EN2 <= #tV 1'b0;
				read_array(Address, OUT_Buf);
          
	    		forever @ ( negedge SCLK_INT or  posedge CS_INT ) 
				  begin
	      			if ( CS_INT == 1'b1 ) 
					  begin 
						disable read_2xio; 
					  end
	        		else 
					  begin
		    			Read_Mode	= 1'b1;
		    			SO_OUT_EN	= 1'b1;
		    			SI_OUT_EN	= 1'b1;
		    			SI_IN_EN	= 1'b0;
		    			SO_IN_EN	= 1'b0;
		    			if ( Dummy_Count ) 
						  begin
							Dummy_Count = Dummy_Count - 1;
							if ( Dummy_Count == 3 )
//								if (DTR_Mode)
//									{SIO1_Reg, SIO0_Reg} = #(tV-3) OUT_Buf[7:6] ;
//								else
									{SIO1_Reg, SIO0_Reg} = #tV OUT_Buf[7:6];
							else if ( Dummy_Count == 2 )
//								if (DTR_Mode)
//									{SIO1_Reg, SIO0_Reg} = #(tV-3) OUT_Buf[5:4] ;
//								else
									{SIO1_Reg, SIO0_Reg} = #tV OUT_Buf[5:4];
							else if ( Dummy_Count == 1 )
//								if (DTR_Mode)
//									{SIO1_Reg, SIO0_Reg} = #(tV-3) OUT_Buf[3:2] ;
//								else
									{SIO1_Reg, SIO0_Reg} = #tV OUT_Buf[3:2];
							else if ( Dummy_Count == 0 )
//								if (DTR_Mode)
//									{SIO1_Reg, SIO0_Reg} = #(tV-3) OUT_Buf[1:0] ;
//								else
									{SIO1_Reg, SIO0_Reg} = #tV OUT_Buf[1:0];
		    			  end
		    			else 
						  begin
            				if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              					Address = {Address[A_MSB:3], 3'b000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              					Address = {Address[A_MSB:5], 5'b0_0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              					Address = {Address[A_MSB:6], 6'b00_0000};
              				else
              					Address = Address + 1;

              				load_address(Address);
              				read_array(Address, OUT_Buf);
							Dummy_Count = 3;
//							if (DTR_Mode)
//							 	{SIO1_Reg, SIO0_Reg} = #(tV-3) OUT_Buf[7:6] ;
//							else
							 	{SIO1_Reg, SIO0_Reg} = #tV OUT_Buf[7:6];
		    			  end
	        		  end
	    			end//forever  

//			  begin
//				if (CR[4] )
//				  begin
//					dummy_cycle_prea(2);
//					Prea_OUT_EN2 = 1'b1;
//					preamble_bit_out;
//				  end
//			  end

			  end
			join
		  end
	  end
    endtask // read_2xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute 4X IO Read Mode				    */
		/*	spi EB AD1 AD2 AD3 DMY... DAT...								*/
		/*	qpi XX AD1 AD2 AD3 DMY... DAT...								*/
    /*----------------------------------------------------------------------*/
    task read_4xio;
	//reg [A_MSB:0] Address;
	reg [7:0]   OUT_Buf ;
	integer	    Dummy_Count;
	  begin
	   	Dummy_Count = 2;
	   	SI_OUT_EN   = 1'b0;
	   	SO_OUT_EN   = 1'b0;
	   	WP_OUT_EN   = 1'b0;
	   	SIO3_OUT_EN = 1'b0;
	   	SI_IN_EN	= 1'b1;
	   	SO_IN_EN	= 1'b1;
	   	WP_IN_EN	= 1'b1;
	   	SIO3_IN_EN  = 1'b1;
//  	if ( BAR[7] || ADD_4B_Mode || CMD_BUS == READ4X4B || (!RDQIO_Mode && (CMD_BUS == RSTEN || CMD_BUS == RST) && EN4XIO_Read_Mode == 1'b1) ) 
//		  begin
//	   		ADD_4B_Mode = 1'b1;
//			dummy_cycle(8);		// for 4-byte address in
//		  end
//	   	else 
			dummy_cycle(6);		// for 3-byte address in

		if ( RPARAM[6:3] == 4'b0001 )
		  begin
			dummy_cycle(1);
			Set_4XIO_Enhance_Mode = 1'b0; 
		  end
		else
	   		dummy_cycle(2);		// first DMY byte: AX input for EBh command
	   	#1;
	   	if (RDQIO_Mode && (SI_Reg[7:4] == 4'hA)) 
			Set_4XIO_Enhance_Mode = 1'b1;	// RDQIO_Mode is EBh read only
	   	else	
			Set_4XIO_Enhance_Mode = 1'b0; 

		  begin
			fork
			  begin	
				// Dummy Clock
        		if ( RPARAM[6:3] == 4'b0000 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0001 )
				  begin
					dummy_cycle(0);
				  end
				else if ( RPARAM[6:3] == 4'b0010 )
				  begin
					dummy_cycle(0);
				  end
				else if ( RPARAM[6:3] == 4'b0011 )
				  begin
					dummy_cycle(1);
				  end
				else if ( RPARAM[6:3] == 4'b0100 )
				  begin
					dummy_cycle(2);
				  end
				else if ( RPARAM[6:3] == 4'b0101 )
				  begin
					dummy_cycle(3);
				  end
				else if ( RPARAM[6:3] == 4'b0110 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0111 )
				  begin
					dummy_cycle(5);
				  end
				else if ( RPARAM[6:3] == 4'b1000 )
				  begin
					dummy_cycle(6);
				  end
				else if ( RPARAM[6:3] == 4'b1001 )
				  begin
					dummy_cycle(7);
				  end
				else if ( RPARAM[6:3] == 4'b1010 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b1011 )
				  begin
					dummy_cycle(9);
				  end
				else if ( RPARAM[6:3] == 4'b1100 )
				  begin
					dummy_cycle(10);
				  end
				else if ( RPARAM[6:3] == 4'b1101 )
				  begin
					dummy_cycle(11);
				  end
				else if ( RPARAM[6:3] == 4'b1110 )
				  begin
					dummy_cycle(12);
				  end
				else if ( RPARAM[6:3] == 4'b1111 )
				  begin
					dummy_cycle(13);
				  end

//				Prea_OUT_EN4 <= #tV 1'b0;
        		read_array(Address, OUT_Buf);

	    		forever @ ( negedge SCLK_INT or  posedge CS_INT ) 
				  begin
	        		if ( CS_INT == 1'b1 ) 
					  begin 
						disable read_4xio; 
						SIR_Mode = 1'b0;
  						SG_Mode = 1'b0;
					  end
	        		else 
					  begin
          				SO_OUT_EN   = 1'b1;
          				SI_OUT_EN   = 1'b1;
          				WP_OUT_EN   = 1'b1;
          				SIO3_OUT_EN = 1'b1;
          				SO_IN_EN    = 1'b0;
          				SI_IN_EN    = 1'b0;
          				WP_IN_EN    = 1'b0;
          				SIO3_IN_EN  = 1'b0;
          				Read_Mode  	= 1'b1;
            			if ( Dummy_Count ) 
						  begin
							Dummy_Count = Dummy_Count - 1;
//							if ( DTR_Mode ) 
//								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #(tV-3) Dummy_Count ? OUT_Buf[7:4] : OUT_Buf[3:0];
//							else
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? OUT_Buf[7:4] : OUT_Buf[3:0];
            			  end
            			else 
						  begin
            				if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              					Address = {Address[A_MSB:3], 3'b000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              					Address = {Address[A_MSB:5], 5'b0_0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              					Address = {Address[A_MSB:6], 6'b00_0000};
              				else
              					Address = Address + 1;
             				load_address(Address);
             				read_array(Address, OUT_Buf);
							Dummy_Count = 1;
//							if (DTR_Mode)
//								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #(tV-3) OUT_Buf[7:4];
//							else
								{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:4];
						  end
					  end
				  end//forever  
			  end

//            begin
//                if ( CR[4] ) begin
//                    Prea_OUT_EN4 = 1'b1;
//                    preamble_bit_out;
//                end
//            end
			join
		  end
	  end
    endtask // read_4xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read dual output data task		    */
    /*		     3B AD1 AD2 AD3 DMY DAT ...					    */
    /*----------------------------------------------------------------------*/
    task fastread_2xio;
	integer Dummy_Count;
	reg  [7:0] OUT_Buf;
	  begin
	   	Dummy_Count = 4 ;
		if ( !BAR[7] && !ADD_4B_Mode )
	     	dummy_cycle(24); 		// for 3-byte address in
		else if ( BAR[7] || ADD_4B_Mode )
			dummy_cycle(32);		// for 4-byte address in

		  begin
		  fork
		    begin
			  begin
				if ( RPARAM[6:3] == 4'b0000 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b0001 )
				  begin
					dummy_cycle(1);
				  end
				else if ( RPARAM[6:3] == 4'b0010 )
				  begin
					dummy_cycle(2);
				  end
				else if ( RPARAM[6:3] == 4'b0011 )
				  begin
					dummy_cycle(3);
				  end
				else if ( RPARAM[6:3] == 4'b0100 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0101 )
				  begin
					dummy_cycle(5);
				  end
				else if ( RPARAM[6:3] == 4'b0110 )
				  begin
					dummy_cycle(6);
				  end
				else if ( RPARAM[6:3] == 4'b0111 )
				  begin
					dummy_cycle(7);
				  end
				else if ( RPARAM[6:3] == 4'b1000 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b1001 )
				  begin
					dummy_cycle(9);
				  end
				else if ( RPARAM[6:3] == 4'b1010 )
				  begin
					dummy_cycle(10);
				  end
				else if ( RPARAM[6:3] == 4'b1011 )
				  begin
					dummy_cycle(11);
				  end
				else if ( RPARAM[6:3] == 4'b1100 )
				  begin
					dummy_cycle(12);
				  end
				else if ( RPARAM[6:3] == 4'b1101 )
				  begin
					dummy_cycle(13);
				  end
				else if ( RPARAM[6:3] == 4'b1110 )
				  begin
					dummy_cycle(14);
				  end
				else if ( RPARAM[6:3] == 4'b1111 )
				  begin
					dummy_cycle(15);
				  end
			  end	
//			Prea_OUT_EN2 <= #tV 1'b0;
       		read_array(Address, OUT_Buf);
	    	forever @ ( negedge SCLK or  posedge CS_INT ) 
			  begin
	      		if ( CS_INT == 1'b1 ) 
				  begin 
					disable fastread_2xio; 
				  end
	        	else 
				  begin
		    		Read_Mode = 1'b1;
		    		SO_OUT_EN = 1'b1;
		    		SI_OUT_EN = 1'b1;
		    		SI_IN_EN  = 1'b0;
		    		SO_IN_EN  = 1'b0;
		    		if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						if ( Dummy_Count == 3 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:6];
						else if ( Dummy_Count == 2 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[5:4];
						else if ( Dummy_Count == 1 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[3:2];
						else if ( Dummy_Count == 0 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[1:0];
		    		  end
		    		else 
					  begin
            			if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              				Address = {Address[A_MSB:3], 3'b000};
              			else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              				Address = {Address[A_MSB:4], 4'b0000};
              			else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              				Address = {Address[A_MSB:4], 4'b0000};
              			else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              				Address = {Address[A_MSB:5], 5'b0_0000};
              			else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              				Address = {Address[A_MSB:6], 6'b00_0000};
              			else
              				Address = Address + 1;
            			load_address(Address);
              			read_array(Address, OUT_Buf);
						Dummy_Count = 3;
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:6];
		    		  end
	        	end
	    	end//forever  
		end

//		  begin
//			if ( CR[4] )
//			  begin
//				dummy_cycle_prea(2);
//				Prea_OUT_EN2 = 1'b1;
//				preamble_bit_out;
//			  end
//		  end
		join
		end
	  end
    endtask // fastread_2xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read quad output data task		    */
    /*		     6B AD1 AD2 AD3 DMY DAT ...					    */
    /*----------------------------------------------------------------------*/
    task fastread_4xio;
	integer Dummy_Count;
	reg  [7:0] OUT_Buf;
	  begin
	   	Dummy_Count = 2 ;
		if ( !BAR[7] && !ADD_4B_Mode )
		    dummy_cycle(24); 		// for 3-byte address in
		else if ( BAR[7] || ADD_4B_Mode )
			dummy_cycle(32);		// for 4-byte address in

		  begin
		  	fork
			  begin
				if ( RPARAM[6:3] == 4'b0000 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b0001 )
				  begin
					dummy_cycle(1);
				  end
				else if ( RPARAM[6:3] == 4'b0010 )
				  begin
					dummy_cycle(2);
				  end
				else if ( RPARAM[6:3] == 4'b0011 )
				  begin
					dummy_cycle(3);
				  end
				else if ( RPARAM[6:3] == 4'b0100 )
				  begin
					dummy_cycle(4);
				  end
				else if ( RPARAM[6:3] == 4'b0101 )
				  begin
					dummy_cycle(5);
				  end
				else if ( RPARAM[6:3] == 4'b0110 )
				  begin
					dummy_cycle(6);
				  end
				else if ( RPARAM[6:3] == 4'b0111 )
				  begin
					dummy_cycle(7);
				  end
				else if ( RPARAM[6:3] == 4'b1000 )
				  begin
					dummy_cycle(8);
				  end
				else if ( RPARAM[6:3] == 4'b1001 )
				  begin
					dummy_cycle(9);
				  end
				else if ( RPARAM[6:3] == 4'b1010 )
				  begin
					dummy_cycle(10);
				  end
				else if ( RPARAM[6:3] == 4'b1011 )
				  begin
					dummy_cycle(11);
				  end
				else if ( RPARAM[6:3] == 4'b1100 )
				  begin
					dummy_cycle(12);
				  end
				else if ( RPARAM[6:3] == 4'b1101 )
				  begin
					dummy_cycle(13);
				  end
				else if ( RPARAM[6:3] == 4'b1110 )
				  begin
					dummy_cycle(14);
				  end
				else if ( RPARAM[6:3] == 4'b1111 )
				  begin
					dummy_cycle(15);
				  end

//				Prea_OUT_EN4 <= #tV 1'b0;
        		read_array(Address, OUT_Buf);

	    		forever @ ( negedge SCLK_INT or  posedge CS_INT ) 
				  begin
	        		if ( CS_INT == 1'b1 ) 
					  begin 
						disable read_4xio; 
						SIR_Mode = 1'b0;
						SG_Mode = 1'b0;
					  end
	        		else 
					  begin
          				SO_OUT_EN   = 1'b1;
          				SI_OUT_EN   = 1'b1;
          				WP_OUT_EN   = 1'b1;
          				SIO3_OUT_EN = 1'b1;
          				SO_IN_EN    = 1'b0;
          				SI_IN_EN    = 1'b0;
          				WP_IN_EN    = 1'b0;
          				SIO3_IN_EN  = 1'b0;
          				Read_Mode  	= 1'b1;
            			if ( Dummy_Count ) 
						  begin
							Dummy_Count = Dummy_Count - 1;
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? OUT_Buf[7:4] : OUT_Buf[3:0];
            			  end
            			else 
						  begin
            				if ( RPARAM[2] && (RPARAM[1:0]==2'b00) && (Address[2:0]==3'b111) )
              					Address = {Address[A_MSB:3], 3'b000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b01) && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RDUNIQ_Mode && (Address[3:0]==4'b1111) )
              					Address = {Address[A_MSB:4], 4'b0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b10) && (Address[4:0]==5'b1_1111) )
              					Address = {Address[A_MSB:5], 5'b0_0000};
              				else if ( RPARAM[2] && (RPARAM[1:0]==2'b11) && (Address[5:0]==6'b11_1111) )
              					Address = {Address[A_MSB:6], 6'b00_0000};
              				else
              					Address = Address + 1;
             				load_address(Address);
             				read_array(Address, OUT_Buf);
							Dummy_Count = 1;
							{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:4];
           				  end
	        		end
	    		end//forever  
			end

//			  begin
//				if (exRPARAM[4] )
//				  begin
//					dummy_cycle_prea(2);
//					Prea_OUT_EN4 = 1'b1;
//					preamble_bit_out;
//				  end
//			  end
		join
	  end
	  end
    endtask // fastread_4xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast DTR read data task			    */
    /*		     0D AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task dtrread_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	  begin
	    Dummy_Count = 8;
        if ( !BAR[7] && !ADD_4B_Mode ) 
	  	  begin
            dummy_cycle(12); 
          end
        else if ( BAR[7] || ADD_4B_Mode ) 
		  begin
            dummy_cycle(16); 
          end

	   	begin
		fork
		  begin
			if ( RPARAM[6:3] == 4'b0000 ) 
			  begin
		    	dummy_cycle(8);
			  end
			else if ( RPARAM[6:3] == 4'b0001 ) 
			  begin
			    dummy_cycle(1);
			  end
			else if ( RPARAM[6:3] == 4'b0010 ) 
			  begin
			    dummy_cycle(2);
			  end
			else if ( RPARAM[6:3] == 4'b0011 ) 
			  begin
			    dummy_cycle(3);
			  end
			else if ( RPARAM[6:3] == 4'b0100 ) 
			  begin
			    dummy_cycle(4);
			  end
			else if ( RPARAM[6:3] == 4'b0101 ) 
			  begin
			    dummy_cycle(5);
			  end
			else if ( RPARAM[6:3] == 4'b0110 ) 
			  begin
			    dummy_cycle(6);
			  end
			else if ( RPARAM[6:3] == 4'b0111 ) 
			  begin
			    dummy_cycle(7);
			  end
			else if ( RPARAM[6:3] == 4'b1000 ) 
			  begin
			    dummy_cycle(8);
			  end
			else if ( RPARAM[6:3] == 4'b1001 ) 
			  begin
			    dummy_cycle(9);
			  end
			else if ( RPARAM[6:3] == 4'b1010 ) 
			  begin
			    dummy_cycle(10);
			  end
			else if ( RPARAM[6:3] == 4'b1011 ) 
			  begin
			    dummy_cycle(11);
			  end
			else if ( RPARAM[6:3] == 4'b1100 ) 
			  begin
			    dummy_cycle(12);
			  end
			else if ( RPARAM[6:3] == 4'b1101 ) 
			  begin
			    dummy_cycle(13);
			  end
			else if ( RPARAM[6:3] == 4'b1110 ) 
			  begin
			    dummy_cycle(14);
			  end
			else if ( RPARAM[6:3] == 4'b1111 ) 
			  begin
			    dummy_cycle(15);
			  end
//			Prea_OUT_EN1 <= #tV 1'b0;
			read_array(Address, OUT_Buf);
			forever @ ( SCLK or posedge CS_INT ) 
			  begin
				if ( CS_INT == 1'b1 ) 
				  begin
					disable dtrread_1xio;
				  end 
				else 
				  begin 
					SO_OUT_EN = 1'b1;
					SI_IN_EN    = 1'b0;
					if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
					  end
					else 
					  begin
						Address = Address + 1;
						load_address(Address);
						read_array(Address, OUT_Buf);
						Dummy_Count = 7;
						SIO1_Reg <= #tV OUT_Buf[Dummy_Count];
					  end
				  end    
				end  // end forever
			end

//			begin
//				if ( CR[4] ) 
//				  begin
//					dummy_cycle_prea(2);
//					Prea_OUT_EN1 = 1'b1;
//					preamble_bit_out_dtr;
//				  end
//			end
		join
	    end
	end   
    endtask // dtrread_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute DTR 2X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task dtrread_2xio;
	reg  [7:0]  OUT_Buf;
	integer     Dummy_Count;
	  begin
	    Dummy_Count=4;
	    SI_IN_EN = 1'b1;
	    SO_IN_EN = 1'b1;
	    SI_OUT_EN = 1'b0;
	    SO_OUT_EN = 1'b0;

        if ( !BAR[7] && !ADD_4B_Mode ) 
		  begin
            dummy_cycle(6); 
          end
        else if ( BAR[7] || ADD_4B_Mode ) 
		  begin
            dummy_cycle(8);
          end

//        dummy_cycle(1); 	// first DMY byte: AX input
//
//	    @ (negedge SCLK );
//	    #1;
//	    if ( RDDIO_Mode == 1'b1 && SI_Reg[3:0] == 4'hA )
//		  begin
//	        Set_2XIO_DTR_Enhance_Mode = 1'b1;
//	      end
//	    else  
//		  begin 
//	        Set_2XIO_DTR_Enhance_Mode = 1'b0;
//	      end

	    begin
		fork
		  begin
			if ( RPARAM[6:3] == 4'b0000 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(3);
			  end
			else if ( RPARAM[6:3] == 4'b0001 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
//	    		@ (negedge SCLK );
//	    		#1;
//				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] == 4'hA) ? 1'b1 : 1'b0 ;

//				dummy_cycle(0);
			  end
			else if ( RPARAM[6:3] == 4'b0010 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(1);
			  end
			else if ( RPARAM[6:3] == 4'b0011 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(2);
			  end
			else if ( RPARAM[6:3] == 4'b0100 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(3);
			  end
			else if ( RPARAM[6:3] == 4'b0101 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(4);
			  end
			else if ( RPARAM[6:3] == 4'b0110 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(5);
			  end
			else if ( RPARAM[6:3] == 4'b0111 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(6);
			  end
			else if ( RPARAM[6:3] == 4'b1000 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(7);
			  end
			else if ( RPARAM[6:3] == 4'b1001 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(8);
			  end
			else if ( RPARAM[6:3] == 4'b1010 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(9);
			  end
			else if ( RPARAM[6:3] == 4'b1011 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(10);
			  end
			else if ( RPARAM[6:3] == 4'b1100 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(11);
			  end
			else if ( RPARAM[6:3] == 4'b1101 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(12);
			  end
			else if ( RPARAM[6:3] == 4'b1110 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(13);
			  end
			else if ( RPARAM[6:3] == 4'b1111 ) 
			  begin
        		dummy_cycle(1); 	// first DMY byte: AX input
	    		@ (negedge SCLK );
	    		#1;
				Set_2XIO_DTR_Enhance_Mode = (RDDIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(14);
			  end
//			Prea_OUT_EN2 <= #tV 1'b0;
			read_array(Address, OUT_Buf);
			forever @ ( SCLK or  posedge CS_INT ) 
			  begin
				if ( CS_INT == 1'b1 ) 
				  begin
					disable dtrread_2xio;
				  end
				else 
				  begin
					SO_OUT_EN	= 1'b1;
					SI_OUT_EN	= 1'b1;
					SI_IN_EN	= 1'b0;
					SO_IN_EN	= 1'b0;
					if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						if ( Dummy_Count == 3 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:6];
						else if ( Dummy_Count == 2 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[5:4];
						else if ( Dummy_Count == 1 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[3:2];
						else if ( Dummy_Count == 0 )
							{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[1:0];
					  end
					else 
					  begin
						Address = Address + 1;
						load_address(Address);
						read_array(Address, OUT_Buf);
						Dummy_Count = 3;
						{SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:6];
					  end
					end
				end//forever  
			end

//			  begin
//				if ( CR[4] ) 
//				  begin
//					dummy_cycle_prea(2);
//					Prea_OUT_EN2 = 1'b1;
//					preamble_bit_out_dtr;
//				  end
//			  end
		join
	    end
	end
    endtask // dtrread_2xio

    /*----------------------------------------------------------------------*/
    /*	Description: Execute DTR 4X IO Read Mode				    */
    /*----------------------------------------------------------------------*/
    task dtrread_4xio;
	//reg [A_MSB:0] Address;
	reg [7:0]   OUT_Buf ;
	integer	    Dummy_Count;
	  begin
	    Dummy_Count = 2;
	    SI_OUT_EN    = 1'b0;
	    SO_OUT_EN    = 1'b0;
	    WP_OUT_EN    = 1'b0;
	    SIO3_OUT_EN  = 1'b0;
	    SI_IN_EN	= 1'b1;
	    SO_IN_EN	= 1'b1;
	    WP_IN_EN	= 1'b1;
	    SIO3_IN_EN   = 1'b1;

//      if ( BAR[7] || ADD_4B_Mode || CMD_BUS == DTRREAD4X4B || (!DTRRead_4XIO_ModeX && (CMD_BUS == RSTEN || CMD_BUS == RST) && ENDTR4XIO_Read_Mode == 1'b1)) 
//		  begin
//        	ADD_4B_Mode = 1'b1;
//          dummy_cycle(4);
//        end
//	    else 
		  begin
        	dummy_cycle(3); 
          end

//      dummy_cycle(1); 	// first DMY byte: AX input
//
//      @ (negedge SCLK );
//	    #1;
//	    if ( RDQIO_Mode && SI_Reg[7:4] == 4'hA )
//		  begin
//	        Set_4XIO_DTR_Enhance_Mode = 1'b1;
//	      end
//	    else  
//		  begin 
//	        Set_4XIO_DTR_Enhance_Mode = 1'b0;
//	      end

	    begin
		fork
		  begin
			if ( RPARAM[6:3] == 4'b0000 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(5);
			  end
			else if ( RPARAM[6:3] == 4'b0001 ) 
			  begin
				dummy_cycle(0); 	// first DMY byte: AX input
				@ (posedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[3:0] === 4'hA) ? 1'b1 : 1'b0 ;

//				dummy_cycle(0);
			  end
			else if ( RPARAM[6:3] == 4'b0010 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(1);
			  end
			else if ( RPARAM[6:3] == 4'b0011 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(2);
			  end
			else if ( RPARAM[6:3] == 4'b0100 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(3);
			  end
			else if ( RPARAM[6:3] == 4'b0101 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(4);
			  end
			else if ( RPARAM[6:3] == 4'b0110 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(5);
			  end
			else if ( RPARAM[6:3] == 4'b0111 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(6);
			  end
			else if ( RPARAM[6:3] == 4'b1000 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(7);
			  end
			else if ( RPARAM[6:3] == 4'b1001 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(8);
			  end
			else if ( RPARAM[6:3] == 4'b1010 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(9);
			  end
			else if ( RPARAM[6:3] == 4'b1011 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(10);
			  end
			else if ( RPARAM[6:3] == 4'b1100 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(11);
			  end
			else if ( RPARAM[6:3] == 4'b1101 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(12);
			  end
			else if ( RPARAM[6:3] == 4'b1110 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(13);
			  end
			else if ( RPARAM[6:3] == 4'b1111 ) 
			  begin
				dummy_cycle(1); 	// first DMY byte: AX input
				@ (negedge SCLK);
				#1;
				Set_4XIO_DTR_Enhance_Mode = (RDQIO_Mode && SI_Reg[7:4] === 4'hA) ? 1'b1 : 1'b0 ;

				dummy_cycle(14);
			  end

//			Prea_OUT_EN4 <= #tV 1'b0;
			read_array(Address, OUT_Buf);
			forever @ ( SCLK or  posedge CS_INT ) 
			  begin
				if ( CS_INT == 1'b1 ) 
				  begin
					disable dtrread_4xio;
				  end
				else 
				  begin
					SO_OUT_EN   = 1'b1;
					SI_OUT_EN   = 1'b1;
					WP_OUT_EN   = 1'b1;
					SIO3_OUT_EN = 1'b1;
					SO_IN_EN    = 1'b0;
					SI_IN_EN    = 1'b0;
					WP_IN_EN    = 1'b0;
					SIO3_IN_EN  = 1'b0;
					if ( Dummy_Count ) 
					  begin
						Dummy_Count = Dummy_Count - 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV Dummy_Count ? OUT_Buf[7:4] : OUT_Buf[3:0];
					  end
					else 
					  begin
						Address = Address + 1;
						load_address(Address);
						read_array(Address, OUT_Buf);
						Dummy_Count = 1;
						{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV OUT_Buf[7:4];
					  end
				  end
				end//forever  
			end

//			begin
//				if ( CR[4] ) 
//				  begin
//					dummy_cycle_prea(1);
//					Prea_OUT_EN4 = 1'b1;
//					preamble_bit_out_dtr;
//				  end
//			end
		join
	    end
	end
    endtask // dtrread_4xio


    /*----------------------------------------------------------------------*/
    /*	Description: define a preamble bit read task SDR		    */
    /*		               					            */
    /*----------------------------------------------------------------------*/
/*
    task preamble_bit_out;
	integer Dummy_Count;
	reg [7:0] Prea_Reg_Out;
        begin
	    Prea_Reg_Out = Prea_Reg;
	    Dummy_Count = 8;

	    forever begin
		@ ( negedge SCLK or posedge CS_INT );
		if ( CS_INT == 1'b1 ) begin
			disable preamble_bit_out;
		end 
		else begin
			if ( Prea_OUT_EN4 ) begin
				SO_OUT_EN   = 1'b1;
				SI_OUT_EN   = 1'b1;
				WP_OUT_EN   = 1'b1;
				SIO3_OUT_EN = 1'b1;
				SO_IN_EN    = 1'b0;
				SI_IN_EN    = 1'b0;
				WP_IN_EN    = 1'b0;
				SIO3_IN_EN  = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV {4{Prea_Reg_Out[Dummy_Count]}};
				end
				else begin
					Dummy_Count = 7;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV {4{Prea_Reg_Out[Dummy_Count]}};
				end
			end
			else if ( Prea_OUT_EN2 ) begin
				SO_OUT_EN   = 1'b1;
				SI_OUT_EN   = 1'b1;
				SO_IN_EN    = 1'b0;
				SI_IN_EN    = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					{SIO1_Reg, SIO0_Reg} <= #tV {2{Prea_Reg_Out[Dummy_Count]}};
				end
				else begin
					Dummy_Count = 7;
					{SIO1_Reg, SIO0_Reg} <= #tV {2{Prea_Reg_Out[Dummy_Count]}};
				end
			end
			else if ( Prea_OUT_EN1 ) begin
				SO_OUT_EN   = 1'b1;
				SI_IN_EN    = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					SIO1_Reg <= #tV Prea_Reg_Out[Dummy_Count];
				end
				else begin
					Dummy_Count = 7;
					SIO1_Reg <= #tV Prea_Reg_Out[Dummy_Count];
				end
			end
                end
            end
        end
     endtask
*/

    /*----------------------------------------------------------------------*/
    /*	Description: define a preamble bit read task DTR		    */
    /*		               					            */
    /*----------------------------------------------------------------------*/
/*
    task preamble_bit_out_dtr;
	integer Dummy_Count;
	reg [7:0] Prea_Reg_Out;
        begin
	    Prea_Reg_Out = Prea_Reg;
	    Dummy_Count = 8;

	    forever begin
		@ ( SCLK or posedge CS_INT );
		if ( CS_INT == 1'b1 ) begin
			disable preamble_bit_out_dtr;
		end 
		else begin
			if ( Prea_OUT_EN4 ) begin
				SO_OUT_EN   = 1'b1;
				SI_OUT_EN   = 1'b1;
				WP_OUT_EN   = 1'b1;
				SIO3_OUT_EN = 1'b1;
				SO_IN_EN    = 1'b0;
				SI_IN_EN    = 1'b0;
				WP_IN_EN    = 1'b0;
				SIO3_IN_EN  = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV {4{Prea_Reg_Out[Dummy_Count]}};
				end
				else begin
					Dummy_Count = 7;
					{SIO3_Reg, SIO2_Reg, SIO1_Reg, SIO0_Reg} <= #tV {4{Prea_Reg_Out[Dummy_Count]}};
				end
			end
			else if ( Prea_OUT_EN2 ) begin
				SO_OUT_EN   = 1'b1;
				SI_OUT_EN   = 1'b1;
				SO_IN_EN    = 1'b0;
				SI_IN_EN    = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					{SIO1_Reg, SIO0_Reg} <= #tV {2{Prea_Reg_Out[Dummy_Count]}};
				end
				else begin
					Dummy_Count = 7;
					{SIO1_Reg, SIO0_Reg} <= #tV {2{Prea_Reg_Out[Dummy_Count]}};
				end
			end
			else if ( Prea_OUT_EN1 ) begin
				SO_OUT_EN   = 1'b1;
				SI_IN_EN    = 1'b0;
				if ( Dummy_Count ) begin
					Dummy_Count = Dummy_Count - 1;
					SIO1_Reg <= #tV Prea_Reg_Out[Dummy_Count];
				end
				else begin
					Dummy_Count = 7;
					SIO1_Reg <= #tV Prea_Reg_Out[Dummy_Count];
				end
			end
                end
            end
        end
     endtask

*/

    /*----------------------------------------------------------------------*/
    /*  Description: Execute Clear Extended Read Parameter                  */
    /*----------------------------------------------------------------------*/
    task clr_extended_read_parameter;
	  begin
		exRPARAM [3:1] = 3'b000;
	  end
	endtask 	// clr_extended_read_parameter

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task read_array;
        input [A_MSB:0] Address;
        output [7:0]    OUT_Buf;
        begin
            if ( SIR_Mode == 1 ) begin
                if 		(Address[13:12] == 2'b00) OUT_Buf = SIR0_ARRAY[Address[A_MSB_SIR:0]];
                else if (Address[13:12] == 2'b01) OUT_Buf = SIR1_ARRAY[Address[A_MSB_SIR:0]];
                else if (Address[13:12] == 2'b10) OUT_Buf = SIR2_ARRAY[Address[A_MSB_SIR:0]];
                else if (Address[13:12] == 2'b11) OUT_Buf = SIR3_ARRAY[Address[A_MSB_SIR:0]];
            end
            else if ( SG_Mode == 1 ) 
  						begin
                OUT_Buf = SG_ARRAY[Address[A_MSB_SG:0]];
            	end
            else if ( RDSFDP_Mode == 1 ) begin
                OUT_Buf = SFDP_ARRAY[Address[A_MSB_SFDP:0]];
            end
            else if ( RDUNIQ_Mode == 1 ) begin
                OUT_Buf = UNIQ_ARRAY[Address[A_MSB_UNIQ:0]];
            end
            else begin
                OUT_Buf = ARRAY[Address] ;
            end
        end
    endtask //  read_array

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task load_address;
        inout [A_MSB:0] Address;
        begin
            //if ( SIR_Mode == 1 ) begin
            //    Address = Address[A_MSB_SIR:0] ;
            //end
						// no wrap in RDSFDP mode	
            //else if ( RDSFDP_Mode == 1 ) begin
            //    Address = Address[A_MSB_SFDP:0] ;
            //end
        end
    endtask //  load_address

    /*----------------------------------------------------------------------*/
    /*	Description: define a safeguard_protect area function		    				*/
    /*	INPUT: address							    																		*/
    /*----------------------------------------------------------------------*/ 
		task safeguard;
				input [A_MSB:0] Address;
				output sg_protect;
				reg [7:0] SG_HBYTE;
				reg [7:0] SG_LBYTE;
				reg [A_MSB_SG:0] A_SG;
				begin
						//protect_define
						if( (WRSR_Mode == 1'b1) || (WRFR_Mode == 1'b1) || (SG_Mode == 1'b1) || (SIR_Mode == 1'b1) ) 
							begin 
									sg_protect = 1'b0; 
							end
						else if ( (CE_Mode == 1'b1) || (BE64K_Mode == 1'b1) )
							begin
									A_SG = {Address[A_MSB:16], 1'b0};
									SG_LBYTE = SG_ARRAY[A_SG];
									SG_HBYTE = SG_ARRAY[A_SG+1];
									if ( &{SG_HBYTE,SG_LBYTE} == 1'b0 ) sg_protect = 1'b1;
									else sg_protect = 1'b0;
							end
						else if ( BE32K_Mode == 1'b1 )
							begin
									A_SG = Address[A_MSB:15];
									SG_LBYTE = SG_ARRAY[A_SG];
									if ( &SG_LBYTE == 1'b0 ) sg_protect = 1'b1;
									else sg_protect = 1'b0;
							end
						else if ( (SER_Mode == 1'b1) || (PP_1XIO_Mode == 1'b1) || (PP_4XIO_Mode == 1'b1) )
							begin
									A_SG = Address[A_MSB:15];
									SG_LBYTE = SG_ARRAY[A_SG];
									if ( SG_LBYTE[Address[14:12]] == 1'b0 ) sg_protect = 1'b1;
									else sg_protect = 1'b0;
							end
				end
		endtask // safeguard

    /*----------------------------------------------------------------------*/
    /*	Description: define a write_protect area function		    						*/
    /*	INPUT: address							    																		*/
    /*----------------------------------------------------------------------*/ 
    function write_protect;
    input [A_MSB:0] Address;
      begin
		Block = Address [A_MSB:16];
        //protect_define
  		if( (WRSR_Mode == 1'b1) || (WRFR_Mode == 1'b1) || (SG_Mode == 1'b1) ) 
		  begin 
			write_protect = 1'b0; 
		  end
        else if( SIR_Mode == 1'b1 ) 
		  begin
            if		( FR_Reg[7] && (Address[13:12] == 2'b11) ) write_protect = 1'b1;
            else if ( FR_Reg[6] && (Address[13:12] == 2'b10) ) write_protect = 1'b1;
            else if ( FR_Reg[5] && (Address[13:12] == 2'b01) ) write_protect = 1'b1;
            else if ( FR_Reg[4] && (Address[13:12] == 2'b00) ) write_protect = 1'b1;
        	else write_protect = 1'b0;
       	  end // SIR_Mode
		else if ( CE_Mode == 1'b1) 
		  begin
			if (Status_Reg[5:2] == 4'b0000) write_protect = 1'b0;
			else write_protect = 1'b1;
		  end // CE_mode
		else if ((PP_1XIO_Mode || PP_4XIO_Mode || SER_Mode) && EN_SEUnlock && (Address[A_MSB:12] == A_Unlock[A_MSB:12]))
			write_protect = 1'b0;
		else	
		//fork
		begin
		  begin
//			if (FR_Reg[1] == 1'b0) // TOP area
			case (Status_Reg[5:2])
				4'b0000 : begin bp_write_protect = 0; end
        		4'b0001 : begin if (Block[Block_MSB:0] >  62 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0010 : begin if (Block[Block_MSB:0] >= 62 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0011 : begin if (Block[Block_MSB:0] >= 60 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0100 : begin if (Block[Block_MSB:0] >= 56 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0101 : begin if (Block[Block_MSB:0] >= 48 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0110 : begin if (Block[Block_MSB:0] >= 32 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0111 : begin bp_write_protect = 1; end
        		4'b1000 : begin bp_write_protect = 1; end
        		4'b1001 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 31) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1010 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 15) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1011 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <=  7) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1100 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <=  3) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1101 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <=  1) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1110 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <   1) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1111 : begin bp_write_protect = 0; end
			endcase
/*
			else if (FR_Reg[1] == 1'b1) // BOTTOM area
			case (Status_Reg[5:2])
				4'b0000 : begin bp_write_protect = 0; end
        		4'b0001 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] < 1) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0010 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 1) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0011 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 3) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0100 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 7) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0101 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 15) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0110 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 31) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b0111 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 63) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1000 : begin if (Block[Block_MSB:0] >= 0 && Block[Block_MSB:0] <= 127) bp_write_protect = 1; else bp_write_protect = 0; end
        		4'b1001 : begin bp_write_protect = 1; end
        		4'b1010 : begin bp_write_protect = 1; end
        		4'b1011 : begin bp_write_protect = 1; end
        		4'b1100 : begin bp_write_protect = 1; end
        		4'b1101 : begin bp_write_protect = 1; end
        		4'b1110 : begin bp_write_protect = 1; end
        		4'b1111 : begin bp_write_protect = 1; end
			endcase
*/
		  end
		  begin
			if (Block[Block_MSB:0] == 0 && TBPARAM)
			  begin
				asp_write_protect = SEC_Pro_Reg_BOT0[Address[15:12]] ? 1'b0 : 1'b1 ;
				if (SEC_Pro_Reg_BOT0[Address[15:12]] == 1'b0)
				  begin
					asp_write_protect = 1'b1;
				  end
				else
				  begin
					asp_write_protect = 1'b0;
				  end
			  end
			else if (Block[Block_MSB:0] == 1 && TBPARAM)
			  begin
				if (SEC_Pro_Reg_BOT1[Address[15:12]] == 1'b0)
				  begin
					asp_write_protect = 1'b1;
				  end
				else
				  begin
					asp_write_protect = 1'b0;
				  end
			  end
			else if (Block[Block_MSB:0] == Block_NUM-1 && !TBPARAM)
			  begin
				if (SEC_Pro_Reg_TOP511[Address[15:12]] == 1'b0)
				  begin
					asp_write_protect = 1'b1;
				  end
				else
				  begin
					asp_write_protect = 1'b0;
				  end
			  end
			else if (Block[Block_MSB:0] == Block_NUM-2 && !TBPARAM)
			  begin
				if (SEC_Pro_Reg_TOP510[Address[15:12]] == 1'b0)
				  begin
					asp_write_protect = 1'b1;
				  end
				else
				  begin
					asp_write_protect = 1'b0;
				  end
			  end
			else 
			  begin
				if (SEC_Pro_Reg[Address[A_MSB:16]] == 1'b0)
				  begin
					asp_write_protect = 1'b1;
				  end
				else
				  begin
					asp_write_protect = 1'b0;
				  end
			  end
		  end
			write_protect = (bp_write_protect || asp_write_protect);
//		  end	// else
		//join
		end
	  end
    endfunction // write_protect

// *============================================================================================== 
// * AC Timing Check Section
// *==============================================================================================
    wire SIO3_EN;
    wire WP_EN;
    assign SIO3_EN = !Status_Reg[6];
    assign WP_EN = (!Status_Reg[6]) && !ENQUAD && SRWD;

    assign  Write_SHSL = !Read_SHSL;

    wire Read_1XIO_Chk_W;
    assign Read_1XIO_Chk_W = Read_1XIO_Chk;

    wire Read_2XIO_Chk_W_0000;
    assign Read_2XIO_Chk_W_0000 = Read_2XIO_Chk && RP_0000;
    wire Read_2XIO_Chk_W_0001;
    assign Read_2XIO_Chk_W_0001 = Read_2XIO_Chk && RP_0001;
    wire Read_2XIO_Chk_W_0010;
    assign Read_2XIO_Chk_W_0010 = Read_2XIO_Chk && RP_0010;
    wire Read_2XIO_Chk_W_0011;
    assign Read_2XIO_Chk_W_0011 = Read_2XIO_Chk && RP_0011;
    wire Read_2XIO_Chk_W_0100;
    assign Read_2XIO_Chk_W_0100 = Read_2XIO_Chk && RP_0100;
    wire Read_2XIO_Chk_W_0101;
    assign Read_2XIO_Chk_W_0101 = Read_2XIO_Chk && RP_0101;
    wire Read_2XIO_Chk_W_0110;
    assign Read_2XIO_Chk_W_0110 = Read_2XIO_Chk && RP_0110;
    wire Read_2XIO_Chk_W_0111;
    assign Read_2XIO_Chk_W_0111 = Read_2XIO_Chk && RP_0111;
    wire Read_2XIO_Chk_W_1000;
    assign Read_2XIO_Chk_W_1000 = Read_2XIO_Chk && RP_1000;
    wire Read_2XIO_Chk_W_1001;
    assign Read_2XIO_Chk_W_1001 = Read_2XIO_Chk && RP_1001;
    wire Read_2XIO_Chk_W_1010;
    assign Read_2XIO_Chk_W_1010 = Read_2XIO_Chk && RP_1010;
    wire Read_2XIO_Chk_W_1011;
    assign Read_2XIO_Chk_W_1011 = Read_2XIO_Chk && RP_1011;
    wire Read_2XIO_Chk_W_1100;
    assign Read_2XIO_Chk_W_1100 = Read_2XIO_Chk && RP_1100;
    wire Read_2XIO_Chk_W_1101;
    assign Read_2XIO_Chk_W_1101 = Read_2XIO_Chk && RP_1101;
    wire Read_2XIO_Chk_W_1110;
    assign Read_2XIO_Chk_W_1110 = Read_2XIO_Chk && RP_1110;
    wire Read_2XIO_Chk_W_1111;
    assign Read_2XIO_Chk_W_1111 = Read_2XIO_Chk && RP_1111;

    wire Read_4XIO_Chk_W_0000;
    assign Read_4XIO_Chk_W_0000 = Read_4XIO_Chk && RP_0000;
    wire Read_4XIO_Chk_W_0001;
    assign Read_4XIO_Chk_W_0001 = Read_4XIO_Chk && RP_0001;
    wire Read_4XIO_Chk_W_0010;
    assign Read_4XIO_Chk_W_0010 = Read_4XIO_Chk && RP_0010;
    wire Read_4XIO_Chk_W_0011;
    assign Read_4XIO_Chk_W_0011 = Read_4XIO_Chk && RP_0011;
    wire Read_4XIO_Chk_W_0100;
    assign Read_4XIO_Chk_W_0100 = Read_4XIO_Chk && RP_0100;
    wire Read_4XIO_Chk_W_0101;
    assign Read_4XIO_Chk_W_0101 = Read_4XIO_Chk && RP_0101;
    wire Read_4XIO_Chk_W_0110;
    assign Read_4XIO_Chk_W_0110 = Read_4XIO_Chk && RP_0110;
    wire Read_4XIO_Chk_W_0111;
    assign Read_4XIO_Chk_W_0111 = Read_4XIO_Chk && RP_0111;
    wire Read_4XIO_Chk_W_1000;
    assign Read_4XIO_Chk_W_1000 = Read_4XIO_Chk && RP_1000;
    wire Read_4XIO_Chk_W_1001;
    assign Read_4XIO_Chk_W_1001 = Read_4XIO_Chk && RP_1001;
    wire Read_4XIO_Chk_W_1010;
    assign Read_4XIO_Chk_W_1010 = Read_4XIO_Chk && RP_1010;
    wire Read_4XIO_Chk_W_1011;
    assign Read_4XIO_Chk_W_1011 = Read_4XIO_Chk && RP_1011;
    wire Read_4XIO_Chk_W_1100;
    assign Read_4XIO_Chk_W_1100 = Read_4XIO_Chk && RP_1100;
    wire Read_4XIO_Chk_W_1101;
    assign Read_4XIO_Chk_W_1101 = Read_4XIO_Chk && RP_1101;
    wire Read_4XIO_Chk_W_1110;
    assign Read_4XIO_Chk_W_1110 = Read_4XIO_Chk && RP_1110;
    wire Read_4XIO_Chk_W_1111;
    assign Read_4XIO_Chk_W_1111 = Read_4XIO_Chk && RP_1111;

    wire FastRD_1XIO_Chk_W_0000;
    assign FastRD_1XIO_Chk_W_0000 = FastRD_1XIO_Chk && RP_0000;
    wire FastRD_1XIO_Chk_W_0001;
    assign FastRD_1XIO_Chk_W_0001 = FastRD_1XIO_Chk && RP_0001;
    wire FastRD_1XIO_Chk_W_0010;
    assign FastRD_1XIO_Chk_W_0010 = FastRD_1XIO_Chk && RP_0010;
    wire FastRD_1XIO_Chk_W_0011;
    assign FastRD_1XIO_Chk_W_0011 = FastRD_1XIO_Chk && RP_0011;
    wire FastRD_1XIO_Chk_W_0100;
    assign FastRD_1XIO_Chk_W_0100 = FastRD_1XIO_Chk && RP_0100;
    wire FastRD_1XIO_Chk_W_0101;
    assign FastRD_1XIO_Chk_W_0101 = FastRD_1XIO_Chk && RP_0101;
    wire FastRD_1XIO_Chk_W_0110;
    assign FastRD_1XIO_Chk_W_0110 = FastRD_1XIO_Chk && RP_0110;
    wire FastRD_1XIO_Chk_W_0111;
    assign FastRD_1XIO_Chk_W_0111 = FastRD_1XIO_Chk && RP_0111;
    wire FastRD_1XIO_Chk_W_1000;
    assign FastRD_1XIO_Chk_W_1000 = FastRD_1XIO_Chk && RP_1000;
    wire FastRD_1XIO_Chk_W_1001;
    assign FastRD_1XIO_Chk_W_1001 = FastRD_1XIO_Chk && RP_1001;
    wire FastRD_1XIO_Chk_W_1010;
    assign FastRD_1XIO_Chk_W_1010 = FastRD_1XIO_Chk && RP_1010;
    wire FastRD_1XIO_Chk_W_1011;
    assign FastRD_1XIO_Chk_W_1011 = FastRD_1XIO_Chk && RP_1011;
    wire FastRD_1XIO_Chk_W_1100;
    assign FastRD_1XIO_Chk_W_1100 = FastRD_1XIO_Chk && RP_1100;
    wire FastRD_1XIO_Chk_W_1101;
    assign FastRD_1XIO_Chk_W_1101 = FastRD_1XIO_Chk && RP_1101;
    wire FastRD_1XIO_Chk_W_1110;
    assign FastRD_1XIO_Chk_W_1110 = FastRD_1XIO_Chk && RP_1110;
    wire FastRD_1XIO_Chk_W_1111;
    assign FastRD_1XIO_Chk_W_1111 = FastRD_1XIO_Chk && RP_1111;

    wire FastRD_2XIO_Chk_W_0000;
    assign FastRD_2XIO_Chk_W_0000 = FastRD_2XIO_Chk && RP_0000;
    wire FastRD_2XIO_Chk_W_0001;
    assign FastRD_2XIO_Chk_W_0001 = FastRD_2XIO_Chk && RP_0001;
    wire FastRD_2XIO_Chk_W_0010;
    assign FastRD_2XIO_Chk_W_0010 = FastRD_2XIO_Chk && RP_0010;
    wire FastRD_2XIO_Chk_W_0011;
    assign FastRD_2XIO_Chk_W_0011 = FastRD_2XIO_Chk && RP_0011;
    wire FastRD_2XIO_Chk_W_0100;
    assign FastRD_2XIO_Chk_W_0100 = FastRD_2XIO_Chk && RP_0100;
    wire FastRD_2XIO_Chk_W_0101;
    assign FastRD_2XIO_Chk_W_0101 = FastRD_2XIO_Chk && RP_0101;
    wire FastRD_2XIO_Chk_W_0110;
    assign FastRD_2XIO_Chk_W_0110 = FastRD_2XIO_Chk && RP_0110;
    wire FastRD_2XIO_Chk_W_0111;
    assign FastRD_2XIO_Chk_W_0111 = FastRD_2XIO_Chk && RP_0111;
    wire FastRD_2XIO_Chk_W_1000;
    assign FastRD_2XIO_Chk_W_1000 = FastRD_2XIO_Chk && RP_1000;
    wire FastRD_2XIO_Chk_W_1001;
    assign FastRD_2XIO_Chk_W_1001 = FastRD_2XIO_Chk && RP_1001;
    wire FastRD_2XIO_Chk_W_1010;
    assign FastRD_2XIO_Chk_W_1010 = FastRD_2XIO_Chk && RP_1010;
    wire FastRD_2XIO_Chk_W_1011;
    assign FastRD_2XIO_Chk_W_1011 = FastRD_2XIO_Chk && RP_1011;
    wire FastRD_2XIO_Chk_W_1100;
    assign FastRD_2XIO_Chk_W_1100 = FastRD_2XIO_Chk && RP_1100;
    wire FastRD_2XIO_Chk_W_1101;
    assign FastRD_2XIO_Chk_W_1101 = FastRD_2XIO_Chk && RP_1101;
    wire FastRD_2XIO_Chk_W_1110;
    assign FastRD_2XIO_Chk_W_1110 = FastRD_2XIO_Chk && RP_1110;
    wire FastRD_2XIO_Chk_W_1111;
    assign FastRD_2XIO_Chk_W_1111 = FastRD_2XIO_Chk && RP_1111;

    wire FastRD_4XIO_Chk_W_0000;
    assign FastRD_4XIO_Chk_W_0000 = FastRD_4XIO_Chk && RP_0000;
    wire FastRD_4XIO_Chk_W_0001;
    assign FastRD_4XIO_Chk_W_0001 = FastRD_4XIO_Chk && RP_0001;
    wire FastRD_4XIO_Chk_W_0010;
    assign FastRD_4XIO_Chk_W_0010 = FastRD_4XIO_Chk && RP_0010;
    wire FastRD_4XIO_Chk_W_0011;
    assign FastRD_4XIO_Chk_W_0011 = FastRD_4XIO_Chk && RP_0011;
    wire FastRD_4XIO_Chk_W_0100;
    assign FastRD_4XIO_Chk_W_0100 = FastRD_4XIO_Chk && RP_0100;
    wire FastRD_4XIO_Chk_W_0101;
    assign FastRD_4XIO_Chk_W_0101 = FastRD_4XIO_Chk && RP_0101;
    wire FastRD_4XIO_Chk_W_0110;
    assign FastRD_4XIO_Chk_W_0110 = FastRD_4XIO_Chk && RP_0110;
    wire FastRD_4XIO_Chk_W_0111;
    assign FastRD_4XIO_Chk_W_0111 = FastRD_4XIO_Chk && RP_0111;
    wire FastRD_4XIO_Chk_W_1000;
    assign FastRD_4XIO_Chk_W_1000 = FastRD_4XIO_Chk && RP_1000;
    wire FastRD_4XIO_Chk_W_1001;
    assign FastRD_4XIO_Chk_W_1001 = FastRD_4XIO_Chk && RP_1001;
    wire FastRD_4XIO_Chk_W_1010;
    assign FastRD_4XIO_Chk_W_1010 = FastRD_4XIO_Chk && RP_1010;
    wire FastRD_4XIO_Chk_W_1011;
    assign FastRD_4XIO_Chk_W_1011 = FastRD_4XIO_Chk && RP_1011;
    wire FastRD_4XIO_Chk_W_1100;
    assign FastRD_4XIO_Chk_W_1100 = FastRD_4XIO_Chk && RP_1100;
    wire FastRD_4XIO_Chk_W_1101;
    assign FastRD_4XIO_Chk_W_1101 = FastRD_4XIO_Chk && RP_1101;
    wire FastRD_4XIO_Chk_W_1110;
    assign FastRD_4XIO_Chk_W_1110 = FastRD_4XIO_Chk && RP_1110;
    wire FastRD_4XIO_Chk_W_1111;
    assign FastRD_4XIO_Chk_W_1111 = FastRD_4XIO_Chk && RP_1111;


    wire AUTO_BOOT_Chk_W_0000;
    assign AUTO_BOOT_Chk_W_0000 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0000 );
    wire AUTO_BOOT_Chk_W_0001;
    assign AUTO_BOOT_Chk_W_0001 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0001 );
    wire AUTO_BOOT_Chk_W_0010;
    assign AUTO_BOOT_Chk_W_0010 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0010 );
    wire AUTO_BOOT_Chk_W_0011;
    assign AUTO_BOOT_Chk_W_0011 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0011 );
    wire AUTO_BOOT_Chk_W_0100;
    assign AUTO_BOOT_Chk_W_0100 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0100 );
    wire AUTO_BOOT_Chk_W_0101;
    assign AUTO_BOOT_Chk_W_0101 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0101 );
    wire AUTO_BOOT_Chk_W_0110;
    assign AUTO_BOOT_Chk_W_0110 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0110 );
    wire AUTO_BOOT_Chk_W_0111;
    assign AUTO_BOOT_Chk_W_0111 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b0111 );
    wire AUTO_BOOT_Chk_W_1000;
    assign AUTO_BOOT_Chk_W_1000 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1000 );
    wire AUTO_BOOT_Chk_W_1001;
    assign AUTO_BOOT_Chk_W_1001 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1001 );
    wire AUTO_BOOT_Chk_W_1010;
    assign AUTO_BOOT_Chk_W_1010 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1010 );
    wire AUTO_BOOT_Chk_W_1011;
    assign AUTO_BOOT_Chk_W_1011 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1011 );
    wire AUTO_BOOT_Chk_W_1100;
    assign AUTO_BOOT_Chk_W_1100 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1100 );
    wire AUTO_BOOT_Chk_W_1101;
    assign AUTO_BOOT_Chk_W_1101 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1101 );
    wire AUTO_BOOT_Chk_W_1110;
    assign AUTO_BOOT_Chk_W_1110 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1110 );
    wire AUTO_BOOT_Chk_W_1111;
    assign AUTO_BOOT_Chk_W_1111 = AUTO_BOOT_Chk && ( AB_Reg[4:1] === 4'b1111 );

	wire DTRRead_1XIO_Mode_W_0000;
	assign DTRRead_1XIO_Mode_W_0000 = DTRRead_1XIO_Mode && RP_0000;
	wire DTRRead_1XIO_Mode_W_0001;
	assign DTRRead_1XIO_Mode_W_0001 = DTRRead_1XIO_Mode && RP_0001;
	wire DTRRead_1XIO_Mode_W_0010;
	assign DTRRead_1XIO_Mode_W_0010 = DTRRead_1XIO_Mode && RP_0010;
	wire DTRRead_1XIO_Mode_W_0011;
	assign DTRRead_1XIO_Mode_W_0011 = DTRRead_1XIO_Mode && RP_0011;
	wire DTRRead_1XIO_Mode_W_0100;
	assign DTRRead_1XIO_Mode_W_0100 = DTRRead_1XIO_Mode && RP_0100;
	wire DTRRead_1XIO_Mode_W_0101;
	assign DTRRead_1XIO_Mode_W_0101 = DTRRead_1XIO_Mode && RP_0101;
	wire DTRRead_1XIO_Mode_W_0110;
	assign DTRRead_1XIO_Mode_W_0110 = DTRRead_1XIO_Mode && RP_0110;
	wire DTRRead_1XIO_Mode_W_0111;
	assign DTRRead_1XIO_Mode_W_0111 = DTRRead_1XIO_Mode && RP_0111;
	wire DTRRead_1XIO_Mode_W_1000;
	assign DTRRead_1XIO_Mode_W_1000 = DTRRead_1XIO_Mode && RP_1000;
	wire DTRRead_1XIO_Mode_W_1001;
	assign DTRRead_1XIO_Mode_W_1001 = DTRRead_1XIO_Mode && RP_1001;
	wire DTRRead_1XIO_Mode_W_1010;
	assign DTRRead_1XIO_Mode_W_1010 = DTRRead_1XIO_Mode && RP_1010;
	wire DTRRead_1XIO_Mode_W_1011;
	assign DTRRead_1XIO_Mode_W_1011 = DTRRead_1XIO_Mode && RP_1011;
	wire DTRRead_1XIO_Mode_W_1100;
	assign DTRRead_1XIO_Mode_W_1100 = DTRRead_1XIO_Mode && RP_1100;
	wire DTRRead_1XIO_Mode_W_1101;
	assign DTRRead_1XIO_Mode_W_1101 = DTRRead_1XIO_Mode && RP_1101;
	wire DTRRead_1XIO_Mode_W_1110;
	assign DTRRead_1XIO_Mode_W_1110 = DTRRead_1XIO_Mode && RP_1110;
	wire DTRRead_1XIO_Mode_W_1111;
	assign DTRRead_1XIO_Mode_W_1111 = DTRRead_1XIO_Mode && RP_1111;

	wire DTRRead_2XIO_Mode_W_0000;
	assign DTRRead_2XIO_Mode_W_0000 = DTRRead_2XIO_Mode && RP_0000;
	wire DTRRead_2XIO_Mode_W_0001;
	assign DTRRead_2XIO_Mode_W_0001 = DTRRead_2XIO_Mode && RP_0001;
	wire DTRRead_2XIO_Mode_W_0010;
	assign DTRRead_2XIO_Mode_W_0010 = DTRRead_2XIO_Mode && RP_0010;
	wire DTRRead_2XIO_Mode_W_0011;
	assign DTRRead_2XIO_Mode_W_0011 = DTRRead_2XIO_Mode && RP_0011;
	wire DTRRead_2XIO_Mode_W_0100;
	assign DTRRead_2XIO_Mode_W_0100 = DTRRead_2XIO_Mode && RP_0100;
	wire DTRRead_2XIO_Mode_W_0101;
	assign DTRRead_2XIO_Mode_W_0101 = DTRRead_2XIO_Mode && RP_0101;
	wire DTRRead_2XIO_Mode_W_0110;
	assign DTRRead_2XIO_Mode_W_0110 = DTRRead_2XIO_Mode && RP_0110;
	wire DTRRead_2XIO_Mode_W_0111;
	assign DTRRead_2XIO_Mode_W_0111 = DTRRead_2XIO_Mode && RP_0111;
	wire DTRRead_2XIO_Mode_W_1000;
	assign DTRRead_2XIO_Mode_W_1000 = DTRRead_2XIO_Mode && RP_1000;
	wire DTRRead_2XIO_Mode_W_1001;
	assign DTRRead_2XIO_Mode_W_1001 = DTRRead_2XIO_Mode && RP_1001;
	wire DTRRead_2XIO_Mode_W_1010;
	assign DTRRead_2XIO_Mode_W_1010 = DTRRead_2XIO_Mode && RP_1010;
	wire DTRRead_2XIO_Mode_W_1011;
	assign DTRRead_2XIO_Mode_W_1011 = DTRRead_2XIO_Mode && RP_1011;
	wire DTRRead_2XIO_Mode_W_1100;
	assign DTRRead_2XIO_Mode_W_1100 = DTRRead_2XIO_Mode && RP_1100;
	wire DTRRead_2XIO_Mode_W_1101;
	assign DTRRead_2XIO_Mode_W_1101 = DTRRead_2XIO_Mode && RP_1101;
	wire DTRRead_2XIO_Mode_W_1110;
	assign DTRRead_2XIO_Mode_W_1110 = DTRRead_2XIO_Mode && RP_1110;
	wire DTRRead_2XIO_Mode_W_1111;
	assign DTRRead_2XIO_Mode_W_1111 = DTRRead_2XIO_Mode && RP_1111;

	wire DTRRead_4XIO_Mode_W_0000;
	assign DTRRead_4XIO_Mode_W_0000 = DTRRead_4XIO_Mode && RP_0000;
	wire DTRRead_4XIO_Mode_W_0001;
	assign DTRRead_4XIO_Mode_W_0001 = DTRRead_4XIO_Mode && RP_0001;
	wire DTRRead_4XIO_Mode_W_0010;
	assign DTRRead_4XIO_Mode_W_0010 = DTRRead_4XIO_Mode && RP_0010;
	wire DTRRead_4XIO_Mode_W_0011;
	assign DTRRead_4XIO_Mode_W_0011 = DTRRead_4XIO_Mode && RP_0011;
	wire DTRRead_4XIO_Mode_W_0100;
	assign DTRRead_4XIO_Mode_W_0100 = DTRRead_4XIO_Mode && RP_0100;
	wire DTRRead_4XIO_Mode_W_0101;
	assign DTRRead_4XIO_Mode_W_0101 = DTRRead_4XIO_Mode && RP_0101;
	wire DTRRead_4XIO_Mode_W_0110;
	assign DTRRead_4XIO_Mode_W_0110 = DTRRead_4XIO_Mode && RP_0110;
	wire DTRRead_4XIO_Mode_W_0111;
	assign DTRRead_4XIO_Mode_W_0111 = DTRRead_4XIO_Mode && RP_0111;
	wire DTRRead_4XIO_Mode_W_1000;
	assign DTRRead_4XIO_Mode_W_1000 = DTRRead_4XIO_Mode && RP_1000;
	wire DTRRead_4XIO_Mode_W_1001;
	assign DTRRead_4XIO_Mode_W_1001 = DTRRead_4XIO_Mode && RP_1001;
	wire DTRRead_4XIO_Mode_W_1010;
	assign DTRRead_4XIO_Mode_W_1010 = DTRRead_4XIO_Mode && RP_1010;
	wire DTRRead_4XIO_Mode_W_1011;
	assign DTRRead_4XIO_Mode_W_1011 = DTRRead_4XIO_Mode && RP_1011;
	wire DTRRead_4XIO_Mode_W_1100;
	assign DTRRead_4XIO_Mode_W_1100 = DTRRead_4XIO_Mode && RP_1100;
	wire DTRRead_4XIO_Mode_W_1101;
	assign DTRRead_4XIO_Mode_W_1101 = DTRRead_4XIO_Mode && RP_1101;
	wire DTRRead_4XIO_Mode_W_1110;
	assign DTRRead_4XIO_Mode_W_1110 = DTRRead_4XIO_Mode && RP_1110;
	wire DTRRead_4XIO_Mode_W_1111;
	assign DTRRead_4XIO_Mode_W_1111 = DTRRead_4XIO_Mode && RP_1111;

    wire tDP_Chk_W;
    assign tDP_Chk_W = tDP_Chk;
    wire tRES1_Chk_W;
    assign tRES1_Chk_W = tRES1_Chk;
    wire tRES2_Chk_W;
    assign tRES2_Chk_W = tRES2_Chk;
    wire PP_4XIO_Chk_W;
    assign PP_4XIO_Chk_W = PP_4XIO_Chk;
    wire Read_SHSL_W;
    assign Read_SHSL_W = Read_SHSL;
    wire SI_IN_EN_W;
    assign SI_IN_EN_W = SI_IN_EN;
    wire SO_IN_EN_W;
    assign SO_IN_EN_W = SO_IN_EN;
    wire WP_IN_EN_W;
    assign WP_IN_EN_W = WP_IN_EN;
    wire SIO3_IN_EN_W;
    assign SIO3_IN_EN_W = SIO3_IN_EN;

    specify
    	/*----------------------------------------------------------------------*/
    	/*  Timing Check                                                        */
    	/*----------------------------------------------------------------------*/
	$period( posedge  SCLK &&& ~CS, tSCLK  );	// SCLK _/~ ->_/~
	$period( negedge  SCLK &&& ~CS, tSCLK  );	// SCLK ~\_ ->~\_
	$period( posedge  SCLK &&& Read_1XIO_Chk_W , tSCLK_NOR ); // SCLK _/~ ->_/~
//	$period( negedge  SCLK &&& Read_1XIO_Chk_W , tSCLK_NOR ); // SCLK ~\_ ->~\_
//	$period( posedge  SCLK &&& DTR_Mode, tSCLK_DTR  );	// SCLK _/~ ->_/~
//	$period( negedge  SCLK &&& DTR_Mode, tSCLK_DTR  );	// SCLK ~\_ ->~\_

	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0000 , tTSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0001 , tTSCLK1 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0010 , tTSCLK2 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0011 , tTSCLK3 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0100 , tTSCLK4 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0101 , tTSCLK5 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0110 , tTSCLK6 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_0111 , tTSCLK7 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1000 , tTSCLK8 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1001 , tTSCLK9 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1010 , tTSCLK10 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1011 , tTSCLK11 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1100 , tTSCLK12 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1101 , tTSCLK13 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1110 , tTSCLK14 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W_1111 , tTSCLK15 ); // SCLK _/~ ->_/~

	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0000 , tQSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0001 , tQSCLK1 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0010 , tQSCLK2 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0011 , tQSCLK3 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0100 , tQSCLK4 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0101 , tQSCLK5 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0110 , tQSCLK6 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_0111 , tQSCLK7 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1000 , tQSCLK8 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1001 , tQSCLK9 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1010 , tQSCLK10 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1011 , tQSCLK11 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1100 , tQSCLK12 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1101 , tQSCLK13 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1110 , tQSCLK14 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_4XIO_Chk_W_1111 , tQSCLK15 ); // SCLK _/~ ->_/~

	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0000 , tFSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0001 , tFSCLK1 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0010 , tFSCLK2 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0011 , tFSCLK3 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0100 , tFSCLK4 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0101 , tFSCLK5 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0110 , tFSCLK6 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_0111 , tFSCLK7 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1000 , tFSCLK8 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1001 , tFSCLK9 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1010 , tFSCLK10 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1011 , tFSCLK11 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1100 , tFSCLK12 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1101 , tFSCLK13 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1110 , tFSCLK14 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_1XIO_Chk_W_1111 , tFSCLK15 ); // SCLK _/~ ->_/~

	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0000 , tFDSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0001 , tFDSCLK1 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0010 , tFDSCLK2 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0011 , tFDSCLK3 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0100 , tFDSCLK4 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0101 , tFDSCLK5 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0110 , tFDSCLK6 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_0111 , tFDSCLK7 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1000 , tFDSCLK8 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1001 , tFDSCLK9 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1010 , tFDSCLK10 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1011 , tFDSCLK11 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1100 , tFDSCLK12 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1101 , tFDSCLK13 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1110 , tFDSCLK14 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_2XIO_Chk_W_1111 , tFDSCLK15 ); // SCLK _/~ ->_/~

	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0000 , tFQSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0001 , tFQSCLK1 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0010 , tFQSCLK2 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0011 , tFQSCLK3 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0100 , tFQSCLK4 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0101 , tFQSCLK5 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0110 , tFQSCLK6 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_0111 , tFQSCLK7 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1000 , tFQSCLK8 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1001 , tFQSCLK9 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1010 , tFQSCLK10 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1011 , tFQSCLK11 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1100 , tFQSCLK12 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1101 , tFQSCLK13 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1110 , tFQSCLK14 ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& FastRD_4XIO_Chk_W_1111 , tFQSCLK15 ); // SCLK _/~ ->_/~

    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0000 , tFDTRSCLK ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0001 , tFDTRSCLK1 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0010 , tFDTRSCLK2 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0011 , tFDTRSCLK3 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0100 , tFDTRSCLK4 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0101 , tFDTRSCLK5 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0110 , tFDTRSCLK6 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_0111 , tFDTRSCLK7 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1000 , tFDTRSCLK8 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1001 , tFDTRSCLK9 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1010 , tFDTRSCLK10 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1011 , tFDTRSCLK11 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1100 , tFDTRSCLK12 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1101 , tFDTRSCLK13 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1110 , tFDTRSCLK14 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_1XIO_Mode_W_1111 , tFDTRSCLK15 ); // SCLK _/~ ->_/~

    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0000 , tTDTRSCLK ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0001 , tTDTRSCLK1 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0010 , tTDTRSCLK2 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0011 , tTDTRSCLK3 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0100 , tTDTRSCLK4 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0101 , tTDTRSCLK5 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0110 , tTDTRSCLK6 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_0111 , tTDTRSCLK7 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1000 , tTDTRSCLK8 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1001 , tTDTRSCLK9 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1010 , tTDTRSCLK10 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1011 , tTDTRSCLK11 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1100 , tTDTRSCLK12 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1101 , tTDTRSCLK13 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1110 , tTDTRSCLK14 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_2XIO_Mode_W_1111 , tTDTRSCLK15 ); // SCLK _/~ ->_/~

    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0000 , tQDTRSCLK ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0001 , tQDTRSCLK1 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0010 , tQDTRSCLK2 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0011 , tQDTRSCLK3 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0100 , tQDTRSCLK4 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0101 , tQDTRSCLK5 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0110 , tQDTRSCLK6 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_0111 , tQDTRSCLK7 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1000 , tQDTRSCLK8 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1001 , tQDTRSCLK9 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1010 , tQDTRSCLK10 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1011 , tQDTRSCLK11 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1100 , tQDTRSCLK12 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1101 , tQDTRSCLK13 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1110 , tQDTRSCLK14 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& DTRRead_4XIO_Mode_W_1111 , tQDTRSCLK15 ); // SCLK _/~ ->_/~

    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0000 , tABSCLK ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0001 , tABSCLK1 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0010 , tABSCLK2 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0011 , tABSCLK3 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0100 , tABSCLK4 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0101 , tABSCLK5 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0110 , tABSCLK6 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_0111 , tABSCLK7 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1000 , tABSCLK8 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1001 , tABSCLK9 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1010 , tABSCLK10 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1011 , tABSCLK11 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1100 , tABSCLK12 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1101 , tABSCLK13 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1110 , tABSCLK14 ); // SCLK _/~ ->_/~
    $period( posedge  SCLK &&& AUTO_BOOT_Chk_W_1111 , tABSCLK15 ); // SCLK _/~ ->_/~

        $width ( posedge  CS  &&& tDP_Chk_W, tDP );       // CS _/~\_
        $width ( posedge  CS  &&& tRES1_Chk_W, tRES1 );   // CS _/~\_
        $width ( posedge  CS  &&& tRES2_Chk_W, tRES2 );   // CS _/~\_

        $width ( posedge  SCLK &&& ~CS, tCKH   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& ~CS, tCKL   );       // SCLK ~\__/~
        $width ( posedge  SCLK &&& Read_1XIO_Chk_W, tCKH_R   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& Read_1XIO_Chk_W, tCKL_R   );       // SCLK ~\__/~
        $width ( posedge  SCLK &&& PP_4XIO_Chk_W, tCKH_4PP   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& PP_4XIO_Chk_W, tCKL_4PP   );       // SCLK ~\__/~

	$width ( posedge  CS  &&& Read_SHSL_W, tCEH_R );	// CS _/~\_
	$width ( posedge  CS  &&& Write_SHSL, tCEH_W );// CS _/~\_
	$setup ( SI &&& ~CS, posedge SCLK &&& SI_IN_EN_W,  tDS );
	$hold  ( posedge SCLK &&& SI_IN_EN_W, SI &&& ~CS,  tDH );

	$setup ( SO &&& ~CS, posedge SCLK &&& SO_IN_EN_W,  tDS );
	$hold  ( posedge SCLK &&& SO_IN_EN_W, SO &&& ~CS,  tDH );
	$setup ( WP &&& ~CS, posedge SCLK &&& WP_IN_EN_W,  tDS );
	$hold  ( posedge SCLK &&& WP_IN_EN_W, WP &&& ~CS,  tDH );

	$setup ( SIO3 &&& ~CS, posedge SCLK &&& SIO3_IN_EN_W,  tDS );
	$hold  ( posedge SCLK &&& SIO3_IN_EN_W, SIO3 &&& ~CS,  tDH );

	$setup    ( negedge CS, posedge SCLK &&& ~CS, tCS );
	$hold     ( posedge SCLK &&& ~CS, posedge CS, tCH );
     
	$setup    ( posedge CS, posedge SCLK &&& CS, tCS );
	$hold     ( posedge SCLK &&& CS, negedge CS, tCH );

	$setup	( negedge HOLD_B_INT, posedge SCLK &&& ~CS,	tHLCH );
	$hold		( posedge SCLK &&& ~CS, posedge HOLD_B_INT, tCHHH );
	$setup 	( posedge HOLD_B_INT, posedge SCLK &&& ~CS, tHHCH );
	$hold		( posedge SCLK &&& ~CS, negedge HOLD_B_INT, tCHHL );

  $width ( negedge  RESETB_INT, tRESET   );      // RESET ~\__/~
	$hold  ( posedge  RESETB_INT, negedge CS, tHWRST );
     endspecify

    integer AC_Check_File;
    // timing check module 
    initial 
    begin 
    	AC_Check_File= $fopen ("ac_check.err" );    
    end

    time  T_CS_P , T_CS_N;
    time  T_WP_P , T_WP_N;
    time  T_SCLK_P , T_SCLK_N;
    time  T_SIO3_P , T_SIO3_N;
    time  T_SI;
    time  T_SO;
    time  T_WP;
    time  T_SIO3;
    time  T_RESET_N, T_RESET_P;                    

    initial 
    begin
	T_CS_P = 0; 
	T_CS_N = 0;
	T_WP_P = 0;  
	T_WP_N = 0;
	T_SCLK_P = 0;  
	T_SCLK_N = 0;
	T_SIO3_P = 0;  
	T_SIO3_N = 0;
	T_SI = 0;
	T_SO = 0;
	T_WP = 0;
	T_SIO3 = 0;
	T_RESET_N = 0;
	T_RESET_P = 0;
    end
 
// Check SCLK period: must be longer than tSCLK; 
    always @ ( posedge SCLK ) begin
	//tSCLK for fast frequency
        if ( (($time - T_SCLK_P) < tSCLK) && ($time > 0) && ~CS ) 
	    $fwrite (AC_Check_File, "Clock Frequence for except Normal READ struction fCT =%d Mhz, fCT timing violation at %d \n", fCT, $time );
	//tSCLK_NOR for normal read frequency
        if ( (($time - T_SCLK_P) < tSCLK_NOR) && Read_1XIO_Chk && ($time > 0) && ~CS )
	    $fwrite (AC_Check_File, "Clock Frequence for Normal READ instruction fC =%d Mhz, fC timing violation at %d \n", fC, $time );

	//fTSCLK
		if ( $time - T_SCLK_P < tTSCLK && Read_2XIO_Chk && RP_0000 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK, $time );
	//fTSCLK1
		if ( $time - T_SCLK_P < tTSCLK1 && Read_2XIO_Chk && RP_0001 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK1, $time );
	//fTSCLK2
		if ( $time - T_SCLK_P < tTSCLK2 && Read_2XIO_Chk && RP_0010 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK2, $time );
	//fTSCLK3
		if ( $time - T_SCLK_P < tTSCLK3 && Read_2XIO_Chk && RP_0011 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK3, $time );
	//fTSCLK4
		if ( $time - T_SCLK_P < tTSCLK4 && Read_2XIO_Chk && RP_0100 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK4, $time );
	//fTSCLK5
		if ( $time - T_SCLK_P < tTSCLK5 && Read_2XIO_Chk && RP_0101 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK5, $time );
	//fTSCLK6
		if ( $time - T_SCLK_P < tTSCLK6 && Read_2XIO_Chk && RP_0110 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK6, $time );
	//fTSCLK7
		if ( $time - T_SCLK_P < tTSCLK7 && Read_2XIO_Chk && RP_0111 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK7, $time );
	//fTSCLK8
		if ( $time - T_SCLK_P < tTSCLK8 && Read_2XIO_Chk && RP_1000 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK8, $time );
	//fTSCLK9
		if ( $time - T_SCLK_P < tTSCLK9 && Read_2XIO_Chk && RP_1001 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK9, $time );
	//fTSCLK10
		if ( $time - T_SCLK_P < tTSCLK10 && Read_2XIO_Chk && RP_1010 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK10, $time );
	//fTSCLK11
		if ( $time - T_SCLK_P < tTSCLK11 && Read_2XIO_Chk && RP_1011 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK11, $time );
	//fTSCLK12
		if ( $time - T_SCLK_P < tTSCLK12 && Read_2XIO_Chk && RP_1100 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK12, $time );
	//fTSCLK13
		if ( $time - T_SCLK_P < tTSCLK13 && Read_2XIO_Chk && RP_1101 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK13, $time );
	//fTSCLK14
		if ( $time - T_SCLK_P < tTSCLK14 && Read_2XIO_Chk && RP_1110 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK14, $time );
	//fTSCLK15
		if ( $time - T_SCLK_P < tTSCLK15 && Read_2XIO_Chk && RP_1111 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 2XIO instruction fTSCLK =%d Mhz, fTSCLK timing violation at %d \n", fTSCLK15, $time );

	//fQSCLK
		if ( $time - T_SCLK_P < tQSCLK && Read_4XIO_Chk && RP_0000 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK, $time );
	//fQSCLK1
		if ( $time - T_SCLK_P < tQSCLK1 && Read_4XIO_Chk && RP_0001 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK1, $time );
	//fQSCLK2
		if ( $time - T_SCLK_P < tQSCLK2 && Read_4XIO_Chk && RP_0010 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK2, $time );
	//fQSCLK3
		if ( $time - T_SCLK_P < tQSCLK3 && Read_4XIO_Chk && RP_0011 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK3, $time );
	//fQSCLK4
		if ( $time - T_SCLK_P < tQSCLK4 && Read_4XIO_Chk && RP_0100 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK4, $time );
	//fQSCLK5
		if ( $time - T_SCLK_P < tQSCLK5 && Read_4XIO_Chk && RP_0101 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK5, $time );
	//fQSCLK6
		if ( $time - T_SCLK_P < tQSCLK6 && Read_4XIO_Chk && RP_0110 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK6, $time );
	//fQSCLK7
		if ( $time - T_SCLK_P < tQSCLK7 && Read_4XIO_Chk && RP_0111 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK7, $time );
	//fQSCLK8
		if ( $time - T_SCLK_P < tQSCLK8 && Read_4XIO_Chk && RP_1000 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK8, $time );
	//fQSCLK9
		if ( $time - T_SCLK_P < tQSCLK9 && Read_4XIO_Chk && RP_1001 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK9, $time );
	//fQSCLK10
		if ( $time - T_SCLK_P < tQSCLK10 && Read_4XIO_Chk && RP_1010 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK10, $time );
	//fQSCLK11
		if ( $time - T_SCLK_P < tQSCLK11 && Read_4XIO_Chk && RP_1011 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK11, $time );
	//fQSCLK12
		if ( $time - T_SCLK_P < tQSCLK12 && Read_4XIO_Chk && RP_1100 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK12, $time );
	//fQSCLK13
		if ( $time - T_SCLK_P < tQSCLK13 && Read_4XIO_Chk && RP_1101 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK13, $time );
	//fQSCLK14
		if ( $time - T_SCLK_P < tQSCLK14 && Read_4XIO_Chk && RP_1110 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK14, $time );
	//fQSCLK15
		if ( $time - T_SCLK_P < tQSCLK15 && Read_4XIO_Chk && RP_1111 && $time > 0 && ~CS )
		$write (AC_Check_File, "Clock Frequence for 4XIO instruction fQSCLK =%d Mhz, fQSCLK timing violation at %d \n", fQSCLK15, $time );


    //fFSCLK
        if ( $time - T_SCLK_P < tFSCLK && FastRD_1XIO_Chk && RP_0000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK, $time );
    //fFSCLK1
        if ( $time - T_SCLK_P < tFSCLK1 && FastRD_1XIO_Chk && RP_0001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK1, $time );
    //fFSCLK2
        if ( $time - T_SCLK_P < tFSCLK2 && FastRD_1XIO_Chk && RP_0010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK2, $time );
    //fFSCLK3
        if ( $time - T_SCLK_P < tFSCLK3 && FastRD_1XIO_Chk && RP_0011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK3, $time );
    //fFSCLK4
        if ( $time - T_SCLK_P < tFSCLK4 && FastRD_1XIO_Chk && RP_0100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK4, $time );
    //fFSCLK5
        if ( $time - T_SCLK_P < tFSCLK5 && FastRD_1XIO_Chk && RP_0101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK5, $time );
    //fFSCLK6
        if ( $time - T_SCLK_P < tFSCLK6 && FastRD_1XIO_Chk && RP_0110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK6, $time );
    //fFSCLK7
        if ( $time - T_SCLK_P < tFSCLK7 && FastRD_1XIO_Chk && RP_0111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK7, $time );
    //fFSCLK8
        if ( $time - T_SCLK_P < tFSCLK8 && FastRD_1XIO_Chk && RP_1000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK8, $time );
    //fFSCLK9
        if ( $time - T_SCLK_P < tFSCLK9 && FastRD_1XIO_Chk && RP_1001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK9, $time );
    //fFSCLK10
        if ( $time - T_SCLK_P < tFSCLK10 && FastRD_1XIO_Chk && RP_1010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK10, $time );
    //fFSCLK11
        if ( $time - T_SCLK_P < tFSCLK11 && FastRD_1XIO_Chk && RP_1011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK11, $time );
    //fFSCLK12
        if ( $time - T_SCLK_P < tFSCLK12 && FastRD_1XIO_Chk && RP_1100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK12, $time );
    //fFSCLK13
        if ( $time - T_SCLK_P < tFSCLK13 && FastRD_1XIO_Chk && RP_1101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK13, $time );
    //fFSCLK14
        if ( $time - T_SCLK_P < tFSCLK14 && FastRD_1XIO_Chk && RP_1110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK14, $time );
    //fFSCLK15
        if ( $time - T_SCLK_P < tFSCLK15 && FastRD_1XIO_Chk && RP_1111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 1XIO instruction fFSCLK =%d Mhz, fFSCLK timing violation at %d \n", fFSCLK15, $time );

    //fFDSCLK
        if ( $time - T_SCLK_P < tFDSCLK && FastRD_2XIO_Chk && RP_0000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK, $time );
    //fFDSCLK1
        if ( $time - T_SCLK_P < tFDSCLK1 && FastRD_2XIO_Chk && RP_0001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK1, $time );
    //fFDSCLK2
        if ( $time - T_SCLK_P < tFDSCLK2 && FastRD_2XIO_Chk && RP_0010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK2, $time );
    //fFDSCLK3
        if ( $time - T_SCLK_P < tFDSCLK3 && FastRD_2XIO_Chk && RP_0011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK3, $time );
    //fFDSCLK4
        if ( $time - T_SCLK_P < tFDSCLK4 && FastRD_2XIO_Chk && RP_0100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK4, $time );
    //fFDSCLK5
        if ( $time - T_SCLK_P < tFDSCLK5 && FastRD_2XIO_Chk && RP_0101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK5, $time );
    //fFDSCLK6
        if ( $time - T_SCLK_P < tFDSCLK6 && FastRD_2XIO_Chk && RP_0110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK6, $time );
    //fFDSCLK7
        if ( $time - T_SCLK_P < tFDSCLK7 && FastRD_2XIO_Chk && RP_0111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK7, $time );
    //fFDSCLK8
        if ( $time - T_SCLK_P < tFDSCLK8 && FastRD_2XIO_Chk && RP_1000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK8, $time );
    //fFDSCLK9
        if ( $time - T_SCLK_P < tFDSCLK9 && FastRD_2XIO_Chk && RP_1001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK9, $time );
    //fFDSCLK10
        if ( $time - T_SCLK_P < tFDSCLK10 && FastRD_2XIO_Chk && RP_1010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK10, $time );
    //fFDSCLK11
        if ( $time - T_SCLK_P < tFDSCLK11 && FastRD_2XIO_Chk && RP_1011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK11, $time );
    //fFDSCLK12
        if ( $time - T_SCLK_P < tFDSCLK12 && FastRD_2XIO_Chk && RP_1100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK12, $time );
    //fFDSCLK13
        if ( $time - T_SCLK_P < tFDSCLK13 && FastRD_2XIO_Chk && RP_1101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK13, $time );
    //fFDSCLK14
        if ( $time - T_SCLK_P < tFDSCLK14 && FastRD_2XIO_Chk && RP_1110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK14, $time );
    //fFDSCLK15
        if ( $time - T_SCLK_P < tFDSCLK15 && FastRD_2XIO_Chk && RP_1111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 2XIO instruction fFDSCLK =%d Mhz, fFDSCLK timing violation at %d \n", fFDSCLK15, $time );

    //fFQSCLK
        if ( $time - T_SCLK_P < tFQSCLK && FastRD_4XIO_Chk && RP_0000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK, $time );
    //fFQSCLK1
        if ( $time - T_SCLK_P < tFQSCLK1 && FastRD_4XIO_Chk && RP_0001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK1, $time );
    //fFQSCLK2
        if ( $time - T_SCLK_P < tFQSCLK2 && FastRD_4XIO_Chk && RP_0010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK2, $time );
    //fFQSCLK3
        if ( $time - T_SCLK_P < tFQSCLK3 && FastRD_4XIO_Chk && RP_0011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK3, $time );
    //fFQSCLK4
        if ( $time - T_SCLK_P < tFQSCLK4 && FastRD_4XIO_Chk && RP_0100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK4, $time );
    //fFQSCLK5
        if ( $time - T_SCLK_P < tFQSCLK5 && FastRD_4XIO_Chk && RP_0101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK5, $time );
    //fFQSCLK6
        if ( $time - T_SCLK_P < tFQSCLK6 && FastRD_4XIO_Chk && RP_0110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK6, $time );
    //fFQSCLK7
        if ( $time - T_SCLK_P < tFQSCLK7 && FastRD_4XIO_Chk && RP_0111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK7, $time );
    //fFQSCLK8
        if ( $time - T_SCLK_P < tFQSCLK8 && FastRD_4XIO_Chk && RP_1000 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK8, $time );
    //fFQSCLK9
        if ( $time - T_SCLK_P < tFQSCLK9 && FastRD_4XIO_Chk && RP_1001 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK9, $time );
    //fFQSCLK10
        if ( $time - T_SCLK_P < tFQSCLK10 && FastRD_4XIO_Chk && RP_1010 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK10, $time );
    //fFQSCLK11
        if ( $time - T_SCLK_P < tFQSCLK11 && FastRD_4XIO_Chk && RP_1011 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK11, $time );
    //fFQSCLK12
        if ( $time - T_SCLK_P < tFQSCLK12 && FastRD_4XIO_Chk && RP_1100 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK12, $time );
    //fFQSCLK13
        if ( $time - T_SCLK_P < tFQSCLK13 && FastRD_4XIO_Chk && RP_1101 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK13, $time );
    //fFQSCLK14
        if ( $time - T_SCLK_P < tFQSCLK14 && FastRD_4XIO_Chk && RP_1110 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK14, $time );
    //fFQSCLK15
        if ( $time - T_SCLK_P < tFQSCLK15 && FastRD_4XIO_Chk && RP_1111 && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for Fast 4XIO instruction fFQSCLK =%d Mhz, fFQSCLK timing violation at %d \n", fFQSCLK15, $time );

    //fABSCLK
        if ( $time - T_SCLK_P < tABSCLK && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0000 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK, $time );
    //fABSCLK1
        if ( $time - T_SCLK_P < tABSCLK1 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0001 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK1, $time );
    //fABSCLK2
        if ( $time - T_SCLK_P < tABSCLK2 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0010 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK2, $time );
    //fABSCLK3
        if ( $time - T_SCLK_P < tABSCLK3 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0011 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK3, $time );
    //fABSCLK4
        if ( $time - T_SCLK_P < tABSCLK4 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0100 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK4, $time );
    //fABSCLK5
        if ( $time - T_SCLK_P < tABSCLK5 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0101 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK5, $time );
    //fABSCLK6
        if ( $time - T_SCLK_P < tABSCLK6 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0110 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK6, $time );
    //fABSCLK7
        if ( $time - T_SCLK_P < tABSCLK7 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b0111 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK7, $time );
    //fABSCLK8
        if ( $time - T_SCLK_P < tABSCLK8 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1000 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK8, $time );
    //fABSCLK9
        if ( $time - T_SCLK_P < tABSCLK9 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1001 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK9, $time );
    //fABSCLK10
        if ( $time - T_SCLK_P < tABSCLK10 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1010 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK10, $time );
    //fABSCLK11
        if ( $time - T_SCLK_P < tABSCLK11 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1011 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK11, $time );
    //fABSCLK12
        if ( $time - T_SCLK_P < tABSCLK12 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1100 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK12, $time );
    //fABSCLK13
        if ( $time - T_SCLK_P < tABSCLK13 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1101 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK13, $time );
    //fABSCLK14
        if ( $time - T_SCLK_P < tABSCLK14 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1110 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK14, $time );
    //fABSCLK15
        if ( $time - T_SCLK_P < tABSCLK15 && AUTO_BOOT_Chk && ( AB_Reg[4:1] == 4'b1111 ) && $time > 0 && ~CS )
        $fwrite (AC_Check_File, "Clock Frequence for auto boot instruction fABSCLK =%d Mhz, fABSCLK timing violation at %d \n", fABSCLK15, $time );


        T_SCLK_P = $time; 
        #0;  
	//tDS
        if ( T_SCLK_P - T_SI < tDS && SI_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum Data SI setup time tDS=%f ns, tDS timing violation at %d \n", tDS, $time );
        if ( T_SCLK_P - T_SO < tDS && SO_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum Data SO setup time tDS=%f ns, tDS timing violation at %d \n", tDS, $time );
        if ( T_SCLK_P - T_WP < tDS && WP_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum Data WP setup time tDS=%f ns, tDS timing violation at %d \n", tDS, $time );

        if ( T_SCLK_P - T_SIO3 < tDS && SIO3_IN_EN && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum Data SIO3 setup time tDS=%f ns, tDS timing violation at %d \n", tDS, $time );
	//tCKL
        if ( T_SCLK_P - T_SCLK_N < tCKL && ~CS && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum SCLK Low time tCKL=%f ns, tCKL timing violation at %d \n", tCKL, $time );
	//tCKL_R
        if ( T_SCLK_P - T_SCLK_N < tCKL_R && Read_1XIO_Chk && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum SCLK Low time tCKL=%f ns, tCKL timing violation at %d \n", tCKL_R, $time );
	//tCKL_4PP
        if ( T_SCLK_P - T_SCLK_N < tCKL_4PP && PP_4XIO_Chk && T_SCLK_P > 0 )
	    $fwrite (AC_Check_File, "minimum SCLK Low time tCKL=%f ns, tCKL timing violation at %d \n", tCKL_4PP, $time );
        #0;
        // tCS
        if ( T_SCLK_P - T_CS_N < tCS  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active setup time tCS=%f ns, tCS timing violation at %d \n", tCS, $time );

        // tCS
        if ( T_SCLK_P - T_CS_P < tCS  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active setup time tCS=%f ns, tCS timing violation at %d \n", tCS, $time );

				// tHLCH
				if ( T_SCLK_P - T_SIO3_N < tHLCH && ~CS && T_SCLK_P > 0 )
					$fwrite (AC_Check_File, "minimum HOLD# setup time tHLCH=%d ns, tHLCH timing violation at %d \n", tHLCH, $time );

				// tHHCH
				if ( T_SCLK_P - T_SIO3_P < tHHCH && ~CS && T_SCLK_P > 0 )
					$fwrite (AC_Check_File, "minimum HOLD setup time tHHCH=%d ns, tHHCH timing violation at %d \n", tHHCH, $time );

    end

    always @ ( negedge SCLK ) begin
        T_SCLK_N = $time;
        #0; 
	//tCKH
        if ( T_SCLK_N - T_SCLK_P < tCKH && ~CS && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun SCLK High time tCKH=%f ns, tCKH timing violation at %d \n", tCKH, $time );
	//tCKH_R
        if ( T_SCLK_N - T_SCLK_P < tCKH_R && Read_1XIO_Chk && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun SCLK High time tCKH=%f ns, tCKH timing violation at %d \n", tCKH_R, $time );
	//tCKH_4PP
        if ( T_SCLK_N - T_SCLK_P < tCKH_4PP && PP_4XIO_Chk && T_SCLK_N > 0 )
	    $fwrite (AC_Check_File, "minimun SCLK High time tCKH=%f ns, tCKH timing violation at %d \n", tCKH_4PP, $time );
    end


    always @ ( SI ) begin
        T_SI = $time; 
        #0;  
	//tDH
	if ( T_SI - T_SCLK_P < tDH && SI_IN_EN && T_SI > 0 )
	    $fwrite (AC_Check_File, "minimun Data SI hold time tDH=%f ns, tDH timing violation at %d \n", tDH, $time );
    end

    always @ ( SO ) begin
        T_SO = $time; 
        #0;  
	//tDH
	if ( T_SO - T_SCLK_P < tDH && SO_IN_EN && T_SO > 0 )
	    $fwrite (AC_Check_File, "minimun Data SO hold time tDH=%f ns, tDH timing violation at %d \n", tDH, $time );
    end

    always @ ( WP ) begin
        T_WP = $time; 
        #0;  
	//tDH
	if ( T_WP - T_SCLK_P < tDH && WP_IN_EN && T_WP > 0 )
	    $fwrite (AC_Check_File, "minimun Data WP hold time tDH=%f ns, tDH timing violation at %d \n", tDH, $time );
    end

    always @ ( SIO3 ) begin
        T_SIO3 = $time; 
        #0;  
	//tDH
       if ( T_SIO3 - T_SCLK_P < tDH && SIO3_IN_EN && T_SIO3 > 0 )
	    $fwrite (AC_Check_File, "minimun Data SIO3 hold time tDH=%f ns, tDH timing violation at %d \n", tDH, $time );
    end

    always @ ( posedge CS ) begin
        T_CS_P = $time;
        #0;  
	// tCH 
        if ( T_CS_P - T_SCLK_P < tCH  && T_CS_P > 0 )
	    $fwrite (AC_Check_File, "minimun CS# active hold time tCH=%f ns, tCH timing violation at %d \n", tCH, $time );
    end

    always @ ( negedge CS ) begin
        T_CS_N = $time;
        #0;
	//tCH
        if ( T_CS_N - T_SCLK_P < tCH  && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimun CS# not active hold time tCH=%f ns, tCH timing violation at %d \n", tCH, $time );
	//tSHSL
        if ( T_CS_N - T_CS_P < tCEH_R && T_CS_N > 0 && Read_SHSL)
            $fwrite (AC_Check_File, "minimun CS# deslect  time tCEH=%f ns, tSHSL timing violation at %d \n", tCEH_R, $time );
        if ( T_CS_N - T_CS_P < tCEH_W && T_CS_N > 0 && Write_SHSL)
            $fwrite (AC_Check_File, "minimun CS# deslect  time tCEH=%f ns, tSHSL timing violation at %d \n", tCEH_W, $time );

        //tDP
        if ( T_CS_N - T_CS_P < tDP && T_CS_N > 0 && tDP_Chk)
            $fwrite (AC_Check_File, "when transite from Standby Mode to Deep-Power Mode, CS# must remain high for at least tDP =%f ns, tDP timing violation at %d \n", tDP, $time );


        //tRES1/2
        if ( T_CS_N - T_CS_P < tRES1 && T_CS_N > 0 && tRES1_Chk)
            $fwrite (AC_Check_File, "when transite from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES1 =%f ns, tRES1 timing violation at %d \n", tRES1, $time );

        if ( T_CS_N - T_CS_P < tRES2 && T_CS_N > 0 && tRES2_Chk)
            $fwrite (AC_Check_File, "when transite from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES2 =%f ns, tRES2 timing violation at %d \n", tRES2, $time );
	//tHWRST
	if ( T_CS_N - T_RESET_P < tHWRST && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimun Reset# high before CS# low time tHWRST=%f ns, tHWRST timing violation at %d \n", tHWRST, $time );
    end

	always @ ( posedge HOLD_B_INT )
		begin
			T_SIO3_P = $time;
			#0;
			//tCHHH
			if ( T_SIO3_P - T_SCLK_P < tCHHH && ~CS && T_SIO3_P > 0 )
				$fwrite (AC_Check_File, "minimum HOLD# hold time tCHHH=%d ns, tCHHH timing violation at %d \n", tCHHH, $time );
		end

	always @ ( negedge HOLD_B_INT )
		begin
			T_SIO3_N = $time;
			#0;
			//tCHHL
			if ( T_SIO3_N - T_SCLK_P < tCHHL && ~CS && T_SIO3_N > 0 )
				$fwrite (AC_Check_File, "minimum HOLD hold time tCHHL=%d ns, tCHHL timing violation at %d \n", tCHHL, $time );
		end




    always @ ( posedge RESETB_INT ) begin
        T_RESET_P = $time;
        #0;
        //tRESET
        if ( (T_RESET_P - T_RESET_N < tRESET) && T_RESET_P > 0 )
            $fwrite (AC_Check_File, "minimun reset pulse width tRESET=%f ns, tRESET timing violation at %d \n", tRESET, $time );
    end

// pragma protect end

endmodule

