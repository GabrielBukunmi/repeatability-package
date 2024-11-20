classdef der_a_hybrid < HybridSystem
    % Distributed Energy Resource Aggregated (DER_A) modeled as a HybridSystem subclass.
    
    properties
        % DER_A Parameters
        dbd1     = -0.05;   % Lower voltage deadband ≤ 0 (pu)
        dbd2     = 0.05;    % Upper voltage deadband ≥ 0 (pu)
        Ddn      = 20;      % Frequency control droop gain (down-side)
        dpmax    = 0.2;     % Power ramp rate up (pu/s)
        dpmin    = -0.2;    % Power ramp rate down (pu/s)
        Dup      = 20;      % Frequency control droop gain (up-side)
        fdbd1    = -0.00283; % Lower frequency control deadband (pu)
        fdbd2    = 0.00283;  % Upper frequency control deadband (pu)
        femax    = 99;      % Frequency control maximum error (pu)
        femin    = -99;     % Frequency control minimum error (pu)
     
        Freq     = 1;       % Frequency (pu)
        Freq_ref = 1;       % Frequency reference (pu)
        Idmax    = 1.2;     % Max active current (pu)
        Idmin    = -1.2;    % Min active current (pu)
        Imax     = 1.2;     % Max converter current (pu)
        Iqh1     = 1;       % Max reactive current (pu)
        Iql1     = -1;      % Min reactive current (pu)
        Iqmax    = 1.09;    % Max total reactive current (pu)
        Iqmin    = -1.09;   % Min total reactive current (pu)
        kig      = 10;      % Active power control integral gain
        kpg      = 0.1;     % Active power control proportional gain
        kqv      = 5;      % Proportional voltage control gain (pu/pu)
        kw       = 10;      % Time constant for anti-windup
        Pmax     = 1.2;     % Maximum power (pu)
        Pmin     = 0;       % Minimum power (pu)
        Pref     = 0.2;     % Active power reference (pu)
        Qref     = 0.1;     % Reactive power reference (pu)
        rrpwr    = 0.016;   % Power rise ramp rate after fault
        rrdn     = 0.5;       % Power rise ramp rate down-side
        rrup     = -0.5;      % Power rise ramp rate up-side
        Tg       = 0.06;    % Current control time constant
        Tiq      = 0.04;    % Q control time constant
        Tp       = 0.02;    % Transducer time constant
        Tpord    = 0.02;    % Power order time constant
        Trf      = 0.02;    % Frequency transducer time constant
        Trv      = 0.02;    % Voltage transducer time constant
        Ts       = 0.01;    % Evaluation time of input signal
        Tv       = 0.02;    % Time constant for voltage/frequency cut-out
        tvh0     = 0.05;    % Timer for vh0 point
        tvh1     = 2;       % Timer for vh1 point
        tvl0     = 0.16;      % Timer for vl0 point
        tvl1     = 0.16;      % Timer for vl1 point
        vh0      = 1.2;     % High voltage cut-out
        vh1      = 1.05;    % Voltage break-point for high voltage cut-out
        vl0      = 0.44;    % Voltage break-point for low voltage cut-out
        vl1      = 0.49;    % Low voltage cut-out
        Vpr      = 0.8;     % Voltage below which frequency tripping is disabled
        Vref     = 1.0;     % Voltage reference set-point (pu)
        Vrfrac   = 0.7;     % Fraction of device recovering after voltage recovery
        Vt       = 1.01;    % Terminal voltage (pu)
        Xe       = 0.2;     % Source impedance reactive (pu)
        pfaref   = 0.95;    % Power factor reference
        tf       = 7;       % Arbitrary fault time
        k        = 1024;    % Auxiliary gain parameter
        inf      = 9999;    % Infinity (algebraic variable)
        neg_inf  = -999;    % Negative infinity (algebraic variable)
    end

    properties(SetAccess = immutable)
        % Define indices for the 11 states (and z).
        Vtf_index = 1;      % Terminal voltage frequency (Vtf)
        Pgenf_index = 2;    % Generated power frequency (Pgenf)
        IqPFC_index = 3;    % Reactive power factor control (IqPFC)
        Iq_index = 4;       % Reactive current (Iq)
        Vtrip_index = 5;    % Voltage trip signal
        Freqflag_index = 6; % Frequency flag
        rr_index = 7;       % Ramp rate (rr)
        PI_index = 8;       % Power integral (PI)
        Pgen_index = 9;     % Generated power (Pgen)
        Ip_index = 10;      % Active current (Ip)
        z_index = 11;       % Timer (z)
    end

    properties
        q = 1;  % Initial mode (q1, normal)
    end

    methods
        function this = der_a_hybrid()
            % Constructor for instances of the der_a_hybrid class.
            state_dim = 11;  % Define the state dimension of the DER_A system (11 states + timer z).
            this = this@HybridSystem(state_dim);
        end

        function xdot = flowMap(this, x, t, j)
            % Define the flow map (continuous dynamics)
            % Extract state components
            Vtf = x(this.Vtf_index);
            Pgenf = x(this.Pgenf_index);
            IqPFC = x(this.IqPFC_index);
            Iq = x(this.Iq_index);
            Vtrip = x(this.Vtrip_index);
            Freqflag = x(this.Freqflag_index);
            PI = x(this.PI_index);
            rr = x(this.rr_index);
            Pgen = x(this.Pgen_index);
            Ip = x(this.Ip_index);

            % Initialize xdot as a column vector (11x1)
            xdot = zeros(11, 1);

            % Mode-dependent variables (beta and gamma) for different modes
            if this.q == 1  % Normal operation (mode 1)
                beta = 1;
                gamma = 1;

                % Mode 1 dynamics
                xdot(1) = (beta * this.Vt - Vtf) / this.Trv;  % Terminal voltage frequency
                xdot(2) = -1 / this.Tp * Pgenf + 1 / this.Tp * aux_fcn_SSF(Pgen, this.Pmax, this.Pmin, this.k);
                xdot(3) = -1 / this.Tiq * IqPFC + 1 / this.Tiq * this.Qref / aux_fcn_SSF(Vtf, this.inf, 0.01, this.k);
                xdot(4) = (-1 / this.Tg )* Iq + 1 / this.Tg * aux_fcn_SSF(IqPFC - aux_fcn_SSF(aux_fcn_Iqv(this, x), this.Iqh1, this.Iql1, this.k), this.Iqmax, this.Iqmin, this.k);
                xdot(5) = 0;  % Voltage trip signal not part of the state
                xdot(6) = 0;  % Frequency flag not active
                xdot(7) = 0;  % Power integral PI
                xdot(8) = gamma * aux_fcn_SSF(-1 / this.Ts * rr + 1 / this.Ts * this.Pref, this.dpmax, this.dpmin, this.k);  % Ramp rate rr
                xdot(9) = rr / this.Tpord - aux_fcn_SSF(Pgen, beta * this.Pmin, beta * this.Pmax, this.k) / this.Tpord;  % Generated power Pgen
                xdot(10) = aux_fcn_SSF((1 / this.Tg )* aux_fcn_SSF(aux_fcn_Idpre(this, x), this.Idmax, this.Idmin, this.k) - (1 / this.Tg * Ip), this.rrup, this.rrdn, this.k);  % Active current Ip

            elseif this.q == 2  % Fault mode (mode 2)
                beta = this.vl1;
                gamma = 0.5;

                % Mode 2 dynamics (adjust equations that are mode-dependent)
                xdot(1) = (beta * this.Vt - Vtf) / this.Trv;  % Terminal voltage frequency
                xdot(2) = -1 / this.Tp * Pgenf + 1 / this.Tp * aux_fcn_SSF(Pgen, this.Pmax, this.Pmin, this.k);
                xdot(3) = -1 / this.Tiq * IqPFC + 1 / this.Tiq * this.Qref / aux_fcn_SSF(Vtf, this.inf, 0.01, this.k);
                xdot(4) = -1 / this.Tg * Iq + 1 / this.Tg * aux_fcn_SSF(IqPFC - aux_fcn_SSF(aux_fcn_Iqv(this, Vtf), this.Iqh1, this.Iql1, this.k), this.Iqmax, this.Iqmin, this.k);
                xdot(5) = 0;  % Voltage trip signal is zero in fault mode
                xdot(6) = 0;  % Frequency flag is zero in fault mode
                xdot(7) = 0; % no PI in fault mode
                xdot(8) = (gamma * aux_fcn_SSF(-1 / this.Ts * rr + 1 / this.Ts * this.Pref, this.dpmax, this.dpmin, this.k));  % Ramp rate rr
                xdot(9) = gamma*rr / this.Tpord - aux_fcn_SSF(Pgen, beta * this.Pmin, beta * this.Pmax, this.k) / this.Tpord;  % Generated power Pgen
                xdot(10) = aux_fcn_SSF(1 / this.Tg * aux_fcn_SSF(aux_fcn_Idpre(this, x), this.Idmax, this.Idmin, this.k) - 1 / this.Tg * Ip, this.rrup, this.rrdn, this.k);  % Active current Ip

            elseif this.q == 3  % Recovery mode (mode 3)
                beta = 1;
                gamma = 1;

                % Mode 3 dynamics (adjust equations that are mode-dependent)
                xdot(1) = (beta * this.Vt - Vtf) / this.Trv;  % Terminal voltage frequency
                xdot(2) = -1 / this.Tp * Pgenf + 1 / this.Tp * aux_fcn_SSF(Pgen, this.Pmax, this.Pmin, this.k);
                xdot(3) = -1 / this.Tiq * IqPFC + 1 / this.Tiq * this.Qref / aux_fcn_SSF(Vtf, this.inf, 0.01, this.k);
                xdot(4) = (-1 / this.Tg * Iq) + (1 / this.Tg * aux_fcn_SSF(IqPFC - aux_fcn_SSF(aux_fcn_Iqv(this, x), this.Iqh1, this.Iql1, this.k), this.Iqmax, this.Iqmin, this.k) * Vtrip);
                xdot(5) = -1 / this.Tv * Vtrip + 1 / this.Tv * pcode_trip_volt(this, x);  % Voltage trip signal
                xdot(6) = (-1 / this.Trf) * Freqflag + this.Freq / this.Trf;  % Frequency flag
                xdot(7) = this.kig * aux_fcn_A(this, x) + this.kw * (aux_fcn_B(this, x) - this.kpg * aux_fcn_A(this, x) - PI);  % Power integral PI
                xdot(8) = aux_fcn_SSF(((-1 / this.Ts) * rr )+ 1 / this.Ts * aux_fcn_B(this, x), this.dpmax, this.dpmin, this.k);  % Ramp rate rr
                xdot(9) = rr / this.Tpord - aux_fcn_SSF(Pgen, beta * this.Pmin, beta * this.Pmax, this.k) / this.Tpord;  % Generated power Pgen
                xdot(10) = aux_fcn_SSF(1 / this.Tg * aux_fcn_SSF(aux_fcn_Idpre(this, x), this.Idmax, this.Idmin, this.k) - 1 / this.Tg * Ip, this.rrup, this.rrdn, this.k) * Vtrip; % Active current Ip
            end

            % Timer (z) always evolves
            xdot(11) = 1;  % Timer (z) evolves
        end

        function xplus = jumpMap(this, x)
            % Extract the current state
            z = x(this.z_index);  % Timer

            % Initialize xplus with the current state
            xplus = x; 

            % Jump logic based on the timer and mode
            if this.q == 1 && z >= this.tf  % Jump from mode q1 to q2
                this.q = 2;
                disp('Jumping from mode 1 to mode 2.');
            elseif this.q == 2 && z >= (this.tf + this.tvl1)  % Jump from mode q2 to q3
                this.q = 3;
                disp('Jumping from mode 2 to mode 3.');
            end

            % Ensure xplus is returned as a column vector
            xplus = xplus(:);  % Ensure column vector format
        end

        function inC = flowSetIndicator(this, x, t)
            % Extract the current state components
            z = x(this.z_index);  % Timer

            % Define flow set conditions for each mode
            if this.q == 1  % Mode 1: Normal Operation
                inC = (z < this.tf);  % Flow in mode 1 until time reaches tf
            elseif this.q == 2  % Mode 2: Fault Mode
                inC = (z < (this.tf + this.tvl1));  % Flow in mode 2 until time reaches tf + tvl1
            elseif this.q == 3  % Mode 3: Recovery Mode
                inC = 1;  % Always flow in mode 3 or later
            else
                inC = 0;  % Default: no flow if no condition is met
            end
        end

        function inD = jumpSetIndicator(this, x)
            % Extract the timer (z) from the state
            z = x(this.z_index);  

            % Check the conditions for jumping between modes
            if (this.q == 1 && z >= this.tf)  % Eligible to jump from mode q1 to q2
                inD = 1;  % Jump condition is satisfied
            elseif (this.q == 2 && z >= (this.tf + this.tvl1))  % Eligible to jump from mode q2 to q3
                inD = 1;  % Jump condition is satisfied
            else
                inD = 0;  % No jump condition satisfied
            end
        end
    end
end
