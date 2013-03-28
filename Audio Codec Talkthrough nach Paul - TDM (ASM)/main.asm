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
#include "consts.h"

						
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

/************

H0 a, b, c, d		F0 d, c, b, a 
H1 d, -c, b, -a     F1 -a, b, -c, d

Generally, to get IDWT filters from DWT

H0 a, b, c
H1 p, q, r, s, t 
F0 p, -q, r, -s
p, -q, r, -s, t F0

***********/

//The high-pass filter. Following Bömer's notation for consistency, regardless of logicality, h/H stands for forward transform, f/F for inverse (reconstruction) transform filters

.VAR hh[TAPLENGTH] = { 0.4r, 0.4r, 0.4r, 0.4r}; //{0.70710678118655r, 0.70710678118655r, 0.70710678118655r, 0.70710678118655r}; 
/*

{	0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,
	0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r,0.070710678118655r, 0.070710678118655r, 0.070710678118655r, 0.070710678118655r};*/ // "filt_coeff.dat"; //file of the form 
											/*	0xff14,
												000000,
												0x114a,
												0x2fa2,
												0x2fa2,
												0x114a,
												000000,
												0xff14 */
												
.VAR hl[TAPLENGTH]; //

.align 2												
.BYTE2 d[DELAY_SIZE];
//.BYTE2 in[INBUF_SIZE]; No use for inbuff, each sample pair
.BYTE2 out[16];
//.BYTE2 MM = DELAY_SIZE; //Cannot use M, apparently reserved
.BYTE4 flags = 0; //

.GLOBAL flags, d, out;
/*****************************************************************************
 Function:	_main	
 
 May change this so it's a function called from a C shell (hehe). The function call will be something like
 _wisewave(unsigned int flags, int filtlen, int n_levels)
 How to initialize different hh, hl, or even change on the fly? One option, the C shell writes 										
 
 Description: After initialization as per the Talkthrough example, my code disables interrupts, initializes the FIR
 	setup, reenables interrupts, and spins until there's something to filter					
******************************************************************************/
.global _main;

.align 8
.section L1_code;
_main:

	call Init_EBIU;
	call Init_Flash;
	call Init_1836;
	call Init_Sport0;
	call Init_DMA;
	call Init_Interrupts;
	call Enable_DMA_Sport0;
		
	
//Here do all the setup for the filter bank
	
	CLI R5; //Disable interrupts while we set up the processing framework

	P1.L = hh;			// Address of the filter coefficient array, size M	
	P1.H = hh;			
	P2.L = d;			//Address of the delay line
	P2.H = d;
//	R3=[P0++];			// Number of filter coefficients, M	
//	R3 = DELAY_SIZE;
	I2=P1;				// Initialize I2 to the start of the filter coeff. array h[]
	B2=P1;				// Filter coeff. array initialized as a circular buffer 
	I0=P2;     			// start of the delay line write pointer
	B0=P2;				// Delay line buffer is initialized as a circular buffer. See later where L2 is set to the length of this buffer
	B1=P2;				// Delay line buffer is initialized as a circular buffer for the second time
	I1=P2;     			// I1 also at delay line origin, need it one sample behing I0
					
	P3.L = out;
	P3.H = out;
	B3 = 0x00000000; //P3;
	I3 = 0;//P3;			// I3 addresses the output buffer
//	P1=R2;	    		// R2 still = nsamples, num samples in the source array, cache it in P1, won't be needed when we have real stream
	P2=R3;				// cache no. filter coeffs in P2, or could we just P2=DELAY_SIZE

	R2=R2+R2;			//only needed if making the output buff circular
	
/*** never mind about checking for even tap count, we'll always make M even ***/
			
	R3 = DELAY_SIZE<<1;	//Tried making bigger, but then I1-- does not automatically reposition 1 sample behind I0++ on next outer loop
	L0 = R3;      		// Set the length of the delay line buffer &-- size of filter coeff array in bytes, I0 will wrap automagically at this point --&
	L1 = R3;      		// Set the length of the delay line buffer &-- size of "delay line", that is sample segment, I1 will wrap at this point --&
	L2 = TAPLENGTH<<1;
	R2.H = 0x100;		//Aha, one cannot write more that 16 bits at a time, so to get
	R2.L = 0;			//0x1000000 into R2 you have to do this two-step
	L3 = R2;			// Make output buff circular anyway, for streaming this is good, though then it only needs to be small
			
	R3 = 0; 			//First output sample pair will be 0
	P2+=-1;				//M-1, so inner loop count P2>1 will be 3 if M=8
	I1-=2;				//one sample behind I0
			
	nop;nop;nop;		// &-- what for? Don't know --&
									

	R2 = [I2++];		//get h[0] into R2.L, h[1] into R2.H for the first time
	NOP ;           // Align the instruction, do not yet understand how one would know when this is needed  
//All new from here on in

//in streaming version spin here till data ready flag set, the OULTLOOP is infinite, so would just JUMP back to OUTLOOP

//	LSETUP(OUTLOOP,END_OUTLOOP)LC0=P1>>1; //Outer Loop N/2 times, in example P1=260, LC0 = 130, bite off 2 samples each loop
	

//******************************************************************************************
	
OUTLOOP:
	STI R5;
	NOP; NOP; NOP; NOP;  //Enable interrupts and spin a while before checking flag again
	P0.L = flags;
	P0.H = flags;		//P0 now contains address of flags
	CLI R5; 			//Disable interrupts while we test flags
	R4.L = W [P0];		//Copy flag word to R4.L
	CC = BITTST(R4, IN_READY); //Is the flag bit set?
	IF !CC JUMP OUTLOOP (BP); //If not, go spin some more,
	BITCLR(R4, IN_READY); //else clear the flag at once, while interrupts are still disabled
	W [P0] = R4.L;			//write the flags back in the flag variable
	
	//N.B. Interrupts are still disabled as yet			
	R0 = R7;			// next two samples delivered by DMA in the ISR are in R7, get them into R0 for first convolution MAC  	
	[I3--] = R6;		//cache the 2 output samples in the output buffer. The ISR will get them from out one by one
						//on the next two interrupts, incrementing I3, i.e. at present no actual buffering of the output. TODO, maybe,
						//but as we have no more circular index registers have to cache I3 somewhere		
	STI R5;				//reenable interrupts
	
//n = 0				
	A0 = R2.L*R0.L, 	//h[0].x[n]
	A1 = R2.L*R0.H ||	//h[0].x[n+1]
	[I0++] = R0 ||		//write the two new samples into d[], at the address indexed by I0, advance I0	
	R0.H = W[I1--];		//R0.H = x[n-1], R0.L = x[n], decrement I1 by one 2-byte step
	
	LSETUP(INLOOP,END_INLOOP) LC1=P2>>1; //deal with 2 samples in every loop, 1 cycle per sample, as in the original fir example	

INLOOP:	
	A0 += R2.H*R0.H,	//add h[1].x[n-1] to A0	N.B. {Two MAC ops in one instruction must both use the same two registers, }
	A1 += R2.H*R0.L ||	//add h[1].x[n] to A1. 		 { e.g if R0 was R1 in the second instruction it would be illegal}
	R2 = [I2++] ||		//get h[2], h[3] into R2, so R2.L = h[2], R2.H = h[3]
	R0.L = W[I1--];		//R0.L = x[n-2], R0.H = x[n-1];								
	
END_INLOOP:
	A0 += R2.L*R0.L,	//add h[2].x[n-2] to A0
	A1 += R2.L*R0.H ||	//add h[2].x[n-1] to A1
	R0.H = W[I1--];		//R0.L= x[n-2], R0.H=x[n-3]

//END_OUTLOOP:	
	R6.L = (A0 += R2.H*R0.H),	//add h[7].x[n-7] to A0, assuming all done copy low word to R6.L 
	R6.H = (A1 += R2.H*R0.L) ||	//add h[7].x[n-6] to A1,      "     "   "  copy low word to R6.H
	R2 = [I2++] ||				//R2.L = h[0], R2.H = h[1], for next outer loop
//	I1+=2; 				//In one outer loop I1 steps backwards by M-1 samples, ending up one sample further forward in the M-sample 
						// circular buffer d[], whilst I0 advances two samples in each outer loop.Hence need to bump up I1 by one more sample
/************
Now using delay line of M+2 samples, so I1 ends up where I0 is, before next 2 samples are written to [I0++]. Need to back I1 by 1 sample.
Here's and illustration for the case of M=4, at the transition between getting out samples y[4], y[5] and initiating convolutions to get y[6], y[7]

Before convoluting to get y[4], y[5]

                                                           ---- put in from R0 ----- 
 |    x[0]     |     x[1]     |     x[2]     |     x[3]     | x[4]     |     x[5]     |
    
  ^                                                          ^
  I0                                                         I1
  
  After (the last operation using I1 was R0.H = W[I1--], getting x[1] (i.e. x[n-M+1], n=4, M=4) into R0.H 
  
                                ------------------used to get y[5] --------------------
                 ---------------------- used to get y[4] ---------------     
  |    x[0]     |     x[1]     |     x[2]     |     x[3]     | x[4]     |     x[5]     |
   ^
   I1
   I0
   
  On loading x[6], x[7] instead of the two oldest samples,  using I0++:
  
   ----- put in from R0 -------
  |    x[6]     |     x[7]     |     x[2]     |     x[3]     | x[4]     |     x[5]     |
  ^                             ^
  I1                            I0
  
  We need I1 to be pointing at x[5] (x[n-1] now n = 6), so it needs to be move back by one sample before initializing the loop again. 
  Then we'll have
   
      ----- put in from R0 -------
  |    x[6]     |     x[7]     |     x[2]     |     x[3]     | x[4]     |     x[5]     |
                                ^                                        ^
                               I0                                        I1

*****************/
	
	A0 += A1;		//Average of pair
	A0 = A0 >>> 1;  //Divide sum by 2
	R6 = A0;		//Stash the detail coeff in R6.H
	R6 <<= 16;// PACK(R6.L, R6.L); //to get low word into high word

	CC = BITTST(R4, DONE_LP);
	IF CC JUMP DONE_BOTH; //If not done HP go do it
	BITSET(R4, DONE_LP); 		//else set flag to show we did the LP
	CLI R5; //Never set flags without disabling interrupts
	W [P0] = R4.L; //Write back bit flags
	STI R5;
//Switch to the LP filter
	P1.L = hl;
	P1.H = hl;
	I2 = P1;			// Initialize I2 to the start of the filter coeff. array h[]
	B2 = P1;			// Set base address of HP FIR coeffs
	R2 = [I2++] ||		//Get hl[0] and hl[1] into R2
	R0 = [I1++];		// Get x[n], x[n+1] back into R0
	JUMP OUTLOOP;

DONE_BOTH:						
	CLI R5;
	R4.L= W[P0]; 
	CC = BITTST(R4, BYE); 
	IF !CC JUMP OUTLOOP (BP);
						
	L0=0;              // Clear the circular buffer initialization
	L1=0;
	L2=0;
	L3=0; 
	
_main.end: nop;				

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

_main.END:
	

