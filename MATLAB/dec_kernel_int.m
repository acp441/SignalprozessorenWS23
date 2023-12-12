% dec_kernel_int.m
%
% Victor Kröger und Lennard Jönsson - WS 23
%
% Zuerst wird ein FIR-Tiefpassfilter erstellt, das eine 
% Stopband-Frequenz von 3350 Hz und eine Passband-Frequenz 
% von 3100 Hz hat.
%
% Dieses Filter wird durch ein Multiratenfilter ersetzt. Dazu 
% folgt eine Dezimation um den Faktor M_min = 4. Das Dezimations-
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

figure(1);
plot(freq*Fs,db(hz)),grid
xlabel('Frequency in Hz');
ylabel('|H| in dB');
hold on





% --- Dezimations- / Interpolationsfilter ---


% add here the design of the decimation/interpolation filter and of the KERNEL filter
clear fo mo w;
% define frequencies for the interpolation and decimation filter

% Bestimmung von Mmin
polynom = [fstop^2-fpass^2, -(fpass + fstop)^2, 2*Fs*(fpass + fstop), -(Fs^2)]; 
Mmin = roots(polynom);
fprintf("Mmin hat den Wert %f.\n", Mmin(3));
% für Mmin wurde 5.33 -> 5 bestimmt
% Verwende 4 als am nächsten liegende Potenz von 2
Mmin = 4;


fstop_dec_int = Fs / Mmin - fstop; 
fpass_dec_int = fpass; 
% delta_pass / 3 weil sich die Ripples der 3 Filter überlagern
[N_FIR_Dec_Int,fo,mo,w] = firpmord( [fpass_dec_int fstop_dec_int], [1 0], [delta_pass/3 delta_stop], Fs );

b_FIR_Dec_Int = firpm(N_FIR_Dec_Int, fo, mo, w); % FIR-Filter-Design
hz = freqz(b_FIR_Dec_Int,1, 2*pi*freq); % Amplitudengang berechnen
figure(1); 
plot(freq*Fs,db(hz)),grid, ylabel('|H| in dB');

fprintf("fpass vom Dezimationsfilter ist %f.\n", fpass_dec_int);
fprintf("fstop vom Dezimationsfilter ist %f.\n", fstop_dec_int);
fprintf("Die minimale Stop-Band Dämpfung ist %f dB.\n", delta_stop_dB);
fprintf("Die Dez-/Int-Filter haben die Ordnung %d. \n\n", N_FIR_Dec_Int);

% Runden auf 16 bit (Hardware nahe Simulation)
b_FIR_Dec_Int = round(b_FIR_Dec_Int*32768)/32768;

% Polyphasenzerlegung des Dezimations- / Interpolationsfilters
% abhängig von M müssen hier mehr oder weniger Zweige gebildet werden
b_poly_40_Dec_Int = b_FIR_Dec_Int(1 : Mmin: end);
b_poly_41_Dec_Int = b_FIR_Dec_Int(2 : Mmin: end);
b_poly_42_Dec_Int = b_FIR_Dec_Int(3 : Mmin: end);
b_poly_43_Dec_Int = b_FIR_Dec_Int(4 : Mmin: end);


% --- Design des Kernel-Filters
clear fo mo w;
Fs_Kernel = Fs / Mmin;
fpass_Kernel = fpass;
fstop_Kernel = fstop;
fprintf("fpass_Kernel ist %f.\n", fpass_Kernel);
fprintf("fstop_Kernel ist %f.\n", fstop_Kernel);
fprintf("Die minimale Stop-Band Dämpfung ist %f dB.\n", delta_stop_dB);

%delta_pass/3, weil sich die Ripples der drei Filter überlagern
[N_Kernel,fo,mo,w] = firpmord( [fpass_Kernel fstop_Kernel], [1 0], ...
    [delta_pass/3 delta_stop], Fs_Kernel);
N_Kernel = N_Kernel + 2;
b_Kernel = firpm(N_Kernel, fo, mo, w); % FIR-Filter-Design

% Runden auf 16 bit (Hardware nahe Simulation)
b_Kernel = round(b_Kernel*32768)/32768;

fprintf("Das Kernel-Filter hat die Ordnung N_Kernel = %d.\n \n", N_Kernel);

hz = freqz(b_Kernel,1, Mmin*2*pi*freq);
plot(freq*Fs,db(hz));
legend("FIR Filter", "Dez/Int-Filter", "Kernel-Filter");

% this is provided in order to let the script end correctly, remove later
N_FIR_kernel_MM = N_Kernel;



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
fprintf(file_ID, '// MMmin = %6.2f\n', Mmin );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d, instead two stages with N_FIR_Dec_Int = %d, N_FIR_KERNEL = %d\n', ...
    N_FIR, N_FIR_Dec_Int, N_FIR_kernel_MM);
fprintf(file_ID, '//------------------------------------------- \n');

fprintf(file_ID, '#define NUM_POLY_BRANCHES %d\n', Mmin);
fprintf(file_ID, '#define N_delays_poly_40_Dec_Int %d\n', length(b_poly_40_Dec_Int));
fprintf(file_ID, '#define N_delays_poly_41_Dec_Int %d\n', length(b_poly_41_Dec_Int));
fprintf(file_ID, '#define N_delays_poly_42_Dec_Int %d\n', length(b_poly_42_Dec_Int));
fprintf(file_ID, '#define N_delays_poly_43_Dec_Int %d\n', length(b_poly_43_Dec_Int));
fprintf(file_ID, '#define N_delays_Kernel %d\n', length(b_Kernel));

% DEC-INT-Polyphasen
fprintf(file_ID, '\n// DEC/INT POLYPHASE 0\n');
fprintf(file_ID, 'short H_filt_poly_40_Dec[N_delays_poly_40_Dec_Int]; \n');
fprintf(file_ID, 'short H_filt_poly_40_Int[N_delays_poly_40_Dec_Int]; \n');
write_coeff(file_ID, 'b_poly_40_Dec_Int', b_poly_40_Dec_Int, length(b_poly_40_Dec_Int));
fprintf(file_ID, '\n// DEC/INT POLYPHASE 1\n');
fprintf(file_ID, 'short H_filt_poly_41_Dec[N_delays_poly_41_Dec_Int]; \n');
fprintf(file_ID, 'short H_filt_poly_41_Int[N_delays_poly_41_Dec_Int]; \n');
write_coeff(file_ID, 'b_poly_41_Dec_Int', b_poly_41_Dec_Int, length(b_poly_41_Dec_Int));
fprintf(file_ID, '\n// DEC/INT POLYPHASE 2\n');
fprintf(file_ID, 'short H_filt_poly_42_Dec[N_delays_poly_42_Dec_Int]; \n');
fprintf(file_ID, 'short H_filt_poly_42_Int[N_delays_poly_42_Dec_Int]; \n');
write_coeff(file_ID, 'b_poly_42_Dec_Int', b_poly_42_Dec_Int, length(b_poly_42_Dec_Int));
fprintf(file_ID, '\n// DEC/INT POLYPHASE 3\n');
fprintf(file_ID, 'short H_filt_poly_43_Dec[N_delays_poly_43_Dec_Int]; \n');
fprintf(file_ID, 'short H_filt_poly_43_Int[N_delays_poly_43_Dec_Int]; \n');
write_coeff(file_ID, 'b_poly_43_Dec_Int', b_poly_43_Dec_Int, length(b_poly_43_Dec_Int));


% Kernel-Filter
fprintf(file_ID, '\n// KERNEL FILTER\n');
fprintf(file_ID, 'short H_filt_Kernel[N_delays_Kernel]; \n');
write_coeff(file_ID, 'b_Kernel', b_Kernel, length(b_Kernel));

fprintf(file_ID, 'p2p_H_polyphase_filt_DEC[NUM_POLY_BRANCHES];\n');

for idx = 0:Mmin-1
    fprintf(file_ID, 'p2p_H_polyphase_filt_DEC[%d] = H_filt_poly_4%d_Dec;\n', idx, Mmin-1-idx);
end
fprintf(file_ID, '\n');
fprintf(file_ID, 'p2p_H_polyphase_filt_INT[NUM_POLY_BRANCHES];\n');

for idx = 0:Mmin-1
    idx2 = rem(idx + 1, Mmin);
    fprintf(file_ID, 'p2p_H_polyphase_filt_INT[%d] = H_filt_poly_4%d_Int;\n', idx, idx2);
end
fprintf(file_ID, '\n');
fprintf(file_ID, 'delays[NUM_POLY_BRANCHES];\n');

for idx = 0:Mmin-1
    fprintf(file_ID, 'delays[%d] = N_delays_poly_4%d_Dec_Int;\n', idx, Mmin - idx - 1);
end
fprintf(file_ID, '\n');
fprintf(file_ID, 'p2p_b_boly_Dec_Int[NUM_POLY_BRANCHES];\n');

for idx = 0:Mmin-1
    fprintf(file_ID, 'p2p_b_boly_Dec_Int[%d] = N_delays_poly_4%d_Dec_Int;\n', idx, Mmin - idx - 1);
end

fclose(file_ID);

