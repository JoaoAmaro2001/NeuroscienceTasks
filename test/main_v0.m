function BAP_final(subID)

    % -------------------------------------------------------------------------
    % Initialization & Settings
    % -------------------------------------------------------------------------
    settingsImageSequence; % Load settings
    NetStation('Connect', '10.10.10.42');
    NetStation('Synchronize');
    
    % Prepare logging table for events
    n = 80;
    T_events = table('Size', [n, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
        'VariableNames', {'Trial', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
    
    % Preallocate variables
    initializeVariables();
    
    % Priority setting for PTB
    Priority(MaxPriority(window1));
    Priority(2);
    
    % -------------------------------------------------------------------------
    % Start the experiment
    % -------------------------------------------------------------------------
    showInitialScreen(window1, W, H, textColor);
    
    % Wait for MRI trigger or start signal
    while 1
        aux = getTrigger(s, joystick_flag);
        if triggerReceived(aux, trial_, n, state)
            break;
        end
    
        % Execute based on the current state
        switch state
            case 1
                [state, trial_, TriggerStart] = runBlankScreen(window1, backgroundColor, trial_, n, W, H, TR, TriggerStart);
            case 2
                [state, tFixation] = runCrossState(window1, W, H, TR, slack, tFixation, fixationDuration, randomizedTrials, nn, trial_);
            case 3
                [state, ImageTime, file] = runImageState(window1, W, H, imageFolder, imgList, trial_, n, TriggerStart);
            case 4
                [state, rt, score_] = handleUserResponse(window1, joystick_flag, img_score, trial_, score_, backgroundColor, pos1, pos2);
            case 5
                [state, score_] = finalizeTrial(window1, score_, flag_vote_state4, joystick_flag, trial_, n, TR);
        end
    end
    
    % -------------------------------------------------------------------------
    % Save Data and Clean Up
    % -------------------------------------------------------------------------
    saveExperimentResults(subID, randomizedTrials, fixationDuration, TriggerStart, trial_);
    closeExperiment();
    end
    
    % -------------------------------------------------------------------------
    % Modular Functions for Each Task Segment
    % -------------------------------------------------------------------------
    
    function initializeVariables()
        % Initialization of necessary variables
        trial_ = 0;
        BlankTime_ = zeros(1, n);
        FixTime = zeros(1, n);
        ImgTime = zeros(1, n);
        rt = zeros(1, n);
        score_ = 0;
        state = 1;
    end
    
    function showInitialScreen(window1, W, H, textColor)
        Screen('DrawText', window1, 'Experiment will start soon', (W / 2 - 300), (H / 2), textColor);
        Screen('Flip', window1);
    end
    
    function aux = getTrigger(s, joystick_flag)
        % Wait for a trigger from the MRI or joystick
        aux = [];
        aux = read(s, 1, 'uint8'); % Reads one sample
        if joystick_flag == 1 || aux == 115
            aux = 115;
        end
    end
    
    function received = triggerReceived(aux, trial_, n, state)
        % Check if a trigger was received and whether to exit the loop
        received = false;
        if (trial_ == n && state == 5) || (~isempty(aux) && aux == 115)
            if trial_ == n && state == 5
                received = true;
            end
        end
    end
    
    function [state, trial_, TriggerStart] = runBlankScreen(window1, backgroundColor, trial_, n, W, H, TR, TriggerStart)
        % Blank Screen and Cross
        Screen(window1, 'FillRect', backgroundColor);
        BlankTime = Screen('Flip', window1);
        NetStation('Event', 'blank');
        disp('Estado: Blank / Cross');
    
        trial_ = trial_ + 1;
        if trial_ == 1
            TriggerStart = BlankTime;
        end
        state = 2;
    end
    
    function [state, tFixation] = runCrossState(window1, W, H, TR, slack, tFixation, fixationDuration, randomizedTrials, nn, trial_)
        % Display cross and wait for the appropriate fixation duration
        t = randomizedTrials(trial_ + nn);
        fixationDuration1 = fixationDuration(t);
        drawCross(window1, W, H);
        tFixation = Screen('Flip', window1);
        NetStation('Event', 'cross');
        disp('Cross');
        state = 3;
    end
    
    function [state, ImageTime, file] = runImageState(window1, W, H, imageFolder, imgList, trial_, n, TriggerStart)
        % Load and display the image
        t = randomizedTrials(trial_);
        file = imgList{t};
        img = imread(fullfile(imageFolder, file));
        img = imresize(img, 2);
        imageDisplay1 = Screen('MakeTexture', window1, img);
    
        % Calculate image position
        imageSize = size(img);
        pos = [(W - imageSize(2)) / 2 (H - imageSize(1)) / 2 (W + imageSize(2)) / 2 (H + imageSize(1)) / 2];
        Screen('FillRect', window1, backgroundColor);
        Screen('DrawTexture', window1, imageDisplay1, [], pos);
        ImageTime = Screen('Flip', window1);
        NetStation('Event', 'image');
        state = 4;
    end
    
    function [state, rt, score_] = handleUserResponse(window1, joystick_flag, img_score, trial_, score_, backgroundColor, pos1, pos2)
        % Manage user responses and update the screen accordingly
        if joystick_flag == 1
            img = squeeze(img_score(:, :, :, score_ + 1));
            imageDisplay2 = Screen('MakeTexture', window1, img);
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTexture', window1, imageDisplay2, [], pos2);
            ImageTime = Screen('Flip', window1);
            score_ = 0;
            state = 5;
        end
    end
    
    function [state, score_] = finalizeTrial(window1, score_, flag_vote_state4, joystick_flag, trial_, n, TR)
        % Finalize the trial and prepare for the next one
        if joystick_flag == 0
            Screen(window1, 'FillRect', backgroundColor);
            BlankTime = Screen('Flip', window1);
            NetStation('Event', 'blank');
            score_ = 0;
            trial_ = trial_ + 1;
            state = 2;
        end
    end
    
    function saveExperimentResults(subID, randomizedTrials, fixationDuration, TriggerStart, trial_)
        % Save the experiment results to a file
        resultsFolder = fullfile('Results', subID);
        mkdir(resultsFolder);
        save(fullfile(resultsFolder, 'Trials2.mat'), 'randomizedTrials', 'fixationDuration');
        save(fullfile(resultsFolder, subID), 'randomizedTrials', 'TriggerStart', 'trial_');
    end
    
    function closeExperiment()
        % Close the experiment and clean up
        Screen('CloseAll');
        close all;
        sca;
        NetStation('Event', 'END');
    end
    
    % Function to draw a fixation cross (helper function)
    function drawCross(window, W, H)
        barLength = 160;
        barWidth = 20;
        barColor = 1;
        Screen('FillRect', window, barColor, [(W - barLength) / 2 (H - barWidth) / 2 (W + barLength) / 2 (H + barWidth) / 2]);
        Screen('FillRect', window, barColor, [(W - barWidth) / 2 (H - barLength) / 2 (W + barWidth) / 2 (H + barLength) / 2]);
    end
    
    