function [SDBF] = aux_fcn_SDBF(x,Up,Lp,k)
% x : state variable
% Up: upper limit
% Lp: lower limit
% k : smoothing factor
alpha = (Up+Lp)/2;
mu    = (Up-Lp)/2;
SDBF  = x - alpha - (mu * ( ((x-alpha)/mu) / ((1 + ((x-alpha)/mu)^k)^(1/k)) ));
end