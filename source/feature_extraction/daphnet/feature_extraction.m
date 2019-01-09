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


% convert the script to a function, data path given as input
% will be called for different window sizes and other hyperparameter values
sample_freq = 64;
path = '../../../data/DAPHNET_mat_files/windows/personalized/S03/settings13/';
file = strcat(path,'training_data.mat');
window_data_struct = load(file);
window_data = window_data_struct.training_data;
clear window_data_struct
disp('calculating means');
means_features = window_means(window_data);
disp('dimensions means');
disp(size(means_features));
% increments_features = mean_value_increments(means_features);
% Performing multiple Singular Spectrum Analysis for each sensor
disp('performing SSA for sensor 1');
[features_sensor1,eigvect_sensor1] = ssa_feature_extraction(...
                                     window_data(:,2:4,:));
disp('performing SSA for sensor 2');

[features_sensor2,eigvect_sensor2] = ssa_feature_extraction(...
                                     window_data(:,5:7,:)); 
disp('performing SSA for sensor 3');
                                 
[features_sensor3,eigvect_sensor3] = ssa_feature_extraction(...
                                     window_data(:,8:10,:)); 
disp('extracting rest of the features');
design_matrix = [means_features,...
                 standard_deviation(window_data),...
                 pairwise_correlation(window_data),...
                 integration_features(window_data),...
                 spectral_features(window_data,sample_freq),...
                 features_sensor1, ...
                 features_sensor2,...
                 features_sensor3,...
                 ];
% eigenvectors for extracting each sensor's principal modes (SSA components)
eigenvectors = [eigvect_sensor1, eigvect_sensor2, eigvect_sensor3];


output_data_path = path;
filename = 'eigenvectors3';
name = strcat(output_data_path,filename);
save(name,'eigenvectors');

% saving design matrix in libsvm compatible format, also in a mat file
file = strcat(path,'training_labels.mat');
labels_data_struct = load(file);
training_labels = labels_data_struct.training_labels;

features = normalize(design_matrix);
features_sparse = sparse(features);

old_folder = pwd;
cd ../../libsvm-3.23/matlab/
libsvmwrite('design_matrix_s3.train',training_labels, features_sparse);
cd(old_folder);             
             
filename = 'design_matrix_s3';
name = strcat(path,filename);
save(name,'design_matrix');             
             