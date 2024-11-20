function [Iqv] = aux_fcn_Iqv(p, x)
    % Extract Vtf (terminal voltage frequency) from the state vector
    Vtf = x(p.Vtf_index);  % Vtf corresponds to x(1)
    
    % Calculate Iqv using the auxiliary function aux_fcn_SDBF
    Iqv = aux_fcn_SDBF(p.Vref - Vtf, p.dbd2, p.dbd1, p.k);
end
