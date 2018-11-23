function [components,var_exp] = pca_freezing(input_data, num_components)
%PCA_FREEZING calculating PCA for the given sensor data and settings
%   Detailed explanation goes here
disp('PCA in progress');
[wcoeff,score,latent,tsquared,explained,~] = ... 
    pca(input_data,'NumComponents',num_components,'VariableWeights','variance');
var_exp = explained;
components = wcoeff;

disp('PCA done');
end


