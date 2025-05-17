function sequence2use = generate_sequences(root_folder, stimuli_names)

% Directories
allstim_path   = fullfile(root_folder, 'img', 'all_stim');
stim_path      = fullfile(root_folder, 'img', 'stim');

% Settings
do_move_jpg    = false;
do_create_sequence = true;

if do_move_jpg; moveJpg(stimuli_names,allstim_path,stim_path); end
if do_create_sequence; sequence2use = createSequence(root_folder,stim_path); end

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% ------------------------------------------------------------------
function sequenceFilesComplete = createSequence(root_folder,stim_path)

    % Assign numbers to each file
    stimFilesCurated = dir(fullfile(stim_path, '*.jpg'));
    numFiles         = length(stimFilesCurated);
    fileNumbers      = 1:numFiles;
    fileNames        = {stimFilesCurated.name}';
    
    % Create a table with numbers and filenames
    fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
    
    % Randomize numbers
    randomOrder = randperm(numFiles);
    sequenceFilesComplete = fileTable.FileName;
    sequenceFilesComplete = sequenceFilesComplete(randomOrder);
    
    % Save sequence
    save(fullfile(root_folder,'sequences','sequence.mat'), 'sequenceFilesComplete', 'randomOrder')

end
% ------------------------------------------------------------------


% ------------------------------------------------------------------
function moveJpg(stimuli_names,allstim_path,stim_path)
        
    stim_names_jpg = strcat(stimuli_names,'.jpg');
    stimFiles      = dir(allstim_path); % Get dir
    stimFiles      = stimFiles(~[stimFiles.isdir]); % Remove folders
    stimFiles      = stimFiles(ismember({stimFiles.name}, stim_names_jpg));
    % Move all .avi files
    for i = 1:length(stimFiles)
        stim2move = dir(fullfile(allstim_path, stimFiles(i).name));
        copyfile(fullfile(stim2move(1).folder, stim2move(1).name), fullfile(stim_path, stim2move(1).name));
    end

end
% ------------------------------------------------------------------

