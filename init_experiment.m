% -------------------------------------------------------------------------
%                             Directories
% -------------------------------------------------------------------------

% orip = uigetdir('C:\'); % Use the GUI
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd;
addpath(genpath(orip));
stim_path = fullfile(orip,'stimuli');
results_path = fullfile(orip,'results');

% -------------------------------------------------------------------------
%                           Troubleshooting
% -------------------------------------------------------------------------

% root = 'C:\toolbox\Psychtoolbox';
% addpath(genpath(root));
% cd(root);
% SetupPyschtoolbox % -> For troubleshooting

% -------------------------------------------------------------------------
%                            Check Devices
% -------------------------------------------------------------------------

% devices = PsychHID('Devices'); % Get a list of all human-interface devices (HID) 

% -------------------------------------------------------------------------
%                         Initiate Experiment
% -------------------------------------------------------------------------

eyes_closed;
run_images_task;


