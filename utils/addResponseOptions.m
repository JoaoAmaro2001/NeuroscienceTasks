function addResponseOptions(windowPtr, responseOptions, boldOption)
    
    % Get the size of the window
    [windowWidth, windowHeight] = Screen('WindowSize', windowPtr);
   
    % Define the positions for the text (centered horizontally and below the main text)
    baseYPosition = windowHeight * 0.7;  % Starting position for response options (below main text)
    spacingY = windowHeight * 0.05;      % Vertical spacing between each option
    centerX = windowWidth * 0.5;         % Center of the screen horizontally
    
    % Create an array for the positions of the response options, centered horizontally
    positions = [
        centerX, baseYPosition;                 % First option
        centerX, baseYPosition + spacingY;      % Second option
        centerX, baseYPosition + 2 * spacingY;  % Third option
        centerX, baseYPosition + 3 * spacingY   % Fourth option
    ];
   
    % Set the text parameters
    Screen('TextSize', windowPtr, 60); % 10 less than the question's text size
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
   
    % Flip the screen to show the text and options
    Screen('Flip', windowPtr);
end
