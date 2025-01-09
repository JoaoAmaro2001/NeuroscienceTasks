% Init matlab session in WorkRepo dir
addpath(genpath(pwd))
computerName = getenv('COMPUTERNAME');
switch computerName
% -------------------------------------------------------------------------
%                       Personal Computers
% -------------------------------------------------------------------------
    case 'JOAO-AMARO'
        run(fullfile(pwd,'setup','joao_personal_pc_setup.m'));
% -------------------------------------------------------------------------
%                       University of Lisbon
% -------------------------------------------------------------------------
    case 'DESKTOP-UJUVJ70' % Acquisition Tower
        run(fullfile(pwd,'setup','tower_computer_setup.m'));
% -------------------------------------------------------------------------
%                          Spike Urban
% -------------------------------------------------------------------------      
    case 'LAPTOP-N37ECEH3' % Lenovo portable computer
        run(fullfile(pwd,'setup','lenovo_pc_setup.m'));
end