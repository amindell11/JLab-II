% Specifications
global V_CC V_T VBE_On VCE_Sat
Av_min = 105; % Minimum required voltage gain
Rin_min = 0.6; % Minimum input resistance (Kohm)
R_L = 10; % Load resistance (Kohm)
beta = 150;
Rout_max = .008;

% Constants
V_T = 0.026; % Thermal voltage (V)
VBE_On  = 0.7; 
V_CC = 15;
VCE_Sat = 0.6; % Collector-emitter saturation voltage (V)

syms IC_2;
gm2 = IC_2/V_T;

%the output resistance is roughly equal to 1/gm2 + (Rout_1 || Rin_2)/(beta+1)

eq0 = 1/gm2 == .75*(Rout_max/2); % allocating half the specified output resistance to 1/gm2, use a margin of .75 for safety
IC_2 = double(solve(eq0, IC_2)); % Solve for I_C2

%the other half of the output resistance is divided equally between the output resistance of the first stage and
% input resistance of the second stage, to allow for maximum power transfer

[R_C, Rout_1, Rin_2] = deal((Rout_max /2) * (beta+1) * 2); 

%for maximum symmetrical swing on the second stage, the supply voltage is
%divided equally between V_CE and V_E:

[VE_2, VCE_2] = deal(V_CC/2);
RE_2 = VE_2 / IC_2; % these voltages determine RE_2
[R3, R4] = thevenin_resisitor(VE_2+VBE_On, Rin_2, V_CC); % Use biasing requirements and input resistance to calculate R3, R4


Av_2 = double(RE_2/((V_T/IC_2)+RE_2))
syms IC_1
gm1 = IC_1/V_T;
rpi1 = beta/gm1;

eq1 = rpi1 == Rin_min; % Rpi1 determines the input resistance
IC_1_Max = double(solve(eq1,IC_1)) % use eq1 to find upper bound of IC_1

eq2 = gm1 * parallel_resistance(R_C, Rin_2)*Av_2 == Av_min; % gain sets lower bound of IC_1
IC_1_Min = double(solve(eq2, IC_1))

IC_1 = IC_1_Min + 0.25*(IC_1_Max-IC_1_Min); % choose a value for IC_1 on the lower end of the range;

[VRC_1,swing] = deal(IC_1*R_C); %KVL to calculate voltage across R_C
VCE_1 = VRC_1 +VCE_Sat; %set VCE to maximize symmetry of output voltage swing
VE_1 = V_CC-VRC_1-VCE_1; %calculate voltage across RE_1
RE_1 = VE_1/IC_1; %calculate RE_1 using ohm's law

% solve for R1, R2 to set biasing voltage while drawing 10X the base
% current through Q1
syms R1 R2
eq3 = VE_1+VBE_On == R1 *  V_CC/ (R1 + R2);
eq4 = V_CC/(R1+R2) == 10*IC_1/beta;
solution = solve([eq3, eq4], [R1, R2]);

R1 = solution.R1;
R2 = solution.R2;

%DESIGN CHECK%

Av_1 = IC_1 * parallel_resistance(R_C, Rin_2) / V_T;
Av = Av_1*Av_2;
Rin = parallel_resistance((beta*V_T/IC_1),R1, R2);
Rout = parallel_resistance(RE_2, (V_T/IC_2 + parallel_resistance(Rin_2, Rout_1)/(beta+1)));

fprintf('\nDesign Results:\n');
fprintf('===============================\n');
fprintf('Q-Point 1            : VCE = %.2f V, IC = %.2f mA\n', VCE_1, IC_1);
fprintf('Q-Point 2            : VCE = %.2f V, IC = %.2f mA\n', VCE_2, IC_2);
fprintf('Output Swing         : %.2f V\n', swing);
fprintf('Voltage Gain         : %.2f V/V\n', Av);
fprintf('Output Resistance    : %.2f Ohms\n', Rout*1e3);
fprintf('Input Resistance     : %.2f Ohms\n', Rin*1e3);

fprintf('Collector Resistance : %.2f Ohms\n', R_C*1e3);
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
function [R1, R2] = thevenin_resisitor(V_th, R_th, V_Total)
    syms R1 R2; % Symbolic variables for voltage divider resistors
    eq0 = V_th == R1 * V_Total / (R1 + R2); % Thevenin voltage
    eq1 = R_th == parallel_resistance(R1, R2); % Thevenin resistance
    solution = solve([eq0, eq1], [R1, R2]);
    R1 = solution.R1;
    R2 = solution.R2;
end