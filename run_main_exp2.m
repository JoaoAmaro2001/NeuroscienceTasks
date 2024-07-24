% Main script for running Emotional Cities' experiment 2
clear; close all; clc; % Clean workspace
settings_main;         % Load all the settings from the file
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

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------

% Wait fot user input to start the experiment
% input('Press Enter to start the task.');

% Start with state 99
state     = 99;   

while trial_ <= n

    switch state

% -------------------------------------------------------------------------
%                  Countdown for empatica sync
% -------------------------------------------------------------------------
        case 99
            start_exp = GetSecs;
            % -------------------------------------------
            parallel_port(99);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI99';  % Store the event type
            eventValues(event_) = 99;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            countdown_from = 10; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', window_1, 60);
                Screen('TextFont', window_1, 'Arial');
                message = sprintf(strcat(eval(strcat('data.text.starting', lanSuf)),' %d'), i);
                DrawFormattedText(window_1, message, 'center', 'center', textColor);
                Screen('Flip', window_1);
                WaitSecs(1);
            end
            % -------------------------------------------
            Eyelink('Message','Empatica Synch');
            % Eyelink('command','record_status_message "Instructions Screen"');
            % -------------------------------------------
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state  = 1;  % Proceed to the message state (set to 1 to ignore baseline)

% -------------------------------------------------------------------------
%                            Eyes closed Baseline
% -------------------------------------------------------------------------
        case 98
            % You need to give clear instructions for when the subject
            % needs to open their eyes again
            Screen('TextSize', window_1, 50);
            DrawFormattedText(window_1, eval(strcat('data.text.baselineClosed', lanSuf)), 'center', 'center', textColor);
            InitialDisplayTime = Screen('Flip', window_1);
            WaitSecs(5);
            countdown_from = 5; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', window_1, 60);
                Screen('TextFont', window_1, 'Arial');
                message = sprintf(strcat( eval(strcat('data.text.starting', lanSuf)),' %d'), i);
                DrawFormattedText(window_1, message, 'center', 'center', textColor);
                Screen('Flip', window_1);
                WaitSecs(1);
            end
            % -------------------------------------------
            % Draw Cross
            drawCross(window_1, W, H);
            tFixation = Screen('Flip', window_1);
            % -------------------------------------------
            parallel_port(98);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI98';  % Store the event type
            eventValues(event_) = 98;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            Eyelink('Message','Eyes Closed');
            % Eyelink('command','record_status_message "Eyes Closed"')
            % -------------------------------------------
            WaitSecs(30);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state  = 98;
           
% -------------------------------------------------------------------------
%                            Eyes open Baseline
% -------------------------------------------------------------------------
        case 97
            Screen('TextSize', window_1, 50);
            DrawFormattedText(window_1, eval(strcat('data.text.baselineOpen', lanSuf)), 'center', 'center', textColor);
            InitialDisplayTime = Screen('Flip', window_1);
            WaitSecs(5);
            countdown_from = 5; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', window_1, 60);
                Screen('TextFont', window_1, 'Arial');
                message = sprintf(strcat( eval(strcat('data.text.starting', lanSuf)),' %d'), i);
                DrawFormattedText(window_1, message, 'center', 'center', textColor);
                Screen('Flip', window_1);
                WaitSecs(1);
            end
            % -------------------------------------------
            % Draw Cross
            drawCross(window_1, W, H);
            tFixation = Screen('Flip', window_1);
            parallel_port(97);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI97';  % Store the event type
            eventValues(event_) = 97;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            Eyelink('Message','Eyes Open');
            % Eyelink('command','record_status_message "Eyes Open"')
            % -------------------------------------------
            WaitSecs(30);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state  = 1;

% -------------------------------------------------------------------------
%                             Message
% -------------------------------------------------------------------------
        case 1
            Screen('TextSize', window_1, 50);
            DrawFormattedText(window_1, eval(strcat('data.text.getready', lanSuf)), 'center', 'center', textColor);
            InitialDisplayTime = Screen('Flip', window_1);
            % ------------------------------------------- EEG
            parallel_port(1);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI1';  % Store the event type
            eventValues(event_) = 1;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % ------------------------------------------- EL
            Eyelink('Message', 'TRIALID %d', trial_);
            Eyelink('Message', '!V CLEAR %d %d %d', el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
            Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trial_, n);
            % -------------------------------------------
            WaitSecs(5);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 2;

% -------------------------------------------------------------------------
%                             Cross
% -------------------------------------------------------------------------
        case 2
            Eyelink('command','draw_cross %d %d',...
            data.format.resolx/2,data.format.resoly/2);
            Eyelink('Message','Fixation Cross');
            % -----------------------------------------
            drawCross(window_1, W, H);
            tFixation = Screen('Flip', window_1);
            parallel_port(2);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI2';  % Store the event type
            eventValues(event_) = 2;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            WaitSecs(1);
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 3;  % Proceed to next state to play video
            % -------------------------------------------EL start
            Eyelink('command','set_idle_mode');
            Eyelink('StartRecording');
            WaitSecs(0.1);
% -------------------------------------------------------------------------
%                             Video
% -------------------------------------------------------------------------
        case 3
            % Eyelink setup
            elCheckRecording; % Check if everything is fine
            Eyelink('Message', 'STIM_ONSET');
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
            videoFile = data.sequences.files{trial_};
            file      = fullfile(stim_path, videoFile);

            try
                % Open the movie, start playback paused
                [movie, duration, fps, width, height, count, aspectRatio] = Screen('OpenMovie', window_1, file, 0, inf, 2);
                Screen('SetMovieTimeIndex', movie, 0);  %Ensure the movie starts at the very beginning

                % Get the first frame and display it
                tex = Screen('GetMovieImage', window_1, movie, 1, 0);
                if tex > 0  % If a valid texture was returned
                    Screen('DrawTexture', window_1, tex, [], dst_rect);  % Draw the texture on the screen
                    Screen('Flip', window_1);  % Update the screen to show the first frame
                    % -------------------------------------------
                    parallel_port(3);   % Send to NetStation
                    eventOnsets(event_) = GetSecs - start_exp;
                    eventTypes{event_}  = 'DI3';  % Store the event type
                    eventValues(event_) = 3;  % Store the event value
                    eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
                    % -------------------------------------------
                    WaitSecs(1);  % Hold the first frame for 1.5 seconds (Not 1 sec?)
                    Screen('Close', tex);  % Close the texture
                    eventDurations(event_) = GetSecs - eventOnsets(event_);
                    event_ = event_ + 1;
                end

                % Continue playing movie from the first frame
                Screen('PlayMovie', movie, 1, 0);  % Start playback at normal speed from the current position
                % -------------------------------------------
                parallel_port(4);   % Send to NetStation
                eventOnsets(event_) = GetSecs - start_exp;
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
                    [tex, pts] = Screen('GetMovieImage', window_1, movie, 1);
                    if tex > 0  % If a valid texture was returned
                        % Draw the texture on the screen
                        Screen('DrawTexture', window_1, tex, [], dst_rect);
                        % Update the screen to show the current frame
                        Screen('Flip', window_1);
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
        WaitSecs(0.1);
        Eyelink('StopRecording');
        % -------------------------------------------
        state = 5;  

% -------------------------------------------------------------------------
%                             Valence
% -------------------------------------------------------------------------
        case 5 
            % Set the mouse cursor to the center of the screen
            ShowCursor;
            SetMouse(centerX, centerY, window_1);
            file_valence = fullfile(allstim_path,'Score_Valence.png');
            % Load the image from the file
            imageArray_valence = imread(file_valence);
            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_valence);
            % Define the destination rectangle to draw the image in its original size
            dst_rect_valence = CenterRectOnPointd([0 0 size(imageArray_valence, 2) size(imageArray_valence, 1)], centerX, centerY);
            % Set text size and font
            Screen('TextSize', window_1, 40);
            Screen('TextFont', window_1, 'Arial');
            % Calculate positions for the circles
            circle_radius = 45;
            contour_thickness = 3;
            space_between_circles = 175;
            total_length = 8 * space_between_circles + 2 * (circle_radius + contour_thickness);
            start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
            y_position = centerY + size(imageArray_valence, 1) / 2 + 100;
            % Initialize variables for circle clicks
            clicked_in_circle = false;
            clicked_circle_index = 0;

            while ~clicked_in_circle
                % Draw the texture to the window
                Screen('DrawTexture', window_1, texture, [], dst_rect_valence);

                % Draw and number circles with contours
                for i = 1:9
                    current_x = start_x + (i-1) * space_between_circles;

                    % Draw contour and circle
                    Screen('FillOval', window_1, [0 0 0], ...
                        [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
                        current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
                    Screen('FillOval', window_1, [255 255 255], ...
                        [current_x - circle_radius, y_position - circle_radius, ...
                        current_x + circle_radius, y_position + circle_radius]);

                    % Draw the number centered in the circle
                    number_str = num2str(i);
                    text_bounds = Screen('TextBounds', window_1, number_str);
                    text_width = text_bounds(3) - text_bounds(1);
                    text_height = text_bounds(4) - text_bounds(2);
                    text_x = current_x - text_width / 2;
                    text_y = y_position - text_height / 2000;
                    DrawFormattedText(window_1, number_str, text_x, text_y, [0 0 0]);
                end

                % Update the display
                ValenceTime = Screen('Flip', window_1); 
                % -------------------------------------------
                parallel_port(5);   % Send to NetStation
                eventOnsets(event_) = GetSecs - start_exp;
                eventTypes{event_}  = 'DI5';  % Store the event type
                eventValues(event_) = 5;  % Store the event value
                eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
                % -------------------------------------------
                % Check for mouse clicks
                [clicks, x, y, whichButton] = GetClicks(window_1, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            rt_valence(trial_)    = GetSecs - ValenceTime;
                            clicked_circle_index  = i;  % Update the clicked circle index
                            clicked_in_circle     = true;
                            choiceValence(trial_) = i;
                            fprintf('Valence rating is %d\n', choiceValence(trial_))
                            elCreateVariables(trial_, videoFile, rt_valence(trial_)) % rt in ms
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            % -------------------------------------------
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 6;

% -------------------------------------------------------------------------
%                             Arousal
% -------------------------------------------------------------------------            
        case 6
            SetMouse(centerX, centerY, window_1);
            file_arousal = fullfile(allstim_path,'Score_Arousal.png');
            % Load the image from the file
            imageArray_arousal = imread(file_arousal);
            % Make texture from the image array
            texture = Screen('MakeTexture', window_1, imageArray_arousal);
            % Define the destination rectangle to draw the image in its original size
            dst_rect_arousal = CenterRectOnPointd([0 0 size(imageArray_arousal, 2) size(imageArray_arousal, 1)], centerX, centerY);
            % Set text size and font
            Screen('TextSize', window_1, 40);
            Screen('TextFont', window_1, 'Arial');
            % Calculate positions for the circles
            circle_radius = 45;
            contour_thickness = 3;
            space_between_circles = 175;
            total_length = 8 * space_between_circles + 2 * (circle_radius + contour_thickness);
            start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
            y_position = centerY + size(imageArray_valence, 1) / 2 + 100;
            % Initialize variables for circle clicks
            clicked_in_circle = false;
            clicked_circle_index = 0;

            while ~clicked_in_circle
                % Draw the texture to the window
                Screen('DrawTexture', window_1, texture, [], dst_rect_arousal);

                % Draw and number circles with contours
                for i = 1:9
                    current_x = start_x + (i-1) * space_between_circles;

                    % Draw contour and circle
                    Screen('FillOval', window_1, [0 0 0], ...
                        [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
                        current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
                    Screen('FillOval', window_1, [255 255 255], ...
                        [current_x - circle_radius, y_position - circle_radius, ...
                        current_x + circle_radius, y_position + circle_radius]);

                     % Draw the number centered in the circle
                    number_str = num2str(i);
                    text_bounds = Screen('TextBounds', window_1, number_str);
                    text_width = text_bounds(3) - text_bounds(1);
                    text_height = text_bounds(4) - text_bounds(2);
                    text_x = current_x - text_width / 2;
                    text_y = y_position - text_height / 2000;
                    DrawFormattedText(window_1, number_str, text_x, text_y, [0 0 0]);
                end

                % Update the display
                ArousalTime = Screen('Flip', window_1);
                % -------------------------------------------
                parallel_port(6);   % Send to NetStation
                eventOnsets(event_) = GetSecs - start_exp;
                eventTypes{event_}  = 'DI6';  % Store the event type
                eventValues(event_) = 6;  % Store the event value
                eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
                % -------------------------------------------
                % Check for mouse clicks
                [clicks, x, y, whichButton] = GetClicks(window_1, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            rt_arousal(trial_)   = GetSecs - ArousalTime;
                            clicked_circle_index = i;  % Update the clicked circle index
                            clicked_in_circle = true;
                            choiceArousal(trial_) = i;
                            fprintf('Arousal rating is %d\n', choiceArousal(trial_))
                            elCreateVariables(trial_, videoFile, rt_arousal(trial_))
                            HideCursor;
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            % -------------------------------------------
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            state = 7;
        
        case 7
            % Fill the screen with white color
            Screen('FillRect', window_1, [255 255 255]);  % Assuming 0 is the color code for black
            % Update the display to show the black screen
            BlankTime = Screen('Flip', window_1);
            % -------------------------------------------
            parallel_port(7);   % Send to NetStation
            eventOnsets(event_) = GetSecs - start_exp;
            eventTypes{event_}  = 'DI7';  % Store the event type
            eventValues(event_) = 7;  % Store the event value
            eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
            % -------------------------------------------
            WaitSecs(1);
            % -------------------------------------------
            eventDurations(event_) = GetSecs - eventOnsets(event_);
            event_ = event_ + 1;
            % ------------------------------------------- End trial EL
            Eyelink('Message','End of trial %d', trial_);
            Eyelink('Message','TRIAL_RESULT 0');
            % -------------------------------------------
            trial_ = trial_ + 1;  
            state  = 2;
            % ------------------------------------------- New trial EL
            Eyelink('Message', 'TRIALID %d', trial_);
            Eyelink('Message', '!V CLEAR %d %d %d', el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
            Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trial_, n);
            Eyelink('command','set_idle_mode');
            Eyelink('command','clear_screen 0'); % clears tracker display
            % -------------------------------------------
    end
end

% ------------------------------------------------- EEG
parallel_port(10);   % Send end event to NetStation
eventOnsets(event_) = GetSecs - start_exp;
eventTypes{event_}  = 'DI10';  % Store the event type
eventValues(event_) = 10;  % Store the event value
eventSamples(event_)= round(eventOnsets(event_) * 500);  % Given 500 Hz sampling rate
eventDurations(event_) = GetSecs - eventOnsets(event_);
% ------------------------------------------------- Eyelink
elFinish;

% -------------------------------------------------------------------------
%                          Convert Log File into TSV/XLSX
% -------------------------------------------------------------------------
addRunColumn = ones(n,1).*str2double(data.input{3});
addSubColumn = repmat(data.input{1}, n, 1);% Add the run and subject columns to the log variables

if exportXlsx
    % Assuming logOnsets, logDurations, logTypes, logValues, logSamples are your log variables
    logTable = table(addSubColumn, addRunColumn, choiceValence', rt_valence', choiceArousal', rt_arousal',...
        'VariableNames', {'sub', 'run', 'valence', 'rt_valence', 'arousal', 'rt_arousal'});
    % Write the log table to an XLSX file
    writetable(logTable, [logs_path filesep data.text.logFileName '.xlsx']);
end

if exportTsv
    % Assuming the same log variables as above
    logTable = table(logOnsets', logDurations', logTypes', logValues', logSamples', ...
        'VariableNames', {'onset', 'duration', 'type', 'value', 'sample'});
    % Write the log table to a TSV file
    writetable(logTable, [logs_path filesep data.text.logFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');
end

% -------------------------------------------------------------------------
%                          Convert Event File into TSV
% -------------------------------------------------------------------------

if exportXlsx
% Create a table from the event data
eventTable = table(eventOnsets', eventDurations', eventTypes', eventValues', eventSamples', ...
    'VariableNames', {'onset', 'duration', 'trial_type', 'value', 'sample'});
% Write the table to an XLSX file
writetable(eventTable, [event_path filesep data.text.eventFileName '.xlsx']);
end

if exportTsv
% Create a table from the event data
eventTable = table(eventOnsets', eventDurations', eventTypes', eventValues', eventSamples', ...
    'VariableNames', {'onset', 'duration', 'trial_type', 'value', 'sample'});
% Write the table to a TSV file
writetable(eventTable, [event_path filesep data.text.eventFileName '.tsv'], 'FileType', 'text', 'Delimiter', 'tab');
end






