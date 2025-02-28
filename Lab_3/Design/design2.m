% Specifications
global V_CC V_T VBE_On
Av_min = 150; % Minimum required voltage gain
Rin_min = 1; % Minimum input resistance (Kohm)
R_L = 10; % Load resistance (Kohm)
V_CE_Sat = 0.6; % Collector-emitter saturation voltage (V)
beta = 150;
Rout_max = .007;

% Constants
V_T = 0.026; % Thermal voltage (V)

%Design
V_CC = 15; % Supply voltage (V)
VCE_1 = 4.5; %V
IC_1 = 5; %mA
VCE_2 = 10;
IC_2 = 8;

% Assumptions
VBE_On = 0.7; % Base-emitter turn-on voltage (V)

% Q-Point Calculation

syms RE_2
eq1 = V_CC - IC_2 * RE_2 - VCE_2 ==0;
RE_2 = double(solve(eq1, RE_2)); % Solve for R_E

syms R1 R2; % Symbolic variables for voltage divider resistors
V_th = R1 * V_CC / (R1 + R2); % Thevenin voltage
R_th = parallel_resistance(R1, R2); % Thevenin resistance

syms RC_1
eq2 = - V_th + IC_2 * RE_2 + (IC_2/beta)*R_th+ VBE_On  == 0;
eq3 = Rout_max >= parallel_resistance(RE_2, (V_T/IC_2) + R_th/(beta+1));
eq4 = Av_min <=  (IC_1/V_T) * parallel_resistance(RC_1, R_th, beta*IC_2/V_T+(beta+1)*RE_2);
eq5 = RC_1>0;

solution = solve([eq2, eq3], [R1, R2, RC_1]);
R3 = solution.R1;
R4 = solution.R2;
RC_1 = solution.RC_1;

disp(double(parallel_resistance(RC_1, R3, R4,beta*IC_2/V_T+(beta+1)*RE_2 )))

syms RE_1
% Symbolic variable for emitter resistance
eq0 = V_CC - IC_1 * RE_1 - VCE_1 - IC_1 * RC_1 == 0;
RE_1 = double(solve(eq0, RE_1)); % Solve for R_E



% Equations for voltage divider design 
eq2 = - V_th + IC_1*R_th/beta + IC_1*RE_1 + VBE_On == 0;
eq3 = R_th == Rin_min;


% Solve for R1 and R2
solution = solve([eq2, eq3], [R1, R2]);
R1 = solution.R1;
R2 = solution.R2;

% Output Swing Calculation
swing = min(IC_1 * RC_1, min(VCE_1 - V_CE_Sat, V_CC - VCE_1));

fprintf('\nDesign Results:\n');
fprintf('===============================\n');
%fprintf('Output Swing         : %.2f V\n', swing);
fprintf('Collector Resistance   : %.2f Ohms\n', RC_1*1e3);
fprintf('Emitter Resistance   : %.2f Ohms\n', RE_1*1e3);
fprintf('Base Divider R1      : %.2f kOhms\n', R1);
fprintf('Base Divider R2      : %.2f kOhms\n', R2);
fprintf('===============================\n');
fprintf('\nStage 2:\n');
fprintf('Emitter Resistance   : %.2f Ohms\n', RE_2*1e3);
fprintf('Base Divider R1      : %.2f kOhms\n', R3);
fprintf('Base Divider R2      : %.2f kOhms\n', R4);

% Helper function to compute parallel resistance
function R_p = parallel_resistance(varargin)
    R_p = 1 / sum(1 ./ [varargin{:}]);
end
