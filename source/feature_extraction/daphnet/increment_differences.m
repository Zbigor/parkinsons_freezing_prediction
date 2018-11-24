function [features] = increment_differences(mean_value_increments)
%UNTITLED Difference between the increments of the windows’ mean values 
% among different axes
% Gives the amount of variation among different axes (of the same sensor). 
% This feature is significant regarding the detection of postural 
% transitions

features = [mean_value_increments(1) - mean_value_increments(2), ...
            mean_value_increments(2) - mean_value_increments(3),...
            mean_value_increments(1) - mean_value_increments(3), ...
            


end

