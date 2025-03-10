% % % % % % %
% Lenovo PC %
% % % % % % %

% User input
git_dir     = 'C:\Users\joaop\git';
username    = 'JoaoAmaro2001';
reponame    = 'task-experiment1';
root_dir    = fullfile(git_dir,username, reponame);
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


% Machine information (inspect manually)
[~, OsVersion] = system('ver');
if ismac
    % Code to run on Mac platform
elseif isunix
    % Code to run on Linux platform
elseif ispc
    % Code to run on Windows platform
    OsVersion = ['Windows 11 Pro' OsVersion(19:end-1)];
else
    disp('Platform not supported')
end

% Store
machine = struct();
machine.monitor.real_screen_size_hor = 35.5; % manually measured
machine.monitor.real_screen_size_ver = 23;   % manually measured
machine.os                           = OsVersion;