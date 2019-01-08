function [features] = mean_value_increments(window_means_data)
%MEAN_VALUE_INCREMENTS Increments of consecutive windows’ mean values
% in each accelerometer axis
%   calculated values provide the amount of variation performed 
% in each axis of the accelerometer.
% expect window means as input, input = windows x features
% outputs 2D feature matrix features = windows x features


dim = size(window_means_data);
% number of windows
N_w = dim(1);
% shifting the windows by 1 for vectorized calculation of consecutive 
% windows mean alues
% for the first window, previous means are set to zero
window_means_data_prev = [zeros(1,dim(2));window_means_data(1:N_w-1,:)];
features = window_means_data - window_means_data_prev;

end

