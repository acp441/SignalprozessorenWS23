//-------------------------------------------
// designed with -- perf_reconstruction.m --
// File : perf_reconstruction.h
// Fs_in = 33333.0 Hz
// fpass = 0.45 * Fs_in
// fstop = 0.55 * Fs_in
// delta_pass (most be equal to dBstop !!!) = 1.00e-004
// delta_stop_dB = -80.00
// N_FIR = 126
//-------------------------------------------

#define N 32

short H_filt_poly_h0_20[N];
short H_filt_poly_h0_21[N];
short H_filt_poly_h1_20[N];
short H_filt_poly_h1_21[N];
short H_filt_poly_g0_20[N];
short H_filt_poly_g0_21[N];
short H_filt_poly_g1_20[N];
short H_filt_poly_g1_21[N];

short h0_20[]={
3748, 14930, -2002, -838, 1538, -1633,
1535, -1379, 1211, -1050, 901, -765,
646, -537, 445, -357, 293, -226,
177, -134, 98, -70, 48, -31,
18, -9, 3, 1, -3, 3,
-3, 6,};
short h0_21[]={
10926, 9091, -6297, 4210, -2938, 2147,
-1634, 1287, -1042, 862, -726, 617,
-531, 456, -396, 335, -293, 246,
-207, 174, -142, 115, -92, 71,
-54, 40, -29, 20, -13, 8,
-6, -2,};
short h1_20[]={
-2, -6, 8, -13, 20, -29,
40, -54, 71, -92, 115, -142,
173, -209, 244, -294, 334, -400,
452, -533, 617, -726, 862, -1042,
1287, -1634, 2147, -2938, 4210, -6297,
9091, 10926,};
short h1_21[]={
-6, 3, -3, 3, -1, -3,
9, -18, 31, -48, 70, -98,
133, -178, 225, -294, 355, -449,
534, -647, 765, -901, 1050, -1211,
1379, -1535, 1633, -1538, 838, 2002,
-14930, -3748,};


short g0_20[]={
-2, -6, 8, -13, 20, -29,
40, -54, 71, -92, 115, -142,
174, -207, 246, -293, 335, -396,
456, -531, 617, -726, 862, -1042,
1287, -1634, 2147, -2938, 4210, -6297,
9091, 10926,};
short g0_21[]={
6, -3, 3, -3, 1, 3,
-9, 18, -31, 48, -70, 98,
-134, 177, -226, 293, -357, 445,
-537, 646, -765, 901, -1050, 1211,
-1379, 1535, -1633, 1538, -838, -2002,
14930, 3748,};
short g1_20[]={
-3748, -14930, 2002, 838, -1538, 1633,
-1535, 1379, -1211, 1050, -901, 765,
-647, 534, -449, 355, -294, 225,
-178, 133, -98, 70, -48, 31,
-18, 9, -3, -1, 3, -3,
3, -6,};
short g1_21[]={
10926, 9091, -6297, 4210, -2938, 2147,
-1634, 1287, -1042, 862, -726, 617,
-533, 452, -400, 334, -294, 244,
-209, 173, -142, 115, -92, 71,
-54, 40, -29, 20, -13, 8,
-6, -2,};