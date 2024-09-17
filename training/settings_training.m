% -------------------------------------------------------------------------
%                         Directories
% -------------------------------------------------------------------------
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path           = fullfile(orip,'stimuli');
results_path        = fullfile(orip,'results');
resting_state_path  = fullfile(orip,'resting_state');

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

try
    % s = serialport('COM3', 57600); %The stimbox works at 57600 s/s
    s = serialport('COM6', 57600); %The stimbox works at 57600 s/s
    disp('Serial port communication is set.')
catch
    s = [];
    disp('No serial port communication.')
end

% -------------------------------------------------------------------------
%                         Setup the joysticks
% -------------------------------------------------------------------------

% Create hotkey to activate the experiment
KbName('UnifyKeyNames') % Unify key names
hotkey          = KbName('LeftControl'); % Simulates MRI trigger for TR
terminateKey    = KbName('ESCAPE');      % Key code for escape key
button1           = 97;                  % Key - code for the first button
button2           = 98;                  % Key - code for the second button
button3           = 99;                  % Key - code for the third button
button4           = 100;                 % Key - code for the fourth button

% -------------------------------------------------------------------------
%                              Text Stimuli
% -------------------------------------------------------------------------

cond_text = {'active','neutral'};

textTraining = {
    'Os pássaros cantam melodias ao pôr do sol.'
    'O queijo azul tem um sabor intenso e peculiar.'
    'As folhas dançam com o vento de outono.'
    'O mar sussurra segredos antigos às rochas.'
    'A lua cheia ilumina o caminho na floresta escura.'
    'As estrelas piscam como diamantes no céu noturno.'
    'O aroma do café recém-moído preenche a cozinha.'
    'As abelhas trabalham diligentemente no jardim colorido.'
    'O relógio antigo marca o tempo com precisão.'
    'As nuvens formam padrões fascinantes no horizonte.'
    'A chuva suave nutre as plantas sedentas.'
    'O fogo crepita alegremente na lareira acolhedora.'
    'As montanhas majestosas tocam o céu azul.'
    'O riso das crianças ecoa pelo parque ensolarado.'
    'A neve cobre a paisagem com um manto branco.'
    'O perfume das flores de jasmim enche o ar noturno.'
};

responseOptions = {
    'Completamente Verdadeiro'
    'Maioritariamente Verdadeiro'
    'Parcialmente Verdadeiro'
    'Falso'
};

