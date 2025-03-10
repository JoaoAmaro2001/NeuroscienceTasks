% ------------------------------------------------------------------------%
%                              Helpers                                    %
% ------------------------------------------------------------------------%
setpath_exp1; cd(root_dir); data = struct();

% ------------------------------------------------------------------------%
%                            Directories                                  %
% ------------------------------------------------------------------------%
data.dir.allstim_path  = fullfile(root_dir, 'supp', 'allStimuli');
data.dir.stim_path     = fullfile(root_dir, 'supp', 'stimuli');
data.dir.logs_path     = fullfile(root_dir, 'supp', 'logfiles');
data.dir.event_path    = fullfile(root_dir, 'supp', 'events');
data.dir.sequence_path = fullfile(root_dir, 'supp', 'sequences');
data.dir.data_path     = fullfile(root_dir, 'data');

% ------------------------------------------------------------------------%
%                              Task                                       %
% ------------------------------------------------------------------------%

% Debugging mode
data.debug                     = true;
% Task parameters
data.task.handedness           = 2;
data.task.number_states        = 6;
data.task.number_ses           = 1;
data.task.number_run           = 2;
data.task.number_stims         = 160;
data.task.stims_per_run        = data.task.number_stims/data.task.number_run;
data.task.duration_structural  = 180; % in secs
data.task.duration_eyes_closed = 180; % in secs
data.task.duration_eyes_open   = 180; % in secs
data.task.duration_preparation = 5;   % in secs
data.task.duration_fixation    = 2;   % in secs
data.task.duration_image       = 4;   % in secs
data.task.duration_blank       = 2;   % in secs
data.task.duration_rating      = 4;   % in secs
data.task.duration_trial      = data.task.duration_blank + ...
                                data.task.duration_fixation + ...
                                data.task.duration_image; % in secs
% Formatting options
data.format.font_size        = 80;
data.format.font             = 'Arial';
data.format.background_color = [255 255 255]; % white (rgb)
data.format.text_color       = [0 0 0];       % black (rgb)

% Text (portuguese and english)
data.text.taskname          = 'imagerating';
data.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
data.text.getready_pt       = 'A experiência começará em breve... Mantenha o olhar fixo na cruz';
data.text.starting_en       = 'Starting in';
data.text.starting_pt       = 'Começa em';
data.text.baselineClosed_en = 'Baseline with eyes closed will start shortly';
data.text.baselineClosed_pt = 'O período de relaxamento com olhos fechados começará em breve';
data.text.baselineOpen_en   = 'Baseline with eyes open will start shortly';
data.text.baselineOpen_pt   = 'O período de relaxamento com olhos abertos começará em breve';

% Stimuli
data.stim.image_size        = [];

% ------------------------------------------------------------------------%
%                            User input                                   %
% ------------------------------------------------------------------------%

% get user input for usage or not of eyelink
prompt={'Introduza o ID do participante',...
    'Linguagem da tarefa','Indique o número da sessão (run)'};
dlg_title='Input';
% Fot this experiment participant_id will be SRMRI (Scenario Rating Mri)
data.input = inputdlg(prompt,dlg_title,1,{'BAP','pt','1'});

% Task Language
if strcmpi(data.input{2},'pt')
    data.task.language_suffix    = '_pt';
    data.task.language           = 'portuguese';
elseif strcmpi(data.input{2},'en')
    data.task.language_suffix    = '_en';
    data.task.language           = 'english';
end

% Filenames
data.output.data_file_name      = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_data'];
data.output.log_file_name       = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_log'];
data.output.event_file_name     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_events'];
data.output.event_sequence      = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_seq'];
% Export options
data.output.export_xlsx         = true;
data.output.export_tsv          = true;

% Ask for more user input (you can add more)
prompt    = {'Vision corrected?',... % "spectacles", "lenses", "none"
            };
dlg_title ='Subject specifics';
answers   = inputdlg(prompt,dlg_title,1,{'none'});

% ------------------------------------------------------------------------%
%                              Screen                                     %
% ------------------------------------------------------------------------%

% Get the screens. See details below (from PTB):
% Screen 0 corresponds to the full Windows desktop area. Useful for stereo presentations in stereomode=4 ...
% Screen 1 corresponds to the display area of the monitor with the Windows-internal name \\.\DISPLAY1 ...
% Screen 2 corresponds to the display area of the monitor with the Windows-internal name \\.\DISPLAY2 ...
% And so on...
screens        = Screen('Screens');
screen_number  = max(screens);
% screen_number  = 1;

% Draw initial screen
[window1, rect] = Screen('Openwindow',screen_number,data.format.background_color); 

% Get resolution of screen
resolution = Screen('Rect', screen_number);  

% Screen parameters
data.screen.output_screen = screen_number; 
data.screen.resolx  = resolution(3);
data.screen.resoly  = resolution(4);
data.screen.pixelx  = rect(RectRight);
data.screen.pixely  = rect(RectBottom);
data.screen.centerx = data.screen.pixelx / 2;  % x center
data.screen.centery = data.screen.pixely / 2;  % y center
data.screen.resizex = 2; % Factor to resize image in x-axis (1 = 1x bigger)
data.screen.resizey = 2; % Factor to resize image in y-axis (1 = 1x bigger)
data.screen.sizex   = data.screen.pixelx/data.screen.resizex; 
data.screen.sizey   = data.screen.pixely/data.screen.resizey;

% ------------------------------------------------------------------------%
%                               Debug mode                                %
% ------------------------------------------------------------------------%

if data.debug
    data.task.handedness           = 1;    
    % Screen preferences
    Screen('Preference', 'Verbosity', 1);
    Screen('Preference', 'SkipSyncTests', 1);   
    Screen('Preference', 'VisualDebugLevel', 1); 
    % Know you are in debug mode
    print_debug();
else
    % Screen preferences
    Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests', 0);   
    Screen('Preference', 'VisualDebugLevel', 0); 
end

% ------------------------------------------------------------------------%
%                               Modalities                                %
% ------------------------------------------------------------------------%

% MRI only
data.mri.tr           = 2;   % in seconds
data.mri.tr_trigger   = 115; % code for the trigger
data.mri.num_volumes  = data.task.duration_trial/data.mri.tr;
data.mri.num_slices   = 36;
data.mri.echo_time    = [];
data.mri.flip_angle   = [];
data.mri.pulse_length = [];

% EEG only
data.eeg.sf           = 500; % in Hz
data.eeg.events_types = {'DIN1',...
                         'DIN2',...
                         'DIN3',...
                         'DIN4',...
                         'DIN5',...
                         'DIN6',...
                        };

% ------------------------------------------------------------------------%
%                           Stimuli Sequences                             %
% ------------------------------------------------------------------------%

% Create stimuli sequences
if str2double(data.input{3}) == 1
    data.task.run = 1;
    createStimulusSequence(root_dir,...
        'FilesPerRun',data.task.stims_per_run, 'NumRuns', data.task.number_run)
    sequence1     = load('sequences\sequence1.mat');
    % save information from chosen sequence in the 'data' structure
    data.stim.files = sequence1.sequenceFiles1;
    save(fullfile(data.dir.sequence_path, data.output.event_sequence), 'sequence1')
elseif str2double(data.input{3}) == 2
    data.task.run = 2;
    sequence2     = load('sequences\sequence2.mat');
    % save information from chosen sequence in the 'data' structure
    data.stim.files = sequence2.sequenceFiles2;
    save(fullfile(data.dir.sequence_path, data.output.event_sequence), 'sequence2')
else
    warning('Selected sequence does not exist');
end

% Create the poisson-distributed times for blank and cross times
data.sequence.lambda       = 1; % Poisson parameter
[blank_times, cross_times] = generate_poisson_times(data.task.stims_per_run, data.mri.tr, data.sequence.lambda);
data.sequence.blank_times  = blank_times; clear blank_times;
data.sequence.cross_times  = cross_times; clear cross_times;

% ------------------------------------------------------------------------%
%                      Communication and Network                          %
% ------------------------------------------------------------------------%

% Serial port comm
if ~data.debug 
    % Parameters
    data.port.port_name = 'COM5';
    data.port.baudrate  = 57600;  % stimbox
    data.port.timeout   = 0.01;   % Timeout to fetch real TR signal
    % Connect with port
    try
        s         = serialport(data.port.port_name, data.port.baudrate); 
        s.Timeout = data.port.timeout;
        disp('Serial port communication is set.')
    catch
        s = [];
        disp('No serial port communication.')
    end
end

% Network
data.network.ns_ipaddress = '10.10.10.32';
% Communicate with NS software

% ------------------------------------------------------------------------%
%                               Controls                                  %
% ------------------------------------------------------------------------%

% initialise system for key query
KbName('UnifyKeyNames')
keyDELETE = KbName('delete'); 
keySPACE  = KbName('space');
keyESCAPE = KbName('escape');
keyCTRL   = KbName('LeftControl'); 

if data.task.handedness == 2

    % Joystick Information
    % ---------------------------------------------------------------------
    % Signals for two-handed joystick:
    % Right up     - 100
    % Right down   - 99
    % Left down    - 98
    % Left up      - 97
    % ---------------------------------------------------------------------
    
    button1         = 97;  % Key - code for the first button
    button2         = 98;  % Key - code for the second button
    button3         = 99;  % Key - code for the third button
    button4         = 100; % Key - code for the fourth button

elseif data.task.handedness == 1

    % -------------------------------------------------------------------------
    %                       Setup Celeritas joystick (one handed)
    % -------------------------------------------------------------------------
    
    % You need to install antimicrox (https://github.com/AntiMicroX/antimicrox/)
    % Setup the keyboard keys in the antimicrox app
    % Use those keyboard keys (e.g. 1,2,3,4) as representing stimuli code
    % You can save the config file as an .amgp and load it in antimicrox
    
    terminateKey    = KbName('ESCAPE');      % Key - code for escape key
    button1         = KbName('1!');          % Key code for response 1
    button2         = KbName('2@');          % Key code for response 2
    button3         = KbName('3#');          % Key code for response 3
    button4         = KbName('4$');          % Key code for response 4

else
    error('Specify if using a one-handed or two-handed joystick.')
end

% ------------------------------------------------------------------------%
%                               Software                                  %
% ------------------------------------------------------------------------%
data.matlab       = matlabRelease;
data.psychtoolbox = PsychtoolboxVersion;

% Further debugging
AssertOpenGL; % gives warning if running in PC with non-OpenGL based PTB
% Screen('OpenWindow', 0); % Open a test window

% ------------------------------------------------------------------------%
%                                BIDS                                     %
% ------------------------------------------------------------------------%

% Assign
data.bids.VisionCorrection     = answers{1}; 
data.bids.StimulusPresentation = struct(...
    'OperatingSystem', machine.os, ...        % OS from setup script
    'ScreenDistance', 60, ...                 % Distance in cm
    'ScreenRefreshRate', Screen('NominalFrameRate', screen_number), ...
    'ScreenResolution', [data.screen.resolx, data.screen.resoly], ...
    'ScreenSize', [machine.monitor.real_screen_size_hor, machine.monitor.real_screen_size_hor]/100, ... % in meters
    'SoftwareName', 'Psychtoolbox', ...
    'SoftwareRRID', 'SCR_002881', ...         % RRID for Psychtoolbox
    'SoftwareVersion', data.psychtoolbox, ... % Already stored in data.psychtoolbox
    'Code', 'n/a', ...                        % Replace with actual DOI if available
    'HeadStabilization', 'none' ...
);

% Additional useful BIDS metadata
data.bids.TaskName        = data.text.taskname;
data.bids.TaskDescription = 'Image rating task';
data.bids.Instructions    = ['Task instructions in ' data.task.language];
data.bids.CogAtlasID      = 'http://www.cognitiveatlas.org/task/id/trm_XXXXXXXX'; % Replace with actual ID if available

% Hardware details
data.bids.DeviceSerialNumber = 'Unknown'; % Add if available
data.bids.ResponseDevice     = 'Joystick';

% ------------------------------------------------------------------------%
%                               Functions                                 %
% ------------------------------------------------------------------------%

function print_debug()
    disp(' ');
    disp('/***********************************************************************/');
    disp('/*                                                                     */');
    disp('/*  ########  ######## ########  ##     ##  ######                     */');
    disp('/*  ##     ## ##       ##     ## ##     ## ##    ##                    */');
    disp('/*  ##     ## ##       ##     ## ##     ## ##                          */');
    disp('/*  ##     ## ######   ########  ##     ## ##   ####                   */');
    disp('/*  ##     ## ##       ##     ## ##     ## ##    ##                    */');
    disp('/*  ##     ## ##       ##     ## ##     ## ##    ##                    */');
    disp('/*  ########  ######## ########   #######   ######                     */');
    disp('/*                                                                     */');
    disp('/*  ##     ##  #######  ########  ########                             */');
    disp('/*  ###   ### ##     ## ##     ## ##                                   */');
    disp('/*  #### #### ##     ## ##     ## ##                                   */');
    disp('/*  ## ### ## ##     ## ##     ## ######                               */');
    disp('/*  ##     ## ##     ## ##     ## ##                                   */');
    disp('/*  ##     ## ##     ## ##     ## ##                                   */');
    disp('/*  ##     ##  #######  ########  ########                             */');
    disp('/*                                                                     */');
    disp('/***********************************************************************/');
    disp(' ');    
end