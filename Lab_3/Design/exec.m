[RC_1, RE_1, RE_2, R1_1, R2_1, R1_2, R2_2] = design();
% Display the values in a structured format
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