function [out_design_matrix] = remove_correlated_features(design_matrix, ...
                                                     correlation_threshold)
%REMOVE_CORRELATED_FEATURES Removing highly correlated features
%   Highly correlated features will be removed as redundant

corr_matrix = corr(design_matrix);

% plotting the heatmap of the feature correlations
feature_names = ["name","name","name","name","name","name","name"] ;

figure
h = heatmap(feature_names,feature_names,corr_matrix);
colormap('jet');
h.Title = 'Correlations of extracted features';

% removing the features with correlation greater than the threshold

% TO BE FINISHED AND USED AS AN EVALUATION OF FEATURE EXTRACTION
end

