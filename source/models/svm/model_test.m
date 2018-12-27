

file = load('svm_model_35_min.mat');
model = file.model;
input_data_path = '../../../data/DAPHNET_mat_files/windows/length35/final/design_matrix_min.test'; 
old_folder = pwd;
cd  ../../libsvm-3.23/matlab/
[data_label, data_inst] = libsvmread(input_data_path);

disp(size(data_inst));
[predicted_labels, accuracy, probs] = svmpredict(data_label,...
                                                 data_inst, model,' -b 1');

disp('Confusion matrix');
C = confusionmat(data_label,predicted_labels,'Order',[1,2,3]);
disp(C);
all_labels = [data_label, predicted_labels];
cd(old_folder)
% disp(probs);


