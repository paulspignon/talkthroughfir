#define TAPLENGTH 4

#define DELAY_SIZE  (TAPLENGTH+2) //#def BASE_TAPLENGTH in fir_coeff.h, =8, Now making d[] two samples bigger. To get I1 back behind the newy inserted 2 samples kick it back two 
//extra samples after each M-sample loop 
#define INBUF_SIZE 8 //buffer incoming samples in a circular buffer of this size, don't need much, if not keeping up we're screwed anyway
#define OUTBUF_SIZE 16
#define BIGBUF_SIZE (1<<24)

//flag bits
#define IN_READY 0	//low bit in sam (e.g.) signals when new samples are in
#define ONE_DONE 1	//ISR checks this to see if R7 contains one 16-bit sample already.
#define DONE_LP 2	//set on doing LP (scaling, approximation) filter, thereupon do HP (wavelet, detail) filter
#define BYE 15 //If set main will exit 

