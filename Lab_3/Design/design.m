% Specifications
function [RC_1, RE_1, RE_2, R1_1, R2_1, R1_2, R2_2] = design()
global V_CC V_T VBE_On
Av_min = 200; % Minimum required voltage gain
Rin_min = 1; % Minimum input resistan b      turation voltage (V)
beta = 150;
Rout_max = .008;
V_CE_Sat = 0.6;

% Constants
V_T = 0.026; % Thermal voltage (V)

%Design
V_CC = 15; % Supply voltage (V)
VCE_1 = 4.5; %V
IC_1 = 5; %mA
VCE_2 = 10;
IC_2 = 5;

% Assumptions
VBE_On = 0.7; % Base-emitter turn-on voltage (V)

% Q-Point Calculation
RC_1 = beta*Rout_max

syms RE_1
% Symbolic variable for emitter resistance
eq0 = V_CC - IC_1*((beta+1)/beta) * RE_1 - VCE_1 - IC_1 * RC_1 == 0;
RE_1 = double(solve(eq0, RE_1)); % Solve for R_E

syms R1 R2; % Symbolic variables for voltage divider resistors
V_th = R1 * V_CC / (R1 + R2); % Thevenin voltage
R_th = parallel_resistance(R1, R2); % Thevenin resistance

% Equations for voltage divider design
eq2 = - V_th + IC_1*RE_1 + VBE_On == 0;
eq3 = parallel_resistance(R_th, beta*V_T/IC_1) >= Rin_min;

% Solve for R1 and R2
solution = solve([eq2, eq3], [R1, R2]);
R1_1 = solution.R1;
R2_1 = solution.R2;

syms RE_2
eq1 = V_CC - IC_2 * RE_2 - VCE_2 ==0;
RE_2 = double(solve(eq1, RE_2)); % Solve for R_E







% Equations for voltage divider design
eq2 = - V_th + IC_2*R_th/beta + IC_2*RE_2 + VBE_On== 0;


eq3 = Rout_max == parallel_resistance(RE_2,(V_T/IC_2)+parallel_resistance(R_th, RC_1)/(beta+1));

solution = solve([eq2, eq3], [R1, R2]);
R1_2 = solution.R1;
R2_2 = solution.R2;

% Output Swing Calculation
swing = min(IC_1 * RC_1, min(VCE_1 - V_CE_Sat, V_CC - VCE_1));

fprintf('\nDesign Results:\n');
fprintf('===============================\n');
%fprintf('Output Swing         : %.2f V\n', swing);
fprintf('Collector Resistance   : %.2f Ohms\n', RC_1*1e3);
fprintf('Emitter Resistance   : %.2f Ohms\n', RE_1*1e3);
fprintf('Base Divider R1      : %.2f kOhms\n', R1_1);
fprintf('Base Divider R2      : %.2f kOhms\n', R2_1);
fprintf('===============================\n');
fprintf('\nStage 2:\n');
fprintf('Emitter Resistance   : %.2f Ohms\n', RE_2*1e3);
fprintf('Base Divider R1      : %.2f kOhms\n', R1_2);
fprintf('Base Divider R2      : %.2f kOhms\n', R2_2);

end

% Helper function to compute parallel resistance
function R_p = parallel_resistance(varargin)
    R_p = 1 / sum(1 ./ [varargin{:}]);
end
