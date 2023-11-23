% dec_kernel_int.m
%
% Victor Kröger und Lennard Jönsson - WS 23
%
% Zuerst wird ein FIR-Tiefpassfilter erstellt, das eine 
% Stopband-Frequenz von 3350 Hz und eine Passband-Frequenz 
% von 3350 Hz hat.
%
% Dieses Filter wird durch ein Multiratenfilter ersetzt. Dazu 
% folgt eine Dezimation um den Faktor M_min = ??. Das Dezimations-
% filter und das Interpolationsfilter haben identische Filter-
% koeffizienten. Sie werden durch eine Polyphasenzerlegung rea-
% lisiert. 
%
addpath('../Matlab Support/');

clear
close('all');
format compact
Fs = inputs('Fs', 50e3);

% create a frequency vector
freq=(1:999)/2000;

% stop-band attentuation is in DB, convert to linear for REMEZ
delta_stop_dB = inputs('stop-band attenuation in dB', 40);
delta_stop = dbinv(-delta_stop_dB);
% for pass-band
delta_pass = 0.01;

% edge frequencies
fpass = inputs('fpass', 3100);
fstop = inputs('fstop', 3350);

% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs );
% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
N_FIR = N_FIR + 2;
b_FIR = firpm(N_FIR,fo,mo,w);

% compute the amplitude response using frequency vector
hz = freqz(b_FIR,1, 2*pi*freq);

fprintf('\n N_FIR=%d, "normal" implementation\n\n', N_FIR);

plot(freq*Fs,db(hz)),grid
title('Amplitude response of desired FIR filter in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');
pause % --------------................-------------

% add here the design of the decimation/interpolation filter and of the KERNEL filter
clear fo mo w;
% define frequencies for the interpolation and decimation filter

% Bestimmung von Mmin
polynom = [fstop^2-fpass^2, (fpass + fstop)^2, 2*Fs*(fpass + fstop), -(Fs^2)]; 
Mmin = roots(polynom);
% für Mmin wurde 3.1553 -> 3 bestimmt

%%
fstop_dec_int = Fs / MMin - fstop; 
fpass_dec_int = fpass; 
[N_FIR_Dec_Int,fo,mo,w] = firpmord( [fpass_dec_int fstop_dec_int], [1 0], [delta_pass delta_stop], Fs );

b_FIR_Dec_Int = firpm(N_FIR_Dec_Int, fo, mo, w); % FIR-Filter-Design
hz = freqz(b_FIR_Dec_Int,1, 2*pi*freq); % Amplitudengang berechnen
figure("Name", "|H| des Dezimations/Interpolationsfilters"); 
plot(freq*Fs,db(hz)),grid, title('Amplitudengang des Dez/Int-Filters in dB'),
xlabel('Frequenz in Hz, Nyquist-Bereich'), ylabel('|H| in dB');

% Polyphasenzerlegung des Dezimations- / Interpolationsfilters
b_poly_20_Dec_Int = b_FIR_Dec_Int(1 : MMin: end);
b_poly_21_Dec_Int = b_FIR_Dec_Int(1 : MMin: end);
% ... ggf. weitere Zweige hinzufügen, abhängig von M





% this is provided in order to let the script end correctly, remove later
MMmin = 0;
N_FIR_kernel_MM = 0;

%---------------------------------------------------------------------------
% write to file !
% create header file and info
filename = 'FIR_normal_WS23.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int.m -- \n', Fs );
fprintf(file_ID, '// Fs = %6.2f\n', Fs );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR);
fprintf(file_ID, '//------------------------------------------- \n');

fprintf(file_ID, '#define N_delays_FIR_dki_normal %d\n', length(b_FIR));
fprintf(file_ID, '\n// DEC FILTER\n');
fprintf(file_ID, 'short H_filt_FIR_normal[N_delays_FIR_dki_normal]; \n');

write_coeff(file_ID, 'b_FIR_normal', b_FIR, length(b_FIR));
fclose(file_ID);

%---------------------------------------------------------------------------
% DEC, KERNEL, INT filter : write to file !
% create header file and info
filename = 'dec_kernel_int_WS23.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int.m -- \n', Fs );
fprintf(file_ID, '// Fs = %6.2f\n', Fs );
fprintf(file_ID, '// MMmin = %6.2f\n', MMmin );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d, instead two stages with N_FIR_Dec_Int = %d, N_FIR_KERNEL = %d\n', ...
    N_FIR, N_FIR_Dec_Int, N_FIR_kernel_MM);
fprintf(file_ID, '//------------------------------------------- \n');

fclose(file_ID);
