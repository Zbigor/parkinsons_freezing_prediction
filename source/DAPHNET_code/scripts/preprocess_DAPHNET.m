% iterating through daphnet dataset folder

input_path = '../../../data/DAPHNET_txt_data/';
files = dir(strcat(input_path,'*.txt'));
output_path = '../../../data/DAPHNET_mat_files/';

% for all files in the dataset
%% 
% generating mat files with labelled preFoG events
% also generating mat files with preFoG only

% preFoG window length in seconds
window_length  = 6;
total = length(files');
elapsed = 0;
for file = files'
    
    extract_events(input_path,file.name, ...
window_length,output_path)
    elapsed = elapsed + 1;
    clc
    disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
end
clearvars -except window_length

%% 
clc

% concatenate all prefog mat files into one file

input_path = '../../../data/DAPHNET_mat_files/';
output_path = '../../../data/PCA_data_DAPHNET/PCA_FoG/';
files = dir(strcat(input_path,'*prefog.mat'));
total = length(files);
elapsed = 0;
data_pre_fog = [];
for file = files'
    temp_dat = load(strcat(input_path,file.name));
    data_pre_fog = [data_pre_fog;temp_dat.data_prefog];
    elapsed = elapsed + 1;
    clc
    disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
end

name_pre_fog = strcat(output_path,'prefog_all','.mat'); 
save(name_pre_fog,'data_pre_fog');
clearvars -except window_length
%% 
% concatenate all mat files into one
clc

input_path = '../../../data/DAPHNET_mat_files/';
output_path = '../../../data/PCA_data_DAPHNET/PCA_all/';
files = dir(strcat(input_path,'*.mat'));
total = length(files);
elapsed = 0;
data_all = [];
for file = files'
    if(isempty(strfind(file.name,'fog')))
        
        temp_dat = load(strcat(input_path,file.name));
        data_all = [data_all;temp_dat.data];
        elapsed = elapsed + 1;
        clc
        disp(strcat(num2str(100 * elapsed/total),' % elapsed'));
    end    
end
clc
disp('100 % elapsed');
name_all = strcat(output_path,'data_all','.mat'); 
save(name_all,'data_all');
clearvars -except window_length

%% 
% perfrom PCA on the full prefog dataset
input_path = '../../../data/PCA_data_DAPHNET/PCA_FoG/';
input_struct = load(strcat(input_path,'prefog_all.mat')); 
input = input_struct.data_pre_fog;
% number of PCA components
num_comps = 6;
[components,var_exp] = pca_freezing(input(:,2:10), num_comps);
disp(var_exp);
disp(components)
var_exp_pre = var_exp;
clearvars -except window_length var_exp_pre

%% 
input_path = '../../../data/PCA_data_DAPHNET/PCA_all/';
input_struct = load(strcat(input_path,'data_all.mat')); 
input = input_struct.data_all;
% perform PCA on the full dataset
% number of PCA components
num_comps = 6;
[components,var_exp] = pca_freezing(input(:,2:10), num_comps);
disp(var_exp);
clearvars -except window_length var_exp var_exp_pre




