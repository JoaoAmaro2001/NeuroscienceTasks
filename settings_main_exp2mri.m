% ------------------------------------------------------------------------%
%                              Helpers                                    %
% ------------------------------------------------------------------------%
setpath_exp2mri; cd(root_dir); data = struct();

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
data.task.stims_per_run        = 30;
data.task.eyes_closed_duration = 1;  % in secs
data.task.eyes_open_duration   = 1;  % in secs
data.task.preparation_duration = 5;  % in secs

% Formatting options
data.format.font_size        = 40;
data.format.font             = 'Arial';
data.format.background_color = [255 255 255]; % rgb
data.format.text_color       = [0 0 0];       % rgb

% Text
data.text.taskname          = 'videorating';
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
% Fot this experiment participant_id will be SRMRI (scenario rating MRI)
data.input = inputdlg(prompt,dlg_title,1,{'SRMRI','pt','1'});

% Task Language
if strcmpi(data.input{2},'pt')
    language_suffix    = '_pt';
    data.task.language = 'portuguese';
elseif strcmpi(data.input{2},'en')
    language_suffix    = '_en';
    data.task.language = 'english';
end

% Filenames
data.output.log_file_name       = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_log'];
data.output.event_file_name     = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_event'];
data.output.event_sequence      = ['sub-',data.input{1},'_task-', data.text.taskname,'_run-',data.input{3},'_seq'];
% Export options
data.output.export_xlsx         = true;
data.output.export_tsv          = true;

% select sequence to use
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

% ------------------------------------------------------------------------%
%                              Screen                                     %
% ------------------------------------------------------------------------%

% Screen preferences
Screen('Preference', 'SkipSyncTests', 0);   
Screen('Preference','VisualDebugLevel', 1); 

% Get the screens
screens        = Screen('Screens');
screen_number  = max(screens);

% Get resolution
if screen_number > 0 % find out if there is more than one screen
    dual = get(0,'MonitorPositions');
    resolution = [0,0,dual(screen_number,3),dual(screen_number,4)];
elseif screen_number == 0 % if not, get the normal screen's resolution
    resolution = get(0,'ScreenSize');
end

% Draw initial screen
[window1, rect] = Screen('Openwindow',screen_number,data.format.background_color); 
slack = Screen('GetFlipInterval', window1)/2;   
W=rect(RectRight);  % screen width
H=rect(RectBottom); % screen height

% Screen parameters
data.screen.output_screen = screen_number; 
data.screen.resolx  = resolution(3);
data.screen.resoly  = resolution(4);
data.screen.centerx = W / 2;                   % x center
data.screen.centery = H / 2;                   % y center
data.screen.resizex = 1; % Factor to resize image in x-axis (1 = 1x smaller)
data.screen.resizey = 1; % Factor to resize image in y-axis (1 = 1x smaller)
data.screen.sizex   = data.screen.resolx/data.screen.resizex; 
data.screen.sizey   = data.screen.resoly/data.screen.resizey;

% ------------------------------------------------------------------------%
%                               Modalities                                %
% ------------------------------------------------------------------------%

% MRI only
data.mri.tr           = 2; % in seconds
data.mri.num_volumes  = data.mri.tr*1;
data.mri.num_slices   = 36;
data.mri.echo_time    = [];
data.mri.flip_angle   = [];
data.mri.pulse_length = [];

% ------------------------------------------------------------------------%
%                       Setting the serial port communication             %
% ------------------------------------------------------------------------%

if ~data.debug 
    % Parameters
    data.port.port_name = 'COM6';
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
AssertOpenGL; % gives warning if running in PC with non-OpenGL based PTB
data.matlab       = matlabRelease;
data.psychtoolbox = PsychtoolboxVersion;
