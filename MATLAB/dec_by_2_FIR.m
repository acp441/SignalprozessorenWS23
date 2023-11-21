% dec_by_2_FIR.m
%
% FIR Filterentwurf fuer den Dezimator von Labor 2
clear
close all
help dec_by_2_FIR.m

% Globale Variablen des Dezimators
Fs_in = 50000;
freq = (1:999)/2000;
MM = 2;

%% Remez equiripple
% Filterentwurfsparameter
fpass = Fs_in/4 + 530;
fstop = Fs_in/4; % has to be determined from the parameters ...
                       % above such that when down- or up-sampling ...
                       % is applied NO aliasing occurs
                       % Die Frequenz fstop sollte sich an B/2 des
                       % Eingangssignals orientieren
delta_pass = 0.01;     % Welligkeit im Passband
delta_stop = 0.01;     % Welligkeit im Stopband
delta_stop_dB = db(delta_stop); % Welligkeit im Stopband in dB (Header-File)

% Abschaetzung der Filterordnung
% high-pass                      fstop fpass  pass stop rip_pass rip_stop 
[N_FIR_HP, fo, mo, w] = firpmord( [fstop fpass], [0 1], [delta_pass delta_stop], Fs_in );

% Grade Anzahl an Koeffizienten erzwingen
if rem(N_FIR_HP,2) ==  1 
    N_FIR_HP = N_FIR_HP + 1; 
end

% Ergänze zwei weitere Koeffizienten um wirklich -40 dB Sperrdämpfung zu
% erreichen
N_FIR_HP_DEC = N_FIR_HP+2;

% FIR-Filterdesign...
b_FIR_HP_dec = firpm(N_FIR_HP_DEC, fo, mo, w);
%b_FIR_HP = firpm(N_FIR_HP, fo, mo, w);

% Runden auf 16 bit (Hardware nahe Simulation)
b_FIR_HP_dec = round(b_FIR_HP_dec*32768)/32768;
%b_FIR_HP = round(b_FIR_HP*32768)/32768;

% Berechnung der Frequenzgänge
hz_FIR_dec_HP = freqz(b_FIR_HP_dec, 1, 2*pi*freq);
%hz_FIR_HP = freqz(b_FIR_HP, 1, 2*pi*freq); (nicht ganz -40 dB)

% Polyphasenzerlegung
b_FIR_HP_dec_2_0 = zeros(1, length(b_FIR_HP_dec(1:MM:end))*2);
b_FIR_HP_dec_2_1 = zeros(1, length(b_FIR_HP_dec(2:MM:end))*2);

b_FIR_HP_dec_2_0(1:2:end) = b_FIR_HP_dec(1:MM:end);
b_FIR_HP_dec_2_1(1:2:end) = b_FIR_HP_dec(2:MM:end);

% Definition von z
z = exp(-1j*2*pi*freq);

% Generierung der Übertragungsfunktionen der Polyphasen
hz_FIR_HP_dec_2_0 = freqz(b_FIR_HP_dec_2_0, 1, 2*pi*freq);
hz_FIR_HP_dec_2_1 = freqz(b_FIR_HP_dec_2_1, 1, 2*pi*freq);

% Aufaddieren der Polyphasenkomponenten zur Gesamtübertragungsfunktion
hz_FIR_dec_HP_polyphase = hz_FIR_HP_dec_2_0 + z.* hz_FIR_HP_dec_2_1;

% Visualisierung des Frequenzgangs des entworfenen Filters
figure(1);
set(gcf,'Units','normal','Position',[0.5 0.4 0.4 0.4]);
plot(freq*Fs_in, db(hz_FIR_dec_HP));
% plot(freq*Fs_in, db(hz_FIR_HP)); % Zum Vergleich: Selber Filter ...
                                   % jedoch mit 2 Koeffizienten weniger
%legend('high-pass-int +2 coeffs', 'high-pass-int')
title('Amplitude response HP-FIR filter for dec in dB');
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H\_FIR\_dec| in dB');
grid

% Visualisierung des Frequenzgangs des entworfenen Filters mit PP-Zerlegung
figure(2);
set(gcf,'Units','normal','Position',[0.5 0.4 0.4 0.4]);
plot(freq*Fs_in, db(hz_FIR_dec_HP_polyphase));
%legend('high-pass-dec +2 coeffs', 'high-pass-dec')
title('Amplitude response of HP-FIR-Polyphase filter for dec in dB');
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H\_FIR\_dec\_pp| in dB');
grid

% Ausgabe der Anzahl an Filterkoeffizienten des entworfenen Filters
fprintf('\n Order of filter, N_FIR_HP_DEC = %d\n\n', N_FIR_HP_DEC);

% Exportieren des entworfenen Filters in Form eines Headerfiles
%---------------------------------------------------------------------------
% write to file !
% create header file and info
fprintf('coefficients are written to file ==> ');
filename = 'dec_by_2_FIR.h';
fprintf(filename);
fprintf('\n\n');

file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_by_2_FIR.m -- \n');
fprintf(file_ID, ['// ',date,'\n'] );
fprintf(file_ID, '// Fs = %6.2f\n', Fs_in );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR_HP_DEC);
fprintf(file_ID, '//------------------------------------------- \n');

% fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_DEC_LAB2 %d\n', length(b_FIR_dec_HP)); % Ist hier nicht ein Fehler???
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_DEC_LAB2 %d\n', N_FIR_HP_DEC); % Korrigierte Zeile
fprintf(file_ID, 'short H_filt_FIR_design_dec_lab2[N_DELAYS_FIR_DESIGN_DEC_LAB2]; \n');
write_coeff(file_ID, 'b_FIR_dec_HP', b_FIR_HP_dec, length(b_FIR_HP_dec));

fclose(file_ID);

