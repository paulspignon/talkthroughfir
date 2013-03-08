#include "Talkthrough.h"

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
						
.section L1_code;
_SPORT0_RX_ISR:

	// Confirm interrupt
	// Clear DMA_DONE bit in DMA1 status register
	P0.L = LO(DMA1_IRQ_STATUS);
	P0.H = HI(DMA1_IRQ_STATUS);
	R1.L = W[ P0 ];
	BITSET(R1,0);
	W[ P0 ] = R1.L; 
	
	// copy input data from dma input buffer into variables
	P1.L = rx_buf;
	P1.H = rx_buf;
	P0.H = Channel0LeftIn;
	P0.L = Channel0LeftIn;
	R0 = [ P1 + INTERNAL_ADC_L0 ];
	[ P0 ] = R0;
	
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
	
	// call function that contains user code
	call Process_Data;
	
	// copy processed data from variables into dma output buffer
	P1.L = tx_buf;
	P1.H = tx_buf;
	P0.H = Channel0LeftOut;
	P0.L = Channel0LeftOut;
	R0 = [ P0 ];
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

_SPORT0_RX_ISR.end:	
	RTI;
	
	