% this function labels all data based on fog times
% passing the mat file with kinedata and fog/gait labels
function extract_events(input_data_path,filename, ...
window_length,output_data_path)


% number of pre-fog samples to be extracted according to window length
% sampling frequency is 128 Hz
N_pre_fog_samp = int32(round(window_length * 128));

path = strcat(input_data_path,filename);
disp(path);
data_struct = load(path);
data = data_struct.data;

% removing data with label 0 (not part of the experiment)
ind_nonzero = data(:,end)~=0;
data = data(ind_nonzero,:);
dims = size(data);
width = dims(2);
% find changes from 1 to 2 (non-fog to fog)
ind_dif = find((data(1:end-1,end)-data(2:end,end))==-1);
fileID = fopen('trials_info.txt','a');
head = strcat('Participant  ', filename);
fprintf(fileID, head);
fprintf(fileID, '\n\n');
fprintf(fileID,'Number of pre-FoG events is \n\n');
text_num = sprintf('%d', length(ind_dif));
fprintf(fileID, text_num);
fprintf(fileID, '\n\n');
fclose(fileID);
% setting pre_fog indices
% initializing
data_prefog = zeros(N_pre_fog_samp*length(ind_dif),width);
% extracting a sample window before each of the detected changes

for it_dif = 1:length(ind_dif)
    
    % extracting the data
    data_prefog((it_dif-1)*N_pre_fog_samp+1:it_dif*N_pre_fog_samp+1,:) = ...
        data((ind_dif(it_dif)-N_pre_fog_samp):ind_dif(it_dif),:);
    % labeling the pre-fog samples
    data(ind_dif(it_dif)-N_pre_fog_samp+1:ind_dif(it_dif),end) = 3;
    
end

% newly labelled data:
% 1 - non event sample(e.g. gait)
% 2 - FoG event sample
% 3 - pre-FoG event sample

filename = erase(filename,'.txt');
name = strcat(output_data_path,filename);

% saving newly labelled data
save(name,'data');


clear data

end