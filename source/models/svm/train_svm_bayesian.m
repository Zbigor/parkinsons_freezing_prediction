function [results,g,c] = train_svm_bayesian(input_data_path,output_data_path,...
                              class_imbalance_weights, filename)
%TRAIN_SVM_BAYESIAN generate svm model with bayesian optimization of
% its hyperparameters
%   Detailed explanation goes here
disp('SVM training started');
fileID = fopen('../../../data/logs/svm/svm_log.txt','a');
fprintf(fileID, 'SVVM training started \n\n');
% reading training data
% assuming the data is already prepared in a proper format
old_folder = pwd;
cd  ../../libsvm-3.23/matlab/
[data_label, data_inst] = libsvmread(input_data_path);
fprintf(fileID, 'number of class1 \n\n');
cl1 = sum(data_label==1);
fprintf(fileID, '%d',cl1);

fprintf(fileID, 'number of class 2 \n\n');
cl2 = sum(data_label==2);
fprintf(fileID, '%d',cl2);

fprintf(fileID, 'number of class 3 \n\n');
cl3 = sum(data_label==3);
fprintf(fileID, '%d',cl3);

fprintf(fileID, 'Input data read \n\n');
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
fprintf(fileID, 'Bayesian optimization started \n\n');
fclose(fileID);
results = bayesopt(minfn,x,'IsObjectiveDeterministic',true,...
    'NumCoupledConstraints',6,...
    'PlotFcn',...
    {@plotMinObjective,@plotConstraintModels},...
    'UseParallel',true,...
    'AcquisitionFunctionName','expected-improvement-plus', ...
    'Verbose',0);
% generating input parameter string
g = results.XAtMinObjective.gamma;
c = results.XAtMinObjective.box;
model_params = "-c " + string(c) + " -g " + string(g);
model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
model_params = model_params + " -w3 " + string(w3) + " -b 1"+ " -m " + string(6500);
% for testing purposes with 2 classes
model_params = model_params + " -b 1";
model_params = char(model_params);
% training the model with optimized parameters
cd ../../libsvm-3.23/matlab/
disp('training the model with optimized parameters');
model = svmtrain(data_label, data_inst,model_params);
cd(old_folder)
% exporting the model
name = strcat(output_data_path,filename);
save(name,'model');

end



















