
path = '../../../data/DAPHNET_mat_files/windows/personalized/S03/settings11/';

% loading the full design matrix with all extracted features
file = strcat(path,'design_matrix_s3.mat');
design_matrix_struct = load(file);
design_matrix = design_matrix_struct.design_matrix;
clear design_matrix_struct

% loading the labels
file = strcat(path,'training_labels.mat');
labels_struct = load(file);
labels = labels_struct.training_labels;
clear labels_struct


% minimal set of features
% just using first channnel (ankle acc horiz forward)

X = design_matrix(:,[1,10,28,37,46,55,64,73,82,91,109,110,111,112,113]);
dim = size(X);
% X = X(:,[6,8,10]);
% labeling as -1 and 1 needed for binomial distribution
labels(labels == 2) = -1;
y = labels;
c = cvpartition(y,'KFold',5,'Stratify',true);
conf = zeros(2,2);
for fold = 1:5

idxTrain = training(c,fold);
idxTest = ~idxTrain;
XTrain = X(idxTrain,:);
yTrain = y(idxTrain);
XTest = X(idxTest,:);
yTest = y(idxTest);

c_opt = cvpartition(yTrain,'KFold',5,'Stratify',true);
% Model = fitcsvm(XTrain,yTrain,'KernelFunction','rbf',...
%     'BoxConstraint',Inf,'ClassNames',[-1,1],'Standardize',true);
opts = struct('Optimizer','bayesopt','ShowPlots',false,'CVPartition',c_opt,...
    'AcquisitionFunctionName','expected-improvement-plus','UseParallel',true);

Model = fitcsvm(XTrain,yTrain,'KernelFunction','rbf',...
    'OptimizeHyperparameters','all','HyperparameterOptimizationOptions',opts);


[yhat,scores1] = predict(Model,XTest);

[con,order] = confusionmat(yTest,double(yhat));
conf = conf + con/sum(sum(con));
end
conf = conf/5;

disp(conf);


















