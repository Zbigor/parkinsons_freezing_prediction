function [objective] = svm_objective_function(x, ...
                                  class_imbalance_weights, cv_param,...
                                  data_label, data_inst)

% initializing class imbalance weights, actual values TO BE DETERMINED
class_imbalance_weights = [1.0,1.0,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);

                              
% building the string of parameters 
model_params = "-c " + string(x.box) + " -g " + string(x.gamma) + " -v " + string(cv_param);
model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
model_params = model_params + " -w3 " + string(w3) + " -b 1";
% conversion to char array
model_params = char(model_params);

% changing folder in order to use LIBSVM
old_folder = pwd;
cd ../../libsvm-3.23/matlab/
% minus sign for bayesian optimization
objective =  - svmtrain(data_label, data_inst, model_params);
% think of a constraint
% maybe number of support vectors, but for that you need the model
% constraint = -1;
cd(old_folder)
end