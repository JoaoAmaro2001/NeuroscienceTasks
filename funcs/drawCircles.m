function [start_x, y_position, space_between_circles, circle_radius] = drawCircles(centerX, centerY, img, window, varargin)
    % Parse input arguments
    p = inputParser;
    addOptional(p, 'surround', 0, @(x) isnumeric(x) && isscalar(x) && (x == 0 || (x >= 1)));
    addOptional(p, 'color', [0 255 0], @(x) isnumeric(x) && isvector(x) && numel(x) == 3);
    addOptional(p, 'numAnswers', 9, @(x) isnumeric(x) && isscalar(x) && x > 0); % Add number of answers as input
    parse(p, varargin{:});
    
    surround = p.Results.surround;
    color = p.Results.color;
    numAnswers = p.Results.numAnswers;
    
    % Circle and spacing parameters
    circle_radius = 45;
    contour_thickness = 3;
    space_between_circles = 200;  % Adjust spacing dynamically if needed
    
    % Dynamically adjust total length based on the number of answers
    total_length = (numAnswers - 1) * space_between_circles + 2 * (circle_radius + contour_thickness);
    start_x = centerX - total_length / 2 + circle_radius + contour_thickness;
    y_position = centerY + size(img, 1) / 2 + 100;

    % Draw the circles
    for i = 1:numAnswers
        current_x = start_x + (i - 1) * space_between_circles;

        % Draw contour (black outer circle)
        Screen('FillOval', window, [0 0 0], ...
            [current_x - (circle_radius + contour_thickness), y_position - (circle_radius + contour_thickness), ...
            current_x + (circle_radius + contour_thickness), y_position + (circle_radius + contour_thickness)]);
        
        % Draw main circle (white inner circle)
        Screen('FillOval', window, [255 255 255], ...
            [current_x - circle_radius, y_position - circle_radius, ...
            current_x + circle_radius, y_position + circle_radius]);
        
        % Draw the number centered in the circle
        number_str = num2str(i);
        text_bounds = Screen('TextBounds', window, number_str);
        text_width = text_bounds(3) - text_bounds(1);
        text_height = text_bounds(4) - text_bounds(2);
        % Center the text vertically and horizontally
        text_x = current_x - text_width / 2;
        text_y = y_position - text_height / 2 + circle_radius / 2; % Adjust for text's internal baseline offset
        DrawFormattedText(window, number_str, text_x, text_y, [0 0 0]);
        
        % Highlight the specified circle with a surrounding color
        if i == surround
            Screen('FrameOval', window, color, ...
                [current_x - (circle_radius + contour_thickness + 10), y_position - (circle_radius + contour_thickness + 10), ...
                current_x + (circle_radius + contour_thickness + 10), y_position + (circle_radius + contour_thickness + 10)], 5);
        end
    end
end
