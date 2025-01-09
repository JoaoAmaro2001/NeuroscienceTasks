% % % % % % % % % 
% Lenovo Tower  %
% % % % % % % % % 

% User input
git_dir     = 'C:\git';
username    = 'JoaoAmaro2001';
projectname = 'task-experiment2_mri';
root_dir    = fullfile(git_dir,username, projectname);
toolbox_dir = 'C:\Packages';

% Add to path
cd(task_dir);
addpath(genpath(task_dir));

% Toolboxes
items = dir(toolbox_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
        folderPath = fullfile(toolbox_dir, items(i).name);
        addpath(folderPath);
        disp(['Added to path: ', folderPath]);
    end
end
