function x_updated = solveForS6_0(p, x)
    % Define the objective function for fsolve
    objectiveFunction = @(s6_0) objectiveFunc(p, x, s6_0);

    % Set the initial guess for s6_0
    initialGuess = x(7);  % Use the current value of x(7) as the initial guess

    % Use fsolve to find the value of s6_0 that satisfies the equation
    options = optimoptions('fsolve', 'Display', 'iter');  % Showing iterations
    x(7) = fsolve(objectiveFunction, initialGuess, options);

    % Return the updated x vector
    x_updated = x;
end

function result = objectiveFunc(p, x, s6_0)
    x_temp = x;
    x_temp(7) = s6_0;  % Update x(7), which corresponds to s6_0, dynamically in each iteration
    result = p.kig * aux_fcn_A(p, x_temp) + ...
             p.kw * (aux_fcn_B(p, x_temp) - p.kpg * aux_fcn_A(p, x_temp) - s6_0);
end

