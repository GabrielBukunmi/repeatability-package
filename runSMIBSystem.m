% SMIB with Fault Transitions and Jump Map

% Automatically locate the SMIBSystem class
className = 'SMIBSystem';

% Search for the class in the MATLAB path
classInfo = meta.class.fromName(className);

if isempty(classInfo)
    error('Class "%s" not found. Ensure it is in the MATLAB path.', className);
end

% Dynamically create the object
sys = feval(className);


%% Define initial conditions and transition times
x0 = [0.1; 0; 0];  % Initial condition: [delta, omega, time]

% Time when fault clears and line reclosure happens
sys.tc = 3.1;   % Onset time of clearing operation (fault cleared)
sys.tr = 40.9;  % Onset time of re-closing operation (second line reclosed)

%% Set time and jump spans
tspan = [0, 250];  % Total time for simulation
jspan = [0, 5];    % Maximum number of jumps

%% Solver options
config = HybridSolverConfig('AbsTol', 1e-6, 'RelTol', 1e-7);

%% Assertions to check flow and jump sets at critical points
% Check if initial condition is in the flow set of mode q1 (fault-on)
sys.assertInC(x0);  % Initial flow should occur in q1

%% Compute the solution
sol = sys.solve(x0, tspan, jspan, config);

%% Extract the solution components for delta and omega
delta_omega = sol.select(1:2);  % Select both delta (x1) and omega (x2) together
%% Define the electrical power function based on the mode
power_fnc = @(x) (x(3) < sys.tc) * 0 + ...  % Mode 1: Fault-on (power = 0)
                 (x(3) >= sys.tc && x(3) < sys.tr) * (0.5 * sys.b * sin(x(1))) + ...  % Mode 2: Fault cleared (half power)
                 (x(3) >= sys.tr) * (sys.b * sin(x(1)));  % Mode 3: Two-line restored (full power)
%% Compute and plot the electrical power along the solution

% Compute and plot the electrical power along the solution
power_data = sol.transform(power_fnc);  % 'power_fnc' is your function to compute power

% Extract time, jumps, and state data from delta_omega
t1 = delta_omega.t;       % Time vector
j1 = delta_omega.j;       % Jump indices
x1 = delta_omega.x;       % State data (delta and omega), size N x 2

% Extract time, jumps, and state data from power_data
t2 = power_data.t;        % Time vector
j2 = power_data.j;        % Jump indices
x2 = power_data.x;        % State data (electrical power), size N x 1

% Check if time vectors and jump indices match
if ~isequal(t1, t2) || ~isequal(j1, j2)
    % If they do not match, interpolate power_data to match delta_omega
    % Interpolate x2 (power_data.x) to the time points of delta_omega
    x2_interp = interp1(t2, x2, t1, 'linear', 'extrap');
else
    x2_interp = x2;
end

% Plot delta and omega in the first subplot
figure(1);
clf;

subplot(2, 1, 1);  % Create a 2-row, 1-column layout and select the first subplot
hpb1 = HybridPlotBuilder();
 hpb.defaults.jump_start_marker_size=24;
    hpb.defaults.flow_line_width = 1;
hpb1.flowLineStyle('-').subplots('off')...
    .flowColor({'blue', 'black'})...  % Colors for delta and omega
    .plotFlows(delta_omega);

% Manually create dummy plots for legend in delta and omega plot
hold on;
delta_handle = plot(nan, nan, 'b-', 'LineWidth', 2.5);  
omega_handle = plot(nan, nan, 'k-', 'LineWidth', 2.5);  

% Add legend entries for delta and omega
legend([delta_handle, omega_handle], '$\delta$', '$\omega$', 'Interpreter', 'latex', 'FontSize', 14);

% Set labels and appearance for the first plot
xlabel('', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('States', 'Interpreter', 'latex', 'FontSize', 14);
set(gca, 'FontSize', 18);
grid on;
hold off;

% Plot P_e in the second subplot
subplot(2, 1, 2);  % Select the second subplot
hpb2 = HybridPlotBuilder();
 hpb2.defaults.jump_start_marker_size=24;
    hpb2.defaults.flow_line_width = 1;
hpb2.flowLineStyle('-').subplots('off')...
    .flowColor({'blue'})...  % Color for power
    .plotFlows(HybridArc(t1, j1, x2_interp));  % Plot only power data

% Manually create dummy plot for legend in power plot
hold on;
power_handle = plot(nan, nan, 'b-', 'LineWidth', 2.5);  % Dummy line for power (magenta)

% Add legend entry for P_e
legend(power_handle, '$P_e$', 'Interpreter', 'latex', 'FontSize', 14);

% Set labels and appearance for the second plot
xlabel('Time (t)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Electrical Power', 'Interpreter', 'latex', 'FontSize', 14);
set(gca, 'FontSize', 18);
grid on;
hold off;

% Export the figure to PDF
exportgraphics(gcf, 'ResultSMIB.pdf', 'ContentType', 'vector');




% % plot the phase portrait
figure(2)
hpb = HybridPlotBuilder();

    hpb.defaults.flow_line_width = 0.75;
hpb.plotPhase(delta_omega);  % Plot the phase portrait for delta (x1) and omega (x2)

% Add axis labels and title
xlabel('$\delta$ (Rotor Angle)', 'Interpreter', 'latex','FontSize',14);  % Label for x-axis (delta)
ylabel('$\omega$ (Rotor Speed Deviation)', 'Interpreter', 'latex','FontSize',14);  % Label for y-axis (omega)
% Set tick label font size for the axes
set(gca, 'FontSize', 18);  % Increase tick label font size

grid on  % Turn on the grid
exportgraphics(gcf, 'phaseportrait.pdf', 'ContentType', 'vector');

