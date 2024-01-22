% filterbank_FIR_amp_dist.m
%
% Victor Kröger und Lennard Jönsson - WS 23
%
% Entwurf einer Filterbank
%
%
%% Settings

clear
close('all');
format compact
Fs = inputs('Fs_in', 50e3);

% create a frequency vector
freq=(1:999)/2000;

%% Labor 6

L = 2;          % Downsampling Faktor
M = 2;          % Upsampling Faktor
Fs1 = Fs;       % Eingangsfrequenz
Fs2 = Fs1;      % Ausgangsfrequenz
Fs3 = Fs1 * L;  % Abtastfrequenz auf der das Filter läuft

% stop-band attentuation is in DB, convert to linear for REMEZ
delta_stop_dB = inputs('stop-band attenuation in dB', 40);
delta_stop = dbinv(-delta_stop_dB);
% for pass-band
delta_pass = 1.45e-4;


% edge frequencies
fstop = inputs('fstop', 16100); %(Fs1/2 - f_pass)
fpass = inputs('fpass', 8900);


% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs1);

% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
N_FIR = N_FIR + 2;  % The number of coefficients must be even!
b_FIR = firpm(N_FIR,fo,mo,w);

% compute the amplitude response using frequency vector
[hz, w] = freqz(b_FIR,1, 2*pi*freq);

fprintf('\n N_FIR = %d\n\n', N_FIR);

% Plot amplitude response
figure(1)
plot(freq*Fs3,db(hz)),grid
legend('FIR\_LP (Fs = 50 kHz)')
xlabel('Frequency in Hz')
ylabel('|H| in dB')
hold on

% Plot phase response
figure(2)
plot(freq*Fs3, w), grid
title('Phase Response of FIR\_LP Filter')
xlabel('Frequency in Hz')
ylabel('Phase in radians')
hold on

% Plot amplitude and phase response using freqz
figure(3)
freqz(b_FIR, 1);


% PPZ coefficients
b_20 = b_FIR(1:2:end);
b_21 = b_FIR(2:2:end);

% PPZ frequency response
hz_20 = freqz(b_20, 1, L*2*pi*freq);
hz_21 = freqz(b_21, 1, L*2*pi*freq);

zhm1 = exp(-1j*2*pi*freq);

% Frequency response from ppz reconstruction
hz_ges = hz_20 + hz_21 .* zhm1;

% Plot amplitude response of ppz reconstruction
figure(4)
plot(freq*Fs3,db(hz_ges)),grid
legend('FIR\_LP PPZ (Fs = 50 kHz)')
xlabel('Frequency in Hz')
ylabel('|H| in dB')
hold on

%% Pol Zeros diagramm
%a = 1;
%b = b_FIR;
%[z,p,k] = tf2zp(b,a);

%fvtool(b,a,'polezero')
%text(real(z)+.1,imag(z),'Zero')
%text(real(p)+.1,imag(p),'Pole')
