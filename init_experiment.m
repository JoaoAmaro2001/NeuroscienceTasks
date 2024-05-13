%% Directories
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path = fullfile(orip,'stimuli');
% root = 'C:\toolbox\Psychtoolbox';
% addpath(genpath(root));
% cd(root);
% SetupPyschtoolbox % -> For troubleshooting


%% Prelims
% build_videos_blocks; % get the random trial order (done)
settings_training;
settings_2step;

%% Training
training;

%% Paradigm
eyes_open_cross;
eyes_closed;
run_images_task;


