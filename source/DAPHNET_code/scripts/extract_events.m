% my_function

function extract_events(input_data_path,filename, ...
window_length,output_data_path)


% number of pre-fog samples to be extracted according to window length
N_pre_fog_samp = int32(round(window_length / 0.015));

path = strcat(input_data_path,filename);
data = load(path);


% removing data with label 0 (not part of the experiment)
ind_nonzero = data(:,11)~=0;
data = data(ind_nonzero,:);

% find changes from 1 to 2 (non-fog to fog)
ind_dif = find((data(1:end-1,11)-data(2:end,11))==-1);
% disp('Number of pre-FoG events is ');
% disp(length(ind_dif));

% setting pre_fog indices
% initializing
data_prefog = zeros(N_pre_fog_samp*length(ind_dif),11);
% extracting a sample window before each of the detected changes

for it_dif = 1:length(ind_dif)
    
    % extracting the data
    data_prefog((it_dif-1)*N_pre_fog_samp+1:it_dif*N_pre_fog_samp+1,:) = ...
        data((ind_dif(it_dif)-N_pre_fog_samp):ind_dif(it_dif),:);
    % labeling the pre-fog samples
    data(ind_dif(it_dif)-N_pre_fog_samp+1:ind_dif(it_dif),11) = 3;
    
end

% newly labelled data:
% 1 - non event sample(e.g. gait)
% 2 - FoG event sample
% 3 - pre-FoG event sample

filename = erase(filename,'.txt');
name = strcat(output_data_path,filename,'.mat');
name_prefog = strcat(output_data_path,filename,'_prefog','.mat');
% saving newly labelled data
save(name,'data');
% saving pre_fog data
save(name_prefog,'data_prefog');
%disp(data_prefog);

clear data
clear data_prefog
end