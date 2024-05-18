% function 2step_task(subID)
%% Load Settings and initialize 

clear, clc
subID = input('subID:','s');
settings_2step_sim; % Load all the settings from the file

%% Run experiment
trial_=1; % In this case -> 1 trial being a blank image
nTrials=45; % 6 mins = 8sec*45 trials
n=nTrials;
BlankTime_=zeros(1,n); % blank time; similar to Diego
FixTime=zeros(1,n); % fixation time; similar to Diego
Trigger=zeros(1,n); % time of trigger - 1st stage presentation??

% Initialize states and variables
% state=1;
nt=0; %1st trigger


Priority(MaxPriority(window1)); % Give priority of resources to experiment
% Priority(2); % Testing lower priority

Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/3), (H/2), textColor);
Screen('Flip',window1);

%% Conduct experiment

flag_first = 1;
tStart = []; % Initialize start time
tWaitStart = GetSecs; % Initialize wait start time

while 1 

    aux = []; % Wait for MRI trigger. Gives [] until the trigger is received
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    
    if keyIsDown
        aux = 115; % Get the key code of the pressed key
        if isempty(tStart) % Start the timer when the key is first pressed
            tStart = GetSecs;
        end
    end
    
    if ~isempty(tStart) && GetSecs - tStart >= 2 % Send the signal every 2 seconds
        aux = 115; % Set aux to 115 to represent the signal
        tStart = GetSecs; % Reset the start time
    end
    
    if GetSecs - tWaitStart >= TR % If wait time exceeds TR, continue to the next iteration
        continue;
    end
    
    if (trial_==n) || (~isempty(aux) && (aux==115)) % 's' is the trigger
        
        if (trial_==n) 
            break
        end
        
        if aux == KbName('s')
            nt = nt+1
        end

        if flag_first
            % 1. Blank screen & Cross
            Screen(window1, 'FillRect', backgroundColor);
            BlankTime = Screen('Flip', window1); % Timestamp for the blank screen
            disp('Estado: Blank / Cross')
            if trial_ ==1
                TriggerStart=BlankTime;
            end
            flag_first=0;
            BlankTime_(trial_)=BlankTime-TriggerStart;
%             FixTime(trial_)=tFixation-TriggerStart;
            Trigger(trial_)=TriggerStart;
        end
        aux=[];
        trial_=trial_+1;
    end
end

sca; % sca -- Execute Screen('CloseAll');

%% End
name_file=[results_path '\eyes_closed_' num2str(subID) '.xlsx'];

M = [BlankTime_', Trigger']
T = [array2table(M)]
T.Properties.VariableNames = {'BlankTime_','Trigger'}
writetable(T,name_file)

% 180 (8*45/2) volumes in total
