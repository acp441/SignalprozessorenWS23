//------------------------------------------- 
// designed with -- dec_by_2_FIR.m -- 
// 21-Nov-2023
// Fs = 50000.00
// fstop = 12500.00
// fpass = 13030.00
// delta_pass =   0.01
// delta_stop_dB = -40.00
// N_FIR = 186
//------------------------------------------- 
#define N_DELAYS_FIR_DESIGN_DEC_LAB2 186
short H_filt_FIR_design_dec_lab2[N_DELAYS_FIR_DESIGN_DEC_LAB2]; 
short b_FIR_dec_HP[187]={
    160,    -15,    -44,     -7,     23,    -18,
    -47,      1,     30,    -24,    -50,     10,
     36,    -31,    -53,     22,     41,    -40,
    -55,     34,     45,    -52,    -56,     49,
     47,    -66,    -55,     65,     46,    -82,
    -52,     83,     42,    -99,    -45,    103,
     35,   -119,    -35,    124,     24,   -139,
    -20,    146,      7,   -161,     -1,    169,
    -14,   -183,     25,    192,    -43,   -206,
     57,    215,    -79,   -229,     99,    237,
   -125,   -250,    151,    259,   -184,   -271,
    218,    279,   -260,   -290,    304,    297,
   -360,   -307,    422,    313,   -499,   -321,
    592,    326,   -713,   -332,    871,    336,
  -1096,   -341,   1440,    343,  -2051,   -346,
   3455,    346, -10424,  16036, -10424,    346,
   3455,   -346,  -2051,    343,   1440,   -341,
  -1096,    336,    871,   -332,   -713,    326,
    592,   -321,   -499,    313,    422,   -307,
   -360,    297,    304,   -290,   -260,    279,
    218,   -271,   -184,    259,    151,   -250,
   -125,    237,     99,   -229,    -79,    215,
     57,   -206,    -43,    192,     25,   -183,
    -14,    169,     -1,   -161,      7,    146,
    -20,   -139,     24,    124,    -35,   -119,
     35,    103,    -45,    -99,     42,     83,
    -52,    -82,     46,     65,    -55,    -66,
     47,     49,    -56,    -52,     45,     34,
    -55,    -40,     41,     22,    -53,    -31,
     36,     10,    -50,    -24,     30,      1,
    -47,    -18,     23,     -7,    -44,    -15,
    160,};
