function [features] = window_means(window_data)
%MEANS Mean value of each accelerometer axis measurements
%   gives the orientation of the inertial system related to gravity
% in absence of movement.
% it returns a vector of scalar feature values

% extracting data without timing and labels 
window_data = window_data(:,2:10);
% calculating mean of each column, effectively calculating mean of each 
% axis for each accelerometer
features = mean(window_data);
end

