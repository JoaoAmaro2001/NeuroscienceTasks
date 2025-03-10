function BAP_final(subID)

    % -------------------------------------------------------------------------
    % Initialization & Settings
    % -------------------------------------------------------------------------
    settingsImageSequence;  % Load general settings
    % Removed NetStation calls as EEG won't be used.
    
    % Prepare logging table for events
    n_trials = 80;
    eventLog = table('Size', [n_trials, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
        'VariableNames', {'Trial', 'AbsoluteTime', 'RelativeTime', 'TimeDiff', 'Event'});
    
    % Preallocate trial-related variables
    initializeVariables();
    
    % Set PTB priority
    Priority(MaxPriority(window1));
    Priority(2);
    
    % -------------------------------------------------------------------------
    % Start the experiment
    % -------------------------------------------------------------------------
    displayInitialScreen(window1, W, H, textColor);
    
    % Wait for MRI trigger or start signal
    while 1
        triggerInput = getTriggerSignal(serialPort, joystickFlag);
        if checkForExperimentEnd(triggerInput, trialIndex, n_trials, currentState)
            break;
        end
    
        % Control flow based on the current state of the experiment
        switch currentState
            case 1
                % Show blank screen and fixation cross
                [currentState, trialIndex, experimentStartTime] = displayBlankScreenAndCross(window1, backgroundColor, trialIndex, n_trials, W, H, TR, experimentStartTime);
    
            case 2
                % Display fixation cross for randomized duration
                [currentState, fixationEndTime] = displayFixationCross(window1, W, H, TR, slack, fixationEndTime, fixationDuration, randomizedTrials, previousTrialsOffset, trialIndex);
    
            case 3
                % Show the main stimulus image
                [currentState, imageDisplayTime, imageFile] = showStimulusImage(window1, W, H, imageFolder, imgList, trialIndex, n_trials, experimentStartTime);
    
            case 4
                % Handle participant response (e.g., joystick input)
                [currentState, responseTime, responseScore] = handleParticipantResponse(window1, joystickFlag, scoreImages, trialIndex, responseScore, backgroundColor, pos1, pos2);
    
            case 5
                % Finalize trial and move to the next one
                [currentState, responseScore] = finalizeTrial(window1, responseScore, stateVoteFlag, joystickFlag, trialIndex, n_trials, TR);
        end
    end
    
    % -------------------------------------------------------------------------
    % Save Data and Clean Up
    % -------------------------------------------------------------------------
    saveExperimentData(subID, randomizedTrials, fixationDuration, experimentStartTime, trialIndex);
    endExperiment();
    
    end
    
    % -------------------------------------------------------------------------
    % Helper Functions
    % -------------------------------------------------------------------------
    
    function initializeVariables()
        % Initialization of necessary variables for trials
        trialIndex = 0;
        BlankScreenTimes = zeros(1, n_trials);
        FixationTimes = zeros(1, n_trials);
        StimulusTimes = zeros(1, n_trials);
        ReactionTimes = zeros(1, n_trials);
        responseScore = 0;
        currentState = 1;
    end
    
    function displayInitialScreen(window1, W, H, textColor)
        % Show initial "Experiment starting soon" screen
        Screen('DrawText', window1, 'Experiment will start soon', (W / 2 - 300), (H / 2), textColor);
        Screen('Flip', window1);
    end
    
    function triggerInput = getTriggerSignal(serialPort, joystickFlag)
        % Wait for a trigger signal from MRI or joystick
        triggerInput = [];
        triggerInput = read(serialPort, 1, 'uint8'); % Read one sample
        if joystickFlag == 1 || triggerInput == 115
            triggerInput = 115;
        end
    end
    
    function isEnd = checkForExperimentEnd(triggerInput, trialIndex, n_trials, currentState)
        % Check if the experiment should end based on trial count or trigger
        isEnd = false;
        if (trialIndex == n_trials && currentState == 5) || (~isempty(triggerInput) && triggerInput == 115)
            if trialIndex == n_trials && currentState == 5
                isEnd = true;
            end
        end
    end
    
    function [currentState, trialIndex, experimentStartTime] = displayBlankScreenAndCross(window1, backgroundColor, trialIndex, n_trials, W, H, TR, experimentStartTime)
        % Display blank screen and fixation cross
        Screen(window1, 'FillRect', backgroundColor);
        blankScreenTime = Screen('Flip', window1);
        disp('State: Blank Screen / Fixation Cross');
        
        trialIndex = trialIndex + 1;
        if trialIndex == 1
            experimentStartTime = blankScreenTime;
        end
        currentState = 2;
    end
    
    function [currentState, fixationEndTime] = displayFixationCross(window1, W, H, TR, slack, fixationEndTime, fixationDuration, randomizedTrials, previousTrialsOffset, trialIndex)
        % Display fixation cross for randomized duration
        trialNum = randomizedTrials(trialIndex + previousTrialsOffset);
        fixationDurationTrial = fixationDuration(trialNum);  % Randomized order based on trial number
        drawCross(window1, W, H);
        fixationEndTime = Screen('Flip', window1);  % Fixation cross display time
        disp('State: Fixation Cross');
        currentState = 3;
    end
    
    function [currentState, imageDisplayTime, imageFile] = showStimulusImage(window1, W, H, imageFolder, imgList, trialIndex, n_trials, experimentStartTime)
        % Show stimulus image during the trial
        trialNum = randomizedTrials(trialIndex);
        imageFile = imgList{trialNum};
        img = imread(fullfile(imageFolder, imageFile));
        img = imresize(img, 2);
        imageTexture = Screen('MakeTexture', window1, img);
    
        % Calculate image position (centered on the screen)
        imageSize = size(img);
        position = [(W - imageSize(2)) / 2 (H - imageSize(1)) / 2 (W + imageSize(2)) / 2 (H + imageSize(1)) / 2];
        Screen('FillRect', window1, backgroundColor);
        Screen('DrawTexture', window1, imageTexture, [], position);
        imageDisplayTime = Screen('Flip', window1);  % Record image display time
        disp('State: Stimulus Image Display');
        currentState = 4;
    end
    
    function [currentState, responseTime, responseScore] = handleParticipantResponse(window1, joystickFlag, scoreImages, trialIndex, responseScore, backgroundColor, pos1, pos2)
        % Handle participant response with joystick input
        if joystickFlag == 1
            img = squeeze(scoreImages(:, :, :, responseScore + 1));
            imageDisplay = Screen('MakeTexture', window1, img);
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTexture', window1, imageDisplay, [], pos2);
            responseTime = Screen('Flip', window1);  % Record response time
            responseScore = 0;
            currentState = 5;
        end
    end
    
    function [currentState, responseScore] = finalizeTrial(window1, responseScore, stateVoteFlag, joystickFlag, trialIndex, n_trials, TR)
        % Finalize the trial and prepare for the next one
        if joystickFlag == 0
            Screen(window1, 'FillRect', backgroundColor);
            blankScreenTime = Screen('Flip', window1);
            responseScore = 0;
            trialIndex = trialIndex + 1;
            currentState = 2;
        end
    end
    
    function saveExperimentData(subID, randomizedTrials, fixationDuration, experimentStartTime, trialIndex)
        % Save the experiment results to a file
        resultsFolder = fullfile('Results', subID);
        mkdir(resultsFolder);
        save(fullfile(resultsFolder, 'Trials2.mat'), 'randomizedTrials', 'fixationDuration');
        save(fullfile(resultsFolder, subID), 'randomizedTrials', 'experimentStartTime', 'trialIndex');
    end
    
    function endExperiment()
        % Clean up and close the experiment
        Screen('CloseAll');
        close all;
        sca;
        disp('Experiment ended');
    end
    
    % Helper function to draw a fixation cross
    function drawCross(window, W, H)
        barLength = 160;
        barWidth = 20;
        barColor = 1;  % white cross
        Screen('FillRect', window, barColor, [(W - barLength) / 2 (H - barWidth) / 2 (W + barLength) / 2 (H + barWidth) / 2]);
        Screen('FillRect', window, barColor, [(W - barWidth) / 2 (H - barLength) / 2 (W + barWidth) / 2 (H + barLength) / 2]);
    end
    
    