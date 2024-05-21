clear, clc, close all

% Directories (Lenovo)
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path           = fullfile(orip,'stimuli');
results_path        = fullfile(orip,'results');
resting_state_path  = fullfile(orip,'resting_state');

% Screen setup 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0; % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
whichScreen = max(Screen('Screens')); % Get the screen numbers
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2); % Use with 2 screens
slack = Screen('GetFlipInterval', window1)/2; % The flip interval is half of the monitor refresh rate; why is it here?
W = rect(RectRight); % screen width
H = rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor); % Fills the screen with the background color
Screen('Flip', window1); % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                         Setup the joysticks
% -------------------------------------------------------------------------

% Create hotkey to activate the experiment
KbName('UnifyKeyNames') % Unify key names
hotkey          = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey    = KbName('ESCAPE');      % Key code for escape key
resp1           = KbName('1!');          % Key code for response 1
resp2           = KbName('2@');          % Key code for response 2
resp3           = KbName('3#');          % Key code for response 3
resp4           = KbName('4$');          % Key code for response 4

%% Set up stimuli lists and results file -> IMAGES

% Get the image files for the experiment
imageFormat = 'png';
imageFolder1 = fullfile(stim_path,'active_stimuli');
imageFolder2 = fullfile(stim_path,'neutral_stimuli');
imageList_act = dir(fullfile(imageFolder1,['*.' imageFormat]));
imageList_neu = dir(fullfile(imageFolder2,['*.' imageFormat]));

% % Get Score Images
% imageFolder_score = fullfile(stim_path,'stars');
% imgList_score = dir(fullfile(imageFolder_score,['*.' 'png']));
% imgList_score = {imgList_score(:).name}; % 0 - 5 and 6th image is the start


% Generate text stimuli and response options for Psychtoolbox

textTraining = {
    "Gosto de todo o tipo de jogos e passatempos."
    "Sou mais sensível à crítica do que era antes."
    "Ultimamente tenho me sentido muito ansioso(a) e receoso(a)."
    "Choro facilmente."
    "Tenho medo de perder a minha sanidade mental."
    "Sinto-me melancólico(a) e deprimido(a)."
    "Não consigo compreender tão bem o que leio como costumava."
    "Gostaria de pôr termo à minha vida."
    "De manhã sinto-me particularmente mal."
    "Já não tenho uma relação próxima com outras pessoas."
    "Sinto que estou prestes a desmoronar."
    "Tenho constantemente medo de dizer ou fazer algo errado."
    "Atualmente estou muito menos interessado(a) na minha vida amorosa do que anteriormente."
    "Muitas vezes sinto-me simplesmente miserável."
    "Por mais que tente, não consigo pensar com clareza."
    "Já não tenho qualquer sentimento."
};

responseOptions = {
    "Completamente Verdadeiro"
    "Maioritariamente Verdadeiro"
    "Parcialmente Verdadeiro"
    "Falso"
};

