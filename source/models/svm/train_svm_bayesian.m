function [results,g,c] = train_svm_bayesian(input_data_path,output_data_path,...
                              class_imbalance_weights, filename)
%TRAIN_SVM_BAYESIAN generate svm model with bayesian optimization of
% its hyperparameters
%   Detailed explanation goes here

% reading training data
% assuming the data is already prepared in a proper format
old_folder = pwd;
cd  ../../libsvm-3.23/matlab/
[data_label, data_inst] = libsvmread(input_data_path);
disp('data labels');
disp(size(data_label));
% cross-validation parameter
cv_param = 5;
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);
cd(old_folder) 

gamma = optimizableVariable('gamma',[1e-6,1e6],'Transform','log');
box = optimizableVariable('box',[1e-6,1e6],'Transform','log');
x = [gamma,box];

minfn = @(x)svm_objective_function(x,class_imbalance_weights, cv_param,...
                                  data_label, data_inst); 
disp('Commencing Bayesian Optimization');
results = bayesopt(minfn,x,'IsObjectiveDeterministic',true,...
    'NumCoupledConstraints',1,'PlotFcn',...
    {@plotMinObjective,@plotConstraintModels},...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',0);
% generating input parameter string
g = results.XAtMinObjective.gamma;
c = results.XAtMinObjective.box;
model_params = "-c " + string(c) + " -g " + string(g);
model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
model_params = model_params + " -w3 " + string(w3) + " -b 1"+ " -m " + string(1000);
% for testing purposes with 2 classes
model_params = model_params + " -b 1";
model_params = char(model_params);
% training the model with optimized parameters
cd ../../libsvm-3.23/matlab/
model = svmtrain(data_label, data_inst,model_params);
cd(old_folder)
% exporting the model
name = strcat(output_data_path,filename);
save(name,'model');

end



















