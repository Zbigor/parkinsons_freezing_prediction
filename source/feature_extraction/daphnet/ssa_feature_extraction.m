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

window_data = normalize(window_data,'range');
trajectory_matrix = [squeeze(window_data(:,1,:));...
                     squeeze(window_data(:,2,:));...
                     squeeze(window_data(:,3,:))]';
dim = size(window_data);
disp(dim);
K = dim(3);
% covariance matrix
%C = (trajectory_matrix * (trajectory_matrix'))/K;

% ind1 = sum(sum(isnan(trajectory_matrix)));
% ind2 = sum(sum(isinf(trajectory_matrix)));
%disp(ind1);
%disp(ind2);
% if (ind1 || ind2)
%     % disp(trajectory_matrix(isnan(trajectory_matrix)));
%     disp('error')
% end
disp('Calculating covariance for ssa');
C = cov(trajectory_matrix/sqrt(dim(3)));
% disp('C_info')
% 
% disp(size(C));
% ind1 = sum(sum(isnan(C)));
% %disp(ind1);
% ind2 = sum(sum(isinf(C)));
% %disp(ind2)
% if(ind1||ind2)
% 
%     disp('err C')
% end
% calculate eigenvectors
disp('calculating eigenvectors for ssa');
[V,D] = eigs(C,9);
clearvars C
% extract the diagonal
D = diag(D);      
% sort eigenvalues
[D,ind]=sort(D,'descend');
% and eigenvectors
V = V(:,ind); 
% maybe extend to more than 10 based on variance explained
% V = V(1:5,:);
disp(size(trajectory_matrix));
disp(size(V));
features_ssa = trajectory_matrix*V;
eigenmatrix = V;
clearvars V 
end

