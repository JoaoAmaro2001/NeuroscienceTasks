function drawText(windowToAdd, textToAdd, trial_num, W, H, backgroundColor, textColor)
    Screen('TextSize', windowToAdd, 70); % trial and error for fmri screen
    text = textToAdd{trial_num};
    [textWidth, textHeight] = RectSize(Screen('TextBounds', windowToAdd, text));
    xPos = (W - textWidth) / 2;
    yPos = (H - textHeight) / 2 - textHeight * 0.1; % Give room
    Screen('FillRect', windowToAdd, backgroundColor);  
    Screen('DrawText', windowToAdd, text, xPos, yPos, textColor);
end