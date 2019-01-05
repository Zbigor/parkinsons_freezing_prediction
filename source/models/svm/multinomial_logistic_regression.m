function [model,d,s,inds] = multinomial_logistic_regression(input_data_path,output_data_path,...
                              class_imbalance_weights, filename)
%MULTINOMIAL_LOGISTIC_REGRESSION Summary of this function goes here
%   Detailed explanation goes here

old_folder = pwd;
cd  ../../libsvm-3.23/matlab/
[data_label, data_inst] = libsvmread(input_data_path);
cd(old_folder)
design_matrix = full(data_inst);
design_matrix = design_matrix(:,37:75);
% design_matrix = [design_matrix(:,19:27),design_matrix(:,37:60)];
% changing labels, so that the gait becomes the reference class
gait_labels = data_label == 1;
prefog_labels = data_label == 3;
data_label(gait_labels) = 3;
data_label(prefog_labels) = 1;
class_labels = nominal(data_label);

[model,d,s] = mnrfit(design_matrix,class_labels);

pvals = s.p;



inds = [];
for it = 1:length(pvals-1)
if (pvals(it,1)>0.05) && (pvals(it,2)>0.05)

    inds = [inds,it];
end
end
design_matrix = design_matrix(:,setdiff(1:end,inds));


[model,dev,stats] = mnrfit(design_matrix,class_labels);




name = strcat(output_data_path,filename);
save(name,'model');



end

