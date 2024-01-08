clear all 
close all


Fs = 25e3;
L = 2;
M = 3;

fprintf("Fs,out = %d. \n", Fs * L / M);
Fs2 = Fs * L;

fstop = 16666 / 2;
fpass = floor(0.97 * fstop);
delta_pass = 0.01;
delta_stop = 0.01;

[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs2);

fprintf("The FIR-filter would be of order N=%d.\n", N_FIR);

b = (fstop - fpass) / (Fs * L);
N_formula = 2 / 3 * log10(1/(10 * delta_stop * delta_pass)) * (1/b);
N_formula = round(N_formula);
fprintf("But we are using order %d instead.\n", N_formula);

b_fir = firpm(N_formula, fo, mo, w);

freq = (1:999)/2000;
hz = freqz(b_fir, 1, 2*pi*freq);
plot(freq*Fs2, db(hz)),grid
xlabel('Frequency in Hz');
ylabel('|H| in dB');


% Polyphasenzerlegung in M Zweige

b_3_0 = b_fir(1:M:end);
b_3_1 = b_fir(2:M:end);
b_3_2 = b_fir(3:M:end);


% z-1 = z+2 * z-3
% z-2 = z+4 * z-6

b_6_0 = b_3_0(1:L:end);
b_6_3 = b_3_0(2:L:end);
b_6_1 = b_3_1(1:L:end);
b_6_4 = b_3_1(2:L:end);
b_6_2 = b_3_2(1:L:end);
b_6_5 = b_3_2(2:L:end);

%% Simulation 

% Create signal
t = 1:1/Fs:1.1;
f = 1000;
% signal = randn(round(Fs2/10 +1), 1)';
signal = sin(2 * pi * f * t);
S1 = fft(signal);
F1 = 0:1/length(S1):(1 - 1/length(S1)); % Frequency axis
F1 = F1 * Fs;
plot(F1, abs(S1) / length(signal));

% "Direct"
sig_int = zeros(L * length(signal), 1);
sig_int(1:L:end) = signal; % Interpolation by 2
filtered = filter(b_fir, 1, sig_int); % Filtering
sig_dec = sig_int(1:M:end); % Decimation
S2 = fft(sig_dec);
F2 = 0:1/length(S2):(1 - 1/length(S2)); % Frequency axis
F2 = F2 * Fs * L / M;
figure
plot(F2, abs(S2) / length(sig_dec));


%% write coefficients to file

% create header file and info
filename = 'SRC_2to3.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- SRC_2to3.m -- \n', Fs );
fprintf(file_ID, '// Fs = %6.2f\n', Fs2);
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop = %6.2f\n', delta_stop);
fprintf(file_ID, '//------------------------------------------- \n');

fprintf(file_ID, '#define NUM_POLY_BRANCHES %d\n', L * M);
fprintf(file_ID, '#define N_delays_poly_60_SRC %d\n', length(b_6_0));
fprintf(file_ID, '#define N_delays_poly_63_SRC %d\n', length(b_6_3));
fprintf(file_ID, '#define N_delays_poly_61_SRC %d\n', length(b_6_1));
fprintf(file_ID, '#define N_delays_poly_64_SRC %d\n', length(b_6_4));
fprintf(file_ID, '#define N_delays_poly_62_SRC %d\n', length(b_6_2));
fprintf(file_ID, '#define N_delays_poly_65_SRC %d\n', length(b_6_5));


% Polyphasen
fprintf(file_ID, '\n// SRC POLYPHASE 0\n');
fprintf(file_ID, 'short H_filt_poly_60_SRC[N_delays_poly_60_SRC]; \n');
write_coeff(file_ID, 'b_poly_60_SRC', b_6_0, length(b_6_0));
fprintf(file_ID, '\n// SRC POLYPHASE 1\n');
fprintf(file_ID, 'short H_filt_poly_61_SRC[N_delays_poly_61_SRC]; \n');
write_coeff(file_ID, 'b_poly_61_SRC', b_6_1, length(b_6_1));
fprintf(file_ID, '\n// SRC POLYPHASE 0\n');
fprintf(file_ID, 'short H_filt_poly_62_SRC[N_delays_poly_62_SRC]; \n');
write_coeff(file_ID, 'b_poly_62_SRC', b_6_2, length(b_6_2));
fprintf(file_ID, '\n// SRC POLYPHASE 3\n');
fprintf(file_ID, 'short H_filt_poly_63_SRC[N_delays_poly_63_SRC]; \n');
write_coeff(file_ID, 'b_poly_63_SRC', b_6_3, length(b_6_3));
fprintf(file_ID, '\n// SRC POLYPHASE 4\n');
fprintf(file_ID, 'short H_filt_poly_64_SRC[N_delays_poly_64_SRC]; \n');
write_coeff(file_ID, 'b_poly_64_SRC', b_6_4, length(b_6_4));
fprintf(file_ID, '\n// SRC POLYPHASE 5\n');
fprintf(file_ID, 'short H_filt_poly_65_SRC[N_delays_poly_65_SRC]; \n');
write_coeff(file_ID, 'b_poly_65_SRC', b_6_5, length(b_6_5));

% Pointer
% fprintf(file_ID, 'short * p2p_H_polyphase_SRC[NUM_POLY_BRANCHES];\n');
% fprintf(file_ID, 'short int * delays[NUM_POLY_BRANCHES];\n');
% 
% fprintf(file_ID, '\n');
% fprintf(file_ID, ['/* *** Diese Definitionen müssen während der Laufzeit ' ...
%     'ausgeführt werden und daher aus dem .h-File in die main.c kopiert werden! ***\n']);
% 
% for idx = 0:(L*M)-1
%     fprintf(file_ID, 'p2p_H_polyphase_SRC[%d] = H_filt_poly_6%d_SRC;\n', idx, (L*M)-1-idx);
% end
% fprintf(file_ID, '\n');
% 
% for idx = 0:(L*M)-1
%     fprintf(file_ID, 'delays[%d] = N_delays_poly_6%d_SRC;\n', idx, (L*M) - idx - 1);
% end
% fprintf(file_ID, '\n');
% 
