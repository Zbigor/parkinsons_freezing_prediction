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
for file = files'
    input_data_file = strcat(input_path,file.name);
    create_windows_session(num_samp, num_overlap, ...
                     input_data_file, output_data_path,file.name, settingsID);
    elapsed = elapsed + 1;
    %clc
    disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
end
%clc
disp('100 % elapsed');

error_code = 0;
end


























