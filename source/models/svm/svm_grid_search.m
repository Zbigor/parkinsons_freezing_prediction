function [c_best,g_best,best_accuracy] = svm_grid_search(g_exp,c_exp, ...
                              class_imbalance_weights, cv_param, ...
                              data_label, data_inst)
%SVM_GRID_SEARCH This function performs grid search over svm parameters
%   Detailed explanation goes here
old_folder = pwd;
cd ../../libsvm-3.23/matlab/

% initializing class imbalance weights, actual values TO BE DETERMINED
class_imbalance_weights = [1.0,1.0,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);
% initalizing indices of the best parameters
g_best = 1;
c_best = 1;
% initializing cv classification accuracy
best_accuracy = 0;
    
% grid search 
for it_c = 1:length(c_exp)
    for it_g = 1:length(g_exp)
        c = pow2(c_exp(it_c));
        g = pow2(g_exp(it_g));
        % building the string of parameters 
        model_params = "-c " + string(c) + " -g " + string(g) + " -v " + string(cv_param);
        model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
        model_params = model_params + " -w3 " + string(w3) + " -b 1";
        % conversion to char array
        model_params = char(model_params); 
        % Do k-fold cross validation for the classifier
        cv_accuracy = svmtrain(data_label, data_inst, model_params);
        if cv_accuracy>best_accuracy
            best_accuracy = cv_accuracy;
            c_best = it_c;
            g_best = it_g;
        end
        
    end

end

cd(old_folder)
end

