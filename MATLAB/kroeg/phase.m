function PHI=phase(G)
%PHASE  Computes the phase of a complex vector
%
%   PHI=phase(G)
%
%   G is a complex-valued row vector and PHI is returned as its
%   phase (in radians), with an effort made to keep it continuous
%   over the pi-borders.

%   L. Ljung 10-2-86
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:21:43 $

%PHI = unwrap(angle(G));

PHI=atan2(imag(G),real(G));
N=length(PHI);
DF=PHI(1:N-1)-PHI(2:N);
I=find(abs(DF)>3.5);
for i=I
if i~=0,
PHI=PHI+2*pi*sign(DF(i))*[zeros(1,i) ones(1,N-i)];
end
end
