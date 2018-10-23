% iterating through daphnet dataset folder

input_path = '../../../data/DAPHNET_txt_data/';
files = dir(strcat(input_path,'*.txt'));
output_path = '../../../data/DAPHNET_mat_files/';

% for all files in the dataset
% generating mat files with labelled preFoG events
% also generating mat files with preFoG only

% preFoG window length in seconds
window_length  = 6;
for file = files'
    
    extract_events(input_path,file.name, ...
window_length,output_path)
end
clear all
