function [features] = pairwise_correlation(window_data)
%PAIRWISE_CORRELATION Pairwise correlations of each two axes, for all
% sensors, for all windows
%   Gives information about linear relation in different axes, 
% which is useful for detecting normal/continuous gait
% returns matrix of features output = #windows x #features

% extracting separate matrices for each sensor
sensor1 = window_data(:,2:4,:);
sensor2 = window_data(:,5:7,:);
sensor3 = window_data(:,8:10,:);
% input dimensions
dim = size(window_data);
% number of windows
N_w = dim(3);
% initializing correlation values for each sensor
R1 = zeros(N_w,3);
R2 = zeros(N_w,3);
R3 = zeros(N_w,3);
% computing correlations for each window in parallel 
parfor it_w = 1:N_w
    r1 = corrcoef(squeeze(sensor1(:,:,it_w)));
    r2 = corrcoef(squeeze(sensor2(:,:,it_w)));
    r3 = corrcoef(squeeze(sensor3(:,:,it_w)));
    R1(it_w,:) = [r1(1,2), r1(2,3),r1(1,3)];
    R2(it_w,:) = [r2(1,2), r2(2,3),r2(1,3)];
    R3(it_w,:) = [r3(1,2), r3(2,3),r3(1,3)];
end  
features = [R1,R2,R3];
clearvars sensor1 sensor2 sensor3

end    
            

