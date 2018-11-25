function [features] = standard_deviation(window)
%STANDARD_DEVIATION Standard deviation of each axis, for each sensor
%   indicates the amount of movement performed during a time window
% returns a 2D matrix of features 

features = std(window(:,2:10,:));
features = squeeze(features)';
end

