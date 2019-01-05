function [objective,constraints] = svm_objective_function(x, ...
                                  class_imbalance_weights, cv_param,...
                                  data_label, data_inst)

class_imbalance_weights = [10,0.1,0.1];
w1 = class_imbalance_weights(1);
w2 = class_imbalance_weights(2);
w3 = class_imbalance_weights(3);                           

order = [1, -1];
% splitting the data for k-fold crossvalidation
c = cvpartition(data_label,'KFold',cv_param,'Stratify',true);
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
cfMat = reshape(sum(cfMat),2,2);
disp('confusion_matrix');
norm_cfMat = 100*cfMat/sum(sum(cfMat));
disp(norm_cfMat);
fileID = fopen('../../../data/logs/svm/svm_log.txt','a');
fprintf(fileID, 'Confusion matrix \n\n');
fmt = '%f %f %f\n';
fprintf(fileID,fmt, norm_cfMat);
fprintf(fileID, '\n\n');

% accuracy
accuracy = trace(cfMat)/(sum(sum(cfMat)));
fprintf(fileID, 'Accuracy \n\n');
fprintf(fileID,'%f',100*accuracy);
fprintf(fileID, '\n\n');
disp('accuracy')
disp(accuracy);

% sensitivity for each class
sens_gait = 0;
if (sum(cfMat(1,:))>0)
    sens_gait = cfMat(1,1)/sum(cfMat(1,:));
end
sens_fog = 0;

if (sum(cfMat(2,:))>0)
    sens_fog = cfMat(2,2)/sum(cfMat(2,:));
end
% sens_prefog = 0;
% if (sum(cfMat(3,:))>0)
% 
%     sens_prefog = cfMat(3,3)/sum(cfMat(3,:));
% end
fprintf(fileID, 'Sensitivities \n\n');
fprintf(fileID,fmt,[sens_gait, sens_fog]);
fprintf(fileID, '\n\n');
% specificity for each class

spec_gait = 0;
if(sum(cfMat(:,1))>0)
spec_gait = cfMat(1,1)/sum(cfMat(:,1));
end
spec_fog = 0;

if (sum(cfMat(:,2))>0)
spec_fog = cfMat(2,2)/sum(cfMat(:,2));
end

% spec_prefog = 0;
% if(sum(cfMat(:,3))>0)
% spec_prefog = cfMat(3,3)/sum(cfMat(:,3));
% end
% objective function value is minimized, hence maximizing accuracy 
objective = - sens_fog - sens_gait;
% forming the coupled constraints
% initially all constraints violated
% all constraints are satisfied if all sensitivities and specificities are
% at least 75 %
constraints = ones(6,1);
constraints(1) = 0.75-sens_gait;
constraints(2) = 0.75-sens_fog;
% constraints(3) = 0.75-sens_prefog;
constraints(3) = 0.75-spec_gait;
constraints(4) = 0.75-spec_fog;
% constraints(6) = 0.75-spec_prefog;
num_file = load('NSV');
constraints(5) = num_file.num_sv - 100;
constraints(6) = 6 - num_file.num_sv;
% if(sens_gait > 0.75)
%     constraints(1) = -1;
% end
% 
% if(sens_fog > 0.75)
%     constraints(2) = -1;
% end
% 
% if(sens_prefog > 0.75)
%     constraints(3) = -1;
% end
% 
% if(spec_gait > 0.75)
%     constraints(4) = -1;
% end
% 
% if(spec_fog > 0.75)
%     constraints(5) = -1;
% end
% 
% if(spec_prefog >0.75)
%     constraints(6) = -1;
% end
disp('SV');
disp(num_file.num_sv);
disp('');
fprintf(fileID,'Num SV\n');
fprintf(fileID,'%d',num_file.num_sv);
fprintf(fileID,'Num SV\n');

% if(num_sv<120)
%     constraints(7) = -1;
% end

fmt = '%f %f %f %f %f\n';
fprintf(fileID,fmt, constraints);
fclose(fileID);


end



