% Script to compute and plot the output swing
% Define ranges for I_C and V_EC
IC_range = linspace(0.1, 15, 10); % Collector current range (0.1 mA to 3 mA)
VEC_range = linspace(0.4, 14, 10); % V_EC range (0.4 V to 12 V)

% Initialize a matrix to store the design values
value = zeros(length(VEC_range), length(IC_range));

% Calculate the swing for each combination of V_EC and I_C
for i = 1:length(VEC_range)
            disp(i)
    for j = 1:length(IC_range)
        [swing, power, stability] = design(VEC_range(i), IC_range(j)); % Call design function
        value(i, j) = compute_design_value(swing, power, stability); % Use local function
    end
end

% Create a 3D surface plot
[X, Y] = meshgrid(IC_range, VEC_range); % Create grid for I_C and V_EC
figure;
surf(X, Y, value);
xlabel('Collector Current (I_C) [A]');
ylabel('Collector-Emitter Voltage (V_EC) [V]');
zlabel('Design Value');
title('Design Value as a Function of I_C and V_EC');
colorbar;

% Local function to compute the design value
function design_value = compute_design_value(swing, P_Consum, stability)
    % Weights for each factor
    w_swing = 0.8;    % Weight for swing
    w_power = 0.3;    % Weight for power consumption
    w_stability = .1; % Weight for stability

    % Normalized swing value
    V_swing = min(1,  (swing) / 5);

    % Normalized power consumption value
    V_power = 1 - min(1, P_Consum / (70));

    % Normalized stability value
    V_stability = min(1, stability / 1000);

    % Composite design value
    design_value = w_swing * V_swing + w_power * V_power + w_stability * V_stability;
end
