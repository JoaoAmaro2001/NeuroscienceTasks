%% Directories
cd('C:\Users\SpikeUrban\Documents\JoaoRepo\WorkRepo\WorkRepo');
orip = pwd; % The root directory for scripts and images
% root = 'C:\toolbox\Psychtoolbox';
% addpath(genpath(root));
% cd(root);
% SetupPyschtoolbox % -> For troubleshooting
main_path = fullfile(orip,'Psychiatry_fMRI');
addpath(genpath(main_path));
stim_path = fullfile(main_path,'stimuli');

%% Prelims
% build_videos_blocks; % get the random trial order (done)
cd(fullfile(orip,'E'));
settings_training;
settings_2step;

%% Training
training;

%% Paradigm
eyes_open_cross;
eyes_closed;
run_images_task;


