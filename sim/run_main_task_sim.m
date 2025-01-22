% Main script for running Emotional Cities' experiment 2
% Hit 'o' after doing the eyetracker calibration
% Hit 'esc' on the training script to start the task

% -------------------------------------------------------------------------
clear; close all; clc;     % Clean workspace
setpath;           % Set all paths
settings_main_sim;         % Load all the settings from the file
HideCursor;

% -------------------------------------------------------------------------
%                       Set variables fot While Loop
% -------------------------------------------------------------------------
% Number of trials/videos based on available videos
n                 = filesForEachSession; 
trial_            = 1;
event_            = 1;

% -------------------------------------------------------------------------
%                       Set variables for Log File
% -------------------------------------------------------------------------

% Reaction times and choices for valence and arousal
rt_valence        = zeros(1,n); 
rt_arousal        = zeros(1,n); 
choiceValence     = zeros(1,n); 
choiceArousal     = zeros(1,n);
stim              = cell(1,n);

% -------------------------------------------------------------------------
%                       Set variables for event files
% -------------------------------------------------------------------------

% Description:
% DIN99 - parallel_port(99) -> Empathic sync
% DIN98 - parallel_port(98) -> Eyes closed baseline
% DIN97 - parallel_port(97) -> Eyes open baseline
% DIN1  - parallel_port(1)  -> Beginning of Task Message
% DIN2  - parallel_port(2)  -> Fixation Cross
% DIN3  - parallel_port(3)  -> Image
% DIN4  - parallel_port(4)  -> Video
% DIN5  - parallel_port(5)  -> Valence
% DIN6  - parallel_port(6)  -> Arousal
% DIN7  - parallel_port(7)  -> Blank Screen

numEvents       = 3 + 7*n; % Equal to number of sent DINs
eventOnsets     = zeros(1, numEvents); % Time of event onset in seconds
eventDurations  = zeros(1, numEvents); % Duration of event in seconds
eventTypes      = cell(1, numEvents);  % Type of event, e.g., 'DI99', 'DI98'
eventValues     = zeros(1, numEvents); % Numeric value to encode the event, optional
eventSamples    = zeros(1, numEvents); % Sample number at which event occurs, optional
eventTime       = cell(1, numEvents);  % Universal time given by datetime('now')

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------

% Wait fot user input to start the experiment
% input('Press Enter to start the task.');

if run==1
    % Start with state 99
    state     = 99;
elseif run==2
    % Start with state 1 and skip baseline
    state     = 1;
end


while trial_ <= n

    % MANUAL CONTROL 
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    if keyIsDown
        if keyCode(terminateKey) % Check if the terminate key (esc) was pressed
            break % Exit the function or script
        end
    end

    switch state

% -------------------------------------------------------------------------
%                             Message
% -------------------------------------------------------------------------
        case 1
            if run==2
            start_exp = GetSecs;
            end
            Screen('TextSize', window1, 50);
            DrawFormattedText(window1, eval(strcat('data.text.getready', lanSuf)), 'center', 'center', textColor);
            InitialDisplayTime = Screen('Flip', window1);
            % ------------------------------------------- EEG
            eventOnsets(event_) = GetSecs - start_exp;
            eventTime{event_}   = datetime('now');
            eventTypes{event_}  = 'DI1';  % Store the event type
            eventValues(event_) = 1;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % ------------------------------------------- EL
            WaitSecs(1);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 2;

% -------------------------------------------------------------------------
%                             Cross
% -------------------------------------------------------------------------
        case 2
            % -----------------------------------------
            drawCross(window1, W, H);
            tFixation = Screen('Flip', window1);
            eventOnsets(event_) = GetSecs - start_exp;
            eventTime{event_}   = datetime('now');
            eventTypes{event_}  = 'DI2';  % Store the event type
            eventValues(event_) = 2;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            WaitSecs(1);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 3;  % Proceed to next state to play video

% -------------------------------------------------------------------------
%                             Video
% -------------------------------------------------------------------------
        case 3
            % Define new dimensions for the video, 1.5x1.5 times smaller
            newWidth  = W / 1.5;
            newHeight = H / 1.5;
            % Calculate the position to center the smaller video on the screen
            dst_rect = [...
                (W - newWidth) / 2, ...
                (H - newHeight) / 2, ...
                (W + newWidth) / 2, ...
                (H + newHeight) / 2];
            % important to select the correct sequence of videos
            videoFile    = data.sequences.files{trial_}; 
            fprintf('Stimulus - %s; Trial nº %d\n',videoFile, trial_);
            file         = fullfile(stim_path, videoFile);
            stim{trial_} = videoFile;

            try
                % Open the movie, start playback paused
                [movie, duration, fps, width, height, count, aspectRatio] = Screen('OpenMovie', window1, file, 0, inf, 2);
                Screen('SetMovieTimeIndex', movie, 0);  %Ensure the movie starts at the very beginning

                % Get the first frame and display it
                tex = Screen('GetMovieImage', window1, movie, 1, 0);
                if tex > 0  % If a valid texture was returned
                    Screen('DrawTexture', window1, tex, [], dst_rect);  % Draw the texture on the screen
                    Screen('Flip', window1);  % Update the screen to show the first frame
                    % -------------------------------------------
                    eventOnsets(event_) = GetSecs - start_exp;
                    eventTime{event_}   = datetime('now');
                    eventTypes{event_}  = 'DI3';  % Store the event type
                    eventValues(event_) = 3;  % Store the event value
                    eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
                    % -------------------------------------------
                    % WaitSecs(1);  % Hold the first frame for 1.5 seconds (Not 1 sec?)
                    Screen('Close', tex);  % Close the texture
                    eventDurations(event_) = GetSecs - eventOnsets(event_);
                    event_ = event_ + 1;
                end

                % Continue playing movie from the first frame
                Screen('PlayMovie', movie, 1, 0);  % Start playback at normal speed from the current position
                % -------------------------------------------
                eventOnsets(event_) = GetSecs - start_exp;
                eventTime{event_}   = datetime('now');
                eventTypes{event_}  = 'DI4';  % Store the event type
                eventValues(event_) = 4;  % Store the event value
                eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
                % -------------------------------------------
                % Further video playback code handling remains unchanged as per your original setup
            catch ME
                disp(['Failed to open movie file: ', file]);
                rethrow(ME);
            end

            state = 4;
            case 4
                % Play and display the movie
                tex = 0;
                while ~KbCheck && tex~=-1  % Continue until keyboard press or movie ends
                    [tex, pts] = Screen('GetMovieImage', window1, movie, 1);
                    if tex > 0  % If a valid texture was returned
                        % Draw the texture on the screen
                        Screen('DrawTexture', window1, tex, [], dst_rect);
                        % Update the screen to show the current frame
                        Screen('Flip', window1);
                        % Release the texture
                        Screen('Close', tex);
                    end
                end

        Screen('PlayMovie', movie, 0); % Stop playback
        % -------------------------------------------
        eventDurations(event_) = GetSecs - eventOnsets(event_);
        event_ = event_ + 1;
        % -------------------------------------------
        Screen('CloseMovie', movie);
        % -------------------------------------------
        state = 5;  
    
% ------------------------------------------------------------------------%
%                             Valence Rating                              %
% ------------------------------------------------------------------------% 
    case 5
    ShowCursor; % If you want to see the cursor, otherwise HideCursor if not needed
    file_valence = fullfile(allstim_path, strcat('Score_Valence', lanSuf, '.png'));
    imageArray_valence = imread(file_valence);
    texture = Screen('MakeTexture', window1, imageArray_valence);
    dst_rect_valence = CenterRectOnPointd([0 0 size(imageArray_valence,2) size(imageArray_valence,1)], centerX, centerY);
    Screen('TextSize', window1, 40);
    Screen('TextFont', window1, 'Arial');
    
    clicked_in_circle = false;
    pos = 5;  % Start at circle #5 (middle)
    while ~clicked_in_circle
        Screen('DrawTexture', window1, texture, [], dst_rect_valence);
        % Draw circles, highlighting the current pos
        [start_x,y_position,space_between_circles,circle_radius] = drawCircles(centerX, centerY, imageArray_valence, window1, 'surround', pos);
        
        ValenceTime = Screen('Flip', window1);
        eventOnsets(event_) = GetSecs - start_exp;
        eventTime{event_}   = datetime('now');
        eventTypes{event_}  = 'DI5';
        eventValues(event_) = 5;
        eventSamples(event_)= round(eventOnsets(event_) * 500);
        
        % Check keyboard presses
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            % ---- WAIT FOR KEY RELEASE ----
            while KbCheck
                % do nothing until key is released
                % ensures we only move once per press
            end
            if keyCode(button1) % Move up by 1
                pos = pos + 1;
                if pos > 9
                    pos = 9; % clamp
                    pause(0.5)
                end
            elseif keyCode(button2) % Move down by 1
                pos = pos - 1;
                if pos < 1
                    pos = 1; % clamp
                    pause(0.5)
                end
            elseif keyCode(button3) % Confirm
                rt_valence(trial_)    = GetSecs - ValenceTime;
                choiceValence(trial_) = pos;
                clicked_in_circle     = true;
                fprintf('Valence rating is %d\n', choiceValence(trial_));
                % Redraw final highlight
                Screen('DrawTexture', window1, texture, [], dst_rect_valence);
                drawCircles(centerX, centerY, imageArray_valence, window1, 'surround', pos, 'color', data.rgb.green);
                Screen('Flip', window1);
                pause(0.5);
            end
        end
    end
    eventDurations(event_) = GetSecs - eventOnsets(event_);
    event_ = event_ + 1;
    state = 6;

% ------------------------------------------------------------------------%
%                             Arousal Rating                              %
% ------------------------------------------------------------------------% 
    case 6
        ShowCursor;
        file_arousal = fullfile(allstim_path, strcat('Score_Arousal', lanSuf, '.png'));
        imageArray_arousal = imread(file_arousal);
        texture = Screen('MakeTexture', window1, imageArray_arousal);
        dst_rect_arousal = CenterRectOnPointd([0 0 size(imageArray_arousal,2) size(imageArray_arousal,1)], centerX, centerY);
        Screen('TextSize', window1, 40);
        Screen('TextFont', window1, 'Arial');
        
        clicked_in_circle = false;
        pos = 5;  % Start at circle #5
        while ~clicked_in_circle
            Screen('DrawTexture', window1, texture, [], dst_rect_arousal);
            [start_x,y_position,space_between_circles,circle_radius] = drawCircles(centerX, centerY, imageArray_arousal, window1, 'surround', pos);
            
            ArousalTime = Screen('Flip', window1);
            eventOnsets(event_) = GetSecs - start_exp;
            eventTime{event_}   = datetime('now');
            eventTypes{event_}  = 'DI6';
            eventValues(event_) = 6;
            eventSamples(event_)= round(eventOnsets(event_) * 500);
            
            [keyIsDown,~,keyCode] = KbCheck;
            if keyIsDown
                % ---- WAIT FOR KEY RELEASE ----
                while KbCheck
                    % do nothing until key is released
                    % ensures we only move once per press
                end
                if keyCode(button1)
                    pos = pos + 1;
                    if pos > 9
                        pos = 9;
                    end
                elseif keyCode(button2)
                    pos = pos - 1;
                    if pos < 1
                        pos = 1;
                    end
                elseif keyCode(button3)
                    rt_arousal(trial_)   = GetSecs - ArousalTime;
                    choiceArousal(trial_)= pos;
                    clicked_in_circle = true;
                    fprintf('Arousal rating is %d\n', choiceArousal(trial_));
                    Screen('DrawTexture', window1, texture, [], dst_rect_arousal);
                    drawCircles(centerX, centerY, imageArray_arousal, window1, 'surround', pos, 'color', data.rgb.green);
                    Screen('Flip', window1);
                    pause(0.5);
                    HideCursor;
                end
            end
        end
        eventDurations(event_) = GetSecs - eventOnsets(event_);
        event_ = event_ + 1;
        state = 7;


% ------------------------------------------------------------------------%
%                             Blank Screen                                %
% ------------------------------------------------------------------------% 
        
        case 7
            % Fill the screen with white color
            Screen('FillRect', window1, [255 255 255]);  % Assuming 0 is the color code for black
            % Update the display to show the black screen
            BlankTime = Screen('Flip', window1);
            % -------------------------------------------
            eventOnsets(event_) = GetSecs - start_exp;
            eventTime{event_}   = datetime('now');
            eventTypes{event_}  = 'DI7';  % Store the event type
            eventValues(event_) = 7;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            WaitSecs(1);
            % -------------------------------------------
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            % -------------------------------------------
            trial_ = trial_ + 1;  
            state  = 2;
            % ------------------------------------------- New trial EL
    end
end


% -------------------------------------------------------------------------
%                          Convert Log File into TSV/XLSX
% -------------------------------------------------------------------------
addRunColumn = ones(n,1).*str2double(data.input{3});
addSubColumn = repmat(data.input{1}, n, 1);% Add the run and subject columns to the log variables

if exportXlsx
    % Assuming logOnsets, logDurations, logTypes, logValues, logSamples are your log variables
    logTable = table(addSubColumn, addRunColumn, choiceValence', rt_valence', choiceArousal', rt_arousal', stim',...
        'VariableNames', {'sub', 'run', 'valence', 'rt_valence', 'arousal', 'rt_arousal', 'stimulus'});
    % Write the log table to an XLSX file
    writetable(logTable, [logs_path filesep data.text.logFileName '.xlsx']);
end

if exportTsv
    % Write the log table to a TSV file
    writetable(logTable, [logs_path filesep data.text.logFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');
end

% -------------------------------------------------------------------------
%                          Convert Event File into TSV
% -------------------------------------------------------------------------

if exportXlsx
% Create a table from the event data
eventTable = table(eventOnsets', eventDurations', eventTypes', eventValues', eventSamples', eventTime', ...
    'VariableNames', {'onset', 'duration', 'trial_type', 'value', 'sample','time'});
% Write the table to an XLSX file
writetable(eventTable, [event_path filesep data.text.eventFileName '.xlsx']);
end

if exportTsv
% Write the table to a TSV file
writetable(eventTable, [event_path filesep data.text.eventFileName '.tsv'], 'FileType', 'text', 'Delimiter', 'tab');
end

