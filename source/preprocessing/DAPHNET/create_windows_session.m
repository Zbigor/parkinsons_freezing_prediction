function [] = create_windows_session(num_samp, num_overlap, ...
                               input_data_file, output_data_path, filename, settingsID)

struct_file = load(input_data_file);
data = struct_file.data;
% data shape
dim = size(data);
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
windows = repmat(struct('data', data(1,:), 'label', 1),1, windows_count);
windows_3D = repmat(zeros(num_samp,dim(2),1),[1,1,windows_count]);
window_labels = zeros(windows_count,1);

while it_w <= windows_count
    
    windows(it_w).data = data(head:head+num_samp-1,:);
    windows_3D(:,:,it_w) = windows(it_w).data;
    samp_labels =  windows(it_w).data(:,11);
    % setting window labels
    % at least one fog sample means the window is fog
    % otherwise at least one pre-fog means the window is prefog
    
    if (sum(samp_labels == 2))
        windows(it_w).label = 2;
    else
        if (sum(samp_labels == 3))
            windows(it_w).label = 3;
        else
            windows(it_w).label = 1;
        end
    end    
    window_labels(it_w) = windows(it_w).label;
    it_w = it_w + 1;
    head = head + num_samp -1 - num_overlap;
end

folder_name = strcat('length',num2str(settingsID));
mkdir(strcat(output_data_path,folder_name));

% saving windows in a structure
filename = erase(filename,'.txt');
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'windows');
% saving windows in 3D matrices
filename = strcat('3D_',filename);
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'windows_3D');
% saving the column of window labels
filename = erase(filename,'3D_');
filename = strcat('labels_',filename);
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'window_labels');


clear windows_3D
clear windows
clear data
end





















