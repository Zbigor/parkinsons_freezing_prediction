function [features] = pairwise_correlation(window)
%PAIRWISE_CORRELATION Pairwise correlations of each two axes, for all
% sensors
%   Gives information about linear relation in different axes, 
% which is useful for detecting normal/continuous gait
% returns a 1-D array of features

% extracting separate matrices for each sensor
sensor1 = window(:,2:4);
sensor2 = window(:,5:7);
sensor3 = window(:,8:10);

% calculating correlation coefficients in matrix form
r1 = corrcoef(sensor1);
r2 = corrcoef(sensor2);
r3 = corrcoef(sensor3);
% extracting pairwise correlation coefficients
features = [r1(1,2), r1(2,3), r1(1,3), r2(1,2), r2(2,3), r2(1,3),...
            r3(1,2), r3(2,3), r3(1,3)];
end

