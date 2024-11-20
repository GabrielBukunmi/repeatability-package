function [SSF] = aux_fcn_SSF(x, U, L, k)
% x: state variable
% U: upper limit
% L: lower limit
% k: smoothing factor
alpha = (U+L)/2;
mu    = (U-L)/2;
SSF   = alpha + (mu * ( ((x-alpha)/mu) / ((1 + ((x-alpha)/mu)^k)^(1/k)) ));
end