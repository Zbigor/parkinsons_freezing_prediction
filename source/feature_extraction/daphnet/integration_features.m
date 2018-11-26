function [out_features] = integration_features(window)
%INTEGRATION_FEATURES Integrating accelerometer data to obtain rough
% velocity 'increments'
%   Exact values and dimesions of velocity not important
% output features in the format of a design matrix

window_data = window(:,2:10,:);

% integrating acceleration on each axis for each sensor to obtain rough
% velocity estimates to be used as features
% integration is done with unit spacing

out_features = squeeze(trapz(window_data))';
    


end

