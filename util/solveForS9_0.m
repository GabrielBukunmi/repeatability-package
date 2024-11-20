function s9_0_solution = solveForS9_0(p, x)
    % Set the initial guess for s9_0 inside the function
    initialGuess = 0;
   
    % Define the objective function for fsolve
    objectiveFunction = @(s9_0) aux_fcn_SSF(1/p.Tg*aux_fcn_SSF(aux_fcn_Idpre(p, x), p.Idmax, p.Idmin, p.k) - 1/p.Tg*s9_0, p.rrup, p.rrdn, p.k);

    % Use fsolve to find s9_0
    options = optimoptions('fsolve', 'Display', 'iter');  
    s9_0_solution = fsolve(objectiveFunction, initialGuess, options);

    % % Display the solution
    % disp(['The solution is s9_0 = ', num2str(s9_0_solution)]);
end


