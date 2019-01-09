function [observation] = online_feature_extraction(window_data,...
                                                   filter1,filter2,...
                                                   filter3)
%ONLINE_FEATURE_EXTRACTION Function for online feature extraction
%   Add later PCA/SSA PCs as additional arguments


% this script performs feature extraction based on the window data

sample_freq = 64;

means_features = window_means(window_data);

% increments_features = mean_value_increments(means_features);
% Performing multiple Singular Spectrum Analysis for each sensor
% disp('performing SSA for sensor 1');
% [features_sensor1,eigvect_sensor1] = ssa_feature_extraction(...
%                                      window_data(:,2:4,:));
% disp('performing SSA for sensor 2');
% 
% [features_sensor2,eigvect_sensor2] = ssa_feature_extraction(...
%                                      window_data(:,5:7,:)); 
% disp('performing SSA for sensor 3');
%                                  
% [features_sensor3,eigvect_sensor3] = ssa_feature_extraction(...
%                                      window_data(:,8:10,:)); 
% disp('extracting rest of the features');

% disp(size(standard_deviation(window_data)));
% disp(size(pairwise_correlation(window_data)));
% disp(size(integration_features(window_data)));
% 
% disp(size(spectral_features(window_data,sample_freq,filter1,filter2,filter3)));


observation = [means_features,...
                 standard_deviation(window_data),...
                 pairwise_correlation(window_data),...
                 integration_features(window_data),...
                 spectral_features(window_data,sample_freq,filter1,filter2,filter3)...
%                  features_sensor1, ...
%                  features_sensor2,...
%                  features_sensor3,...
                 ];
% eigenvectors for extracting each sensor's principal modes (SSA components)
% eigenvectors = [eigvect_sensor1, eigvect_sensor2, eigvect_sensor3];
% disp(size(observation));
% disp('wait');
% disp('go');

% CONSIDER NORMALIZING FEATURE MATRIX FOR TRAINING DATA

end
