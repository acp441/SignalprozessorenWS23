% FIR_Entwurf_firpm_demo.m
%
% US 24-Okt-23
%
% firpm(...) FIR Filterentwurf Demo
clear
close all
clc

Fs = 50000;
f_pass = 0.10*Fs/2;
f_stop = 0.11*Fs/2;
fprintf('Fs = %6.2f Hz, fpass = %6.2f Hz, fstop = %6.2f Hz\n', Fs, f_pass, f_stop);

% N_FIR ist die Ordnung                       TP    Ripple DB   R. SB   Fs
[N_FIR,fo,mo,w] = firpmord( [f_pass f_stop], [1 0], [0.01       0.001], Fs );

%%
if rem(N_FIR,2) == 1 
    N_FIR=N_FIR+1; 
end;
b_FIR_TP        = firpm(N_FIR,fo,mo,w);

freq = (1:1999)/4000;
hz_FIR_TP = freqz(b_FIR_TP, 1, 2*pi*freq);

subplot(211);
stem(-N_FIR/2:N_FIR/2, b_FIR_TP),grid
title('Impulsantwort');
subplot(212);
plot(freq*Fs, db(hz_FIR_TP)),grid
title('Amplitudengang FIR Filter');

fprintf('N_FIR = %d \n', N_FIR);

