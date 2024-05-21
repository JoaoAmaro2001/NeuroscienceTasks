
function addResponseOptions(windowPtr, responseOptions)
    
    % Get the size of the window
    [windowWidth, windowHeight] = Screen('WindowSize', windowPtr);
    
    % Define the positions for the text
    positions = [
        windowWidth * 0.25, windowHeight * 0.25;  % Upper left
        windowWidth * 0.25, windowHeight * 0.75;  % Lower left
        windowWidth * 0.75, windowHeight * 0.25;  % Upper right
        windowWidth * 0.75, windowHeight * 0.75   % Lower right
    ];
    
    % Set the text size
    Screen('TextSize', windowPtr, 24);
    
    % Add the text to the screen
    for i = 1:length(responseOptions)
        DrawFormattedText(windowPtr, responseOptions{i}, positions(i, 1), positions(i, 2), [255, 255, 255]);
    end
    
    % Flip the screen to show the text
    Screen('Flip', windowPtr);
end

function checkKeyPressAndDisplayBoldText(windowPtr, responseOptions, positions)
    % Check for key press
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        % Find the index of the pressed key
        key = find(keyCode);
        
        % If the key index corresponds to a response option, display the corresponding text in bold
        if key > 0 && key <= length(responseOptions)
            % Set the text style to bold
            Screen('TextStyle', windowPtr, 1);
            
            % Draw the text
            DrawFormattedText(windowPtr, responseOptions{key}, positions(key, 1), positions(key, 2), [255, 255, 255]);
            
            % Flip the screen to show the text
            Screen('Flip', windowPtr);
            
            % Set the text style back to normal
            Screen('TextStyle', windowPtr, 0);
        end
    end
end