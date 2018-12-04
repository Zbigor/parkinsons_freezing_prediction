input_data_path = '../../../data/DAPHNET_mat_files/windows/length25/final/design_matrix25.train'; 

output_data_path = '../../../data/DAPHNET_mat_files/windows/length25/final/';

class_imbalance_weights = [1.0,1.0,1.0];
filename = 'svm_model_25.mod';

disp('Commencing model training');
[results,g,c] = train_svm_bayesian(input_data_path,output_data_path,...
                              class_imbalance_weights, filename);


% clearvars
% load fisheriris
% 
% 
% labels = zeros(length(species),1);
% for it = 1:length(species)
%     if (species{it} == "setosa")
%         labels(it) = 1;
%         
%     else
%         if (species{it} == "versicolor")
%         
%             labels(it) = 2;
%         
%         else
%             labels(it) = 3;
%         end
%     end
% end
% 
% clearvars species
% 
% data_label = labels;
% data_inst = normalize(meas,'range');
% cv_param = 5;
% order = [1 2 3];
% c = cvpartition(data_label,'KFold',cv_param);
% f_eval = @(xtr,ytr,xte,yte)confusionmat(yte,...
%                                       svm_classify(xte,yte,xtr,ytr),'order',order);
% 
% old_folder = pwd;
% 
% cd(old_folder)
% cfMat = crossval(f_eval,data_inst,data_label,'partition',c);
% cfMat = reshape(sum(cfMat),3,3);
% % accuracy
% acc = trace(cfMat)/(sum(sum(cfMat)));
% % sensitivity for each class
% sens_gait = cfMat(1,1)/sum(cfMat(1,:));
% sens_fog = cfMat(2,2)/sum(cfMat(2,:));
% sens_prefog = cfMat(3,3)/sum(cfMat(3,:));
% % specificity for each class
% spec_gait = cfMat(1,1)/sum(cfMat(:,1));
% spec_fog = cfMat(2,2)/sum(cfMat(:,2));
% spec_prefog = cfMat(3,3)/sum(cfMat(:,3));






