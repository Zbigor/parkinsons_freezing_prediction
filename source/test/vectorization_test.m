A = [3 5 1 9;7 0 9 11;1 5 2 7;2 1 5 6];
window_data = cat(3,A,[2 3 2 1;3 0 9 8;1 5 3 7;2 1 5 7]);
window_data = cat(3,window_data,[3 1 3 8;1 0 9 3;4 5 3 4;5 1 2 1]);
% extracting data without timing and labels
% window_data = window_data(:,2:3,:);
% calculating mean of each column, effectively calculating mean of each 
% axis for each accelerometer, for each window
features = squeeze(mean(window_data))';
dim = size(window_data);
% z = zeros(size(window_data));
% window_data(:,:,1) = 0;
% window_data_prev = cat(3,zeros(dim(1),dim(2)),window_data(:,:,1:2));
dim2 = size(features);
N_w = dim2(1);
features_prev = [zeros(1,dim2(2));features(1:N_w-1,:)];
features2 = features - features_prev;

% extracting separate matrices for each sensor
sensor1 = window_data(:,1:3,:);
sensor2 = window_data(:,2:4,:);
sensor3 = window_data(:,1:4,:);
% input dimensions
dim = size(window_data);
% number of windows
N_w = dim(3);
% initializing correlation values for each sensor
R1 = zeros(N_w,3);
R2 = zeros(N_w,3);
R3 = zeros(N_w,3);
tic
% computing correlations for each window in parallel 
parfor it_w = 1:N_w
    r1 = corrcoef(squeeze(sensor1(:,:,it_w)));
    r2 = corrcoef(squeeze(sensor2(:,:,it_w)));
    r3 = corrcoef(squeeze(sensor3(:,:,it_w)));
    R1(it_w,:) = [r1(1,2), r1(2,3),r1(1,3)];
    R2(it_w,:) = [r2(1,2), r2(2,3),r2(1,3)];
    R3(it_w,:) = [r3(1,2), r3(2,3),r3(1,3)];
end
features2 = [R1,R2,R3];
elapsed = toc;

