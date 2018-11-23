% creates sample windows for all sessions based on input parameters
% labels each window, can assign additional info
function [error_code] = create_windows(window_length, sample_rate,...
                                       pre_fog_length,overlap_length)


%% 
% % creating mat files
% input_path = '../../../data/freezing_data_old/H5-Files';
% output_path = '../../../data/Freezing_mat_files/'; 
% convert_h5_to_mat(input_path, output_path);
% clear input_path
% clear output_path
%% 
num_samp = window_length * sample_rate;
num_overlap = overlap_length * sample_rate;
input_path = '../../../data/Freezing_mat_files/';
output_data_path = '../../../data/Freezing_mat_files/windows/';
files = dir(strcat(input_path,'*.mat'));
total = length(files);
elapsed = 0;
% somehow identify current configuration of parameters 
% (generate parameterIDs, maybe just save a value in a file and increment)
settingsID = 25;
for file = files'
    input_data_file = strcat(input_path,file.name);
    create_windows_session(num_samp, num_overlap, pre_fog_length, ...
                     input_data_file, output_data_path,file.name, settingsID);
    elapsed = elapsed + 1;
    % clc
    disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
end
% clc
disp('100 % elapsed');

error_code = 0;
end