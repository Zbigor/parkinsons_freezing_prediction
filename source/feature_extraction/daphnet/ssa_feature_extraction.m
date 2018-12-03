function [features_ssa,eigenmatrix] = ssa_feature_extraction(window_data)
%SSA_FEATURE_EXTRACTION SSA feature extraction
% Performing multiple Singular Spectrum Analysis for the data from the 
% given sensor
% assumes input window data from one sensor (usually three channels)
% this function can be called for the spectral domain too
% input = window_length x #channels x #windows
% eigenmatrix is provided on the output as matrix of 5 eigenvectors that
% represent the basis for 5 principle components
% for classifier training, a vector of feature values is provided for each
% window, making the deign matrix form #windows x #features(=5)

% forming trajectory matrix

window_data = normalize(window_data);
trajectory_matrix = [squeeze(window_data(:,1,:));...
                     squeeze(window_data(:,2,:));...
                     squeeze(window_data(:,3,:))];
dim = size(window_data);
K = dim(3);
% covariance matrix
%C = (trajectory_matrix * (trajectory_matrix'))/K;
C = cov(trajectory_matrix);
disp(C);
disp(dim(C));
% calculate eigenvectors
[V,D] = eig(C);  
% extract the diagonal
D = diag(D);      
% sort eigenvalues
[D,ind]=sort(D,'descend');
% and eigenvectors
V = V(:,ind); 
% maybe extend to more than 10 based on variance explained
V = V(1:10,:);
features_ssa = (V * trajectory_matrix)';
eigenmatrix = V;
end

