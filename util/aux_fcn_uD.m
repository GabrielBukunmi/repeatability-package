function [uD] = aux_fcn_uD(p,x)
uD = aux_fcn_SSF(aux_fcn_SDBF(p.Freq_ref-x(6) ,p.fdbd2,p.fdbd1,p.k)*p.Ddn ,0,-p.inf,p.k) + aux_fcn_SSF(aux_fcn_SDBF(p.Freq_ref-x(6) ,p.fdbd2,p.fdbd1,p.k)*p.Dup ,p.inf,0,p.k);
end