% Acquisition Tower

% Directories
cd('C:\github\JoaoAmaro2001\psychiatry-study');
orip = pwd;
addpath(genpath(orip));

% Toolboxes
toolbox_dir = 'C:\toolbox';
items = dir(toolbox_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
        folderPath = fullfile(toolbox_dir, items(i).name);
        addpath(folderPath);
        disp(['Added to path: ', folderPath]);
    end
end
