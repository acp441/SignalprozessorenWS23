% function Ages = fops(MMvar, fpass, fstop, delta_pass, delta_stop, Fs)
%
% US 30-Jul-06
% 
% computes the FOPS according to p. 144 Fliebe, Ages formula
% function [Ages, A_dec_int,A_kern] = fops(MMvar, fpass, fstop, delta_pass, delta_stop, Fs)
function [Ages, A_dec_int, A_kern] = fops(MMvar, fpass, fstop, delta_pass, delta_stop, Fs)
fact1 = 2*Fs./(Fs-MMvar*(fstop+fpass)) ;
fact2 = Fs./(MMvar.^2*(fstop-fpass));

% BOTH, DEC + INT filters, NO factor 1/2 !!
A_dec_int = 2/3*log10(1/(10*delta_pass/3*delta_stop))*(fact1)*Fs;

% kernel filter effort
A_kern = 2/3*log10(1/(10*delta_pass/3*delta_stop))*(fact2)*Fs;

% total effort
Ages = 2/3*log10(1/(10*delta_pass/3*delta_stop))*(fact1 + fact2)*Fs;
return;