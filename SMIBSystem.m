classdef SMIBSystem < HybridSystem
    % SMIBSystem defines the Single Machine Infinite Bus (SMIB) system 
    % with appropriate reset maps for fault and line reconnection events.
    
    properties
        % System parameters
        k = 0.05;   % Damping coefficient.
        Pm = 0.2;   % Mechanical input power.
        b = 0.7;    % Critical power of two lines operation.
        
        % Time events for transitions
        tc = 3.8;  % Onset time of clearing operation (fault cleared).
        tr = 40.9;  % Onset time of re-closing operation (second line reclosed).
    end

    % Indices for accessing state variables
    properties(SetAccess = immutable)
        delta_index = 1;  % Index for rotor angle (delta)
        omega_index = 2;  % Index for rotor speed deviation (omega)
        time_index = 3;   % Index for time (z)
    end

    % Mode tracking, not part of state vector
    properties
        mode = 1;  % Initial mode (q1, fault-on)
    end

    methods
        % Constructor for the SMIBSystem class
        function this = SMIBSystem()
            % Call the superclass constructor for HybridSystem.
            state_dim = 3;  % Only 3 states: [delta, omega, time]
            this = this@HybridSystem(state_dim);
        end

        % Flow map function (continuous dynamics)
        function xdot = flowMap(this, x, t, j)
            % Extract the state variables
            delta = x(this.delta_index);  % Rotor angle
            omega = x(this.omega_index);  % Rotor speed deviation
            z = x(this.time_index);       % Time

            % Define the alpha coefficient based on the mode
            if this.mode == 1
                alpha = 0;  % Fault-on (no electrical power)
            elseif this.mode == 2
                alpha = 0.5;  % One-line operation
            elseif this.mode == 3
                alpha = 1;  % Two-line operation
            end

            % Electrical power as alpha * b * sin(delta)
            electrical_power = alpha * this.b * sin(delta);

            % Define the flow map based on the current mode
            xdot = [omega; this.Pm - electrical_power - this.k * omega; 1];
        end

        % Jump map function (discrete transitions)
        function xplus = jumpMap(this, x)
            % Extract the state variables
            delta = x(this.delta_index);  % Rotor angle
            omega = x(this.omega_index);  % Rotor speed deviation
            z = x(this.time_index);       % Time

            % Define jump conditions based on time events and mode
            if this.mode == 1 && z >= this.tc && z <this.tr
                % Transition to mode q2 at tc (fault cleared)
                this.mode = 2;  
            elseif this.mode == 2 && z >= this.tr
                % Transition to mode q3 at tr (second line reclosed)
                this.mode = 3;
            end

            % Return the updated state after jump
            xplus = [delta; omega; z];
        end

        % Flow set indicator (continuous evolution conditions)
        function inC = flowSetIndicator(this, x)
            z = x(this.time_index);  % Time

            % System remains in the flow set until tc or tr, depending on mode
            if this.mode == 1
                inC = (z < this.tc);  % Flow in q1 until tc
            elseif this.mode == 2
                inC = (z < this.tr);  % Flow in q2 until tr
            else
                inC = 1;  % Continue flowing in q3 (after tr)
            end
        end

        % Jump set indicator (discrete transition conditions)
        function inD = jumpSetIndicator(this, x)
            z = x(this.time_index);  % Time

            % The system can jump when time reaches tc or tr
            if this.mode == 1 && z >= this.tc
                inD = 1;  % Jump from q1 to q2
            elseif this.mode == 2 && z >= this.tr
                inD = 1;  % Jump from q2 to q3
            else
                inD = 0;  % No jump
            end
        end
    end
end
