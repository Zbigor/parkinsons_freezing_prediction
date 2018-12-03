% creates sample windows for all sessions based on input parameters
% labels each window, can assign additional info
function [error_code] = create_windows(window_length, sample_rate, overlap_length)


%% 
% creating mat files

% addpath /home/igor/lab_rotation/parkinsons_freezing_project/source/DAPHNET_code/scripts/
% preprocess_DAPHNET;
% rmpath /home/igor/lab_rotation/parkinsons_freezing_project/source/DAPHNET_code/scripts/
%% 
num_samp = window_length * sample_rate;
num_overlap = overlap_length * sample_rate;
input_path = '../../../data/DAPHNET_mat_files/';
output_data_path = '../../../data/DAPHNET_mat_files/windows/';
files = dir(strcat(input_path,'*.mat'));
total = length(files);
elapsed = 0;
% somehow identify current configuration of parameters
settingsID = 25;
% initializing training and test 3D matrices
training_set = [];
test_set = [];
for file = files'
    input_data_file = strcat(input_path,file.name);
    create_windows_session(num_samp, num_overlap, ...
                     input_data_file, output_data_path,file.name, settingsID);
    % creating training and test set 3d window data matrices  
    % leaving 2 patients data out exclusively for testing
    % they amount to 35 percent of the freezing events
    folder_name = strcat('length',num2str(settingsID));
    folder_path = strcat(output_data_path,folder_name,'/');

    output_data_file = strcat(folder_path,strcat('3D_',file.name));
    out_data_struct = load(output_data_file);
    if (file.name == "S03R01.mat")||(file.name == "S05R01.mat")
        test_set = cat(3,test_set,out_data_struct.windows_3D);
    
    else
        
        training_set = cat(3,training_set,out_data_struct.windows_3D);

    end
    clearvars out_data_struct
    elapsed = elapsed + 1;
    %clc
    disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
end
%clc
disp('100 % elapsed');

% saving training and test sets
folder_name = strcat('length',num2str(settingsID));
filename = strcat('training_set_',num2str(settingsID));
name = strcat(output_data_path,'/',folder_name,'/',filename);
save(name,'training_set');

filename = strcat('test_set_',num2str(settingsID));
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'test_set');

error_code = 0;
end


























