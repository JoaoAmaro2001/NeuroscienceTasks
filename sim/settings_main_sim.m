% -------------------------------------------------------------------------
%                             Directories
% ------------------------------------------------------------------------- 
orip               = root_dir;
log_path           = fullfile(orip,'log'); mkdir(log_path)
event_path         = fullfile(orip,'events'); mkdir(event_path)
allstim_path       = fullfile(orip, 'supp', 'allStimuli');
stim_path          = fullfile(orip, 'supp', 'stimuli');
sequence_path      = fullfile(orip, 'supp', 'sequences');

% -------------------------------------------------------------------------
%                            Task Parameters
% ------------------------------------------------------------------------- 
data                        = struct();
data.simulation             = 1;
data.screen_num             = 2; % Number of screens to use
data.handedness             = 2;
data.text.taskname          = 'videorating';
data.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
data.text.getready_pt       = 'A experiência começará em breve... Mantenha o olhar fixo na cruz';
data.text.starting_en       = 'Starting in';
data.text.starting_pt       = 'Começa em';
data.rgb.red                = [255 0 0];
data.rgb.green              = [0 255 0];

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
save(fullfile(sequence_path, eventSequence), 'sequence')

% save information from chosen sequence in the 'data' structure
data.sequences.files      = sequence.sequenceFiles;


% ------------------------------------------------------------------------%
%                             SETUP SCREEN                                %
% ------------------------------------------------------------------------% 
clear screen
Screen('Preference', 'SkipSyncTests', 1);   % Is this safe?
Screen('Preference','VisualDebugLevel', 0); % Minimum amount of diagnostic output
backgroundColor = 255;                      % Background color
textColor       = 0;                        % Text color

                            % ----------%
                            % 1 SCREEN  %
                            % ----------%
if data.screen_num == 1
whichScreenMin = min(Screen('Screens')); % Get the screen numbers
resolution = get(0,'ScreenSize'); % Get resolution
[screenWidth, screenHeight] = Screen('WindowSize', whichScreenMin); % Get the screen size
[window_1, rect] = Screen('OpenWindow', whichScreenMin, backgroundColor, [0 0 screenWidth/2, screenHeight/2]);
                            % ----------%
                            % 2 SCREENS %
                            % ----------%
elseif data.screen_num == 2
    secondaryScreen = max(Screen('Screens')); % Use the secondary screen
    [screenWidth, screenHeight] = Screen('WindowSize', secondaryScreen); % Get screen dimensions
    [window_1, rect] = Screen('OpenWindow', secondaryScreen, backgroundColor);
    resolution = [0, 0, screenWidth, screenHeight];
end

                            % ------------%
                            % SHOW SCREEN %
                            % ------------%
data.format.resolx = resolution(3);
data.format.resoly = resolution(4);

% Calculate screen center and other parameters
slack = Screen('GetFlipInterval', window_1) / 2; % Half refresh interval
W = rect(3); % Screen width
H = rect(4); % Screen height
centerX = W / 2; % X center
centerY = H / 2; % Y center

% Fill screen with background color and update display
Screen('FillRect', window_1, backgroundColor);
Screen('Flip', window_1);


% -------------------------------------------------------------------------
%                    Setup Keyboard Control
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

% -------------------------------------------------------------------------
%                       Version and Prerequisites
% -------------------------------------------------------------------------
AssertOpenGL;           % gives warning if running in PC with non-OpenGL based PTB
PsychtoolboxVersion;    % Get the Psychtoolbox version
% PerceptualVBLSyncTest % Perform test for synch issues
