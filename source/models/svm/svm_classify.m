function [predicted_labels] = svm_classify(x,test_data,test_labels, ...
                                           training_data, training_labels)
%SVM_CLASSIFY performing SVM clasification for given values of
% hyperparameters
% data already divided into kfold training and test

old_folder = pwd;

cd ../../libsvm-3.23/matlab/

% initializing class imbalance weights, actual values TO BE DETERMINED
class_imbalance_weights = [1.0,1.0,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);
% building the string of parameters 
model_params = "-c " + string(x.box) + " -g " + string(x.gamma);
model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
model_params = model_params + " -w3 " + string(w3) + " -b 1" + " -m "+ string(1000);
% conversion to char array
model_params = char(model_params);
% training the model
model = svmtrain(training_labels, training_data, model_params);
% predicted labels at the output
[predicted_labels, accuracy, prob_estimates] = svmpredict(test_labels,...
                                                  test_data, model,'-b 1');

cd(old_folder);

end

