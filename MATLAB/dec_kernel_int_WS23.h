//------------------------------------------- 
// designed with -- dec_kernel_int.m -- 
// Fs = 50000.00
// MMmin =   4.00
// fstop = 3350.00
// fpass = 3100.00
// delta_pass =   0.01
// delta_stop_dB =  40.00
// N_FIR = 391, instead two stages with N_FIR_Dec_Int = 18, N_FIR_KERNEL = 116
//------------------------------------------- 
#define NUM_POLY_BRANCHES 4
#define N_delays_poly_40_Dec_Int 5
#define N_delays_poly_41_Dec_Int 5
#define N_delays_poly_42_Dec_Int 5
#define N_delays_poly_43_Dec_Int 4
#define N_delays_Kernel 117

// DEC/INT POLYPHASE 0
short H_filt_poly_40_Dec[N_delays_poly_40_Dec_Int]; 
short H_filt_poly_40_Int[N_delays_poly_40_Dec_Int]; 
short b_poly_40_Dec_Int[5]={
    316,  -1105,   7426,   1970,   -349,};


// DEC/INT POLYPHASE 1
short H_filt_poly_41_Dec[N_delays_poly_41_Dec_Int]; 
short H_filt_poly_41_Int[N_delays_poly_41_Dec_Int]; 
short b_poly_41_Dec_Int[5]={
     99,   -205,   8431,   -205,     99,};


// DEC/INT POLYPHASE 2
short H_filt_poly_42_Dec[N_delays_poly_42_Dec_Int]; 
short H_filt_poly_42_Int[N_delays_poly_42_Dec_Int]; 
short b_poly_42_Dec_Int[5]={
   -349,   1970,   7426,  -1105,    316,};


// DEC/INT POLYPHASE 3
short H_filt_poly_43_Dec[N_delays_poly_43_Dec_Int]; 
short H_filt_poly_43_Int[N_delays_poly_43_Dec_Int]; 
short b_poly_43_Dec_Int[4]={
   -941,   4891,   4891,   -941,};


// KERNEL FILTER
short H_filt_Kernel[N_delays_Kernel]; 
short b_Kernel[117]={
     63,   -104,     -1,     39,    -15,    -55,
     12,     56,    -23,    -64,     32,     69,
    -46,    -74,     62,     77,    -80,    -78,
    101,     77,   -124,    -72,    149,     63,
   -176,    -50,    205,     32,   -235,     -8,
    267,    -22,   -298,     61,    330,   -108,
   -362,    166,    394,   -236,   -424,    323,
    452,   -430,   -478,    565,    502,   -742,
   -523,    986,    541,  -1354,   -555,   1987,
    565,  -3417,   -571,  10410,  16957,  10410,
   -571,  -3417,    565,   1987,   -555,  -1354,
    541,    986,   -523,   -742,    502,    565,
   -478,   -430,    452,    323,   -424,   -236,
    394,    166,   -362,   -108,    330,     61,
   -298,    -22,    267,     -8,   -235,     32,
    205,    -50,   -176,     63,    149,    -72,
   -124,     77,    101,    -78,    -80,     77,
     62,    -74,    -46,     69,     32,    -64,
    -23,     56,     12,    -55,    -15,     39,
     -1,   -104,     63,};

short * p2p_H_polyphase_filt_DEC[NUM_POLY_BRANCHES];
short * p2p_H_polyphase_filt_INT[NUM_POLY_BRANCHES];
short int * delays[NUM_POLY_BRANCHES];
short * p2p_b_boly_Dec_Int[NUM_POLY_BRANCHES];

/* *** Diese Definitionen müssen während der Laufzeit ausgeführt werden und daher aus dem .h-File in die main.c kopiert werden! ***
p2p_H_polyphase_filt_DEC[0] = H_filt_poly_43_Dec;
p2p_H_polyphase_filt_DEC[1] = H_filt_poly_42_Dec;
p2p_H_polyphase_filt_DEC[2] = H_filt_poly_41_Dec;
p2p_H_polyphase_filt_DEC[3] = H_filt_poly_40_Dec;

p2p_H_polyphase_filt_INT[0] = H_filt_poly_41_Int;
p2p_H_polyphase_filt_INT[1] = H_filt_poly_42_Int;
p2p_H_polyphase_filt_INT[2] = H_filt_poly_43_Int;
p2p_H_polyphase_filt_INT[3] = H_filt_poly_40_Int;

delays[0] = N_delays_poly_43_Dec_Int;
delays[1] = N_delays_poly_42_Dec_Int;
delays[2] = N_delays_poly_41_Dec_Int;
delays[3] = N_delays_poly_40_Dec_Int;

p2p_b_boly_Dec_Int[0] = N_delays_poly_43_Dec_Int;
p2p_b_boly_Dec_Int[1] = N_delays_poly_42_Dec_Int;
p2p_b_boly_Dec_Int[2] = N_delays_poly_41_Dec_Int;
p2p_b_boly_Dec_Int[3] = N_delays_poly_40_Dec_Int;
*** */