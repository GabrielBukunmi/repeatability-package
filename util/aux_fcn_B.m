function [B] = aux_fcn_B(p,x)
    % Extract PI (power integral) from the state vector
    PI = x(p.PI_index);  % PI corresponds to x(7)
    
    % Calculate B using the auxiliary scaling function and relevant parameters
    B = aux_fcn_SSF(PI + p.kpg * aux_fcn_A(p,x), p.Pmax, p.Pmin, p.k);
end
