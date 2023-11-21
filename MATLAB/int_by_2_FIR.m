% int_by_2_FIR.m
%
% FIR Filterentwurf fuer den Interpolator von Labor 2
clear
close all
help int_by_2_FIR.m

Fs1 = 50000;
Fs2 = 2*Fs1;
freq = (1:999)/2000;
MM = 2;

%% Remez equiripple
% Vorgaben
fpass = Fs1/4 + 530;
fstop = Fs1/4; % has to be determined from the parameters ...
                     % above such that when down- or up-sampling ...
                     % is applied NO aliasing occurs
                     % Die Frequenz fstop sollte sich an B/2 des Eingangssignals orientieren
delta_pass = 0.01;
delta_stop = 0.01;
delta_stop_dB = db(delta_stop);

% Abschaetzung der Filterordnung
% high-pass                      fstop fpass  pass stop rip_pass rip_stop 
[N_FIR_HP_INT, fo, mo, w] = firpmord( [fstop fpass], [0 1], [0.01 0.01], Fs2 );

% Ordnung erhöhen, um wirklich die geforderte Sperrdämpfung zu erreichen und ...
% gerade Anzahl an Koeffizienten erzwingen 
N_FIR_HP_INT = N_FIR_HP_INT + 1;
if rem(N_FIR_HP_INT,2) == 1 
    N_FIR_HP_INT = N_FIR_HP_INT + 1; 
end

% Das eigentliche FIR-Filterdesign...
b_FIR_HP_int = firpm(N_FIR_HP_INT, fo, mo, w);
%b_FIR_HP = firpm(N_FIR_HP_INT, fo, mo, w);


% Runden auf 16 bit (Hardware nahe Simulation)
b_FIR_HP_int = round(b_FIR_HP_int*32768)/32768;

% Berechnung der Amplitudengaenge
hz_FIR_HP_int = freqz(b_FIR_HP_int, 1, 2*pi*freq);
%hz_FIR_HP = freqz(b_FIR_HP, 1, 2*pi*freq);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Polyphasenzerlegung
b_FIR_HP_int_2_0 = zeros(1, length(b_FIR_HP_int(1:MM:end))*2);
b_FIR_HP_int_2_1 = zeros(1, length(b_FIR_HP_int(2:MM:end))*2);

b_FIR_HP_int_2_0(1:2:end) = b_FIR_HP_int(1:MM:end);
b_FIR_HP_int_2_1(1:2:end) = b_FIR_HP_int(2:MM:end);


% Definition von z
z = exp(-1j*2*pi*freq);

% Generierung der Übertragungsfunktionen der Polyphasen
hz_FIR_HP_int_2_0 = freqz(b_FIR_HP_int_2_0, 1, 2*pi*freq);
hz_FIR_HP_int_2_1 = freqz(b_FIR_HP_int_2_1, 1, 2*pi*freq);

% Aufaddieren der Polyphasenkomponenten zur Gesamtübertragungsfunktion
hz_FIR_int_HP_polyphase = hz_FIR_HP_int_2_0 + z.* hz_FIR_HP_int_2_1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Anzeige der Ergebnisse
figure(1);
set(gcf,'Units','normal','Position',[0.5 0.4 0.4 0.4])
plot(freq*Fs2, db(hz_FIR_HP_int));
%legend('high-pass-int +2 coeffs', 'high-pass-int')
title('Amplitude response HP-FIR filter for int in dB');
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H\_FIR\_int| in dB');
grid


figure(2);
set(gcf,'Units','normal','Position',[0.5 0.4 0.4 0.4]);
plot(freq*Fs2, db(hz_FIR_int_HP_polyphase));
title('Amplitude response of HP-FIR-Polyphase filter for int in dB');
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H\_FIR\_int\_pp| in dB');
grid

fprintf('\n Order of filter, N_FIR_HP_INT = %d\n\n', N_FIR_HP_INT);

pause
%---------------------------------------------------------------------------
% write to file !
% create header file and info
fprintf('coefficients are written to file ==> ');
filename = 'int_by_2_FIR.h';
fprintf(filename);
fprintf('\n\n');

file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- int_by_2_FIR.m -- \n');
fprintf(file_ID, ['// ',date,'\n'] );
fprintf(file_ID, '// Fs = %6.2f\n', Fs2 );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  N_FIR_HP_INT);
fprintf(file_ID, '//------------------------------------------- \n');

% fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_DEC_LAB2 %d\n', length(b_FIR_dec_HP)); % Ist hier nicht ein Fehler???
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_INT_LAB2 %d\n', N_FIR_HP_INT); % Korrigierte Zeile
fprintf(file_ID, 'short H_filt_FIR_design_int_lab2[N_DELAYS_FIR_DESIGN_INT_LAB2]; \n');
write_coeff(file_ID, 'b_FIR_int_HP', b_FIR_HP_int, length(b_FIR_HP_int));

fclose(file_ID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Exportieren des entworfenen Filters in Form eines Headerfiles
%---------------------------------------------------------------------------
% write to file !
% create header file and info
fprintf('coefficients are written to file ==> ');
filename = 'int_by_2_FIR_PP_decomp.h';
fprintf(filename);
fprintf('\n\n');

file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- int_by_2_FIR.m -- \n');
fprintf(file_ID, ['// ',date,'\n'] );
fprintf(file_ID, '// Fs = %6.2f\n', Fs1 );
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  length(b_FIR_HP_int(1:MM:end))); %N_FIR_HP_DEC
fprintf(file_ID, '// N_FIR = %d\n',  length(b_FIR_HP_int(2:MM:end))); %N_FIR_HP_DEC
fprintf(file_ID, '//------------------------------------------- \n');

% fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2 %d\n', length(b_FIR_int_HP)); % Ist hier nicht ein Fehler???
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2 %d\n', length(b_FIR_HP_int(1:MM:end))); % Korrigierte Zeile
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_INT_BRANCH_2_1_LAB2 %d\n', length(b_FIR_HP_int(2:MM:end))); % Korrigierte Zeile
fprintf(file_ID, 'short H_filt_FIR_design_int_2_0_lab2[N_DELAYS_FIR_DESIGN_INT_BRANCH_2_0_LAB2]; \n');
fprintf(file_ID, 'short H_filt_FIR_design_int_2_1_lab2[N_DELAYS_FIR_DESIGN_INT_BRANCH_2_1_LAB2]; \n');
write_coeff(file_ID, 'b_FIR_int_2_0_HP', b_FIR_HP_int(1:MM:end), length(b_FIR_HP_int(1:MM:end)));
write_coeff(file_ID, 'b_FIR_int_2_1_HP', b_FIR_HP_int(2:MM:end), length(b_FIR_HP_int(2:MM:end)));

fclose(file_ID);


