% this script performs feature extraction based on the window data
% window_data is a 3d matrix stored in a mat file with 
% dimensions = window_length x #channels x # windows
% #window is the total number of windows for the training data
% #windows small enough that all the data can be loaded into one matrix
% otherwise training in batches
% the resulting design matrix is store in a mat file, as well as any other
% generated outputs
% design_matrix dimensions = # windows x # features
% each field in the design matrix represents the value of the feature at a
% given window

% sample frequency for the DAPHNET dataset is 64 Hz
sample_freq = 64;
path = '';
window_data = load(path);
means_features = window_means(window_data);
increments_features = mean_value_increments(means_features);
% Performing multiple Singular Spectrum Analysis for each sensor
[features_sensor1,eigvect_sensor1] = ssa_feature_extraction(...
                                     window_data(:,2:4,:));
[features_sensor2,eigvect_sensor2] = ssa_feature_extraction(...
                                     window_data(5:7)); 
[features_sensor3,eigvect_sensor3] = ssa_feature_extraction(...
                                     window_data(8:10)); 

design_matrix = [means_features, increments_features,... 
                 increment_differences(incremens_features),...
                 standard_deviation(window_data),...
                 pairwise_correlation(window_data),...
                 integration_features(window_data),...
                 spectral_features(window_data),...
                 features_sensor1, ...
                 features_sensor2,...
                 features_sensor3,...
                 ];
% eigenvectors for extracting each sensor's principal modes (SSA components)
eigenvectors = [eigvect_sensor1', eigvect_sensor2', eigvect_sensor3'];

folder_name = 'eigenvectors';
output_data_path = path;
filename = 'ID';
name = strcat(output_data_path,folder_name,'/',filename);
save(name,'eigenvectors');


% window labels can be loaded directly from the structure files
labels = load('labels');
features = normalize(design_matrix,'range');
features_sparse = sparse(features);

libsvmwrite('design_matrix.train',labels, features_sparse);

             
             
             
             