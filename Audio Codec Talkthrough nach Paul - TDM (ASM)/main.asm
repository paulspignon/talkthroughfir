/*****************************************************************************    
**											
**	 Name: 	BF533 ASM Talkthrough TDM						
**											
****************************************************************************** 
																		
(C) Copyright 2006 - Analog Devices, Inc.  All rights reserved.			
										
File Name:	Main.asm					
										
Date Modified:	04/07/03	Rev 1.0			
										
Software:	VisualDSP++4.5						
										
Hardware:	ADSP-BF533 EZ-KIT Board					
																		
Connections:	Disconnect RSCLK0 and TSCLK0 (Turn SW9 pin 6 OFF)
		Disconnect RFS0 and TFS0 (Turn SW9 pin 5 OFF)
		Connect an input source (such as a radio) to the Audio	
		input jack and an output source (such as headphones) to 
		the Audio output jack					
											
Purpose:	THIS program sets up the SPI port on the ADSP-BF533 to 
		configure the AD1836 codec.  The SPI port is disabled 	
		after initialisation.  The data to/from the codec are 	
		transfered over SPORT0 in TDM mode.			
											
******************************************************************************/

#include "Talkthrough.h"
						
/*****************************************************************************
 Variables															
 
 Description:	The variables ChannelxLeftIn and ChannelxRightIn contain 	                              
		the data coming from the codec AD1836.  The (processed)		
		playback data are written into the variables 			
		ChannelxLeftOut and ChannelxRightOut respectively, which        
		are then sent back to the codec in the SPORT0 ISR.  		
		The values in the array Codec1836TxRegs can be modified to 
		set up the codec in different configurations according to   
		the AD1885 data sheet.		
												
******************************************************************************/

/****************************************************************************
Hacked by Paul to embed wavelet filter bank (_wfb).
The filter bank is always running, in main, but spins until the rx ISR flags data available.
It disables interrupts, clears that flag, renables interrupts, does the FIR cascade, writes/outputs
new samples (presently 2 at a time).

***************************************************************************/
.section L1_data_a;

// left input data from ad1836
.var Channel0LeftIn, Channel1LeftIn;
// right input data from ad1836
.var Channel0RightIn, Channel1RightIn;
// left ouput data for ad1836
.var Channel0LeftOut, Channel1LeftOut;
// right ouput data for ad1836
.var Channel0RightOut, Channel1RightOut;
// array for registers to configure the ad1836
// names are defined in "Talkthrough.h"
.align 2;
.byte2	Codec1836TxRegs[CODEC_1836_REGS_LENGTH] =
{									
					DAC_CONTROL_1	| 0x000,
					DAC_CONTROL_2	| 0x000,
					DAC_VOLUME_0	| 0x3ff,
					DAC_VOLUME_1	| 0x3ff,
					DAC_VOLUME_2	| 0x3ff,
					DAC_VOLUME_3	| 0x3ff,
					DAC_VOLUME_4	| 0x3ff,
					DAC_VOLUME_5	| 0x3ff,
					ADC_CONTROL_1	| 0x000,
					ADC_CONTROL_2	| 0x180,
					ADC_CONTROL_3	| 0x000
					
};
// SPORT0 DMA transmit buffer
.align 4;
.byte4	tx_buf[8];
// SPORT0 DMA receive buffer
.align 4;
.byte4	rx_buf[8];

/*****************************************************************************
 Function:	_main														
 
 Description:	After calling a few initalisation routines, main just 		
		waits in a loop forever.  The code to process the incoming  
		data can be placed in the function Process_Data in the	 	
		file "Process_Data.asm".					
******************************************************************************/
.global _main;

.section L1_code;
_main:

	call Init_EBIU;
	call Init_Flash;
	call Init_1836;
	call Init_Sport0;
	call Init_DMA;
	call Init_Interrupts;
	call Enable_DMA_Sport0;
	
WAIT_FOREVER:
	JUMP WAIT_FOREVER;

_main.END:
	

