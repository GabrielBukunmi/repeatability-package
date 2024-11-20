function [Idpre] = aux_fcn_Idpre(p,x)
    % Extract Pgen (generated power) and Vtf (terminal voltage frequency) from the state vector
    Pgen = x(p.Pgen_index);  % Pgen corresponds to x(9)
    Vtf = x(p.Vtf_index);    % Vtf corresponds to x(1)
    
    % Calculate Idpre using the auxiliary scaling function
    Idpre = aux_fcn_SSF(Pgen, p.Pmax, p.Pmin, p.k) / aux_fcn_SSF(Vtf, p.inf, 0.01, p.k);
end
