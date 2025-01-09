% -------------------------------------------------------------------------
%                             Directories
% ------------------------------------------------------------------------- 
orip               = root_dir;
log_path           = fullfile(orip,'log'); mkdir(log_path)
event_path         = fullfile(orip,'events');  mkdir(event_path)

% -------------------------------------------------------------------------
%                            Task Parameters
% ------------------------------------------------------------------------- 
params                     = struct();
params.simulation          = 0;
params.screen_num          = 1; % Number of screens to use
params.handedness          = 2;

% -------------------------------------------------------------------------
%                              User Inputs
% ------------------------------------------------------------------------- 

% Get user input 
prompt={'Introduza o ID do participante',...
        'Linguagem da tarefa',...
        'Indique o número da sessão (run)'};
dlg_title='Input';
% Participant_id will be MRVxxx (magnetic resonance videos)
data.input = inputdlg(prompt,dlg_title,1,{'MRV','pt','1'});

% Task Language
if strcmpi(data.input{2},'pt')
    lanSuf = '_pt';
elseif strcmpi(data.input{2},'en')
    lanSuf = '_en';
end

% Filenames
logFileName       = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_log'];
eventFileName     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_event'];
eventSequence     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_seq'];

% select sequence to use
if str2double(data.input{3}) == 1
    run = 1;
    generate_sequences;  % Generate new stimuli sequence
    sequence = load('sequences\sequence1.mat');
elseif str2double(data.input{3}) == 2
    run = 2;
    filesForEachSession = 30;
    sequence = load('sequences\sequence2.mat');
else
    warning('Selected sequence does not exist');
end
save(fullfile(sequence_path, data.text.eventSequence), 'sequence')

% save information from chosen sequence in the 'data' structure
data.sequences.files      = sequence.sequenceFiles;


% ------------------------------------------------------------------------%
%                             SETUP SCREEN                                %
% ------------------------------------------------------------------------% 
backgroundColor = 255; % Background color: choose a number from 0 (black) to 255 (white)
textColor = 0; % Text color: choose a number from 0 (black) to 255 (white)
clear screen
Screen('Preference', 'SkipSyncTests', 1); % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
                            % ----------%
                            % 1 SCREEN  %
                            % ----------%
if data.screen_num == 1
whichScreenMin = min(Screen('Screens')); % Get the screen numbers
[screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
[window1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth/2, screenHeight/2]);
                            % ----------%
                            % 2 SCREENS %
                            % ----------%
elseif data.screen_num == 2
whichScreenMax = max(Screen('Screens')); % Get the screen numbers
[window1, rect] = Screen('Openwindow',whichScreenMax,backgroundColor,[],[],2);
end
                            % ------------%
                            % SHOW SCREEN %
                            % ------------%
slack = Screen('GetFlipInterval', window1)/2; %The flip interval is half of the monitor refresh rate; why is it here?
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor); % Fills the screen with the background color
Screen('Flip', window1); % Updates the screen (flip the offscreen buffer to the screen)

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

try
    s = serialport('COM6', 57600);   % The stimbox works at 57600 s/s
    s.Timeout = 0.01;                % Timeout to fetch fMRI trigger
    disp('Serial port communication is set.')
catch
    s = [];
    disp('No serial port communication.')
end

% -------------------------------------------------------------------------
%                         Setup MRI joysticks (two handed)
% -------------------------------------------------------------------------

if data.handedness == 2

% Joystick Information
% -------------------------------------------------------------------------
% Signals for two-handed joystick:
% Right up     - 100
% Right down   - 99
% Left down    - 98
% Left up      - 97
% -------------------------------------------------------------------------

KbName('UnifyKeyNames')                  % Unify key names
hotkey          = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey    = KbName('ESCAPE');      % Key - code for escape key
button1         = 97;                    % Key - code for the first button (Right-bottom)
button2         = 98;                    % Key - code for the second button
button3         = 99;                    % Key - code for the third button
button4         = 100;                   % Key - code for the fourth button

elseif data.handedness == 1

% -------------------------------------------------------------------------
%                    Setup Celeritas joystick (one handed)
% -------------------------------------------------------------------------

% You need to install antimicrox (https://github.com/AntiMicroX/antimicrox/)
% Setup the keyboard keys in the antimicrox app
% Use those keyboard keys (e.g. 1,2,3,4) as representing stimuli code
% You can save the config file as an .amgp and load it in antimicrox

KbName('UnifyKeyNames')                  % Unify key names
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
%                     Image Stimuli - active state
% -------------------------------------------------------------------------
imageFilesActive = dir(fullfile(orip, 'images', 'active','*.jpg')); % Adjust the extension if needed
active_images = cell(numel(imageFilesActive), 1);         % Create a cell array for file paths
for i = 1:numel(imageFilesActive)
    active_images{i} = fullfile(orip,'images', 'active', imageFilesActive(i).name); % Store file paths
end

% -------------------------------------------------------------------------
%                     Image Stimuli - neutral state
% -------------------------------------------------------------------------
imageFilesControl = dir(fullfile(orip,'images',  'control', '*.jpg')); % Adjust the extension if needed
neutral_images = cell(numel(imageFilesControl), 1);         % Create a cell array for file paths
for i = 1:numel(imageFilesControl)
    neutral_images{i} = fullfile(orip, 'images', 'control', imageFilesControl(i).name); % Store file paths
end

% -------------------------------------------------------------------------
%                       Version and Prerequisites
% -------------------------------------------------------------------------
AssertOpenGL;           % gives warning if running in PC with non-OpenGL based PTB
PsychtoolboxVersion;    % Get the Psychtoolbox version
% PerceptualVBLSyncTest % Perform test for synch issues
