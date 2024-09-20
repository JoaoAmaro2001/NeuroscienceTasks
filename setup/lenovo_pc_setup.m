% Lenovo Tower

% Directories
cd('C:\git\JoaoAmaro2001\task-experiment1_depression');
orip = pwd; % The root directory for scripts and images
addpath(genpath(orip));

% Toolboxes
toolbox_dir = 'C:\Packages';
items = dir(toolbox_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
        folderPath = fullfile(toolbox_dir, items(i).name);
        addpath(folderPath);
        disp(['Added to path: ', folderPath]);
    end
end
