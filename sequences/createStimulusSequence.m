function createStimulusSequence(scripts, varargin)
% createStimulusSequence - Creates stimulus sequences for experimental runs
%
% Syntax:
%   createStimulusSequence(scripts)
%   createStimulusSequence(scripts, 'Parameter', value, ...)
%
% Required Inputs:
%   scripts    - Path to scripts directory
%
% Optional Parameters:
%   'MoveAvi'        - Boolean to move AVI files (default: false)
%   'CreateSequence' - Boolean to create sequence (default: true)
%   'Method'         - String: 'real-time' or 'pre-built' (default: 'pre-built')
%   'FilesPerRun'    - Number of files for each run (default: 30)
%   'NumRuns'        - Number of runs (default: 2)

% Parse inputs
p = inputParser;
addRequired(p, 'scripts', @ischar);
addParameter(p, 'MoveAvi', false, @islogical);
addParameter(p, 'CreateSequence', true, @islogical);
addParameter(p, 'Method', 'pre-built', @ischar);
addParameter(p, 'FilesPerRun', 30, @isnumeric);
addParameter(p, 'NumRuns', 2, @isnumeric);
parse(p, scripts, varargin{:});

% Extract parameters
moveAvi         = p.Results.MoveAvi;
createSequence  = p.Results.CreateSequence;
method          = p.Results.Method;
filesForEachRun = p.Results.FilesPerRun;
numOfRuns       = p.Results.NumRuns;

% Set paths
allstim_path = fullfile(scripts, 'supp', 'allStimuli');
stim_path    = fullfile(scripts, 'supp', 'stimuli');

% Move AVI files if requested
if moveAvi
    stimFolders = dir(allstim_path);
    stimFolders = stimFolders([stimFolders.isdir]);
    
    % Move all .avi files
    for i = 1:length(stimFolders)
        stimFiles = dir(fullfile(allstim_path, stimFolders(i).name, '*.avi'));
        for j = 1:length(stimFiles)
            copyfile(fullfile(allstim_path, stimFolders(i).name, stimFiles(j).name), ...
                    fullfile(stim_path, stimFiles(j).name));
        end
    end
end

% Create sequence if requested
if createSequence
    if strcmpi(method, 'real-time')
        % Assign numbers to each file
        stimFilesCurated = dir(fullfile(stim_path, '*.avi'));
        numFiles = length(stimFilesCurated);
        fileNumbers = 1:numFiles;
        fileNames = {stimFilesCurated.name}';
        
        % Create a table with numbers and filenames
        fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
        
        % Randomize numbers
        randomOrder = randperm(numFiles);
        
        % Select files for the first sequence
        sequenceFilesComplete = fileTable.FileName;
        sequenceFilesComplete(randomOrder) = fileTable.FileName;
        
        % Save sequence 1
        cd(fullfile(scripts, 'sequences'))
        save('sequence1.mat', 'sequenceFiles', 'sequenceNumbers')
        
        % Perform second randomization for sequence2
        remainingNumbers = setdiff(randomOrder, sequenceNumbers);
        sequenceNumbers = remainingNumbers(randperm(filesForEachRun));
        sequenceFiles = fileTable.FileName(sequenceNumbers);
        
        % Save sequence 2
        save('sequence2.mat', 'sequenceFiles', 'sequenceNumbers');
        
    elseif strcmpi(method, 'pre-built')
        % Assign numbers to each file
        stimFilesCurated = dir(fullfile(stim_path, '*.avi'));
        numFiles = length(stimFilesCurated);
        fileNumbers = 1:numFiles;
        fileNames = {stimFilesCurated.name}';
        
        % Create a table with numbers and filenames
        fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
        
        % Randomize numbers
        randomOrder = randperm(numFiles);
        sequenceFilesComplete = fileTable.FileName;
        sequenceFilesComplete(randomOrder) = fileTable.FileName;
        
        % Save run 1 sequence
        sequenceFiles1 = sequenceFilesComplete(1:filesForEachRun);
        cd(fullfile(scripts, 'sequences'))
        save('sequence1.mat', 'sequenceFiles1', 'randomOrder')
        
        % Save run 2 sequence
        sequenceFiles2 = sequenceFilesComplete(filesForEachRun+1:end);
        save('sequence2.mat', 'sequenceFiles2', 'randomOrder')
        
        % Output sequence side by side
        out_sequence = {sequenceFiles1{:}; sequenceFiles2{:}};
        disp(out_sequence');
        
        % Verify randomization
        if length(unique(out_sequence)) ~= filesForEachRun * numOfRuns
            error('Stimulus randomization went wrong...')
        end
    else
        error('Invalid method specified. Use either ''real-time'' or ''pre-built''.')
    end
end

% Return to scripts directory
cd(scripts)
end