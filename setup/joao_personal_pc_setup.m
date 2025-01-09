% % % % % % %
% Lenovo PC %
% % % % % % %

% User input
git_dir     = 'C:\Users\joaop\git';
username    = 'JoaoAmaro2001';
projectname = 'task-experiment2_mri';
root_dir    = fullfile(git_dir,username, projectname);
toolbox_dir = 'C:\Users\joaop\toolbox';

% Add to path
cd(root_dir);
addpath(genpath(root_dir));

% Toolboxes
items = dir(toolbox_dir);
for i = 1:length(items)
    if items(i).isdir && ~strcmp(items(i).name, '.') && ~strcmp(items(i).name, '..')
        folderPath = fullfile(toolbox_dir, items(i).name);
        switch items(i).name
            case 'Corr_toolbox_v2'
            addpath(genpath(folderPath));
            disp(['Added to path (via genpath): ', folderPath]);
            case 'plotly_matlab-master'
            addpath(genpath(folderPath));
            disp(['Added to path (via genpath): ', folderPath]);
            plotlysetup_offline;
            otherwise
            addpath(folderPath);
            disp(['Added to path: ', folderPath]);
        end
    end
end
