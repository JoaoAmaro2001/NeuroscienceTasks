% Participant ID: PID_<PATIENT/CONTROL><RIGHT/LEFT>_<XXX>
% e.g. PID_CR_001 or PID_PL_011
% Participants:
% 1) sub-
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
clear, clc, close all
init_experiment;
sub_id     = input("Write the participant's id code:\n", 's');
task       = 'imagerating';
lang       = '_pt';  % _en for english and _pt for portuguese
handedness = 1;      % 1 for one handed or 2 for two handed joysticks
settings_main_sim;       % Load all the settings from the file

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 1. Blank screen
% 2. Cross
% 3. Image
% -------------------------------------------------------------------------

% Init (only change the first parameter)
state       = 1;                    % Gets the state information
been_here   = 0;                    % Whether while loop has been in that state
tr_final    = stimuli_number*TR*4;  % Number of triggers == 640 (8 seconds/trial)
tr_trigger  = -1;                   % TR trigger counter (There are 640 -> 10.6 mins)
trial_num   = 0;                    % Trial counter
evt_counter = 0;                    % Counter for new stored events
flag_resp   = 0;                    % Flag for response -> can only respond while is 1
flag_answer = 0;                    % FLag to know if subject answered
true_tr_time= 0;                    % Init variable holding true time for the TR value
% LOG INFO
rt_num      = zeros(1,stimuli_number);          % Reaction time for response
res_num     = zeros(1,stimuli_number);          % Response number
trial       = zeros(1,stimuli_number);          % Trial number
stim_cell   = cell(1,stimuli_number);

% EVENT INFO (TR INFO + TASK INFO)
T_events = table('Size', [10000, 7], 'VariableTypes', {'double', 'double', 'datetime', 'double', 'double', 'double', 'string'}, ...
'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference','Description'});

% Pyschtoolblox prelim
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/2), (H/2), textColor);
Screen('Flip',window1);
WaitSecs(5)

% BLANK SCREEN
Screen(window1, 'FillRect', backgroundColor);
Screen('Flip', window1); % Flip the screen (don't clear the buffer)
disp('Estado: Ecrã em branco')

% Start the experiment
while 1
    
    % END OF EXPERIMENT 
    if tr_trigger == tr_final && trial_number == stimuli_number 
        break
    end

    if tr_trigger == -1
        tstart_sim = tic; % Tic for simulation
        start_exp = GetSecs;
        state     = 1;
        tr_trigger = tr_trigger + 1;
        first_trigger = 1;
        prevDigit = -1;
        fprintf('First trigger received - beginning volumes\n')
    else    
        % SIMULATING SERIAL PORT COMMUNICATION
        timetmp = toc(tstart_sim);
        firstDigit = str2double(num2str(floor(timetmp)));
        if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
            aux = 115;
            tr_trigger = tr_trigger + 1;
            evt_counter = evt_counter + 1;
            toc; % beep
            % Create a new row for the event info table---------------------------------------------------------------------
            currentTime = GetSecs();
            newRow = table(tr_trigger, trial_num, datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS'), currentTime - start_exp, currentTime - toc, true_tr_time - currentTime, "tr",...
            'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
            T_events(evt_counter,:) = newRow;
            %---------------------------------------------------------------------------------------------------------------
        else
            aux = [];
        end
        prevDigit = firstDigit; % Update prevDigit
    end

    % MANUAL CONTROL 
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    if keyIsDown
        if keyCode(terminateKey) % Check if the terminate key was pressed
            break % Exit the function or script
        end
        if keyCode(hotkey) % Check if the hotkey was pressed
            aux = 115;
        end
    end
    
    % BUTTON CHECK CONTROL CONTROL (one-handed joystick)
    if state == 3 && flag_resp && handedness == 1 && tr_trigger ~= -1
        [keyIsDown, ~, keyCode] = KbCheck; 
        if keyIsDown && keyCode(button1)
            disp('button1-------------------------------------------')
            flag_answer = 1;
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_1.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);            
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 1;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button2)
            disp('button2-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_2.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 2;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button3)
            disp('button3-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_3.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 3;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button4)
            disp('button4-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_4.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 4;  
            flag_resp               = 0;
        end
    end
    
    % BUTTON CHECK CONTROL CONTROL (two-handed joystick)
    if state == 3 && flag_resp && handedness == 2 && tr_trigger ~= -1
        [keyIsDown, ~, keyCode] = KbCheck; 
        if keyIsDown && keyCode(button1)
            disp('button1-------------------------------------------')
            flag_answer = 1;
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_1.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);            
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 1;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button2)
            disp('button2-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_2.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 2;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button3)
            disp('button3-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_3.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 3;  
            flag_resp               = 0;
        end
        if keyIsDown && keyCode(button4)
            disp('button4-------------------------------------------')
            flag_answer = 1;            
            % Update screen
            imgScore = imread(fullfile(orip,'img', 'score', 'Score_4.JPG'));
            imageDisplay2 = Screen('MakeTexture', window1, imgScore);
            imgScoreResized = imresize(imgScore, 0.7);
            imageSize = size(imgScoreResized);
            pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
            imageDisplays = [imageDisplay1, imageDisplay2];
            positions = [pos1', pos2'];
            % Display 
            Screen('FillRect', window1, backgroundColor);
            Screen('DrawTextures', window1, imageDisplays, [], positions);
            Screen('Flip', window1);    
            % Log vars
            rt                      = toc(image_start);
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 4;  
            flag_resp               = 0;
        end
    end

    % TR-DEPENDENT STIMULUS CONTROL 
    if first_trigger

        switch state

            case 1
                % 1. Blank screen
                if ~been_here
                been_here = 1;
                trial_num = trial_num + 1;
                trial(trial_num) = trial_num;
                this_blank_time = blank_times(trial_num);
                % Draw screen
                Screen(window1, 'FillRect', backgroundColor);
                Screen('Flip', window1); % Flip the screen (don't clear the buffer)
                disp('Estado: Ecrã em branco')      
                % Count time
                blank_start = tic;
                % Create a new row for the event info table---------------------------------------------------------------------
                evt_counter = evt_counter + 1;
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS'), currentTime - start_exp, this_blank_time, NaN, "blank",...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(evt_counter,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------       
                end
                if toc(blank_start)>=this_blank_time
                    state = 2;
                    been_here = 0;
                end

            case 2
                % 2. Cross counter
                if ~been_here
                been_here = 1;
                this_cross_time = cross_times(trial_num);
                % Draw screen
                drawCross(window1, W, H);
                Screen('Flip', window1);
                disp('Estado: Cross')      
                % Count time
                cross_start = tic;                
                % Create a new row for the event info table---------------------------------------------------------------------
                evt_counter = evt_counter + 1;
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS'), currentTime - start_exp, this_cross_time, NaN, "cross",...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(evt_counter,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------         
                end
                if toc(cross_start)>=this_cross_time
                    state = 3;
                    been_here = 0;
                end                

            case 3
                % 3. Image Stimulus
                if ~been_here                
                been_here = 1;
                this_image_time = 4; % 4 seconds
                stim_cell{trial_num} = sequence{trial_num};
                fprintf('Imagem %s\n', sequence{trial_num})

                % Draw screen
                img = imread(fullfile(orip,'img', 'stim', sequence{trial_num}));
                img = imresize(img, 2);
                
                % Calculate image position (centered)
                imageSize = size(img);
                pos1 = [(W - imageSize(2)) / 2, (H - imageSize(1)) / 2, (W + imageSize(2)) / 2, (H + imageSize(1)) / 2];
                imageDisplay1 = Screen('MakeTexture', window1, img);
                
                % Load initial score image
                imgScoreInitial = imread(fullfile(orip,'img', 'score', 'Start_scoring.JPG'));   
                imageDisplay2 = Screen('MakeTexture', window1, imgScoreInitial);
                imgScoreResized = imresize(imgScoreInitial, 0.7);
                imageSize = size(imgScoreResized);
                pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
                
                % Combine image displays
                imageDisplays = [imageDisplay1, imageDisplay2];
                positions = [pos1', pos2'];
                
                % Display images
                Screen('FillRect', window1, backgroundColor);
                Screen('DrawTextures', window1, imageDisplays, [], positions);  
                Screen('Flip', window1);
                fprintf('Estado: Imagem nº %d\n', trial_num)      
                             
                % Create a new row for the event info table---------------------------------------------------------------------
                evt_counter = evt_counter + 1;
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSSSSS'), currentTime - start_exp, this_image_time, NaN, "image",...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(evt_counter,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------         
                % Count time and allow answers
                flag_resp = 1;
                image_start = tic;                    
                end
                if toc(image_start)>=this_image_time
                    state = 1;
                    been_here = 0;
                    disp('hey')
                    if ~flag_answer
                        % Update screen
                        imgScore = imread(fullfile(orip,'img', 'score', 'Score_0.JPG'));
                        imageDisplay2 = Screen('MakeTexture', window1, imgScore);
                        imgScoreResized = imresize(imgScore, 0.7);
                        imageSize = size(imgScoreResized);
                        pos2 = [(W - imageSize(2)) / 2, H * 0.75, (W + imageSize(2)) / 2, H * 0.75 + imageSize(1)];
                        imageDisplays = [imageDisplay1, imageDisplay2];
                        positions = [pos1', pos2'];
                        % Display 
                        Screen('FillRect', window1, backgroundColor);
                        Screen('DrawTextures', window1, imageDisplays, [], positions);
                        Screen('Flip', window1);    
                        % Log vars
                        rt_num(trial_num)       = NaN;
                        res_num(trial_num)      = NaN;  
                        flag_resp               = 0;
                    end
                    disp('bye')
                    flag_answer = 0;
                end                   

        end
    end
end

sca;
end_exp = GetSecs;
fprintf('Tempo total: %f seconds\n', end_exp-start_exp) % Total time of the experiment

% Save event information in excel file
eventname_file = [event_path strcat('\sub-',sub_id,'_task-',task,'_events.xlsx')];
T_events(ismissing(T_events.Datetime), :) = [];
writetable(T_events,eventname_file)

% Save log information in excel file
logname_file = [log_path strcat('\sub-',sub_id,'_task-',task,'_log.xlsx')];
T_log = table(trial', stim_cell', res_num',rt_num','VariableNames',{'Trial','Type','Response','ReactionTime'});
writetable(T_log,logname_file)

