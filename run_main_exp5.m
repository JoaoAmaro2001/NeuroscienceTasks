clear, clc, close all
subID = input('subID:','s');
settings_main; % Load all the settings from the file
terminateKey    = KbName('ESCAPE');      % Key code for escape key

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 0. Blank screen
% 1. Blank screen & Cross
% 2. Load active stimulus
% 3. Load neutral stimulus

% -------------------------------------------------------------------------
%                              Variables
% ------------------------------------------------------------------------- 
n                  = 8; % number of trials/videos

BlankTime_         = zeros(1,n); 
FixTime            = zeros(1,n); 
Video1Time         = zeros(1,n); 
trial_             = 1;
score_             = 0;
flag_vote_state4   = 0;
t                  = trial_;

Video_name_trial   = cell(1,n); % list of movienames presented at each trial

% valence and arousal
SelectValenceTime  = zeros(1,n); %selection time for valence (start)
SelectArousalTime  = zeros(1,n); %selection time for arousal (start)

rtValence          = zeros(1,n); % reaction times for valence selection
rtArousal          = zeros(1,n); % reaction times for arousal selection

choiceValence      = zeros(1,n); % choice for valence
choiceArousal      = zeros(1,n); % choice for arousal

% states and variables
num_cross   = 0;                 % Counter for the cross state
state       = 0;                 % Gets the state information
rt_num      = zeros(1,n);        % Reaction time for response
res_num     = zeros(1,n);        % Response number
trial       = zeros(1,n);        % Trial number
stim_txt    = cell(1,n);         % Stimulus text
res_txt     = cell(1,n);         % Response text
cond        = cell(1,n);         % Conditions
TR          = 2;
Trigger=zeros(1,n);

% flags
flag_screen = 1;                 % Flag for updating screen
flag_resp   = 1;                 % Flag for response -> can only respond while is 1
flag_cross  = 1;                 % Flag for cross -> first time entering cross

% Define circle positions (just an example, adjust as needed)
circlePositions = [100 500 900 1300];  % X-positions of circles



% -------------------------------------------------------------------------
%                       Pyschtoolblox prelim
% ------------------------------------------------------------------------- 
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/6), (H/4), textColor);
Screen('Flip',window1);

% -------------------------------------------------------------------------
%                       Start experiment
% ------------------------------------------------------------------------- 
prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
tic;
while 1

    switch state

        case 0
            % 0. Blank screen
            Screen(window1, 'FillRect', backgroundColor);
            BlankTime_ = Screen('Flip', window1); % Flip the screen (don't clear the buffer)
            disp('Estado: Ecrã em branco')
            if trial_ == 1
                 TriggerStart = BlankTime_;
            end

            % Cross
            t = trial_; % randomizedTrials(trial_);
            fixationDuration1 = poissrnd(2, 1, n); % Example initialization
            drawCross(window1, W, H);
            tFixation = Screen('Flip', window1);  % Cross should appear during the same blank TR
            disp('Cross')
            time_cross = GetSecs - BlankTime_;
            WaitSecs(fixationDuration(trial_));  % wait for the fixation duration to end
            state = 2;  % Transition to the video presentation state

        case 2

            % 2. Load active stimulus
            if trial_ >= 1 && trial_ <= 8
                columnName = sprintf('Var%d', trial_);
                trialIndex = randomizedTrials{1, columnName};  % Accesses the table correctly
                file = videoList{trialIndex};  % Assumes trialIndex is a valid index in videoList
            else
                error('Trial number out of range.');
            end
            Video_name_trial{trial_}  = file;
            moviename                 = fullfile(videoFolder,file);
            movienames_trials{trial_} = moviename;
            disp(moviename)
            % Open movie file:
            movie                     = Screen('OpenMovie', window1, moviename);
            % Start playback engine:
            Screen('PlayMovie', movie, 1);

            BlankTime_(trial_)        = BlankTime-TriggerStart;
            FixTime(trial_)           = tFixation-TriggerStart;
            Trigger(trial_)           = TriggerStart;
            
            Screen('FillRect', window1, backgroundColor);

        case 3
            tic
            [vid,VidTime]=present_video(window1,movie,dst_rect);
            %             VideoTime=Screen('Flip', window1);
            time_Video = VidTime - TriggerStart;
            
            % Load Score image
            Video1Time(trial_)=time_Video;
            %Variables for scoring
            
            % Open movie file:
            movie_frame1=moviename
            a=strsplit(movie_frame1,'.mp4')
            movie_frame1=strcat(a{1,1},'_Moment.jpg')
            vid = imread(movie_frame1);
            vid = imresize( vid , 0.6);
            imageSize = size(vid);
            
            % Make the new texture (i.e., the #1 video frame):
            shift_left=(W/4);
            shift_bottom=(H/4);
            new_dst_rect = [shift_left shift_bottom shift_left*3 shift_bottom*2];
            
            % Release texture:
%             Screen('Close', vid);
            % Close movie:
%             Screen('CloseMovie', movie);
            
            videoDisplay=Screen('MakeTexture', window1, vid);
            

            % Make the new texture (i.e., score image):
            file2                      = 'Score_Valence.png';
            img                        = imread(fullfile(imageFolder_score,file2));
            img                        = imresize( img , 0.7);
            imageSize                  = size(img);
            shift_left                 = (W-imageSize(2))/2;
            shift_bottom               = ((3/2)*H-imageSize(1))/2;
            posimage                   = [shift_left shift_bottom shift_left+imageSize(2) shift_bottom+imageSize(1)];
           
            imagescoreDisplay = Screen('MakeTexture', window1, img);
            pos = [new_dst_rect' posimage'];

            % Draw circles for the regions
            circleSize = 50;
            for i = 1:numel(circlePositions)
                Screen('FillOval', window, [255 100 0], ...
                [circlePositions(i)-circleSize/2, windowRect(4)-circleSize, ...
                circlePositions(i)+circleSize/2, windowRect(4)]);
            end
            
            Screen('Flip', window);
        
            % Wait for mouse click inside one of the circles
            clickedCircle = false;
            while ~clickedCircle
                [clicksX, ~, ~, ~] = GetClicks(window, 0);
                for i = 1:numel(circlePositions)
                    if clicksX > circlePositions(i)-circleSize/2 && ...
                        clicksX < circlePositions(i)+circleSize/2
                        clickedCircle = true;
                        choiceValence(trial_) = clicksX;
                    break;
                    end
                end
            end

            % Draw the new texture immediately to screen:
            Screen('DrawTextures', window1, imagescoreDisplay, [], pos);
           
            state = 4;
            toc

        case 4
            % Update display:
            tempo_4                   = GetSecs - TriggerStart;
            ValenceTime               = Screen('Flip', window1);
            SelectValenceTime(trial_) = ValenceTime-TriggerStart;
            disp('Estado: 4');
            time_to_vote              = 1;
            state                     = 5;
            rtValence(trial_)         = GetSecs - ValenceTime;

        if (state == 5)
            file_arousal               = 'Score_Arousal.png';
            img_arousal                = imread(fullfile(imageFolder_score,file_arousal));
            img_arousal                = imresize( img_arousal , 0.7);
            imageSize                  = size(img_arousal);
            shift_left                 = (W-imageSize(2))/2;
            shift_bottom               = ((3/2)*H-imageSize(1))/2;
            posimage                   = [shift_left shift_bottom shift_left+imageSize(2) shift_bottom+imageSize(1)];
           
            imagescoreDisplay = Screen('MakeTexture', window1, img_arousal);
            pos = [new_dst_rect' posimage'];

            % Draw circles for the regions
            circleSize = 50;
            for i = 1:numel(circlePositions)
                Screen('FillOval', window, [255 100 0], ...
                [circlePositions(i)-circleSize/2, windowRect(4)-circleSize, ...
                circlePositions(i)+circleSize/2, windowRect(4)]);
            end
            
            Screen('Flip', window);
        
            % Wait for mouse click inside one of the circles
            clickedCircle = false;
            while ~clickedCircle
                [clicksX, ~, ~, ~] = GetClicks(window, 0);
                for i = 1:numel(circlePositions)
                    if clicksX > circlePositions(i)-circleSize/2 && ...
                        clicksX < circlePositions(i)+circleSize/2
                        clickedCircle = true;
                        choiceArousal(trial_) = clicksX;
                    break;
                    end
                end
            end

            % Draw the new texture immediately to screen:
            Screen('DrawTextures', window1, imagescoreDisplay, [], pos);
           
            state = 6;
            toc
        end

        case 5
            % Update display:
            tempo_5                   = GetSecs - TriggerStart;
            ArousalTime               = Screen('Flip', window1);
            SelectArousalTime(trial_) = ArousalTime-TriggerStart;
            disp('Estado: 4');
            time_to_vote              = 1;
            state                     = 6;
            rtArousal(trial_) = GetSecs - ArousalTime;
    end
end

%% End
name_file = [results_path '/resultfile_' num2str(subID) '.xlsx'];

% nm_ny_array=repmat(nm_ny,1,nTrials)

movienames_trials;

M = [BlankTime_', FixTime', Video1Time', SelectValenceTime', SelectArousalTime', ...
    rtValence', rtArousal', choiceValence', choiceArousal',Trigger'];

T = [array2table(M), cell2table(Video_name_trial')];

T.Properties.VariableNames = {'BlankTime_','FixTime','Video1Time','SelectValenceTime','SelectArousalTime',...
   'rtValence','rtArousal','choiceValence','choiceArousal', 'Trigger','Video_name_trial'};
writetable(T,name_file);

sca;





