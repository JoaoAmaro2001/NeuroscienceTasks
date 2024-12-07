% -------------------------------------------------------------------------
%                         Directories
% -------------------------------------------------------------------------
log_path           = fullfile(orip,'log'); mkdir(log_path)
event_path         = fullfile(orip,'events');  mkdir(event_path)

% -------------------------------------------------------------------------
%                             SETUP SCREEN
% ------------------------------------------------------------------------- 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0; % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
% -------------------------------------------------------------------------
%                             1 SCREEN
% % ------------------------------------------------------------------------- 
% whichScreenMin = min(Screen('Screens')); % Get the screen numbers
% [screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
% [window1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth, screenHeight/2]);
% -------------------------------------------------------------------------
%                             2 SCREENS
% ------------------------------------------------------------------------- 
whichScreenMax = max(Screen('Screens')); % Get the screen numbers
[window1, rect] = Screen('Openwindow',whichScreenMax,backgroundColor,[],[],2);
% -------------------------------------------------------------------------
%                             Continue
% ------------------------------------------------------------------------- 
slack = Screen('GetFlipInterval', window1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor); % Fills the screen with the background color
Screen('Flip', window1); % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                            Variables
% -------------------------------------------------------------------------
TR             = 2;  % Repetition time
stimuli_number = 80; % Number of stimuli 
lambda         = 1;  % Poisson parameter 

% -------------------------------------------------------------------------
%                         Setup MRI joysticks (two handed)
% -------------------------------------------------------------------------

if handedness == 2

% Joystick Information
% -------------------------------------------------------------------------
% Signals for two-handed joystick:
% Right up     - 100
% Right down   - 99
% Left down    - 98
% Left up      - 97
% -------------------------------------------------------------------------

KbName('UnifyKeyNames') % Unify key names
hotkey          = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey    = KbName('ESCAPE');      % Key - code for escape key
button1         = 97;                    % Key - code for the first button
button2         = 98;                    % Key - code for the second button
button3         = 99;                    % Key - code for the third button
button4         = 100;                   % Key - code for the fourth button

elseif handedness == 1

% -------------------------------------------------------------------------
%                         Setup Celeritas joystick (one handed)
% -------------------------------------------------------------------------

% You need to install antimicrox (https://github.com/AntiMicroX/antimicrox/)
% Setup the keyboard keys in the antimicrox app
% Use those keyboard keys (e.g. 1,2,3,4) as representing stimuli code
% You can save the config file as an .amgp and load it in antimicrox

KbName('UnifyKeyNames') % Unify key names
hotkey          = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey    = KbName('ESCAPE');      % Key - code for escape key
button1         = KbName('1!');          % Key code for response 1
button2         = KbName('2@');          % Key code for response 2
button3         = KbName('3#');          % Key code for response 3
button4         = KbName('4$');          % Key code for response 4

else
    error('Specify if using a one-handed or two-handed joystick.')
end

% -------------------------------------------------------------------------
%                           Helpers
% -------------------------------------------------------------------------

% Get stimuli to use
load(fullfile(orip,'files','significant_stimuli.mat'))
% Generate a random order of stimuli
sequence = generate_sequences(orip, stim2stay);
% Rename saved sequence file
movefile(fullfile(orip,'sequences','sequence.mat'), fullfile(orip,'sequences',strcat(sub_id,'_sequence.mat')));
% Create the poisson-distributed times for blank and cross
[blank_times, cross_times] = generate_poisson_times(stimuli_number, TR, lambda);

% -------------------------------------------------------------------------
%                       Version and Testing
% -------------------------------------------------------------------------

% PsychtoolboxVersion     % Get the Psychtoolbox version
% PerceptualVBLSyncTest   % Perform test for synch issues
