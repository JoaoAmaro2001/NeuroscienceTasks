% Main script for running Emotional Cities' experiment 1 in MRI
% Hit 'esc' to terminate the task
% -------------------------------------------------------------------------

clear; close all; clc; % Clean workspace
settings_main_exp1;    % Load all the settings from the file
HideCursor;            % Hide cursor

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 1. Blank screen
% 2. Screen
% 3. Image and rating
% -------------------------------------------------------------------------

% Init task control vars
begin_task  = false;                      % Flag to begin task
flag_resp   = 0;                          % Flag for response -> can only respond while is 1
flag_input  = 0;                          % Flag for answer -> i if participant answered
simTrCount  = 1;                          % Simulated TR count
trueTrCount = -1;
prevDigit   = -1;                         % Initialize prevDigit

% Init state gatekeepers (0 if not entering state for first time before everything ran)
state1_gate = 1;
state2_gate = 1;
state3_gate = 1;

% -------------------------------------------------------------------------
%                       Set variables for Log File
% -------------------------------------------------------------------------

trialCounter      = 0;
rt_valence        = nan(1,data.task.stims_per_run); 
choice_valence    = nan(1,data.task.stims_per_run); 
stim              = cell(1,data.task.stims_per_run);

% -------------------------------------------------------------------------
%                       Set variables for event files
% -------------------------------------------------------------------------

% Description:
% - capture simulated TR trigger
% - capture MRI TR triggers
% - capture time information

eventCounter = 1;
event_table  = table('Size', [data.mri.num_volumes*2+50, 4],...
    'VariableTypes', {'double', 'double', 'datetime', 'string'}, ...
    'VariableNames', {'TR', 'RelativeTime', 'Datetime', 'Description'});

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------

% Initial state
state = 1;

% Prelim state
Screen('TextSize', window1, data.format.font_size);
DrawFormattedText(window1, eval(strcat('data.text.getready', data.task.language_suffix)),...
                  'center', 'center', data.format.text_color);
Screen('Flip', window1);
WaitSecs(data.task.duration_preparation);

while trialCounter <= data.task.stims_per_run

    % ------------------------------------------------------------------------%
    %                               AUXILLIARY                                %
    % ------------------------------------------------------------------------%    
    
        % % % % % % % % % % % %
        % MRI TRIGGER CONTROL %
        % % % % % % % % % % % %
        
        % Wait for first mri trigger
        if trueTrCount == -1 && ~data.debug
            aux        = read(s,1,'uint8'); disp(aux);
            if aux == data.mri.tr_trigger 
                trueTrCount= trueTrCount + 1;
                begin_task = true;
                init_time  = tic;
                fprintf('Received first trigger: TR nº0 at %f seconds\n', toc(init_time))
            end
            flush(s)
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
                fprintf('TR nº%d - at %f seconds\n', simTrCount,toc(init_time))
                [event_table,eventCounter,simTrCount] = create_event_mri(event_table,...
                eventCounter, simTrCount, "SimTR", toc(init_time), datetime('now','Format','dd-MMM-yyyy HH:mm:ss.SS'));
            end
            prevDigit = firstDigit; % Update prevDigit
        end
    
        % Fetch true mri triggers
        if ~data.debug
            if s.NumBytesAvailable > 0 && trueTrCount ~= -1
                allBytes = read(s, s.NumBytesAvailable, 'uint8'); % Read all available bytes
                for i = 1:length(allBytes)
                    byte = allBytes(i);
                    if byte == data.mri.tr_trigger
                        % Log TR event
                        [event_table,eventCounter,trueTrCount] = create_event_mri(event_table,...
                        eventCounter, trueTrCount, "TrueTR", toc(init_time), datetime('now','Format','dd-MMM-yyyy HH:mm:ss.SS'));
                        fprintf('Fetching mri trigger at %f seconds - TR nº%d\n', toc(init_time), trueTrCount);
                    end
                end
                % Clear buffer after loop (useless?)
                allBytes = [];
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
    
        if state == 3 && flag_resp && data.task.handedness == 1 
            [keyIsDown, ~, keyCode] = KbCheck; 
            if keyIsDown && keyCode(button1)
                disp('button1===========================================')
                flag_input   = 1;
                rating_value = 1; fprintf('Answer - %d\n',rating_value)
                imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_1.PNG'));
            elseif keyIsDown && keyCode(button2)
                disp('button2===========================================')
                flag_input   = 1;
                rating_value = 2; fprintf('Answer - %d\n',rating_value)
                imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_2.PNG'));
            elseif keyIsDown && keyCode(button3)
                disp('button3===========================================')
                flag_input   = 1;
                rating_value = 3; fprintf('Answer - %d\n',rating_value)     
                imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_3.PNG'));                
            elseif keyIsDown && keyCode(button4)
                disp('button4===========================================')
                flag_input   = 1;
                rating_value = 4; fprintf('Answer - %d\n',rating_value)
                imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_4.PNG'));                
            end
            if flag_input
                % Update screen
                imageDisplay2   = Screen('MakeTexture', window1, imgScore);
                imgScoreResized = imresize(imgScore, 0.7);
                imageSize       = size(imgScoreResized);
                pos2            = [(data.screen.pixelx - imageSize(2)) / 2,...
                                    data.screen.pixely * 0.75,...
                                   (data.screen.pixelx + imageSize(2)) / 2,...
                                    data.screen.pixely * 0.75 + imageSize(1)];
                imageDisplays   = [imageDisplay1, imageDisplay2];
                positions       = [pos_stim', pos2'];
                % Display 
                Screen('FillRect', window1, data.format.background_color);
                Screen('DrawTextures', window1, imageDisplays, [], positions);
                Screen('Flip', window1);   
                % Don't allow more answers
                flag_resp    = 0;
                flag_input   = 0;
                % Log values
                rt_valence(trialCounter)     = toc(image_start);
                choice_valence(trialCounter) = rating_value;
            end
        end

        % When enterring this module (2 handed), note that the same port will receive
        % triggers from the TR and joystick, which can (and probably will) mess up the events 
        if state == 3 && flag_resp && data.task.handedness == 2
            if s.NumBytesAvailable > 0 && ~data.debug
                allBytes = read(s, s.NumBytesAvailable, 'uint8'); % reading removes the bytes from the buffer
                for i = 1:length(allBytes)
                    byte = allBytes(i);
                    if byte == data.mri.tr_trigger
                        % Process TR
                        [event_table,eventCounter,trueTrCount] = create_event_mri(event_table,...
                        eventCounter, trueTrCount, "TrueTR", toc(init_time), datetime('now','Format','dd-MMM-yyyy HH:mm:ss.SS'));
                        fprintf('Fetching mri trigger at %f seconds - TR nº%d\n', toc(init_time), trueTrCount);
                    else
                        % Process response
                        aux = byte;
                        if aux == button1
                            disp('button1===========================================')
                            flag_input   = 1;
                            rating_value = 1; fprintf('Answer - %d\n',rating_value)
                            imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_1.PNG'));
                        elseif aux == button2
                            disp('button2===========================================')
                            flag_input   = 1;
                            rating_value = 2; fprintf('Answer - %d\n',rating_value)
                            imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_2.PNG'));
                        elseif aux == button3
                            disp('button3===========================================')
                            flag_input   = 1;
                            rating_value = 3; fprintf('Answer - %d\n',rating_value)
                            imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_3.PNG'));        
                        elseif aux == button4
                            disp('button4===========================================')
                            flag_input   = 1;
                            rating_value = 4; fprintf('Answer - %d\n',rating_value)
                            imgScore     = imread(fullfile(data.dir.allstim_path, 'Score_4.PNG'));
                        end
                    end
                end
                % Clear buffer after loop (useless?)
                allBytes = [];
            end
            if flag_input
                % Update screen
                imageDisplay2   = Screen('MakeTexture', window1, imgScore);
                imgScoreResized = imresize(imgScore, 0.7);
                imageSize       = size(imgScoreResized);
                pos2            = [(data.screen.pixelx - imageSize(2)) / 2,...
                                    data.screen.pixely * 0.75,...
                                   (data.screen.pixelx + imageSize(2)) / 2,...
                                    data.screen.pixely * 0.75 + imageSize(1)];
                imageDisplays   = [imageDisplay1, imageDisplay2];
                positions       = [pos_stim', pos2'];
                % Display 
                Screen('FillRect', window1, data.format.background_color);
                Screen('DrawTextures', window1, imageDisplays, [], positions);
                Screen('Flip', window1);   
                % Don't allow more answers
                flag_resp    = 0;
                flag_input   = 0;
                % Log values
                rt_valence(trialCounter)     = toc(image_start);
                choice_valence(trialCounter) = rating_value;
            end
        end
    
    % ------------------------------------------------------------------------%
    %                                TASK                                     %
    % ------------------------------------------------------------------------%
    if begin_task

        switch state

            case 1        
                % 1. Blank screen       
                if state1_gate
                    state1_gate     = 0;
                    trialCounter    = trialCounter + 1;
                    this_blank_time = data.sequence.blank_times(trialCounter);                    
                    Screen('FillRect', window1, data.format.background_color);
                    Screen('Flip', window1);
                    blank_time  = tic;
                end
                if toc(blank_time) >= this_blank_time
                    state1_gate = 1;
                    state       = 2;
                end                

            case 2
                % 2. Cross    
                if state2_gate
                    state2_gate = 0;
                    this_cross_time = data.sequence.cross_times(trialCounter);
                    drawCross(window1, data.screen.pixelx, data.screen.pixely);
                    Screen('Flip', window1);
                    cross_time  = tic;
                end
                if toc(cross_time) >= this_cross_time
                    state2_gate = 1;
                    state       = 3;
                end                

            case 3
                % 3. Image Stimulus
                if state3_gate 
                    
                    % Close gate
                    state3_gate = 0;
                    
                    % Load image
                    imageFile = data.stim.files{trialCounter}; 
                    fprintf('Stimulus - %s; Trial nº %d\n', imageFile, trialCounter);
                    fprintf('Time elapsed since beginning: %f minutes\n', toc(init_time)/60);
                    imageDir = fullfile(data.dir.stim_path, imageFile);
                    stim{trialCounter} = imageFile;

                    % Draw screen
                    img = imread(imageDir);
                    img = imresize(img, data.screen.resizex); % adjust for screen
                    
                    % Calculate image position (centered)
                    shift = 0.1 * data.screen.pixely;
                    imageSize = size(img);
                    pos_stim = [(data.screen.pixelx - imageSize(2)) / 2,...
                                (data.screen.pixely - imageSize(1)) / 2 - shift,...
                                (data.screen.pixelx + imageSize(2)) / 2,...
                                (data.screen.pixely + imageSize(1)) / 2 - shift];
                    imageDisplay1 = Screen('MakeTexture', window1, img);
                    
                    % Load initial score image
                    imgScoreInitial = imread(fullfile(data.dir.allstim_path,'Start_scoring.PNG'));   
                    imageDisplay2   = Screen('MakeTexture', window1, imgScoreInitial);
                    imgScoreResized = imresize(imgScoreInitial, 0.7);
                    imageSize       = size(imgScoreResized);
                    pos_score       = [(data.screen.pixelx - imageSize(2)) / 2,...
                                        data.screen.pixely * 0.75,...
                                       (data.screen.pixelx + imageSize(2)) / 2,...
                                        data.screen.pixely * 0.75 + imageSize(1)];
                    
                    % Combine image displays
                    imageDisplays = [imageDisplay1, imageDisplay2];
                    positions     = [pos_stim', pos_score'];
                    
                    % Display images
                    Screen('FillRect', window1, data.format.background_color);
                    Screen('DrawTextures', window1, imageDisplays, [], positions);  
                    Screen('Flip', window1);
                    fprintf('Estado: Imagem nº %d\n', trialCounter)      
                                     
                    % Count time and allow answers
                    flag_resp   = 1;
                    image_start = tic;                    
                end
                if toc(image_start) >= data.task.duration_image
                    state3_gate = 1;
                    state       = 1;
                    if flag_input
                        % Update screen
                        imgScore        = imread(fullfile(data.dir.allstim_path, 'Score_0.PNG'));
                        imageDisplay2   = Screen('MakeTexture', window1, imgScore);
                        imgScoreResized = imresize(imgScore, 0.7);
                        imageSize       = size(imgScoreResized);
                        pos2            = [(data.screen.pixelx - imageSize(2)) / 2,...
                                            data.screen.pixely * 0.75,...
                                           (data.screen.pixelx + imageSize(2)) / 2,...
                                            data.screen.pixely * 0.75 + imageSize(1)];
                        imageDisplays   = [imageDisplay1, imageDisplay2];
                        positions       = [pos_stim', pos2'];
                        % Display 
                        Screen('FillRect', window1, data.format.background_color);
                        Screen('DrawTextures', window1, imageDisplays, [], positions);
                        Screen('Flip', window1);    
                        % Log values
                        rt_valence(trialCounter)     = NaN;
                        choice_valence(trialCounter) = NaN;
                        flag_resp                    = 0;
                    end
                    flag_input = 0;
                end                   
        end
    end
end

% Clear screen
sca;

% Export data struct
save([data.dir.data_path filesep data.output.data_file_name '.mat'], 'data');

% ------------------------------------------------------------------------%
%                          Convert Log File into TSV/XLSX                 %
% ------------------------------------------------------------------------%
addRunColumn = ones(data.task.stims_per_run,1).*str2double(data.input{3});
addSubColumn = repmat(data.input{1}, data.task.stims_per_run, 1);
logTable     = table(addSubColumn, addRunColumn, choice_valence', rt_valence', stim',...
    'VariableNames', {'sub', 'run', 'valence', 'rt_valence', 'stimulus'});
save([data.dir.logs_path filesep data.output.log_file_name '.mat'], 'logTable');

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

% Remove NaT rows and save as .mat file
event_table = event_table(~isnat(event_table.Datetime),:);
save([data.dir.event_path filesep data.output.event_file_name '.mat'], 'event_table');

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

function [event_table,index, tr_number] = create_event_mri(event_table, index, tr_number, trigger, time, datetime)
    % Event table to log MRI triggers
    % -----------------------------------------------
    % Columns:
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

function [event_table, index, tr_number] = create_event(event_table, index, tr_number, trigger, time, datetime)
    % Build a table for _events.tsv according to BIDS
    % ---------------------------------------------------------------------
    % The events table follows the BIDS specification (Gorgolewski et al., 2016),
    % which requires at least the following columns:
    %   - onset (number): onset time in seconds from the beginning of the run.
    %   - duration (number): duration of the event in seconds (>= 0).
    %
    % Optional columns include:
    %   - trial_type (string): categorization of the event (here we use the trigger)
    %   - response_time (number): response time in seconds (NaN if unavailable)
    %   - HED (string): Hierarchical Event Descriptor tags
    %   - stim_file (string): relative path to any associated stimulus file
    %   - channel (string): channel(s) associated with the event
    %
    % Inputs:
    %   event_table - existing table (can be empty) to which the event is appended.
    %   index       - current row index for insertion.
    %   tr_number   - trial number (or event counter).
    %   trigger     - string describing the event (will populate trial_type).
    %   time        - onset time (in seconds).
    %   datetime    - a datetime object (not part of BIDS, but can be logged).
    %
    % Outputs:
    %   event_table - updated table with the new event row appended.
    %   index       - updated row index.
    %   tr_number   - updated trial/event counter.
    
    % If the table hasn't been initialized, create it with BIDS columns.
    if isempty(event_table)
        % Init table
        event_table = table('Size',[0 7], ...
            'VariableTypes',{'double','double','cell','double','cell','cell','cell'}, ...
            'VariableNames',{'onset', 'duration', 'trial_type', 'response_time', 'HED', 'stim_file', 'channel'});
    end
    
    % Define default values:
    %   - duration is set to 0 (impulse event)
    %   - trial_type is set to trigger,
    %   - response_time is not available (NaN),
    %   - HED, stim_file, and channel are empty strings.
    %
    % The datetime value is not part of the BIDS events.tsv spec, so it is omitted.
    newRow = {time, 0, trigger, NaN, '', '', ''};
    
    % Append the new row to the event table.
    event_table = [event_table; newRow];
    
    % Update indices.
    index = index + 1;
    tr_number = tr_number + 1;
end

% function triggers_eeg()

