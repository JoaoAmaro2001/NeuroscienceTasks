%% Directories
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path = fullfile(orip,'stimuli');
results_path = fullfile(orip,'results');
% root = 'C:\toolbox\Psychtoolbox';
% addpath(genpath(root));
% cd(root);
% SetupPyschtoolbox % -> For troubleshooting


%% Prelims
settings_2step;

%% Training
settings_training;
training;

%% Paradigm
eyes_closed;
run_images_task;


