% -------------------------------------------------------------------------
%                             Directories
% ------------------------------------------------------------------------- 
cd('C:\git\JoaoAmaro2001\psychiatry-study');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));
stim_path = fullfile(orip,'stimuli');
results_path = fullfile(orip,'results');
resting_state_path = fullfile(orip,'resting_state');

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
button1         = KbName('1!');          % Key code for response 1
button2         = KbName('2@');          % Key code for response 2
button3         = KbName('3#');          % Key code for response 3
button4         = KbName('4$');          % Key code for response 4

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
%                              Text Stimuli
% -------------------------------------------------------------------------
cond_text = {'active','neutral'};

textActiveStimuli = {
    'Gosto de todo o tipo de jogos e passatempos.'
    'Sou mais sensível à crítica do que era antes.'
    'Ultimamente tenho me sentido muito ansioso(a) e receoso(a).'
    'Choro facilmente.'
    'Tenho medo de perder a minha sanidade mental.'
    'Sinto-me melancólico(a) e deprimido(a).'
    'Não consigo compreender tão bem o que leio como costumava.'
    'Gostaria de pôr termo à minha vida.'
    'De manhã sinto-me particularmente mal.'
    'Já não tenho uma relação próxima com outras pessoas.'
    'Sinto que estou prestes a desmoronar.'
    'Tenho constantemente medo de dizer ou fazer algo errado.'
    'Atualmente estou muito menos interessado(a) na minha vida amorosa do que anteriormente.'
    'Muitas vezes sinto-me simplesmente miserável.'
    'Por mais que tente, não consigo pensar com clareza.'
    'Já não tenho qualquer sentimento.'
};

textNeutralStimuli = {
    'Gosto de construir armários de cozinha.'
    'Gosto de assentar tijolos ou azulejos.'
    'Gostava de desenvolver um medicamento novo.'
    'Gosto de estudar maneiras de reduzir a poluição da água.'
    'Gosto de escrever livros ou peças de teatro.'
    'Gosto de tocar um instrumento musical.'
    'Gosto de ensinar a alguém uma rotina de exercícios.'
    'Gosto de ajudar pessoas com problemas pessoais ou emocionais.'
    'Gosto de comprar e vender ações e obrigações financeiras.'
    'Gosto de gerir uma loja.'
    'Gosto de desenvolver uma folha de cálculo usando software de computador.'
    'Gosto de fazer a revisão de registos ou formulários.'
    'Gosto de reparar eletrodomésticos.'
    'Gosto de criar peixes.'
    'Gosto de realizar experiências químicas.'
    'Gosto de estudar o movimento dos planetas.'
};

responseOptions = {
    'Completamente Verdadeiro'
    'Maioritariamente Verdadeiro'
    'Parcialmente Verdadeiro'
    'Falso'
};

% -------------------------------------------------------------------------
%                       Version and Testing
% -------------------------------------------------------------------------
PsychtoolboxVersion     % Get the Psychtoolbox version
% PerceptualVBLSyncTest % Perform test for synch issues
