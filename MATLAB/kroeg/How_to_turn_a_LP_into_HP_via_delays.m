% How_to_turn_a_LP_into_HP_via_delays.m
% 
% US 21-Nov-2012
clear
close all
% design low-pass filter
[N_FIR,fo,mo,w] = remezord( [1500 2000], [1 0], [0.01 0.01], 8000 );
% make sure that the number of coeffs is ODD, degree is EVEN
if rem(N_FIR,2)==1
    N_FIR = N_FIR+1;
end;
% show amplitude response
b_FIR = remez(N_FIR,fo,mo,w);
freq=(1:999)/2000;
hz_FIR = freqz(b_FIR,1,2*pi*freq);
plot(freq, db(hz_FIR)),grid
pause
% determine the number of delays, group delay of filter is N_FIR/2 !!
num_delays = [zeros(1,N_FIR/2),1];;
hz_delays = freqz(num_delays,1,2*pi*freq);
hz_ges = hz_FIR - hz_delays;
plot(freq, db(hz_FIR),freq, db(hz_ges)),grid
pause
