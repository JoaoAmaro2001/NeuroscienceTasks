% Main script for running Emotional Cities' experiment 2 in MRI
% Hit 'esc' to terminate the task
% -------------------------------------------------------------------------

clear; close all; clc; % Clean workspace
settings_main_exp2mri_tr; % Load all the settings from the file
HideCursor;            % Hide cursor

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 1. Cross
% 2. Play video
% 3. Valence
% 4. Arousal
% 5. Blank
% -------------------------------------------------------------------------

% Number of trials and TRs
n           = data.task.stims_per_run; % 40 videos in total
tr_final    = n*(data.task.cross_duration+...
                 data.task.video_duration+...
                 data.task.valence_duration+...
                 data.task.arousal_duration+...
                 data.task.blank_duration)/...
                 data.mri.tr; % Number of triggers == 310

% Init task control vars
begin_task  = false;                      % Flag to begin task
flag_resp   = 0;                          % Flag for response -> can only respond while is 1
flag_input  = 0;
simTrCount  = 1;
trueTrCount = -1;
prevDigit   = -1;                         % Initialize prevDigit

% Init state gatekeepers (0 if not entering state for first time before everything ran)
state1_gate = 1;
state2_gate = 1;
state3_gate = 1;
state4_gate = 1;
state5_gate = 1;

% -------------------------------------------------------------------------
%                       Set variables for Log File
% -------------------------------------------------------------------------

trialCounter      = 1;
rt_valence        = nan(1,n); 
rt_arousal        = nan(1,n); 
choice_valence    = nan(1,n); 
choice_arousal    = nan(1,n);
stim              = cell(1,n);

% -------------------------------------------------------------------------
%                       Set variables for event files
% -------------------------------------------------------------------------

% Description:
% - capture simulated TR trigger
% - capture MRI TR triggers
% - capture time information

eventCounter = 1;
event_table  = table('Size', [tr_final*2, 4],...
    'VariableTypes', {'double', 'double', 'datetime', 'string'}, ...
    'VariableNames', {'TR', 'RelativeTime', 'Datetime', 'Description'});

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------

% Initial state
state = 1;

% Prelim state
Screen('TextSize', window1, data.format.font_size);
DrawFormattedText(window1, eval(strcat('data.text.getready', language_suffix)),...
                  'center', 'center', data.format.text_color);
Screen('Flip', window1);
WaitSecs(data.task.preparation_duration);
        
while trialCounter <= n

% ------------------------------------------------------------------------%
%                               AUXILLIARY                                %
% ------------------------------------------------------------------------%    

    % % % % % % % % % % % %
    % MRI TRIGGER CONTROL %
    % % % % % % % % % % % %
    
    % Wait for first mri trigger
    if trueTrCount == -1 && ~data.debug
        aux        = read(s,1,'uint8'); disp(aux);
        if aux == 115 
            trueTrCount= trueTrCount + 1;
            begin_task = true;
            init_time  = tic;
        end
    % Simulate first trigger (debug mode)
    elseif trueTrCount == -1 && data.debug
        trueTrCount= trueTrCount + 1;
        begin_task = true;
        init_time  = tic;
    % Simulating serial port communication        
    else
        timetmp = toc(init_time);
        firstDigit = str2double(num2str(floor(timetmp)));
        if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
            % create event
            [event_table,eventCounter,simTrCount] = create_event(event_table,...
            eventCounter, simTrCount, "SimTR", toc(init_time), datetime('now','Format','dd-MMM-yyyy HH:mm:ss.SS'));
        end
        prevDigit = firstDigit; % Update prevDigit
    end

    % Fetch true mri triggers
    if ~data.debug
        if s.NumBytesAvailable > 0 && trueTrCount ~= -1
            mri_trigger = read(s,1,'uint8');
            if ~isempty(mri_trigger) && (mri_trigger == 115)
                % create event
                [event_table,eventCounter,trueTrCount] = create_event(event_table,...
                eventCounter, trueTrCount, "TrueTR", toc(init_time), datetime('now','Format','dd-MMM-yyyy HH:mm:ss.SS'));
                fprintf('Fetching mri trigger at %f seconds\n', toc(init_time));
            end
            flush(s)
        end
    end
    
    % % % % % % % % % %
    % MANUAL CONTROL  %
    % % % % % % % % % %

    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(keyESCAPE) 
            break 
        end
    end

    % % % % % % % % %
    % CHECK ANSWERS %
    % % % % % % % % %

    if (state == 3 || state == 4) && flag_resp && data.task.handedness == 1 
        [keyIsDown, ~, keyCode] = KbCheck; 
        if keyIsDown && keyCode(button1)
            disp('button1-------------------------------------------')
            flag_input   = 1;
            rating_value = 1; fprintf('Answer - %d\n',rating_value)
        elseif keyIsDown && keyCode(button2)
            disp('button2-------------------------------------------')
            flag_input   = 1;
            rating_value = 2; fprintf('Answer - %d\n',rating_value)
        elseif keyIsDown && keyCode(button3)
            disp('button3-------------------------------------------')
            flag_input   = 1;
            rating_value = 3; fprintf('Answer - %d\n',rating_value)           
        elseif keyIsDown && keyCode(button4)
            disp('button4-------------------------------------------')
            flag_input   = 1;
            rating_value = 4; fprintf('Answer - %d\n',rating_value)
        end
        if state==3 && flag_input
            rt_valence(trialCounter)     = toc(valence_time);
            choice_valence(trialCounter) = rating_value;   
            % Redraw all the circles with highlighted answer
            Screen('DrawTexture', window1, texture, [], dst_rect_valence);
            drawCircles(data.screen.centerx, data.screen.centery, imageArray_valence, window1, 'surround', rating_value, 'numAnswers', 4);
            Screen('Flip', window1);
            % Don't allow more answers
            flag_resp  = 0;
            flag_input = 0;
        elseif state==4 && flag_input
            rt_arousal(trialCounter)     = toc(arousal_time);
            choice_arousal(trialCounter) = rating_value;   
            % Redraw all the circles with highlighted answer
            Screen('DrawTexture', window1, texture, [], dst_rect_arousal);
            drawCircles(data.screen.centerx, data.screen.centery, imageArray_valence, window1, 'surround', rating_value, 'numAnswers', 4);
            Screen('Flip', window1);
            % Don't allow more answers
            flag_resp  = 0;
            flag_input = 0;            
        end
    end

    if (state == 2 || state == 3) && flag_resp && data.task.handedness == 2
        if s.NumBytesAvailable > 0
            aux = read(s,1,'uint8');
            flush(s)
        end
        if aux == button1
            disp('button1-------------------------------------------')
            flag_input   = 1;          
            rating_value = 1; fprintf('Answer - %d\n',rating_value)
        elseif aux == button2
            disp('button2-------------------------------------------')
            flag_input   = 1;            
            rating_value = 2; fprintf('Answer - %d\n',rating_value)
        elseif aux == button3
            disp('button3-------------------------------------------')
            flag_input   = 1;            
            rating_value = 3; fprintf('Answer - %d\n',rating_value)            
        elseif aux == button4
            disp('button4-------------------------------------------')
            flag_input   = 1;            
            rating_value = 4; fprintf('Answer - %d\n',rating_value)
        end
        if state==3 && flag_input
            rt_valence(trialCounter)     = toc(valence_time);
            choice_valence(trialCounter) = rating_value;   
            % Redraw all the circles with highlighted answer
            Screen('DrawTexture', window1, texture, [], dst_rect_valence);
            drawCircles(data.screen.centerx, data.screen.centery, imageArray_valence, window1, 'surround', rating_value, 'numAnswers', 4);
            Screen('Flip', window1);
            % Don't allow more answers
            flag_resp  = 0;
            flag_input = 0;       
        elseif state==4 && flag_input
            rt_arousal(trialCounter)     = toc(arousal_time);
            choice_arousal(trialCounter) = rating_value;   
            % Redraw all the circles with highlighted answer
            Screen('DrawTexture', window1, texture, [], dst_rect_arousal);
            drawCircles(data.screen.centerx, data.screen.centery, imageArray_valence, window1, 'surround', rating_value, 'numAnswers', 4);
            Screen('Flip', window1);
            % Don't allow more answers
            flag_resp  = 0;
            flag_input = 0;            
        end
    end

% ------------------------------------------------------------------------%
%                                TASK                                     %
% ------------------------------------------------------------------------%
    if begin_task

    switch state

        % ----------------------------------------------------------------%
        %                             Cross                               %
        % ----------------------------------------------------------------%
        case 1
            if state1_gate
                drawCross(window1, data.screen.pixelx, data.screen.pixely);
                Screen('Flip', window1);
                cross_time  = tic;
                state1_gate = 0;
            end
            if toc(cross_time)>=data.task.cross_duration
                state1_gate = 1;
                state = 2;
            end
        % ----------------------------------------------------------------%
        %                             Video                               %
        % ----------------------------------------------------------------%
        case 2
            if state2_gate
                % Init video playing flag
                video_playing = true;
                % Resize video
                newWidth  = data.screen.sizex;
                newHeight = data.screen.sizey;
                % Calculate the position to center the smaller video on the screen
                dst_rect = [... 
                    (data.screen.pixelx - newWidth) / 2, ...
                    (data.screen.pixely - newHeight) / 2, ...
                    (data.screen.pixelx + newWidth) / 2, ...
                    (data.screen.pixely + newHeight) / 2];
                % Important to select the correct sequence of videos (30 fps)
                videoFile = data.stim.files{trialCounter}; 
                fprintf('Stimulus - %s; Trial nº %d\n', videoFile, trialCounter);
                fprintf('Time elapsed since beginning: %f minutes\n', toc(init_time)/60);
                file = fullfile(data.dir.stim_path, videoFile);
                stim{trialCounter} = videoFile;
                % Open the movie, preload frames, and start playback paused
                try
                    [movie, duration, fps, width, height, count, aspectRatio] = Screen('OpenMovie', window1, file);
                    Screen('SetMovieTimeIndex', movie, 0);  % Ensure the movie starts at the very beginning
                    playback_start_time = GetSecs();        % Reference time for playback
                    frame_interval = 1 / fps;               % Calculate time interval between frames
                    Screen('PlayMovie', movie, 1, 0);       % Start playback in paused mode
                catch ME
                    disp(['Failed to open movie file: ', file]);
                    rethrow(ME);
                end
                % Set high priority for smooth playback
                oldPriority = Priority(MaxPriority(window1));
                state2_gate = false;
            end
            
            if video_playing
                % Fetch the current time
                current_time = GetSecs();
                % Check if it's time for the next frame
                if current_time - playback_start_time >= frame_interval
                    % Get the next frame of the movie
                    [tex, pts] = Screen('GetMovieImage', window1, movie, 1);
                    if tex > 0  % If a valid texture was returned
                        % Draw the texture on the screen
                        Screen('DrawTexture', window1, tex, [], dst_rect);
                        % Update the screen to show the current frame
                        Screen('Flip', window1);
                        % Release the texture
                        Screen('Close', tex);
                        % Synchronize playback timing using presentation timestamp
                        playback_start_time = pts + frame_interval;
                        if data.debug
                        fprintf('Current time: %f, Playback start time: %f, Frame interval: %f\n', current_time, playback_start_time, frame_interval);
                        fprintf('Texture value: %d\n', tex);
                        fprintf('Movie duration: %f, FPS: %f, Width: %d, Height: %d\n', duration, fps, width, height);
                        end
                    else
                        % End of video or error
                        video_playing = false;
                        Screen('PlayMovie', movie, 0); % Stop playback
                        Screen('CloseMovie', movie);   % Close the movie
                        state = 3;
                        fprintf('Time elapsed since beginning: %f minutes\n', toc(init_time)/60);
                        state2_gate = true;
                        % Reset priority to normal
                        Priority(oldPriority);
                    end
                end
            end

        % ----------------------------------------------------------------%
        %                            Valence                              %
        % ----------------------------------------------------------------%
        case 3
            if state3_gate
                % Load the image from the file
                file_valence = fullfile(data.dir.allstim_path,strcat('Score_Valence', language_suffix, '.png'));
                imageArray_valence = imread(file_valence);
                texture = Screen('MakeTexture', window1, imageArray_valence);
                dst_rect_valence = CenterRectOnPointd([0 0 size(imageArray_valence, 2) size(imageArray_valence, 1)], data.screen.centerx, data.screen.centery);
                % Set text size and font
                Screen('TextSize', window1, data.format.font_size);
                Screen('TextFont', window1, data.format.font);
                % Draw the texture to the window
                Screen('DrawTexture', window1, texture, [], dst_rect_valence);
                % Draw circles
                [start_x,y_position,space_between_circles,circle_radius] = drawCircles(data.screen.centerx,  data.screen.centery, imageArray_valence, window1, 'surround', 0, 'numAnswers', 4);
                % Update the display
                Screen('Flip', window1); 
                % Control
                valence_time = tic;
                state3_gate  = 0;
                flag_resp    = 1;
            end

            if toc(valence_time)>=data.task.valence_duration
                state3_gate = 1;
                state       = 4;
            end

        % ----------------------------------------------------------------%
        %                            Arousal                              %
        % ----------------------------------------------------------------%           
        case 4
            if state4_gate
                % Load the image from the file
                file_arousal = fullfile(data.dir.allstim_path,strcat('Score_Arousal', language_suffix, '.png'));
                imageArray_arousal = imread(file_arousal);
                texture = Screen('MakeTexture', window1, imageArray_arousal);
                dst_rect_arousal = CenterRectOnPointd([0 0 size(imageArray_arousal, 2) size(imageArray_arousal, 1)], data.screen.centerx, data.screen.centery);
                % Set text size and font
                Screen('TextSize', window1, data.format.font_size);
                Screen('TextFont', window1, data.format.font);
                % Draw the texture to the window
                Screen('DrawTexture', window1, texture, [], dst_rect_arousal);
                % Draw circles
                [start_x,y_position,space_between_circles,circle_radius] = drawCircles(data.screen.centerx,  data.screen.centery, imageArray_arousal, window1, 'surround', 0, 'numAnswers', 4);
                % Update the display
                Screen('Flip', window1); 
                % Control
                arousal_time = tic;
                state4_gate  = 0;
                flag_resp    = 1;
            end

            if toc(arousal_time)>=data.task.arousal_duration
                state4_gate = 1;
                state       = 5;
            end
        % ----------------------------------------------------------------%
        %                         Blank screen                            %
        % ----------------------------------------------------------------%
        case 5
            if state5_gate
                Screen('FillRect', window1,data.format.background_color);
                Screen('Flip', window1);
                blank_time  = tic;
                state5_gate = 0;
            end
            if toc(blank_time)>=data.task.blank_duration
                trialCounter = trialCounter + 1;
                state5_gate = 1;
                state = 1;
            end

    end % switch case
    end % if begin_task 
end     % while loop

% Clear screen
sca;

% ------------------------------------------------------------------------%
%                          Convert Log File into TSV/XLSX                 %
% ------------------------------------------------------------------------%
addRunColumn = ones(n,1).*str2double(data.input{3});
addSubColumn = repmat(data.input{1}, n, 1);
logTable     = table(addSubColumn, addRunColumn, choice_valence', rt_valence', choice_arousal', rt_arousal', stim',...
    'VariableNames', {'sub', 'run', 'valence', 'rt_valence', 'arousal', 'rt_arousal', 'stimulus'});
if data.output.export_xlsx
    % Write the log table to an XLSX file
    writetable(logTable, [data.dir.logs_path filesep data.output.log_file_name '.xlsx']);
end

if data.output.export_tsv
    % Write the log table to a TSV file
    writetable(logTable, [data.dir.logs_path filesep data.output.log_file_name '.tsv'], 'FileType', 'text', 'Delimiter', '\t');
end

% ------------------------------------------------------------------------%
%                        Convert Event File into TSV/XLSX                 %
% ------------------------------------------------------------------------%

if data.output.export_xlsx
    % Write the table to an XLSX file
    writetable(event_table, [data.dir.event_path filesep data.output.event_file_name '.xlsx']);
end

if data.output.export_tsv
    % Write the table to a TSV file
    writetable(event_table, [data.dir.event_path filesep data.output.event_file_name '.tsv'], 'FileType', 'text', 'Delimiter', 'tab');
end

% ------------------------------------------------------------------------%
%                              Functions                                  %
% ------------------------------------------------------------------------%

function [event_table,index, tr_number] = create_event(event_table, index, tr_number, trigger, time, datetime)
    % event_var -> event table variable
    % index     -> row number to add data
    % trigger   -> string/char characterizing event
    % time      -> time since beginning of experiment
    % datetime  -> datetime
    newRow = table(tr_number, time, datetime, trigger,...
    'VariableNames',{'TR', 'RelativeTime', 'Datetime', 'Description'});
    event_table(index,:) = newRow;    
    index                = index + 1;
    tr_number            = tr_number + 1; 
end