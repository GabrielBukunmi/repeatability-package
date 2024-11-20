function [A] = aux_fcn_A(p,x)
    % Extract Pgenf (generated power frequency) from the state vector
    Pgenf = x(p.Pgenf_index);  % Pgenf corresponds to x(2)

    % Calculate A using the auxiliary scaling function and relevant parameters
    A = aux_fcn_SSF(p.Pref + aux_fcn_uD(p,x) - Pgenf, p.femax, p.femin, p.k);
end
