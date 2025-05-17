function [blank_times, cross_times] = generate_poisson_times(nStimuli, TR, lambda)
    % Generate Poisson-distributed random numbers
    x = poissrnd(lambda, [1, nStimuli]);
    
    % Normalize x to be between [2 3]
    x_norm      = x/(max(x)-min(x));
    cross_times = ((3/2)*TR - x_norm)';
    
    % Calculate blank times so that total_time = cross_time + blank_time
    blank_times = TR*2 - cross_times;
end
