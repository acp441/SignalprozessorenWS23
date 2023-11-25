//------------------------------------------- 
// designed with -- int_by_2_FIR.m -- 
// 25-Nov-2023
// Fs = 50000.00
// fstop = 12500.00
// fpass = 13030.00
// delta_pass =   0.01
// delta_stop_dB = -40.00
// N_FIR = 186
// N_FIR = 185
//------------------------------------------- 
#define N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2 186
#define N_DELAYS_FIR_DESIGN_INT_BRANCH_2_1_LAB2 185
short H_filt_FIR_design_int_2_0_lab2[N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2]; 
short H_filt_FIR_design_int_2_1_lab2[N_DELAYS_FIR_DESIGN_INT_BRANCH_2_1_LAB2]; 
short b_FIR_int_2_0_HP[186]={
    111,    -67,    -35,      2,      5,    -18,
    -11,     17,      9,    -20,     -9,     22,
      8,    -25,     -7,     27,      5,    -30,
     -4,     32,      2,    -35,      0,     38,
     -3,    -40,      6,     43,     -9,    -45,
     13,     48,    -17,    -50,     22,     52,
    -27,    -54,     33,     55,    -39,    -56,
     46,     57,    -53,    -58,     60,     58,
    -69,    -57,     78,     56,    -87,    -54,
     98,     52,   -109,    -48,    121,     43,
   -133,    -38,    147,     31,   -162,    -22,
    179,     12,   -197,      1,    217,    -16,
   -239,     35,    266,    -58,   -297,     87,
    334,   -124,   -381,    175,    444,   -245,
   -533,    352,    672,   -535,   -930,    923,
   1591,  -2332,  -7497,  -7497,  -2332,   1591,
    923,   -930,   -535,    672,    352,   -533,
   -245,    444,    175,   -381,   -124,    334,
     87,   -297,    -58,    266,     35,   -239,
    -16,    217,      1,   -197,     12,    179,
    -22,   -162,     31,    147,    -38,   -133,
     43,    121,    -48,   -109,     52,     98,
    -54,    -87,     56,     78,    -57,    -69,
     58,     60,    -58,    -53,     57,     46,
    -56,    -39,     55,     33,    -54,    -27,
     52,     22,    -50,    -17,     48,     13,
    -45,     -9,     43,      6,    -40,     -3,
     38,      0,    -35,      2,     32,     -4,
    -30,      5,     27,     -7,    -25,      8,
     22,     -9,    -20,      9,     17,    -11,
    -18,      5,      2,    -35,    -67,    111,
};

short b_FIR_int_2_1_HP[185]={
    -84,    -53,    -14,      9,     -7,    -20,
      5,     19,     -7,    -21,      9,     22,
    -12,    -23,     14,     24,    -17,    -24,
     20,     25,    -23,    -25,     27,     25,
    -31,    -25,     35,     25,    -39,    -24,
     43,     23,    -48,    -21,     53,     19,
    -58,    -16,     63,     13,    -68,     -9,
     74,      5,    -79,      0,     85,     -6,
    -91,     13,     97,    -21,   -102,     29,
    108,    -39,   -114,     50,    119,    -62,
   -125,     76,    130,    -92,   -135,    109,
    140,   -129,   -144,    152,    149,   -179,
   -153,    211,    157,   -249,   -160,    296,
    163,   -356,   -166,    436,    168,   -548,
   -170,    720,    172,  -1025,   -173,   1728,
    173,  -5212,  24402,  -5212,    173,   1728,
   -173,  -1025,    172,    720,   -170,   -548,
    168,    436,   -166,   -356,    163,    296,
   -160,   -249,    157,    211,   -153,   -179,
    149,    152,   -144,   -129,    140,    109,
   -135,    -92,    130,     76,   -125,    -62,
    119,     50,   -114,    -39,    108,     29,
   -102,    -21,     97,     13,    -91,     -6,
     85,      0,    -79,      5,     74,     -9,
    -68,     13,     63,    -16,    -58,     19,
     53,    -21,    -48,     23,     43,    -24,
    -39,     25,     35,    -25,    -31,     25,
     27,    -25,    -23,     25,     20,    -24,
    -17,     24,     14,    -23,    -12,     22,
      9,    -21,     -7,     19,      5,    -20,
     -7,      9,    -14,    -53,    -84,};

