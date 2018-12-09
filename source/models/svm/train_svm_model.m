% assumes that all training data is already available in the proper format
function [] = train_svm_model(input_data_path,output_data_path,...
                              class_imbalance_weights, filename)
old_folder = pwd;
cd  ../../libsvm-3.23/matlab/
    
    % reading training data
    % assuming the data is already prepared in a proper format
    [data_label, data_inst] = libsvmread(input_data_path);

    % building the svm model
    % explain input parameters
    % TO DO: OPTIMIZE hyperparameters
    % perform crossvalidated grid search
    % additionally try solving class imbalance by adding weights
    % Initially just use 1.0 until you have the definite imbalance
    % for class penalties
    w1 = class_imbalance_weights(1);
    w2 = class_imbalance_weights(2);
    w3 = class_imbalance_weights(3);
    
    % cross-validation parameter
    cv_param = 5;
    % exponents for the parameter C
    c_exp = linspace(-3,4,9);
    % exponents for the parameter gamma
    g_exp = linspace(-6,3,5);
    cd(old_folder)
    % number of iteration, 'zooming in' around the best tuple for each iter
    N_zooms = 1;
    c_best = 0;
    g_best = 0;
    best_accuracy = 0;
    acc = zeros(1,N_zooms);
    step = 2;
    for it_z = 1:N_zooms
        % grid search
        [c_best, g_best,best_accuracy] = svm_grid_search(g_exp,c_exp, ...
                                  class_imbalance_weights, cv_param,...
                                  data_label,data_inst);
        acc(it_z) = best_accuracy; 
        if (it_z<N_zooms)
            % fine grid search in the interval around the best parameter tuple
            % setting the parameter exponent interval
            c_exp_new = linspace(c_exp(c_best)-step,c_exp(c_best)+step,5);
            g_exp_new = linspace(g_exp(g_best)-step,g_exp(g_best)+step,5);
            step = step * 0.1;
            clearvars c_exp g_exp
            % fine grid 
            c_exp = c_exp_new;
            g_exp = g_exp_new;
        end
    end
    % generating input parameter string
    c = pow2(c_exp(c_best));
    g = pow2(g_exp(g_best));
    model_params = "-c " + string(c) + " -g " + string(g);
    model_params = model_params + " -w1 " + string(w1) + " -w2 " + string(w2);
    model_params = model_params + " -w3 " + string(w3) + " -b 1" + " -m" + string(6400) + " -q 0";
    % for testing purposes with 2 classes
%     model_params = model_params + " -b 1";
    model_params = char(model_params);
    % training the model with optimized parameters
    cd ../../libsvm-3.23/matlab/
    model = svmtrain(data_label, data_inst,model_params);
    cd(old_folder)
    % exporting the model
    name = strcat(output_data_path,filename);
    save(name,'model');
    disp("best accuracy = ");
    disp(best_accuracy);
    disp("c = ");
    disp(c);
    disp("g = ");
    disp(g);
    disp(acc);
    figure
    plot(1:N_zooms,acc);

end

