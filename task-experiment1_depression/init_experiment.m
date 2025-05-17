% -------------------------------------------------------------------------
%                             Directories
% -------------------------------------------------------------------------

% orip = uigetdir('C:\'); % Use the GUI to get to this directory
addpath(genpath(pwd))
computerName = getenv('COMPUTERNAME');
switch computerName
    case 'LAPTOP-N37ECEH3'
        lenovo_pc_setup;
    case 'DESKTOP-UJUVJ70'
        tower_computer_setup;
    case 'JOAO-AMARO'
        joao_personal_pc_setup;
end

% -------------------------------------------------------------------------
%                         check system info
% -------------------------------------------------------------------------

[~, cmdout] = system('systeminfo');
disp(cmdout);
matlabroot
ver
PsychtoolboxVersion

% -------------------------------------------------------------------------
%                     Troubleshooting Psychtoolbox
% -------------------------------------------------------------------------

% root = 'C:\toolbox\Psychtoolbox';
% addpath(genpath(root));
% cd(root);
% SetupPyschtoolbox % -> For troubleshooting

% -------------------------------------------------------------------------
%                            Check Devices
% -------------------------------------------------------------------------

% devices = PsychHID('Devices') % Get a list of all human-interface devices (HID) 
% clear all

% -------------------------------------------------------------------------
%                              TASK BELOW
%
% -------------------------------------------------------------------------
%                         Initiate Training
% -------------------------------------------------------------------------

% training;

% -------------------------------------------------------------------------
%                         Initiate Experiment
% -------------------------------------------------------------------------

% eyes_closed;
% run_main_task;


