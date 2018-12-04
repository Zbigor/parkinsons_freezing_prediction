function [objective, constraints] = svm_objective_function(x, ...
                                  class_imbalance_weights, cv_param,...
                                  data_label, data_inst)

class_imbalance_weights = [1.0,1.0,1.0];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);                           

order = [1 2 3];
% splitting the data for k-fold crossvalidation
c = cvpartition(data_label,'KFold',cv_param);
% evaluation function for crossvalidated confusion matrix
f_eval = @(xtr,ytr,xte,yte)confusionmat(yte,...
                                      svm_classify(x,xte,yte,xtr,ytr),'order',order);
old_folder = pwd;
cd(old_folder)
disp('performing crossvalidation');
fileID = fopen('../../../data/logs/svm/svm_log.txt','a');
fprintf(fileID, 'Performing crossvalidation \n\n');
fclose(fileID);


cfMat = crossval(f_eval,data_inst,data_label,'partition',c);
cfMat = reshape(sum(cfMat),3,3);
disp('confusion_matrix');
norm_cfMat = 100*cfMat/sum(sum(cfMat));
disp(norm_cfMat);
fileID = fopen('../../../data/logs/svm/svm_log.txt','a');
fprintf(fileID, 'Confusion matrix \n\n');
fmt = '%f %f %f\n';
fprintf(fileID,fmt, norm_cfMat);

% accuracy
accuracy = trace(cfMat)/(sum(sum(cfMat)));
fprintf(fileID, 'Accuracy \n\n');
fprintf(fileID,'%f',100*accuracy);
disp('accuracy')
disp(accuracy);

% sensitivity for each class
sens_gait = cfMat(1,1)/sum(cfMat(1,:));
sens_fog = cfMat(2,2)/sum(cfMat(2,:));
sens_prefog = cfMat(3,3)/sum(cfMat(3,:));
% specificity for each class
spec_gait = cfMat(1,1)/sum(cfMat(:,1));
spec_fog = cfMat(2,2)/sum(cfMat(:,2));
spec_prefog = cfMat(3,3)/sum(cfMat(:,3));

% objective function value is minimized, hence maximizing accuracy 
objective = -accuracy;
% forming the coupled constraints
% initially all constraints violated
% all constraints are satisfied if all sensitivities and specificities are
% at least 75 %
constraints = ones(6,1);

if(sens_gait > 0.75)
    constraints(1) = -1;
end

if(sens_fog > 0.75)
    constraints(2) = -1;
end

if(sens_prefog > 0.75)
    constraints(3) = -1;
end

if(spec_gait > 0.75)
    constraints(4) = -1;
end

if(spec_fog > 0.75)
    constraints(5) = -1;
end

if(spec_prefog >0.75)
    constraints(6) = -1;
end
fmt = '%f %f %f %f %f %f\n';
fprintf(fileID,fmt, constraints);
fclose(fileID);


end



