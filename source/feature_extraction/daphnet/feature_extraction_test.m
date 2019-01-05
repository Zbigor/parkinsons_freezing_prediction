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
% path = '../../../data/DAPHNET_mat_files/windows/personalized/S05/length105/';
path = '../../../data/DAPHNET_mat_files/windows/length25/';
file = strcat(path,'test_set_25.mat');
% file = strcat(path,'test_set_105.mat');
window_data_struct = load(file);
% window_data = window_data_struct.training_set;
window_data = window_data_struct.test_set;

clear window_data_struct

means_features = window_means(window_data);
disp('Means features');
disp(size(means_features));

increments_features = mean_value_increments(means_features);
disp('Mean value incs');
disp(size(increments_features));

differences_features = increment_differences(increments_features);
disp('Differences features');
disp(size(differences_features));

correlation_features = pairwise_correlation(window_data);
disp('correlation features');
disp(size(correlation_features));

velocity_features = integration_features(window_data);
disp('velocity features');
disp(size(velocity_features));
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
disp('extracting rest of the features');


% eigenvectors for extracting each sensor's principal modes (SSA components)
% eigenvectors = [eigvect_sensor1, eigvect_sensor2, eigvect_sensor3];


% output_data_path = path;
% filename = 'eigenvectors25';
% name = strcat(output_data_path,filename);
% save(name,'eigenvectors');

% saving design matrix in libsvm compatible format, also in a mat file
% path = '../../../data/DAPHNET_mat_files/windows/length25/';
% file = strcat(path,'training_labels_25.mat');
% training_labels_st = load(file);
% training_labels = training_labels_st.training_labels;
% features = normalize(design_matrix,'range');
% features_sparse = sparse(features);
% old_folder = pwd;
% cd ../../libsvm-3.23/matlab/
% libsvmwrite('design_matrix25.train',training_labels, features_sparse);
% filename = 'design_matrix_25';
% name = strcat(path,filename);
% save(name,'design_matrix');
% cd(old_folder);             
output_data_path = path;
filename = 'eigenvectors25';
name = strcat(output_data_path,filename);
eigv_file = load(name);
eigenvectors = eigv_file.eigenvectors;
window_data = normalize(window_data);
trajectory_matrix1 = [squeeze(window_data(:,1,:));...
                     squeeze(window_data(:,2,:));...
                     squeeze(window_data(:,3,:))]';
  
trajectory_matrix2 = [squeeze(window_data(:,4,:));...
                     squeeze(window_data(:,5,:));...
                     squeeze(window_data(:,6,:))]';                 
                 
trajectory_matrix3 = [squeeze(window_data(:,7,:));...
                     squeeze(window_data(:,8,:));...
                     squeeze(window_data(:,9,:))]';
                 
% ssa_features = [trajectory_matrix1 * eigenvectors(:,1:5),...
%                trajectory_matrix2 * eigenvectors(:,6:10),...
%                trajectory_matrix3 * eigenvectors(:,11:15)];

         
             
design_matrix = [means_features, increments_features,... 
                 differences_features,...
                 standard_deviation(window_data),...
                 correlation_features,...
                 velocity_features,...
                 spectral_features(window_data,sample_freq),...
                 trajectory_matrix1 * eigenvectors(:,1:5), ...
                 trajectory_matrix2 * eigenvectors(:,6:10),...
                 trajectory_matrix3 * eigenvectors(:,11:15)...
                 ];
           
% saving design matrix in libsvm compatible format, also in a mat file
path = '../../../data/DAPHNET_mat_files/windows/length25/';
file = strcat(path,'test_labels_25.mat');
test_labels_st = load(file);
test_labels = test_labels_st.test_labels;
features = normalize(design_matrix);
features_sparse = sparse(features);
old_folder = pwd;
cd ../../libsvm-3.23/matlab/
libsvmwrite('design_matrix_25.test',test_labels, features_sparse);
filename = 'design_matrix_25_t';
name = strcat(path,filename);
save(name,'design_matrix');
cd(old_folder);  



             
             