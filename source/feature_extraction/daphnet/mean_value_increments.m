function [features] = mean_value_increments(window_prev,window)
%MEAN_VALUE_INCREMENTS Increments of consecutive windows’ mean values
% in each accelerometer axis
%   calculated values provide the amount of variation performed 
% in each axis of the accelerometer.
% outputs a 1D vector
features = window_means(window) - window_means(window_prev);
end

