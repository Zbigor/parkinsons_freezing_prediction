% testing the svm input

% normalizing data
% will be used as a separate function

M = data;
labels = M(:,11);
features = normalize(M(:,2:10),'range');
features_sparse = sparse(features);

libsvmwrite('test_data.train',labels, features_sparse);

[data_label, data_inst] = libsvmread('test_data.train');
model = svmtrain(data_label, data_inst, '-c 1 -g 0.07 -b 1');
[predict_label, accuracy, prob_estimates] = svmpredict(data_label,...
                                            data_inst, model, '-b 1');
