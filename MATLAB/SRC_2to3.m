% SRC.m
%
% Victor Kröger und Lennard Jönsson - WS 23
%
% Entwurf eines Samplerate-Converters
%
%
%% Settings

clear
close('all');
format compact
%Fs = inputs('Fs_in', 25e3);
Fs = 25e3;

% create a frequency vector
freq=(1:999)/2000;


%% Labor 5

L = 2;
M = 3;
Fs1 = Fs;
Fs2 = (L/M) * Fs1;
Fs3 = Fs1 * L;      % Abtastfrequenz für welche das Filter designed wird


% stop-band attentuation is in DB, convert to linear for REMEZ
% delta_stop_dB = inputs('stop-band attenuation in dB', 40);
% delta_stop = dbinv(-delta_stop_dB);
delta_stop = 0.01;
% for pass-band
delta_pass = 0.01;

% Fs3 entspricht der Hälfte der kleinsten im System vorkommenden Frequenz
if L < M
    fstop = Fs2/2;
elseif L > M
    fstop = Fs1/2;
end

% edge frequencies
% fstop = inputs('fstop', floor(fstop));
% fpass = inputs('fpass', floor(0.97 * fstop));
fpass = 0.97 * fstop;

% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs3 );
% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
N_FIR = N_FIR + 2;
b_FIR = firpm(N_FIR,fo,mo,w);

% compute the amplitude response using frequency vector
hz = freqz(b_FIR,1, 2*pi*freq);

%fprintf('\n N_FIR=%d, "normal" implementation\n\n', N_FIR);

figure(1);
plot(freq*Fs3,db(hz)),grid
legend('FIR\_LP (Fs = 50 kHz)')
xlabel('Frequency in Hz');
ylabel('|H| in dB');
hold on

% Theoretische Berechnung der Filterordnung
b = (fstop - fpass) / Fs3;  % Equation 1
N_FIR_calculated = (2/3) * log10( 1/(10*delta_pass*delta_stop) ) * (1/b); % Equation 2

% Comparison of the filter degree of firpmord() vs the result derived from equation (1) and (2)
fprintf('\n N_FIR=%d, "normal" implementation\n', N_FIR);
fprintf('\n N_FIR_calculated=%d, "optimised" implementation\n\n', N_FIR_calculated);

% Filter designed with calculated filterdegree
b_FIR_calculated = firpm(N_FIR_calculated,fo,mo,w);

% compute the amplitude response using frequency vector
hz_calculated = freqz(b_FIR_calculated,1, 2*pi*freq);

figure(2);
plot(freq*Fs3,db(hz_calculated)),grid
legend('FIR\_LP\_calculated (Fs = 50 kHz)')
xlabel('Frequency in Hz');
ylabel('|H| in dB');
hold on


% 1. Polyphasenzerlegung
b_3_0 = b_FIR_calculated(1:M:end);
b_3_1 = b_FIR_calculated(2:M:end);
b_3_2 = b_FIR_calculated(3:M:end);

% 2. Polyphasenzerlegung
b_6_0 = b_3_0(1:L:end);
b_6_3 = b_3_0(2:L:end);
b_6_1 = b_3_1(1:L:end);
b_6_4 = b_3_1(2:L:end);
b_6_2 = b_3_2(1:L:end);
b_6_5 = b_3_2(2:L:end);

%% Simulation SRC (Direkte Implementierung)
% Create signal
Fs = Fs1;
t = 0:1/Fs:1;
f = 1000;
signal = sin(2 * pi * f * t);
% signal = chirp(t, Fs, 1);
% spectrogram(signal, 128, 64, 128);

% Plot fft of signal
FFT_signal_in = fft(signal);
F1 = 0:1/length(FFT_signal_in):(1 - 1/length(FFT_signal_in)); % Frequency axis
F1 = F1 * Fs;
figure(3)
% plot(F1, abs(FFT_signal_in) / length(signal)),grid;
% xlabel('Frequency in Hz');
% ylabel('|Y\_in|');

% Filter signal with FIR-filter
sig_int = zeros(L * length(signal), 1);
sig_int(1:L:end) = signal;              % Interpolation by 2
filtered = filter(b_FIR_calculated, 1, sig_int);   % Filtering
sig_dec = sig_int(1:M:end);             % Decimation by 3

FFT_signal_out = fft(sig_dec);
F2 = 0:1/length(FFT_signal_out):(1 - 1/length(FFT_signal_out)); % Frequency axis
F2 = F2 * Fs * L / M;
figure(4)
plot(F2, abs(FFT_signal_out) / length(sig_dec)),grid;
xlim([0 18000])
xlabel('Frequency in Hz');
ylabel('|Y\_out|');

%% Simulation SRC (Optimierte Implementierung)

% Initializing
input_sample = 0;
output_sample = 0;
output_signal = zeros(round(length(signal) * L / M), 1);

H_6_0_delays = zeros(length(b_6_0), 1);
H_6_1_delays = zeros(length(b_6_1), 1);
H_6_2_delays = zeros(length(b_6_2), 1);
H_6_3_delays = zeros(length(b_6_3), 1);
H_6_4_delays = zeros(length(b_6_4), 1);
H_6_5_delays = zeros(length(b_6_5), 1);

y_H_6_4 = 0;
y_H_6_2 = 0;
y_H_6_5 = 0;
branch3_buf = 0;
branch2_buf = 0;

k = 1;
for n = 1:length(signal)
    switch mod(n,(L*M))-1
    case 0
        % get input sample
        input_sample = signal(n);        
        % Berechne poly branch H_6_0
        H_6_0_delays = feed_delays(input_sample, H_6_0_delays);
        y_H_6_0 = b_6_0 * H_6_0_delays;   % calculate branch 
    case 1
        % Berechne poly branch H_6_3
        H_6_3_delays = feed_delays(input_sample, H_6_3_delays);
        y_H_6_3 = b_6_3 * H_6_3_delays;   % calculate branch 
    case 2
        % get input sample
        input_sample = signal(n);

        H_6_1_delays = feed_delays(input_sample, H_6_1_delays);
        y_H_6_1 = b_6_1 * H_6_1_delays;   % calculate branch
    case 3     
        % Berechne poly branch H_6_4
        H_6_4_delays = feed_delays(branch2_buf, H_6_4_delays);
        y_H_6_4 = b_6_4 * H_6_4_delays;   % calculate branch
        branch2_buf = input_sample;
        

    case 4
        % get input sample
        input_sample = signal(n); 

        % Berechne poly branch H_6_2
        H_6_2_delays = feed_delays(branch3_buf, H_6_2_delays);
        y_H_6_2 = b_6_2 * H_6_2_delays;   % calculate branch
        % we are storing the branch3_buf after calculation of H_6_5
    case -1
        % Berechne poly branch H_6_5
        H_6_5_delays = feed_delays(branch3_buf, H_6_5_delays);
        y_H_6_5 = b_6_5 * H_6_5_delays;   % calculate branch
        branch3_buf = input_sample;  

        % Calculate DAC sample
        output_sample = y_H_6_0 + y_H_6_4 + y_H_6_2; 
        output_signal(k) = 2 * output_sample;
        k = k + 1;


        % Calculate DAC sample
        output_sample = y_H_6_3 + y_H_6_1 + y_H_6_5; 
        output_signal(k) = 2 * output_sample;
        k = k + 1;
    otherwise
        % do nothing
    end
end

figure(5)
t = 0:1/Fs:1;
plot(t, signal),grid;
xlim([100/Fs 200/Fs]);

figure(6)
t = 0:M/(L*Fs):1;
plot(t, output_signal'),grid;
xlim([100/Fs 200/Fs]);


%% Write coefficients to header-file
%---------------------------------------------------------------------------
% create header file and info
filename = 'SRC_2to3.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- SRC_2to3.m -- \n');
fprintf(file_ID, '// Fs = %6.2f\n', floor(Fs2) );
fprintf(file_ID, '// L = %6.2f\n', L );
fprintf(file_ID, '// M = %6.2f\n', M );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR_calculated);
fprintf(file_ID, '//------------------------------------------- \n');

% Delays
fprintf(file_ID, '#define NUM_POLY_BRANCHES %d\n', M*L);
fprintf(file_ID, '#define N_delays_poly_60 %d\n', length(b_6_0));
fprintf(file_ID, '#define N_delays_poly_61 %d\n', length(b_6_1));
fprintf(file_ID, '#define N_delays_poly_62 %d\n', length(b_6_2));
fprintf(file_ID, '#define N_delays_poly_63 %d\n', length(b_6_3));
fprintf(file_ID, '#define N_delays_poly_64 %d\n', length(b_6_4));
fprintf(file_ID, '#define N_delays_poly_65 %d\n', length(b_6_5));

% Polyphasen
fprintf(file_ID, '\n// POLYPHASE 0\n');
fprintf(file_ID, 'short H_filt_poly_60[N_delays_poly_60]; \n');
write_coeff(file_ID, 'b_poly_60', b_6_0, length(b_6_0));
fprintf(file_ID, '\n// POLYPHASE 1\n');
fprintf(file_ID, 'short H_filt_poly_61[N_delays_poly_61]; \n');
write_coeff(file_ID, 'b_poly_61', b_6_1, length(b_6_1));
fprintf(file_ID, '\n// POLYPHASE 2\n');
fprintf(file_ID, 'short H_filt_poly_62[N_delays_poly_62]; \n');
write_coeff(file_ID, 'b_poly_62', b_6_2, length(b_6_2));
fprintf(file_ID, '\n// POLYPHASE 3\n');
fprintf(file_ID, 'short H_filt_poly_63[N_delays_poly_63]; \n');
write_coeff(file_ID, 'b_poly_63', b_6_3, length(b_6_3));
fprintf(file_ID, '\n// POLYPHASE 4\n');
fprintf(file_ID, 'short H_filt_poly_64[N_delays_poly_64]; \n');
write_coeff(file_ID, 'b_poly_64', b_6_4, length(b_6_4));
fprintf(file_ID, '\n// POLYPHASE 5\n');
fprintf(file_ID, 'short H_filt_poly_65[N_delays_poly_65]; \n');
write_coeff(file_ID, 'b_poly_65', b_6_5, length(b_6_5));


fprintf(file_ID, 'p2p_H_polyphase_filt[NUM_POLY_BRANCHES];\n');

for idx = 0:(L*M)-1
    idx2 = rem(idx + 1, (L*M));
    fprintf(file_ID, 'p2p_H_polyphase_filt[%d] = H_filt_poly_6%d;\n', idx, idx2);
end
fprintf(file_ID, '\n');
fprintf(file_ID, 'delays[NUM_POLY_BRANCHES];\n');


for idx = 0:(L*M)-1
    fprintf(file_ID, 'delays[%d] = N_delays_poly_6%d;\n', idx, (L*M) - idx - 1);
end
fprintf(file_ID, '\n');


%fprintf(file_ID, 'p2p_b_poly[NUM_POLY_BRANCHES];\n');

%for idx = 0:(L*M)-1
%    fprintf(file_ID, 'p2p_b_poly[%d] = N_delays_poly_6%d;\n', idx, (L*M) - idx - 1);
%end

fclose(file_ID);

