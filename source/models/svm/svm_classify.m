function [predicted_labels] = svm_classify(x,test_data,test_labels, ...
                                           training_data, training_labels)
%SVM_CLASSIFY performing SVM clasification for given values of
% hyperparameters
% data already divided into kfold training and test

old_folder = pwd;
fileID = fopen('../../../data/logs/svm/svm_log.txt','a');
fprintf(fileID,'%f',x.box);
fprintf(fileID,'//');
fprintf(fileID,'%f',x.gamma);
fprintf(fileID,'//');

cd ../../libsvm-3.23/matlab/

% initializing class imbalance weights, actual values TO BE DETERMINED
class_imbalance_weights = [0.1,0.5,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);
% building the string of parameters 
% training without the probabilities since they are not taken into account
% for optimization
model_params = "-c " + string(x.box) + " -g " + string(x.gamma) + " -w1" + string(100);
% model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
% model_params = model_params + " -w3 " + string(w3) + " -m "+ string(6400);
model_params = model_params + " -m "+ string(6400) + " -b 1";
% conversion to char array
model_params = char(model_params);
% training the model
disp('training the model');
fprintf(fileID, 'Training a model for given parameters \n\n');
model = svmtrain(training_labels, training_data, model_params);
% predicted labels at the output
disp('generating predicted labels');
fprintf(fileID, 'Generated predicted labels \n\n');
[predicted_labels, accuracy, vals] = svmpredict(test_labels,...
                                                  test_data, model);
fclose(fileID);
cd(old_folder);

end

