function s8_0_solution = solveForS8_0(p, s7_0)
    % Define the objective function for fsolve
    objectiveFunction = @(s8_0) 1/p.Tpord * s7_0 - 1/p.Tpord * aux_fcn_SSF(s8_0, p.Pmax, p.Pmin, p.k) + p.kw * (aux_fcn_SSF(s8_0, p.Pmax, p.Pmin, p.k) - s8_0);

    % Set the initial guess for s8_0
    initialGuess = 0;  % You can adjust this based on expected s8_0 range

    % Use fsolve to find s8_0
    options = optimoptions('fsolve', 'Display', 'iter');  % Showing iterations
    s8_0_solution = fsolve(objectiveFunction, initialGuess, options);

    % Display the solution
    disp(['The solution for s8_0 is: ', num2str(s8_0_solution)]);
end
