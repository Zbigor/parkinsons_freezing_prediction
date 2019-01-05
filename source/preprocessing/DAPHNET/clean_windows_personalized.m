function [clean_gait,clean_fog] = clean_windows_personalized(input_file,...
                                               labels_file, window_length,...
                                               sample_rate, overlap_length)
%CLEAN_WINDOWS_PERSONALIZED Summary of this function goes here
%   Detailed explanation goes here
input_path = strcat('../../../data/DAPHNET_txt_data/',input_file);
labels_path = strcat('../../../data/DAPHNET_txt_data/',labels_file);
raw_data = load(input_path);
raw_intervals = floor(64*load(labels_path));
clean_gait = [];
clean_fog = [];
num_samp = window_length * sample_rate;
num_overlap = overlap_length * sample_rate;
for it_in = 1:length(raw_intervals)
   
    if raw_intervals(it_in,1) ~= 0
    
        gait_data = raw_data(raw_intervals(it_in,1):raw_intervals(it_in,2),:);
        % window iterator
        it_w = int64(1);
        % current sample at the start of the window
        head = int64(1);
        % number of windows
        windows_count = int64(fix((length(gait_data)-num_overlap)/(num_samp-num_overlap)));
        
        while it_w <= windows_count    
        
            clean_gait = cat(3,clean_gait,gait_data(head:head+num_samp-1,:));
            it_w = it_w + 1;
            head = head + num_samp -1 - num_overlap;
        end
      
    end
    
    if raw_intervals(it_in,3) ~= 0
    
        fog_data = raw_data(raw_intervals(it_in,2):raw_intervals(it_in,3),:);
        % window iterator
        it_w = int64(1);
        % current sample at the start of the window
        head = int64(1);
        % number of windows
        windows_count = int64(fix((length(fog_data)-num_overlap)/(num_samp-num_overlap)));
        
        while it_w <= windows_count    
        
            clean_fog = cat(3,clean_fog,fog_data(head:head+num_samp-1,:));
            it_w = it_w + 1;
            head = head + num_samp -1 - num_overlap;
        end
      
    end
    
    
    
end

clean_fog(:,1:10,:) = clean_fog(:,1:10,:)/1000;
clean_gait(:,1:10,:) = clean_gait(:,1:10,:)/1000;

output_data_path = '../../../data/DAPHNET_mat_files/windows/personalized/S03/';
settings_file = load(strcat(output_data_path,'settings_id.mat'));
settingsID = settings_file.settingsID;
folder_name = strcat('settings',num2str(settingsID));
mkdir(strcat(output_data_path,folder_name));
% add log file with settings values
settingsID = settingsID + 1;
save(strcat(output_data_path,'settings_id.mat'),'settingsID');
training_data = cat(3,clean_gait,clean_fog);
save(strcat(output_data_path,folder_name,'/','training_data.mat'),'training_data');

training_labels = [ones(length(clean_gait(1,1,:)),1);2*ones(length(clean_fog(1,1,:)),1)];
save(strcat(output_data_path,folder_name,'/','training_labels.mat'),'training_labels');

end

