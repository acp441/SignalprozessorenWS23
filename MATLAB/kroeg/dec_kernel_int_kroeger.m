% dec_kernel_int.m
%
% author:	Victor Kröger - WS 23
% topic:	Lab 03
% date:     27.11.2023
%
clear
close('all');
format compact
Fs = inputs('Fs', 50e3);

% create a frequency vector
freq=(1:999)/2000;

%% Filter design parameters
% stop-band attentuation is in DB, convert to linear for REMEZ
delta_stop_dB = inputs('stop-band attenuation in dB', 40);
delta_stop = dbinv(-delta_stop_dB);
% for pass-band
delta_pass = 0.01;

%% conventional filter design
% edge frequencies
fpass = inputs('fpass', 3100); 
fstop = inputs('fstop', 3350); 

% determine N_FIR and the coefficients using REMEZ ("normal" FIR filter)
[N_FIR,fo,mo,w] = firpmord( [fpass fstop], [1 0], [delta_pass delta_stop], Fs );

% for safety reasons, add 2 to N_FIR to achieve the stop-band attenuation for sure
N_FIR = N_FIR + 2;

% force even filter order, to achieve positive symmetry and therefore
% a linear phase for almost any type of filter (Source: SP_05_Filter_Design, page 4)
if rem(N_FIR,2) ==  1 
    N_FIR = N_FIR + 1;
end

% calculate coefficients
b_FIR = firpm(N_FIR,fo,mo,w);

% compute the amplitude response using frequency vector
hz = freqz(b_FIR,1, 2*pi*freq);

% Show amplitude response of LP
figure(2)
plot(freq*Fs,db(hz)),grid
title('Amplitude response of desired FIR filter in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');

% Estimate amplitude response of HP
% determine the number of delays, group delay of filter is N_FIR/2 !!
num_delays = [zeros(1,N_FIR/2),1];
hz_delays = freqz(num_delays,1,2*pi*freq);
hz_ges = hz - hz_delays;

% Show amplitude response of HP
figure(3)
plot(freq*Fs, db(hz_ges)),grid
title('Amplitude response of complementary FIR filter in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');

% original print line about filter detail (moved to other section)
% fprintf('\n N_FIR=%d, "normal" implementation\n\n', N_FIR);

%% Multi-rate FIR Filter design

% determine minumum of Ages
%MMvar = 1:0.01:10;
%Ages = fops(MMvar, fpass, fstop, delta_pass, delta_stop, Fs);

%figure(4),
%plot(MMvar,Ages);grid,title('Ages')

% third-order function
num = [(fstop^2-fpass^2), -(fstop+fpass)^2, 2*Fs*(fstop+fpass), -Fs^2];

% Estimate minimum factor M
rts = roots(num);
ox = find(imag(rts)==0);
for kx=1:length(ox)
    MMmin = rts(ox(kx));
    fprintf(' Ages has a MIN at %6.2f\n', MMmin);
end

%% Design filter
MM = inputs('MM', 4); 
Fs_MM = Fs/MM;

% design of kernel filter -------------------------------------------------
[N_FIR_kernel_MM,fo,mo,w] = remezord( [fpass fstop], [1 0], [delta_pass/3 delta_stop], Fs_MM );
% safety, add to N_fir + 2
N_FIR_kernel_MM = N_FIR_kernel_MM + 2;

% force even filter order, to achieve positive symmetry and therefore
% a linear phase for almost any type of filter (Source: SP_05_Filter_Design, page 4)
if rem(N_FIR_kernel_MM,2) ==  1 
    N_FIR_kernel_MM = N_FIR_kernel_MM + 1;
end

b_FIR_kernel_MM = remez(N_FIR_kernel_MM,fo,mo,w);
% fprintf(' N_FIR_kernel_MM=%d\n\n', N_FIR_kernel_MM);

% kernel filter on Fs/MM
hz_kernel_MM = freqz(b_FIR_kernel_MM,1, 2*pi*freq);

figure(5);
plot(freq*Fs_MM,db(hz_kernel_MM)),grid,
title(['kernel filter on Fs/MM, fpass = ',num2str(fpass),' Hz, fstop = ',num2str(fstop),' Hz']);

% kernel filter on Fs, Nyquist range, thus * MM
hz_kernel_MM_on_Fs = freqz(b_FIR_kernel_MM,1, 2*pi*freq*MM);

% figure(6);
% plot(freq*Fs,db(hz_kernel_MM_on_Fs)),grid,
% title(['kernel filter on Fs (due to M=2), fpass = ',num2str(fpass),' Hz, fstop = ',num2str(fstop),' Hz']);
% axis([0,Fs/2,-60,0]);

% Estimate the Filter degree of dec and int by formular
% N_FIR_Dec_Int_tst = 2/3*log10(1/(10*delta_pass/3*delta_stop))*Fs/(Fs/MM-fstop-fpass);
% N_FIR_kernel_tst  = 2/3*log10(1/(10*delta_pass/3*delta_stop))*Fs_MM/(fstop-fpass);

% design of int and dec Filter -------------------------------------------------
f_stop_Dec_Int = Fs_MM-fstop;
[N_FIR_Dec_Int,fo,mo,w] = remezord( [fpass f_stop_Dec_Int], [1 0], [delta_pass/3 delta_stop], Fs );
% safety, add to N_fir + 2
N_FIR_Dec_Int = N_FIR_Dec_Int + 2;

% force even filter order, to achieve positive symmetry and therefore
% a linear phase for almost any type of filter (Source: SP_05_Filter_Design, page 4)
if rem(N_FIR_Dec_Int,2) ==  1 
    N_FIR_Dec_Int = N_FIR_Dec_Int + 1;
end

b_FIR_Dec_Int = remez(N_FIR_Dec_Int, fo, mo, w);
hz_Dec_Int = freqz(b_FIR_Dec_Int,1, 2*pi*freq);

% the mirror image, shifted in Freq. Domain by Pi 
hz_Dec_Int_mirror = hz_Dec_Int(length(hz_Dec_Int):-1:1);

% compare the filter degrees of MATLAB and formula
%fprintf(' N_FIR_Dec_Int = %d,\n f_stop_Dec_Int = %6.2f Hz\n', N_FIR_Dec_Int, f_stop_Dec_Int);
%fprintf(' N_FIR_Dec_Int_tst= %6.0f,\n N_FIR_kernel_tst=%6.0f\n', N_FIR_Dec_Int_tst, N_FIR_kernel_tst);

figure(7);
plot(freq*Fs,db(hz_Dec_Int) );
title(['decimation filter on Fs/MM, fpass = ',num2str(fpass),' Hz, fstop of Dec filter = ',num2str(f_stop_Dec_Int),' Hz']);
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');
grid

%-------- visualize decimation, interpolation and kernel filter------------
hz_kernel = freqz(b_FIR_kernel_MM,1, 2*pi*freq*MM);

figure(8);
plot(   freq*Fs, db(hz_Dec_Int), ...
        freq*Fs, db(hz_kernel), ...
        freq*Fs, db( hz_Dec_Int  .* hz_kernel) );
grid,title('Dec., kernel and (Dec + kernel) filters in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');
axis([0,Fs/2,-80,10]);


figure(9);
plot(   freq*Fs, db(hz_Dec_Int), 'b-', ...
        freq*Fs, db(hz_kernel), 'r-',...
        freq*Fs, db(hz_Dec_Int(length(freq):-1:1)),'g-'...
        );
grid,title('Decimation and Kernel filters in dB'),
xlabel('Frequency in Hz, Nyquist range');
ylabel('|H| in dB');
axis([0,Fs/2,-170,10]);

%% polyphase decomposition of kernel, dec and int
% the coefficients
b_FIR_Dec_Int_4_0  = b_FIR_Dec_Int(1:MM:length(b_FIR_Dec_Int));
b_FIR_Dec_Int_4_1  = b_FIR_Dec_Int(2:MM:length(b_FIR_Dec_Int));
b_FIR_Dec_Int_4_2  = b_FIR_Dec_Int(2:MM:length(b_FIR_Dec_Int));
b_FIR_Dec_Int_4_3  = b_FIR_Dec_Int(2:MM:length(b_FIR_Dec_Int));

% the delays
H_filt_4_0_delays = zeros(1,length(b_FIR_Dec_Int_4_0));
H_filt_4_1_delays = zeros(1,length(b_FIR_Dec_Int_4_1));
H_filt_4_2_delays = zeros(1,length(b_FIR_Dec_Int_4_2));
H_filt_4_3_delays = zeros(1,length(b_FIR_Dec_Int_4_3));


%% verification of polyphase decomposition
% Definition von z
z = exp(-1j*2*pi*freq);

% Generierung der Übertragungsfunktionen der Polyphasen
hz_FIR_HP_dec_4_0 = freqz(b_FIR_Dec_Int_4_0, 1, 4*pi*freq);
hz_FIR_HP_dec_4_1 = freqz(b_FIR_Dec_Int_4_1, 1, 4*pi*freq);
hz_FIR_HP_dec_4_2 = freqz(b_FIR_Dec_Int_4_2, 1, 4*pi*freq);
hz_FIR_HP_dec_4_3 = freqz(b_FIR_Dec_Int_4_3, 1, 4*pi*freq);

% Aufaddieren der Polyphasenkomponenten zur Gesamtübertragungsfunktion
% hz_FIR_dec_int_polyphase = hz_FIR_HP_dec_4_0 + z.* hz_FIR_HP_dec_4_1 + ...
%     exp(-1j*2*pi*freq*2) .* H_filt_4_2_delays + exp(-1j*2*pi*freq*3) .* H_filt_4_3_delays;

% figure(10);
% set(gcf,'Units','normal','Position',[0.5 0.4 0.4 0.4]);
% plot(freq*Fs, db(hz_FIR_dec_int_polyphase));
% %legend('high-pass-dec +2 coeffs', 'high-pass-dec')
% title('Amplitude response of HP-FIR-Polyphase filter for dec in dB');
% xlabel('Frequency in Hz, Nyquist range');
% ylabel('|H\_FIR\_dec\_pp| in dB');
% grid

%% show filter design details
fprintf('\n Design of the "normal" FIR filter implementation and of the "Multi-rate" FIR filter implementation:');
fprintf('\n N_FIR=%d, "normal" FIR filter implementation', N_FIR);
fprintf('\n N_FIR_Dec_Int=%d, N_FIR_kernel_MM=%d,"Multi-rate" FIR filter implementation\n\n', N_FIR_Dec_Int, N_FIR_kernel_MM);

%% -------------------------------- Notizen ---------------------------------
% estimation of k
% num_of_T = 10;
% Tgr_of_dec_kern_int_of_T = grpdelay(num_of_T, 1, 2*pi*freq);
%--------------------------------------------------------------------------
% write to file !
% create header file and info
filename = 'FIR_normal_WS20_EMIL.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int.m -- \n');
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
filename = 'dec_kernel_int_WS20_EMIL.h';
file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int_WS20_EMIL.m -- \n');
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

%% ------------------------------------------------------------------------
% Exportieren des entworfenen Filters in Form eines Headerfiles
%---------------------------------------------------------------------------
% write to file !
% create header file and info
fprintf('coefficients are written to file ==> ');
filename = 'multirate_dec_int_FIR_PP_decomp.h';
fprintf(filename);
fprintf('\n\n');

file_ID = fopen(filename, 'w');		% generate include-file
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '// designed with -- dec_kernel_int.m -- \n');
fprintf(file_ID, ['// ',date,'\n'] );
fprintf(file_ID, '// Fs = %6.2f\n', Fs);
fprintf(file_ID, '// fstop = %6.2f\n', fstop);
fprintf(file_ID, '// fpass = %6.2f\n', fpass);
fprintf(file_ID, '// delta_pass = %6.2f\n', delta_pass);
fprintf(file_ID, '// delta_stop_dB = %6.2f\n', delta_stop_dB);
fprintf(file_ID, '// N_FIR = %d\n',  length(b_FIR_HP_dec(1:MM:end))); %N_FIR
fprintf(file_ID, '// N_FIR = %d\n',  length(b_FIR_HP_dec(2:MM:end))); %N_FIR
fprintf(file_ID, '//------------------------------------------- \n');
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_DEC_BRANCH_2_0_LAB2 %d\n', length(b_FIR_HP_dec(1:MM:end)));
fprintf(file_ID, '#define N_DELAYS_FIR_DESIGN_DEC_BRANCH_2_1_LAB2 %d\n', length(b_FIR_HP_dec(2:MM:end)));
fprintf(file_ID, 'short H_filt_FIR_design_dec_2_0_lab2[N_DELAYS_FIR_DESIGN_DEC_BRANCH_2_0_LAB2]; \n');
fprintf(file_ID, 'short H_filt_FIR_design_dec_2_1_lab2[N_DELAYS_FIR_DESIGN_DEC_BRANCH_2_1_LAB2]; \n');
write_coeff(file_ID, 'b_FIR_dec_2_0_HP', b_FIR_HP_dec(1:MM:end), length(b_FIR_HP_dec(1:MM:end)));
write_coeff(file_ID, 'b_FIR_dec_2_1_HP', b_FIR_HP_dec(2:MM:end), length(b_FIR_HP_dec(2:MM:end)));

fclose(file_ID);