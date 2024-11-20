function [Vmult] = pcode_trip_volt(p, x)
    Vt = x(1);  % Terminal voltage from state vector x
    Vmin = Vt;  % Initialize Vmin to the current voltage
    Multiplier = 1;  % Default multiplier is 1
    Timer1 = 0;  % Initialize Timer1 and Timer2
    Timer2 = 0;
    Counter1 = 0;  % Initialize counters
    Counter2 = 0;

    % Timer and voltage trip logic for the first voltage threshold vl1
    if Vt < p.vl1 && Timer1 == 0
        Timer1 = tic;  % Start the timer if voltage drops below vl1
    elseif Vt >= p.vl1 && Timer1 > 0
        Timer1 = 0;  % Reset the timer if voltage recovers above vl1
    end

    % Timer and voltage trip logic for the second voltage threshold vl0
    if Vt < p.vl0 && Timer2 == 0
        Timer2 = tic;  % Start the timer if voltage drops below vl0
    elseif Vt >= p.vl0 && Timer2 > 0
        Timer2 = 0;  % Reset the timer if voltage recovers above vl0
    end

    % Check if Vmin is below vl0 and set it to vl0 if true
    if Vmin <= p.vl0
        Vmin = p.vl0;
    end

    % Define the multiplier based on voltage thresholds and counters
    if Vt <= p.vl0 || Counter2 == 1
        Multiplier = 0;
    elseif Vt <= p.vl1 && Counter1 == 0
        Multiplier = (Vt - p.vl0) / (p.vl1 - p.vl0);
    elseif Vt <= p.vl1 && Counter1 == 1
        Multiplier = ((Vmin - p.vl0) + p.Vrfrac * (Vt - Vmin)) / (p.vl1 - p.vl0);
    elseif Vt >= p.vl1 && Counter1 == 0
        Multiplier = 1;
    else
        Multiplier = p.Vrfrac * ((p.vl1 - Vmin) / (p.vl1 - p.vl0)) + ((Vmin - p.vl0) / (p.vl1 - p.vl0));
    end

    % Update Counter1 and Counter2 based on timers
    if Counter1 == 0 && Timer1 > p.tvl1
        Counter1 = 1;
        Vmin = Vt;  % Store the voltage at the time of counter activation
    end

    if Counter2 == 0 && Timer2 > p.tvl0
        Counter2 = 1;
    end

    % Calculate the final voltage multiplier
    Vmult = Vt * Multiplier;
end
