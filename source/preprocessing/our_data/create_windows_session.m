% creating windows from mat files generated from our data
function [] = create_windows_session(num_samp, num_overlap, pre_fog_length,...
                                     input_data_file, output_data_path, ... 
                                     filename, settingsID)
filename = erase(filename,'.txt');
struct_file = load(input_data_file);

struct_data = struct_file.kinedata;
clear struct_file

% merging all columns of kinedata
data = [struct_data.time',struct_data.rightankle.acc,struct_data.rightankle.gyr,...
    struct_data.rightankle.mag, struct_data.leftankle.acc,...
    struct_data.leftankle.gyr, struct_data.leftankle.mag, ...
    struct_data.lumbar.acc, struct_data.lumbar.gyr, struct_data.lumbar.mag];
% disp('data shape')
% disp(size(data));
% adding labels based on the manual annotations
label_our_raw_data(data,filename);
clearvars data
% extracting and labeling prefog events
input_data_path = '../../../data/Freezing_mat_files/Labeled_files/';
output_label_path = '../../../data/Freezing_mat_files/fully_labeled/';
extract_events(input_data_path,filename,pre_fog_length,output_label_path);
data_structure = load(strcat(output_label_path,filename));
data = data_structure.data;
data_size = size(data);
width = data_size(2);
% window iterator
it_w = int64(1);
% current sample at the start of the window
head = int64(1);
% initialize the array of windows
windows_count = int64(fix((length(data)-num_overlap)/(num_samp-num_overlap)));
disp('data length');
disp(length(data));
disp('windows count');
disp(windows_count)

if(windows_count>1)
windows = repmat(struct('data', data(1,:), 'label', 1),1, windows_count);
% creating windows from data
while it_w <= windows_count
    
    windows(it_w).data = data(head:head+num_samp-1,:);
    samp_labels =  windows(it_w).data(:,width);
    % setting window labels
    % at least one fog sample means the window is fog
    % otherwise at least one pre-fog means the window is prefog
    
    if (sum(samp_labels == 2)>0)
        windows(it_w).label = 2;
    else
        if (sum(samp_labels == 3)>0)
            windows(it_w).label = 3;
        else
            windows(it_w).label = 1;
        end
    end    
    
    it_w = it_w + 1;
    head = head + num_samp -1 - num_overlap;
end
else
    % error code for bad data/labels
    windows = -1;
end

folder_name = strcat('length',num2str(settingsID));
mkdir(strcat(output_data_path,folder_name));

name = strcat(output_data_path,folder_name,'/',filename);
save(name,'windows');
clear windows
clear data

end
