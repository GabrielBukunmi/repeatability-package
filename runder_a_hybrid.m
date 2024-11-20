% Initialize the DER_A hybrid system
clear; close all; clc
addpath(genpath('./util'))
% Automatically locate the DER_A class
className = 'der_a_hybrid';

% Search for the class in the MATLAB path
classInfo = meta.class.fromName(className);

if isempty(classInfo)
    error('Class "%s" not found. Ensure it is in the MATLAB path.', className);
end

% Dynamically create the object
sys = feval(className);
  % Instantiate the DER_A system

% Set initial conditions for the states
Vtf0 = 1.0;        % Initial terminal voltage frequency
Pgenf0 = 0.1;      % Initial generated power frequency
IqPFC0 = 0.025525;   % Initial reactive power factor control
Iq0 = 0.027;      % Initial reactive current
Vtrip0 = 0.5;        % Initial voltage trip signal
Freqf0 = 1;     % Initial frequency flag
PI0 = 0.1;         % Initial power integral
rr0 = 0.2;         % Initial ramp rate
Pgen0 = 0.1;       % Initial generated power
Ip0 = 0.0253;      % Initial active current
z0 = 0;            % Initial timer

% Time when fault clears and line reclosure happens
sys.tf = 0.7;   % Onset time of clearing operation (fault cleared)

% Combine all initial states into a single vector
x0 = [Vtf0; Pgenf0; IqPFC0; Iq0; Vtrip0; Freqf0; PI0; rr0; Pgen0; Ip0; z0];

% Set the time span for the simulation
tspan = [0, 1.8];  % Simulate for 200 seconds
jspan = [0, 3];   % Allow for up to 40 jumps

% Define solver options
config = HybridSolverConfig('AbsTol', 1e-6, 'RelTol', 1e-8);

% Compute the solution using the hybrid solver
sol = sys.solve(x0, tspan, jspan, config);

% Plot the results
%% Plot the system dynamics (all states over time)

% Plot each state in separate figures with individual titles and labels, then save each as a PDF.
for i = 1:10
    fig = figure(i);
    clf
    hpb = HybridPlotBuilder();
    hpb.defaults.jump_start_marker_size=36;
    hpb.defaults.flow_line_width = 2;
    hpb.subplots('off')...                          % Turn off subplots to create individual figures
        .plotFlows(sol.select(i));                   % Plot the i-th state variable

    % Define the filename based on the state name for exporting
    switch i
        case 1
            ylabel('$x_1$', 'Interpreter', 'latex','FontSize',22);  % Terminal voltage frequency (Vtf)
            filename = 'Vtf.pdf';
            
        case 2
            ylabel('$x_2$', 'Interpreter', 'latex','FontSize',22);  % Generated power frequency (Pgenf)
            filename = 'Pgenf.pdf';
        case 3
            ylabel('$x_3$', 'Interpreter', 'latex','FontSize',22);  % Reactive power factor control (IqPFC)
            filename = 'IqPFC.pdf';
        case 4
            ylabel('$x_4$', 'Interpreter', 'latex','FontSize',22);  % Reactive current (Iq)
            filename = 'Iq.pdf';
        case 5
            ylabel('$x_5$', 'Interpreter', 'latex','FontSize',22);  % Voltage trip signal (Vtrip)
            filename = 'Vtrip.pdf';
        case 6
            ylabel('$x_6$', 'Interpreter', 'latex','FontSize',22);  % Frequency flag (Freqflag)
            filename = 'Freqflag.pdf';
        case 7
            ylabel('$x_7$', 'Interpreter', 'latex','FontSize',22);  % Power integral (PI)
            filename = 'PI.pdf';
        case 8
            ylabel('$x_8$', 'Interpreter', 'latex','FontSize',22);  % Ramp rate (rr)
            filename = 'rr.pdf';
        case 9
            ylabel('$x_9$', 'Interpreter', 'latex','FontSize',22);  % Generated power (Pgen)
            filename = 'Pgen.pdf';
        case 10
            ylabel('$x_{10}$', 'Interpreter', 'latex','FontSize',22);  % Active current (Ip)
            filename = 'Ip.pdf';
    end

    % Label the x-axis
    xlabel('Time (t)', 'Interpreter', 'latex','FontSize',22);  
    set(gca, 'FontSize', 22);  % Adjust tick labels' size

    % Export the figure to a PDF with the defined filename
    exportgraphics(gcf, filename, 'ContentType', 'vector');
end
