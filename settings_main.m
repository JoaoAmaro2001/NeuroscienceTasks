% -------------------------------------------------------------------------
%                         Directories
% -------------------------------------------------------------------------
log_path           = fullfile(orip,'log'); mkdir(log_path)
event_path         = fullfile(orip,'events');  mkdir(event_path)

% -------------------------------------------------------------------------
%                         Screen Setup
% -------------------------------------------------------------------------
backgroundColor = 255;                          % Background color: choose a number from 0 (black) to 255 (white)
textColor       = 0;                            % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1);       % Skip synch tests only when testing
Screen('Preference','VisualDebugLevel', 1);     % Minimum amount of diagnostic output
whichScreen = max(Screen('Screens'));           % Get the screen numbers
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2); % Use with 2 screens
slack = Screen('GetFlipInterval', window1)/2;   % The flip interval is half of the monitor refresh rate; why is it here?
W = rect(RectRight);                            % screen width
H = rect(RectBottom);                           % screen height
Screen('FillRect',window1, backgroundColor);    % Fills the screen with the background color
Screen('Flip', window1);                        % Updates the screen (flip the offscreen buffer to the screen)

% -------------------------------------------------------------------------
%                       Setting the serial communication  
% -------------------------------------------------------------------------
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

% -------------------------------------------------------------------------
TR             = 2;  % Repetition time
stimuli_number = 80; % Number of stimuli 
lambda         = 1;  % Poisson parameter
% -------------------------------------------------------------------------

try
    % s = serialport('COM3', 57600); % The stimbox works at 57600 s/s
    s = serialport('COM6', 57600);   % The stimbox works at 57600 s/s
    s.Timeout = TR;                  % Timeout to fetch real TR signal
    disp('Serial port communication is set.')
catch
    s = [];
    disp('No serial port communication.')
end

% -------------------------------------------------------------------------
%                         Settings on StimBox
% -------------------------------------------------------------------------
% Trigger on slice     =   Each
% Trigger on volume    =   1
% TR                   =   2000 ms
% Volumes              =   256 -> dummies do not send (1st tr trigger is tr nº0)
% Slices               =   36
% Pulse                =   50 ms
% 1º start laptop; 2º start session in syncbox; 3º start mri machine

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
% Create the poisson-distributed times for blank and cross
[blank_times, cross_times] = generate_poisson_times(stimuli_number, TR, lambda);

% -------------------------------------------------------------------------
%                       Version and Testing
% -------------------------------------------------------------------------

% PsychtoolboxVersion     % Get the Psychtoolbox version
% PerceptualVBLSyncTest   % Perform test for synch issues
