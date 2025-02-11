I_O = 1; %mA
I_REF = 15; %mA
global V_T; % V
V_T = .026;
V_Minus = 0; % V
V_Plus = 10; % V
V_BE1 = 0.7; %V

%Caclulate R_E to set I_REF and I_O;
R_E = V_T*log(I_REF/I_O)/I_O;


R_1 = (V_Plus-V_Minus-V_BE1)/I_REF;

[I_REF,I_O,max_load] = design_check(.062,1.2, V_Minus,V_Plus, V_BE1,0.7);


fprintf('\nDesign Results:\n');
fprintf('===============================\n');
fprintf('Emitter Resistance R_E   : %.2f Ohms\n', R_E*1e3);
fprintf('Widlar Resistance R1     : %.2f Ohms\n', R_1*1e3);

fprintf('\nDesign Check:\n');
fprintf('===============================\n');
fprintf('I_REF                  : %.2f mA\n', I_REF);
fprintf('I_O                    : %.2f mA\n', I_O);
fprintf('max_R_L                : %.2f kOhms\n', max_load);

function [I_O, I_REF,max_load] = design_check(R_E, R_1, V_Minus, V_Plus, V_BE1,V_BSat)
syms I_O_sym
global V_T
I_REF = (V_Plus-V_Minus-V_BE1)/R_1;
eqn1 = R_E == V_T*log(I_REF/I_O_sym)/I_O_sym;
I_O = solve(eqn1, I_O_sym);
max_load = (I_REF*R_1-V_BSat)/I_O;
end