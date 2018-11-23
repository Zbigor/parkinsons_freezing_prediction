% assumes that all training data is already available in the proper format
function [] = train_svm_model(input_data_path,output_data_path,filename)

addpath ../../libsvm-3.23/matlab/
    
    % reading training data
    % assuming the data is already prepared in a proper format
    [data_label, data_inst] = libsvmread(input_data_path);

    % building the svm model
    % explain input parameters
    % TO DO: OPTIMIZE hyperparameters
    % perform crossvalidated grid search
    
    
    
    
    
    model = svmtrain(data_label, data_inst, '-c 1 -g 0.07 -b 1');
    % exporting the model
    name = strcat(output_data_path,filename);
    save(name,'model');

rmpath ../../libsvm-3.23/matlab/

end

