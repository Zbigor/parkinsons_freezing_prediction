function [features] = window_means(window_data)
%MEANS Mean value of each accelerometer axis measurements
%   gives the orientation of the inertial system related to gravity
% in absence of movement.
% Expects a 3D matrix of window data as input
% size(window_data) = samples x channels x windows
% it returns a vector of scalar feature values output = windows x channels

% extracting data without timing and labels 
window_data = window_data(:,2:10);
% calculating mean of each column, effectively calculating mean of each 
% axis for each accelerometer, for each window
features = mean(window_data);
end

