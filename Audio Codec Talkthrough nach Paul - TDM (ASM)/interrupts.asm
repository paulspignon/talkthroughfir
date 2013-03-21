#include "Talkthrough.h"
#include "consts.h"

/*****************************************************************************
 Function:	Sport0_RX_ISR												
 
 Description: This ISR is executed after a complete frame of input data 	
	      has been received. The new samples are stored in 	
	      Channel0LeftIn, Channel0RightIn, Channel1LeftIn and 		
	      Channel1RightIn respectively.  Then the function 		
	      Process_Data is called in which user code can be executed.	
	      After that the processed values are copied from the 		
	      variables Channel0LeftOut, Channel0RightOut, 			
	      Channel1LeftOut and Channel1RightOut into the dma	 	
	      transmit buffer.											
******************************************************************************/
.EXTERN flags;

 
						
.section L1_code;
_SPORT0_RX_ISR:
/***
Modified by Paul.
First of all, it was very impolite, did not preserve any of the registers it
uses, so we do, i.e. push them on the stack, pop them on exit.
Uses P0, P1 R0, R1

Secondly, incoming samples are copied to R7, to feed the processing loop in main
Have a counter which shows how many samples in R7, when 2 then set IN_READY flag bit 
***/

//Push registers on stack
	[--SP] = P0;
	[--SP] = P1;
	[--SP] = P2;
	
	[--SP] = R0;
	[--SP] = R1;
	[--SP] = R2;
	[--SP] = R3;

	// Confirm interrupt
	// Clear DMA_DONE bit in DMA1 status register
	P0.L = LO(DMA1_IRQ_STATUS);
	P0.H = HI(DMA1_IRQ_STATUS);
	R1.L = W[ P0 ];
	BITSET(R1,0);
	W[ P0 ] = R1.L; 
	
	// copy input data from dma input buffer into R7 (processing loop looks there)
	P1.L = rx_buf;
	P1.H = rx_buf;
//	P0.H = Channel0LeftIn;
//	P0.L = Channel0LeftIn;

	R1 = [ P1 + INTERNAL_ADC_L0 ]; //Assuming this is 32-bit sample of 24-bit precision, left-justified,
						//R1.H contains top 16 bits of 24 bit sample
	P2.H = tx_buf;
	P2.L = tx_buf;
	
	P0.L = flags;
	P0.H = flags;
	R0.L = W [P0]; //Get flag bits into R0.L, clear R2

	R2 = 0; 
	CC = BITTST(R0, ONE_DONE); //Have we one sample in R7?
	IF CC JUMP TWO; 				//If so, then jump to where we load the second one
		R7 = PACK(R2.H, R1.L);			//else load the first one into R7.L
		BITSET(R0, ONE_DONE); //set flag indicating R7.L now contains first of two samples
		//Output the first of the two ready samples in R6
		R3 = PACK(R6.L, R2.L); //Get first 16-bit out sample from R6.L into 32-bit with low word 0 in R3
		[ P2 + INTERNAL_DAC_L0 ] = R3;
		JUMP DONE_TWO;
TWO:
	R7 = PACK(R1.H, R2.L); //Write the 2nd sample to R7.H
	R3 = PACK(R6.H, R2.L); //2nd 16-bit sample from R6.H to 32-bit format
	[ P2 + INTERNAL_DAC_L0 ] = R3; //push out sample
	BITCLR(R0, ONE_DONE); //By clearing this flag we allow R7 to be overwritten on next input interrupt, assume it got processed
	BITSET(R0, IN_READY); 
	//By now the processing loop must have two samples ready for output in R6, even if it doesn't we
	//send out what it's got
	
DONE_TWO:
	W [P0] = R0.L; //write back the flags

/***	
	P0 = 0;
	P0.L = R6;	//Cache the 2 16-bit samples in P0
	P0 = R
	P1.L = tx_buf;
	P1.H = tx_buf;
	[ P1 + INTERNAL_DAC_L0 ] = 	
***/
/*** using only channel0 left, så länge **************	
	P0.H = Channel0RightIn;
	P0.L = Channel0RightIn;
	R0 = [ P1 + INTERNAL_ADC_R0 ];
	[ P0 ] = R0;
	
	P0.H = Channel1LeftIn;
	P0.L = Channel1LeftIn;
	R0 = [ P1 + INTERNAL_ADC_L1 ];
	[ P0 ] = R0;
	
	P0.H = Channel1RightIn;
	P0.L = Channel1RightIn;
	R0 = [ P1 + INTERNAL_ADC_R1 ];
	[ P0 ] = R0;
**************************/	
	// call function that contains user code NO, do not attempt to process in an ISR!
//	call Process_Data;
/****	
	// copy processed data from variables into dma output buffer
	P1.L = tx_buf;
	P1.H = tx_buf;
//	P0.H = Channel0LeftOut;
//	P0.L = Channel0LeftOut;
//	R0 = [ P0 ];
	[ P1 + INTERNAL_DAC_L0 ] = R0;
	
	P0.H = Channel0RightOut;
	P0.L = Channel0RightOut;
	R0 = [ P0 ];
	[ P1 + INTERNAL_DAC_R0 ] = R0;

	P0.H = Channel1LeftOut;
	P0.L = Channel1LeftOut;
	R0 = [ P0 ];
	[ P1 + INTERNAL_DAC_L1 ] = R0;
	[ P1 + INTERNAL_DAC_L2 ] = R0;
	
	P0.H = Channel1RightOut;
	P0.L = Channel1RightOut;
	R0 = [ P0 ];
	[ P1 + INTERNAL_DAC_R1 ] = R0;
	[ P1 + INTERNAL_DAC_R2 ] = R0;
***/
//Pop saved registers off stack, in reverse order of course	
	
	R3 = [SP++];	
	R2 = [SP++];
	R1 = [SP++];
	R0 = [SP++];
	P2 = [SP++];
	P1 = [SP++];
	P0 = [SP++];

_SPORT0_RX_ISR.end:	
	RTI;
	
	