% Script containing the settings for the training experiment

% clear all
% close all

TR=2;
% trialTimeout=2*TR*0.95;

%% Keyboard and serial mode opt 0='off' 1='on'
kb_opt=0; 
s_opt=1;

%% Screen setup
% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 255;
% Text color: choose a number from 0 (black) to 255 (white)
textColor = 0;
clear screen
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
whichScreen = max(Screen('Screens'));
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen('FillRect',window1, backgroundColor);
Screen('Flip', window1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Keyboard settings

% Path to text file input (optional; for no text input set to 'none')
% textFile = 'searchPrompt.txt';
textFile = 'none';

% Response keys (optional; for no subject response use empty list)
% responseKeys = {'y','n', '0)', '1!', '2@', '3#', '4$', '5%', '6^', '7&', '8*','9(','LeftArrow','RightArrow','UpArrow','DownArrow'};
%responseKeys = {};
% left - 37
% right - 39
% up - 38
% down - 40

% % Keyboard setup
% KbName('UnifyKeyNames');
% KbCheckList = [KbName('space'),KbName('ESCAPE'), KbName('0)'), KbName('1!'), KbName('2@'), KbName('3#'), KbName('4$'),  KbName('5%'),  KbName('6^'),  KbName('7&'),  KbName('8*'),  KbName('9('), KbName('LeftArrow'),KbName('RightArrow'),KbName('UpArrow'),KbName('DownArrow')];
% for i = 1:length(responseKeys)
%     KbCheckList = [KbName(responseKeys{i}),KbCheckList];
% end
% RestrictKeysForKbCheck(KbCheckList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Time Trial settings 
% How long to the subject watches the image
ImageDuration=TR;

% Number of trials to show before a break (for no breaks, choose a number
% greater than the number of trials in your experiment)
breakAfterTrials = 100000;

% Image format of the image files in this experiment (eg, jpg, gif, png, bmp)
% imageFormat = 'jpg';

% How long to pause in between trials (if 0, the experiment will wait for
% the subject to press a key before every trial)
timeBetweenTrials = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting the serial communication
%serial 

%Trigger on slice: 1
%Trigger on volume: Each
%TR=2000
%Slices=320 --
%Volumes=35
%Pulse=50ms
% start laptop 1º, dps ent start na syncbox

try
% s=serialport('COM7', 57600); %The stimbox works at 57600 s/s
s=serialport('COM4', 57600); %The stimbox works at 57600 s/s
% s.Timeout=trialTimeout-ImageDuration; %Max wait time for user input
s.Timeout=TR; %Max wait time for user input
disp('s ok')
catch
    s=[];
    disp('No serial port communication')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the video files for the experiment
videoFolder = fullfile(pwd(),'Training') 
videoFormat = 'avi';
videoList = dir(fullfile(videoFolder,['*.' videoFormat]));
videoList = {videoList(:).name};
nTrials = length(videoList); %1
% 
% lambda_poisson = 0.5;
% x = poissrnd(lambda_poisson,[1 nTrials])

min_secs=0.5;
max_secs=1.5; %TR
fixationDuration = min_secs + (max_secs-min_secs)*rand(1,nTrials);

% x=zeros(1,nTrials);
% for i=1:nTrials
%     x(i)=poissrnd(1);
% end
% fixationDuration=(x/(max(x)-min(x)))+(TR-1); %Fitting distribution into [TR-1,TR+1] interval
% fixationDuration=(x/(max(x)-min(x))); %Fitting distribution into [0,1] interval
% fixationDuration=3/2*TR-fixationDuration; %Fitting distribution into [3/2*TR-1,3/2TR] interval poisson to the right direction TR=2 ==> [2,3]

% fixationDuration = TR*x;

% Score images
imageFolder_score = 'score_images';
% imgList_score = dir(fullfile(imageFolder_score,['*.' 'JPG']));
% imgList_score = {imgList_score(:).name}; % 0 - 5 and 6th image is the start
% 
% %Load score image
% for k=1:length(imgList_score)
%     file = imgList_score{k}; 
%     m_score(:,:,:,k) = imread(fullfile(imageFolder_score,file));
% end
% img_score=m_score;
% % img_score=m_score(:,:,:,7:end); %Score images
% % img_score_conf=m_score(:,:,:,1:6); %Conf score images
% imageSize = size(squeeze(img_score(:,:,:,end))); %Start scoring is the last one
% pos_score = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];


% Load the text file (optional)
if strcmp(textFile,'none') == 0
    showTextItem = 1;
    textItems = importdata(textFile);
else
    showTextItem = 0;
end


% Randomize the trial list
% randomizedTrials = randperm(nTrials);
%build_videos_blocks;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

start_exp=GetSecs;

%nVolumes=72? 75?

