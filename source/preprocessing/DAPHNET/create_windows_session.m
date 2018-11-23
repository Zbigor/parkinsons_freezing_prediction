function [] = create_windows_session(num_samp, num_overlap, ...
                               input_data_file, output_data_path, filename, settingsID)

struct_file = load(input_data_file);
data = struct_file.data;
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

while it_w <= windows_count
    
    windows(it_w).data = data(head:head+num_samp-1,:);
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
    
    it_w = it_w + 1;
    head = head + num_samp -1 - num_overlap;
end

folder_name = strcat('length',num2str(settingsID));
mkdir(strcat(output_data_path,folder_name));

filename = erase(filename,'.txt');
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'windows');
clear windows
clear data
end





















