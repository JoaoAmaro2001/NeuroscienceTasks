% Participant ID: PID_<PATIENT/CONTROL><RIGHT/LEFT>_<XXX>
% e.g. PID_CR_001 or PID_PL_011
% Participants:
% 1) sub-
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
clear, clc, close all
init_experiment;
sub_id     = input("Write the participant's id code:\n", 's');
task       = 'sentences';
lang       = '_pt';  % _en for english and _pt for portuguese
handedness = 1;      % 1 for one handed or 2 for two handed joysticks
settings_main;       % Load all the settings from the file

% -------------------------------------------------------------------------
%                           State Information:
%                               
% 1. Blank screen
% 2. Screen
% 3. Image
% 4. Rating
% -------------------------------------------------------------------------

% Init (only change the first parameter)
state       = 1;                    % Gets the state information
next_state  = 0;                    % Tells wether I can change to next state
been_here   = 0;                    % Whether while loop has been in that state
tr_final    = stimuli_number*TR*4;  % Number of triggers == 640 (8 seconds/trial)
tr_trigger  = -1;                   % TR trigger counter (There are 640 -> 10.6 mins)
trigger_one = 0;                    % Whether first trigger has been received
tr_cross    = 0;                    % tr counter for cross
num_cross   = 0;                    % Counter for the cross state
trial_num   = 0;                    % Trial counter
flag_screen = 1;                    % Flag for updating screen
flag_resp   = 1;                    % Flag for response -> can only respond while is 1
flag_first  = 1;                    % Flag for first time reading the aux
true_tr_time= 0;                    % Init variable holding true time for the TR value
beg_cross   = 0;                    % Variable telling if we have already reached a cross block
% LOG INFO
rt_num      = zeros(1,stimuli_number);          % Reaction time for response
res_num     = zeros(1,stimuli_number);          % Response number
trial       = zeros(1,stimuli_number);          % Absolute Trial number

% EVENT INFO (TR INFO + TASK INFO)
T_events = table('Size', [10000, 7], 'VariableTypes', {'double', 'double', 'datetime', 'double', 'double', 'double', 'string'}, ...
'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference','Description'});

% Pyschtoolblox prelim
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/3), (H/2), textColor);
Screen('Flip',window1);
WaitSecs(5)

% BLANK SCREEN
Screen(window1, 'FillRect', backgroundColor);
Screen('Flip', window1); % Flip the screen (don't clear the buffer)
disp('Estado: Ecrã em branco')

% Start the experiment
while 1

    if tr_trigger == -1
        % FMRI SERIAL PORT COMMUNICATION FOR FIRST TRIGGER    
        flush(s)
        aux = read(s,1,'uint8'); disp(aux);
        prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
        tstart_sim = tic; % Tic for simulation
        % TR-DEPENDENT STIMULUS CONTROL (FIRST TRIGGER ONLY)
        if ~isempty(aux) && (aux == 115) && ~first_trigger     
            if tr_trigger == -1
                start_exp = GetSecs;
                state     = 1;
                tr_trigger = tr_trigger + 1;
                first_trigger = 1;
                fprintf('First trigger received - beginning volumes\n')
            end    
        end        
    else
        % LISTENING TO TRUE FMRI TR TRIGGERS
        flush(s)
        true_tr = read(s,1,'uint8');
        if ~isempty(true_tr) && (true_tr == 115)
            true_tr_time = GetSecs();
            fprintf('Fetching TRUE TR at %f seconds \n', true_tr_time - start_exp)
        end        
        % SIMULATING SERIAL PORT COMMUNICATION
        timetmp = toc(tstart_sim);
        firstDigit = str2double(num2str(floor(timetmp)));
        if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
            aux = 115;
            tr_trigger = tr_trigger + 1;
            toc; % beep
            % Create a new row for the event info table---------------------------------------------------------------------
            currentTime = GetSecs();
            newRow = table(tr_trigger, trial_num, datetime, currentTime - start_exp, currentTime - toc, true_tr_time - currentTime, "tr",...
            'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
            T_events(tr_trigger,:) = newRow;
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
    
    % BUTTON CHECK CONTROL CONTROL (both types of joystick)
    if state == 3 && flag_resp && handedness == 1 && tr_trigger ~= -1
        next_state = 0;
        [keyIsDown, ~, keyCode] = KbCheck; 
        if keyIsDown && keyCode(button1)
            disp('button1-------------------------------------------')
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 1;  
            flag_resp               = 0;
            next_state              = 1;
        end
        if keyIsDown && keyCode(button2)
            disp('button2-------------------------------------------')
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 2;  
            flag_resp               = 0;
            next_state              = 1;
        end
        if keyIsDown && keyCode(button3)
            disp('button3-------------------------------------------')
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 3;  
            flag_resp               = 0;
            next_state              = 1;
        end
        if keyIsDown && keyCode(button4)
            disp('button4-------------------------------------------')
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 4;  
            flag_resp               = 0;
            next_state              = 1;
        end
    end

    if state == 3 && flag_resp && handedness == 2 && tr_trigger ~= -1
        [keyIsDown, ~, keyCode] = KbCheck;         
        if aux == button1
            boldOption              = 1;
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 1;  
            res_txt{trial_num}      = responseOptions{1}; 
            flag_resp               = 0;
            boldOption              = [];
        elseif aux == button2
            boldOption              = 2;
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 2;  
            res_txt{trial_num}      = responseOptions{2}; 
            flag_resp               = 0;
            boldOption              = [];
        elseif aux == button3
            boldOption              = 3;
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 3;  
            res_txt{trial_num}      = responseOptions{3}; 
            flag_resp               = 0;
            boldOption              = [];
        elseif aux == button4
            boldOption              = 4;
            drawText(window1, text_input, trialnumi, W, H, backgroundColor, textColor)
            addResponseOptions(window1, responseOptions, boldOption)
            rt_end                  = GetSecs;
            rt                      = rt_end - rt_beg;
            rt_num(trial_num)       = rt;
            res_num(trial_num)      = 4;  
            res_txt{trial_num}      = responseOptions{4}; 
            flag_resp               = 0;
            boldOption              = [];
        end
    end

    % TR-DEPENDENT STIMULUS CONTROL 
    if ~first_trigger && next_state

        switch state

            case 1
                % 1. Blank screen
                if ~been_here
                been_here = 1;
                trial_num = trial_num + 1;
                this_blank_time = blank_times(trial_num);
                % Draw screen
                Screen(window1, 'FillRect', backgroundColor);
                Screen('Flip', window1); % Flip the screen (don't clear the buffer)
                disp('Estado: Ecrã em branco')      
                % Count time
                blank_start = tic;
                % Create a new row for the event info table---------------------------------------------------------------------
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime, currentTime - start_exp, this_blank_time, NaN, 'blank',...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
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
                drawCross(window_1, W, H);
                Screen('Flip', window_1);
                disp('Estado: Cross')      
                % Count time
                cross_start = tic;                
                % Create a new row for the event info table---------------------------------------------------------------------
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime, currentTime - start_exp, this_cross_time, NaN, 'cross',...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
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
                % Draw screen
                img = imread(fullfile(orip,'img', 'stim', sequence{trial_num}));
                img = imresize(img, 2);
                imageDisplay1 = Screen('MakeTexture', window1, img);
                % Calculate image position (centered)
                imageSize = size(img);
                pos = [(W - imageSize(2)) / 2, (H - imageSize(1)) / 2, (W + imageSize(2)) / 2, (H + imageSize(1)) / 2];
                % Count time
                image_start = tic;                
                % Create a new row for the event info table---------------------------------------------------------------------
                currentTime = GetSecs();
                newRow = table(NaN, trial_num, datetime, currentTime - start_exp, this_image_time, NaN, 'image',...
                'VariableNames', {'TR', 'Trial', 'Datetime', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------         
                end
                if toc(image_start)>=this_image_time
                    state = 1;
                    been_here = 0;
                end                   

                
            case 4
                % 3. Load neutral stimulus
                fprintf('Estado: Bloco neutro e frase nº%d\n', trial_num)
                tr_trigger = tr_trigger + 1; fprintf('TR nº%d\n', tr_trigger);
                tr_N = tr_N + 1; fprintf('Block-N TR nº%d\n', tr_N);
                tr_n = tr_n + 1; fprintf('Stimulus TR nº%d\n', tr_n);
                % Create a new row for the event info table---------------------------------------------------------------------
                currentTime = GetSecs();
                newRow = table(tr_trigger, currentTime - start_exp, currentTime - toc, currentTime, "Neutral Stimuli",...
                'VariableNames', {'TR', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------
                if tr_n==0 & beg_cross
                    % Create a new row for the event info table
                    currentTime = GetSecs();
                    loopTime    = toc;
                    newRow = table(tr_trigger, currentTime - start_exp, loopTime - timetmp, currentTime, "Cross",...
                    'VariableNames', {'TR', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                    T_events(tr_trigger,:) = newRow;
                end                
                %---------------------------------------------------------------------------------------------------------------
                if tr_n == 4
                    stim_input = eval(strcat('textNeutralStimuli', lang));
                    % Fill variables for the log file
                    if rt_num(trial_num) == 0
                        rt_num(trial_num)   = NaN;
                        res_num(trial_num)  = NaN;         
                        trial(trial_num)    = trial_num;
                        btrial(trial_num)   = trial_neu;
                        stim_txt{trial_num} = stim_input{trial_neu};         
                        res_txt{trial_num}   = "";
                        cond{trial_num}     = cond_text{2};
                    else
                        rt_num(trial_num)   = rt_num(trial_num);
                        res_num(trial_num)  = res_num(trial_num);
                        trial(trial_num)    = trial_num;
                        btrial(trial_num)   = trial_neu;
                        stim_txt{trial_num} = stim_input{trial_neu};
                        res_txt{trial_num}  = res_txt{trial_num};
                        cond{trial_num}     = cond_text{2};
                    end
                    % Prepare for the next stimulus
                    trial_num   = trial_num + 1;
                    trial_neu   = trial_neu + 1;
                    tr_n        = 0;
                    flag_screen = 1;
                    flag_resp   = 1;
                end
                if flag_screen && tr_N ~= 16
                    drawText(window1, eval(strcat('textNeutralStimuli', lang)), trial_neu, W, H, backgroundColor, textColor)     
                    addResponseOptions(window1, responseOptions, boldOption)
                    rt_beg = GetSecs;
                    flag_screen = 0;
                end
                if tr_N == 16 % 4*4 TRs
                    state = 1;
                    tr_N = -1;
                    tr_n = -1;                    
                    % Go to the cross34
                    num_cross = num_cross + 1;
                    drawCross(window1,W,H);
                    Screen('Flip', window1);
                    disp('Estado: Blank / Cross')                    
                end
        end
    end
end

sca;
end_exp = GetSecs;
fprintf('Tempo total: %f seconds\n', end_exp-start_exp) % Total time of the experiment

% Save event information in excel file
eventname_file = [event_path strcat('\sub-',sub_id,'_task-',task,'_events.xlsx')];
writetable(T_events,eventname_file)

% Save log information in excel file
logname_file = [log_path strcat('\sub-',sub_id,'_task-',task,'_log.xlsx')];
T_log = table(trial', btrial', stim_txt',res_txt',res_num',rt_num',cond','VariableNames',{'Trial','Block Trial','Stimulus','Response', 'ResponseIndex','ReactionTime','Condition'});
writetable(T_log,logname_file)

