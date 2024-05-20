clear, clc, close all

% Directories (Lenovo)
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path = fullfile(orip,'stimuli');
results_path = fullfile(orip,'results');
resting_state_path = fullfile(orip,'resting_state');

% Create hotkey to activate the experiment
KbName('UnifyKeyNames') % Unify key names
hotkey = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey = KbName('ESCAPE'); % Key code for escape key

TR = 2; % one cycle = 2 seconds

% Screen setup 

backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0; % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
% -------------------------------------------------------------------------
%                             1 SCREEN
% ------------------------------------------------------------------------- 
whichScreenMin = min(Screen('Screens')); % Get the screen numbers
[screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
[window1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth, screenHeight/2]);
% -------------------------------------------------------------------------
%                             2 SCREENS
% ------------------------------------------------------------------------- 
% whichScreenMax = max(Screen('Screens')); % Get the screen numbers
% [window1, rect] = Screen('Openwindow',whichScreenMax,backgroundColor,[],[],2);
% -------------------------------------------------------------------------
%                             Continue
% ------------------------------------------------------------------------- 
slack = Screen('GetFlipInterval', window1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor); % Fills the screen with the background color
Screen('Flip', window1); % Updates the screen (flip the offscreen buffer to the screen)


ImageDuration=TR*4; % Total duration of the image on the screen = 8 seconds
breakAfterTrials = 100000;
imageFormat = 'png';
% How long to pause in between trials (if 0, the experiment will wait for
% the subject to press a key before every trial)
timeBetweenTrials = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting the serial communication

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % Information

% Parameters
% -------
% num_volumes
%     Number of volumes
% num_slices
%     Number of slices in each volume
% trigger_slice
%     Slice number to trigger on
% trigger_volume
%     How often to trigger on a volume. 
% pulse_length
%     Pulse length in ms. Only needed in simulation mode.
% TR_time
%     TR time in ms. Only needed in simulation mode.
% optional_trigger_slice
%     0 for triggering on the slice typed above. 1 for triggering on each slice. 2 for triggering on random slice. (1 and 2 override above settings)
% optional_trigger_volume
%     0 for triggering on each volume typed above. 1 for triggering on each volume. 2 for triggering on random volume. (1 and 2 override above settings)
% simulation
%     False for synchronization mode. True for simulation mode.

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % Serial setup 

% Trigger on slice: 1
% Trigger on volume: Each
% TR=2000
% Volumes=256
% Slices=35
% Pulse=50ms
% start laptop 1º, dps ent start na syncbox

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% Set up stimuli lists and results file -> IMAGES

% Get the image files for the experiment
imageFolder1 = fullfile(stim_path,'active_stimuli');
imageFolder2 = fullfile(stim_path,'neutral_stimuli');
imageList_act = dir(fullfile(imageFolder1,['*.' imageFormat]));
imageList_neu = dir(fullfile(imageFolder2,['*.' imageFormat]));

% Get Score Images
imageFolder_score = fullfile(stim_path,'stars');
imgList_score = dir(fullfile(imageFolder_score,['*.' 'png']));
imgList_score = {imgList_score(:).name}; % 0 - 5 and 6th image is the start

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

PsychtoolboxVersion % Get the Psychtoolbox version
start_exp = GetSecs; % Get time

