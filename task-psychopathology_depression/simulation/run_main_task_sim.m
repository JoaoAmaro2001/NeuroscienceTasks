clear, clc, close all
init_experiment;
sub_id = input("Write the participant's id code:\n", 's');
task   = 'sentences';
handedness = 1;
settings_main_sim; % Load all the settings from the file


% -------------------------------------------------------------------------
%                           State Information:
%                               
% 0. Blank screen (Optional)
% 1. Cross
% 2. Load active stimulus
% 3. Load neutral stimulus
% -------------------------------------------------------------------------

% Init
tr_final    = (8*32 + 8*32)/2;      % Number of triggers
tr_trigger  = -1;                   % TR trigger counter (There are 261 -> ((8*32 + 8*32 + 10)/2) = 8.7 mins)
tr_N        = -1;                   % tr counter inside loop for each block
tr_n        = -1;                   % tr counter inside loop for each stimulus
tr_cross    = 0;                    % tr counter for cross
num_cross   = 0;                    % Counter for the cross state
state       = 2;                    % Gets the state information
ds_block    = 0;                    % Set the ds block counter -> active stimulus
dn_block    = 0;                    % Set the dn block counter -> neutral stimulus
trial_num   = 1;                    % Trial counter
trial_act   = 1;                    % Trial counter for active block
trial_neu   = 1;                    % Trial counter for neutral block
flag_screen = 1;                    % Flag for updating screen
flag_resp   = 1;                    % Flag for response -> can only respond while is 1
flag_first  = 1;                    % Flag for first time reading the aux
boldOption  = [];                   % Variable that carries response info
beg_cross   = 0;                    % Variable for whether we have already reached a cross block
% LOG INFO
rt_num      = zeros(1,32);          % Reaction time for response
res_num     = zeros(1,32);          % Response number
trial       = zeros(1,32);          % Absolute Trial number
btrial      = zeros(1,32);          % Block Trial number
stim_txt    = cell(1,32);           % Stimulus text
res_txt     = cell(1,32);           % Response text
cond        = cell(1,32);           % Conditions
% EVENT INFO
T_events = table('Size', [tr_final, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
'VariableNames', {'TR', 'AbsoluteTime', 'RelativeTime', 'Difference','Description'});

% Read the subject id - handedness information within the id

% Pyschtoolblox prelim
Priority(MaxPriority(window1)); % Give priority of resources to experiment
Screen('TextSize', window1, 50);
Screen('DrawText',window1,'A experiência começará em breve', (W/3), (H/2), textColor);
Screen('Flip',window1);

% Start Experiment
prevDigit = -1;  % Initialize prevDigit to a value that firstDigit will never be
tic;
while 1

    % SIMULATING SERIAL PORT COMMUNICATION
    timetmp = toc;
    firstDigit = str2double(num2str(floor(timetmp)));
    if mod(firstDigit, 2) == 0 && firstDigit ~= prevDigit && firstDigit ~= 0
        aux = 115;
        %beep
        % S(1) = load('gong');
        % S(2) = load('handel');
        % sound(S(1).y,S(1).Fs)
        % sound(S(2).y,S(2).Fs)
        toc
    else
        aux = [];
    end
    prevDigit = firstDigit; % Update prevDigit

    % MANUAL CONTROL
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    if keyIsDown
        if keyCode(terminateKey) % Check if the terminate key was pressed
            break % Exit the function or script
        end
        % if keyCode(hotkey) % Check if the hotkey was pressed
        %     aux = 115;
        % end
    end

    % BUTTON CHECK CONTROL CONTROL (FINISH!)
    if (state == 2 || state == 3) && flag_resp && tr_trigger ~= -1
        [keyIsDown, ~, keyCode] = KbCheck; 
        if state == 2
            text_input = textActiveStimuli;
            trialnumi  = trial_act;
        elseif state == 3
            text_input = textNeutralStimuli;
            trialnumi  = trial_neu;
        end
        if keyIsDown && keyCode(button1)
            disp('button1-------------------------------------------')
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
        end
        if keyIsDown && keyCode(button2)
            disp('button2-------------------------------------------')
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
        end
        if keyIsDown && keyCode(button3)
            disp('button3-------------------------------------------')
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
        end
        if keyIsDown && keyCode(button4)
            disp('button4-------------------------------------------')
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
    if ~isempty(aux) && (aux == 115)

        if tr_trigger == -1
            start_exp = GetSecs;
            fprintf('First trigger received\n')
        end
        if tr_trigger == tr_final % end trigger
            break
        end

        switch state

            % case 0 
            %     % 0. Blank screen
            %     tr_trigger = tr_trigger + 1;
            %     Screen(window1, 'FillRect', backgroundColor);
            %     Screen('Flip', window1); % Flip the screen (don't clear the buffer)
            %     disp('Estado: Ecrã em branco')
            %     if tr_trigger == 4 % It needs to be 5-1 such that tr = 5 begins case 2
            %         state = 2;
            %         ds_block = ds_block + 1; % DS is the first block
            %     end

            case 1
                beg_cross = 1;
                % 1. Cross counter
                tr_trigger = tr_trigger + 1; fprintf('TR nº%d\n', tr_trigger);
                tr_cross = tr_cross + 1; fprintf('Cross TR nº%d\n', tr_cross);
                % Create a new row for the event info table---------------------------------------------------------------------
                currentTime = GetSecs();
                loopTime    = toc;
                newRow = table(tr_trigger, currentTime - start_exp, loopTime - timetmp, currentTime, "Cross",...
                'VariableNames', {'TR', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
                %---------------------------------------------------------------------------------------------------------------                
                if tr_cross == 15 % prepare things before the last TR 
                    tr_cross = 0;
                    if mod(num_cross,2) == 0 % Even is active stimulus
                        state = 2;
                        ds_block = ds_block + 1; % DS is the first block
                        flag_screen = 1;
                    elseif mod(num_cross,2) == 1 % Odd is neutral stimulus
                        state = 3;
                        dn_block = dn_block + 1; % DN is the second block 
                        flag_screen = 1;
                    end
                end

            case 2
                % 2. Load active stimulus
                fprintf('Estado: Bloco ativo e frase nº%d\n', trial_num)
                tr_trigger = tr_trigger + 1; fprintf('TR nº%d\n', tr_trigger);
                tr_N = tr_N + 1; fprintf('Block-A TR nº%d\n', tr_N);
                tr_n = tr_n + 1; fprintf('Stimulus TR nº%d\n', tr_n);
                % Create a new row for the event info table---------------------------------------------------------------------
                if tr_trigger ~= 0
                currentTime = GetSecs();
                newRow = table(tr_trigger, currentTime - start_exp, currentTime - toc, currentTime, "Active Stimuli",...
                'VariableNames', {'TR', 'AbsoluteTime', 'RelativeTime', 'Difference', 'Description'});
                T_events(tr_trigger,:) = newRow;
                end
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
                % End Task
                if tr_trigger == tr_final % end trigger
                    break
                end
                %---------------------------------------------------------------------------------------------------------------                
                if tr_n == 4 % 4 because tr_n=1 signifies beginning of first TR
                    % Fill variables for the log file
                    if rt_num(trial_num) == 0
                        rt_num(trial_num)   = NaN;
                        res_num(trial_num)  = NaN;         
                        trial(trial_num)    = trial_num;   
                        btrial(trial_num)   = trial_act;
                        stim_txt{trial_num} = textActiveStimuli{trial_act};         
                        res_txt{trial_num}  = "";
                        cond{trial_num}     = cond_text{1};
                    else
                        rt_num(trial_num)   = rt_num(trial_num);
                        res_num(trial_num)  = res_num(trial_num);
                        trial(trial_num)    = trial_num;
                        btrial(trial_num)   = trial_act;
                        stim_txt{trial_num} = textActiveStimuli{trial_act};
                        res_txt{trial_num}  = res_txt{trial_num};
                        cond{trial_num}     = cond_text{1};
                    end
                    % Prepare for the next stimulus
                    trial_num   = trial_num + 1;
                    trial_act   = trial_act + 1;
                    tr_n        = 0;
                    flag_screen = 1;
                    flag_resp   = 1;
                end
                if flag_screen && tr_N ~= 16
                    drawText(window1, textActiveStimuli, trial_act, W, H, backgroundColor, textColor)
                    addResponseOptions(window1, responseOptions, boldOption)
                    rt_beg = GetSecs;
                    flag_screen = 0;
                end
                if tr_N == 16 % 4*4 TRs
                    state = 1;
                    tr_N = -1;
                    tr_n = -1;
                    % Go to the cross
                    num_cross = num_cross + 1;
                    drawCross(window1,W,H);
                    Screen('Flip', window1);
                    disp('Estado: Blank / Cross')
                end
                
            case 3
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
                    % Fill variables for the log file
                    if rt_num(trial_num) == 0
                        rt_num(trial_num)   = NaN;
                        res_num(trial_num)  = NaN;         
                        trial(trial_num)    = trial_num;
                        btrial(trial_num)   = trial_neu;
                        stim_txt{trial_num} = textNeutralStimuli{trial_neu};         
                        res_txt{trial_num}   = "";
                        cond{trial_num}     = cond_text{2};
                    else
                        rt_num(trial_num)   = rt_num(trial_num);
                        res_num(trial_num)  = res_num(trial_num);
                        trial(trial_num)    = trial_num;
                        btrial(trial_num)   = trial_neu;
                        stim_txt{trial_num} = textNeutralStimuli{trial_neu};
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
                    drawText(window1, textNeutralStimuli, trial_neu, W, H, backgroundColor, textColor)     
                    addResponseOptions(window1, responseOptions, boldOption)
                    rt_beg = GetSecs;
                    flag_screen = 0;
                end
                if tr_N == 16 % 4*4 TRs
                    state = 1;
                    tr_N = -1;
                    tr_n = -1;
                    % Go to the cross
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
