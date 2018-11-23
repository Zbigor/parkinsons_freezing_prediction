% TO DO: automate the process
% creating windows

% window_length = 2.5;
% sample_rate = 64;
% overlap_length = 1.25;
% pre_fog_length = 6; 
% error = create_windows(window_length, sample_rate, pre_fog_length,...
%                        overlap_length);
% disp(error);

% window statistics - number of windows for each class

n_gait = 0;
n_fog = 0;
n_prefog = 0;

% in one of the length directories
% windows of specified width extracted
files = dir(strcat('/home/igor/lab_rotation/parkinsons_freezing_project/data/Freezing_mat_files/windows/length25/','*.mat'));
path = '/home/igor/lab_rotation/parkinsons_freezing_project/data/Freezing_mat_files/windows/length25/';
for file = files'
    windows_struct = load(strcat(path,file.name));
    windows = windows_struct.windows;
    for it = 1:length(windows)
        if (windows(it).label == 1)
            n_gait = n_gait + 1;
        else
            if(windows(it).label == 2)
            
                n_fog = n_fog + 1;
            else
                n_prefog = n_prefog +1;
            end
        end
    
    end
    
end

disp('Total gait windows = ');
disp(n_gait);
disp('Total FoG windows = ');
disp(n_fog);
disp('Total pre-FoG windows = ');
disp(n_prefog);




