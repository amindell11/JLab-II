function Req = parallel_resistance(varargin)
    % parallel_resistance calculates the equivalent resistance of any number of parallel resistors
    %
    % Inputs:
    %   varargin - A variable number of inputs representing resistances (in Ohms)
    %              Pass resistances as separate arguments or in an array.
    %
    % Output:
    %   Req - Equivalent parallel resistance (in Ohms)
    
    % Convert input arguments to an array if they are passed individually
    if length(varargin) == 1 && isvector(varargin{1})
        resistances = varargin{1};
    else
        resistances = [varargin{:}];
    end
    
    % Check for special cases
    if any(resistances == 0)
        Req = 0; % If any resistance is 0, the total parallel resistance is 0
        return;
    elseif isempty(resistances)
        error('No resistances provided. Please provide at least one resistance value.');
    end
    
    % Calculate the reciprocal of the equivalent resistance
    reciprocal_sum = sum(1 ./ resistances);
    
    % Calculate the equivalent resistance
    Req = 1 / reciprocal_sum;
end
