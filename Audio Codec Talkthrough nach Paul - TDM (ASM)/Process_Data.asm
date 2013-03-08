#include "Talkthrough.h"

/*****************************************************************************
 Function:	Process_Data												
 
 Description: This function is called from inside the SPORT0 ISR every 
  	      time a complete audio frame has been received. The new 		
	      input samples can be found in the variables Channel0LeftIn,	
	      Channel0RightIn, Channel1LeftIn and Channel1RightIn 		
	      respectively. The processed data should be stored in 	
	      Channel0LeftOut, Channel0RightOut, Channel1LeftOut,		
	      Channel1RightOut, Channel2LeftOut and Channel2RightOut	
	      respectively.												
******************************************************************************/

.section L1_code;
Process_Data:

	P0.H = Channel0LeftIn;
	P0.L = Channel0LeftIn;
	R0 = [ P0 ];
	P1.H = Channel0LeftOut;
	P1.L = Channel0LeftOut;
	[ P1 ] = R0;
	
	P0.H = Channel0RightIn;
	P0.L = Channel0RightIn;
	R0 = [ P0 ];
	P1.H = Channel0RightOut;
	P1.L = Channel0RightOut;
	[ P1 ] = R0;
	
	P0.H = Channel1LeftIn;
	P0.L = Channel1LeftIn;
	R0 = [ P0 ];
	P1.H = Channel1LeftOut;
	P1.L = Channel1LeftOut;
	[ P1 ] = R0;
	
	P0.H = Channel1RightIn;
	P0.L = Channel1RightIn;
	R0 = [ P0 ];
	P1.H = Channel1RightOut;
	P1.L = Channel1RightOut;
	[ P1 ] = R0;
	
Process_Data.END:	
	RTS;
	
