% dec_kern_int_M_5_FIR.m
%
% FIR Filterentwurf fuer den Tiefpass-/Hochpass Branching-Filter des Labors 3
clear
close all
help dec_kern_int.m

Fs_in = 50000;
Fs_out = Fs_in;
freq = (1:999)/2000;

MM = 2; % TBD

%% Remez equiripple
% Entwurfsparameter
fpass = 3350;
fstop = 3100;
delta_pass = 0.01;
delta_stop = 0.01;
delta_stop_dB = db(delta_stop);

% Abschaetzung der Filterordnung
% high-pass                      fstop fpass  pass stop rip_pass rip_stop 
[N_FIR_HP, fo, mo, w] = firpmord( [fstop fpass], [0 1], [delta_pass delta_stop], Fs_in );

% Grade Anzahl an Koeffizienten erzwingen
if rem(N_FIR_HP,2) ==  1 
    N_FIR_HP = N_FIR_HP + 1; 
end












