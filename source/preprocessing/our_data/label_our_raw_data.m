% generating mat files with labelled preFoG events
% add the right paths
% index the labels with arrays of indices from excel

function [] = label_our_raw_data(data,filename)

% correct the label timepoints by adding the trigger value
% sort the arrays in excel before putting them in a file

% read the files
filename = erase(filename,'.mat');
filename_gait = strcat('gait_labels_',filename,'.txt');
filename_freezing = strcat('freezing_labels_',filename,'.txt');
path = '../../../data/Freezing_mat_files/labels/';
freezing_labels = load(strcat(path,filename_freezing));
gait_labels = load(strcat(path,filename_gait));

labels = zeros(length(data),1);

it_fl = 1;

% checking for bad data/invalid indices
if ((sum(gait_labels<0)== 0) && (sum(freezing_labels<0) == 0))

% labeling based on the given freezing timepoints indices
% timepoints given in seconds, corrections inbetween sequences performed
ind = 0;
while (it_fl+1<=length(freezing_labels))&&(ind == 0)
   
   start_index = freezing_labels(it_fl);
   end_index = freezing_labels(it_fl+1);
   % labeling the freezing sequence
   % if needed due to different resolutions of video and imu
   if (end_index<=length(labels))
       labels(start_index:end_index) = 2;
   else
       labels(start_index:end) =2;
       ind = 1;
   end
   % labeling one second after freezing as non-freezing/gait
   if(end_index+127<=length(labels))
        labels(end_index+1:end_index+127) = 1;
   else
       labels(end_index:length(labels)) = 1;
       ind = 1;
   end
   % labeling one second before freezing as non-freezing/gait
   % during pre-fog extraction, these will be labelled as pre-fog
   
   if(start_index-127>0)
   labels(start_index-127:start_index-1) = 1;
   else
   labels(1:start_index) = 1;    
   end
   it_fl = it_fl+2;
end

it_gl = 1;
ind = 0;
% labeling based on the given gait timepoints indices
% the "non-experimental" part of the recordings stays labelled as zero and
% will be removed from the data matrix
while(it_gl+1<=length(gait_labels))&&(ind == 0)
   
   start_index = gait_labels(it_gl);
   end_index = gait_labels(it_gl+1);
   % labeling the gait sequence
   labels(start_index:end_index) = 1;
   % labeling one second after also as gait, since the freezing is labeled
   % to have started right at the end of next second
   if(end_index+127<=length(labels))
        labels(end_index+1:end_index+127) = 1;
   else
       labels(end_index:end) = 1;
       ind = 1;
   end
   % labeling one second before gait also as non-freezing/gait
   % during pre-fog extraction, these will be labelled as pre-fog
   if(start_index-127>0)
   labels(start_index-127:start_index-1) = 1;
   else
   labels(1:start_index) = 1;    
   end
   it_gl = it_gl + 2; 
end

% samples for which no labels are provided during the measurement time are
% assumed not to belong to ht experiment, stay labeled

% WHAT TO FOR THE DATA BETWEEN 2 FOGS IF THEY HAPPENED TOO CLOSE TO EACH
% OTHER? (ex. less than 6,7 seconds)
% merging into one FOG by removing the data inbetween?

end
disp(size(data));
disp(size(labels));
disp(filename);
% adding labels to the data matrix
data = [data, labels];

% saving the labeled data
data_path = '../../../data/Freezing_mat_files/Labeled_files/';

full_path = strcat(data_path,filename,'.mat');
save(full_path,'data');
clear data labels


end


