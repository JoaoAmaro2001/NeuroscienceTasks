function addResponseOptions(windowPtr, responseOptions, boldOption)
       
    % Get the size of the window
    [windowWidth, windowHeight] = Screen('WindowSize', windowPtr);
   
    % Define the positions for the text (symmetrical positions)
    positions = [
        windowWidth * 0.25, windowHeight * 0.25;  % Upper left
        windowWidth * 0.25, windowHeight * 0.75;  % Lower left
        windowWidth * 0.75, windowHeight * 0.25;  % Upper right
        windowWidth * 0.75, windowHeight * 0.75   % Lower right
    ];
   
    % Set the text parameters
    Screen('TextSize', windowPtr, 40);
    Screen('TextStyle', windowPtr, 0); % normal
   
    % Add the text to the screen
    for i = 1:length(responseOptions)
        if ~isempty(boldOption) && boldOption == i
            Screen('TextStyle', windowPtr, 1); % bold
            DrawFormattedText(windowPtr, responseOptions{i}, 'center', positions(i, 2), [0, 0, 0], [], [], [], 1.5, [], [positions(i, 1), positions(i, 2), positions(i, 1), positions(i, 2)]);
            Screen('TextStyle', windowPtr, 0); % normal
        else
            DrawFormattedText(windowPtr, responseOptions{i}, 'center', positions(i, 2), [0, 0, 0], [], [], [], 1.5, [], [positions(i, 1), positions(i, 2), positions(i, 1), positions(i, 2)]);
        end
    end
   
    % Flip the screen to show the text and points
    Screen('Flip', windowPtr);
end
