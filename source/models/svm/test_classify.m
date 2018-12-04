function [ypred] = test_classify(xte,yte,xtr,ytr)
%TEST_CLASSIFY Test version of the SVM classifier
%   calling the SVM 
old_folder = pwd;

cd ../../libsvm-3.23/matlab/

% initializing class imbalance weights, actual values TO BE DETERMINED
class_imbalance_weights = [1.0,1.0,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);
% building the string of parameters 
model_params = "-c " + string(100) + " -g " + string(0.1);
model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
model_params = model_params + " -w3 " + string(w3) + " -b 1" + " -m "+ string(1000);
% conversion to char array
model_params = char(model_params);

model = svmtrain(ytr, xtr, model_params);
[ypred, accuracy, prob_estimates] = svmpredict(yte, xte, model,'-b 1');

cd(old_folder);
% disp(prob_estimates);



end

