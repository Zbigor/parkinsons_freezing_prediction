
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

X = design_matrix(:,[1,10,28,37,46,55,64,73,82,91]);
dim = size(X);
% X = X(:,[6,8,10]);
% labeling as 0 and 1 needed for binomial distribution
yBinom = labels - 1;

c = cvpartition(yBinom,'KFold',5,'Stratify',true);
conf = zeros(2,2);
for fold = 1:5

idxTrain = training(c,fold);
idxTest = ~idxTrain;
XTrain = X(idxTrain,:);
yTrain = yBinom(idxTrain);
XTest = X(idxTest,:);
yTest = yBinom(idxTest);

[B,FitInfo] = lassoglm(XTrain,yTrain,'binomial','CV',10,'Alpha',0.5,...
                                  'Options',statset('UseParallel',true));


idxMinDeviance = FitInfo.IndexMinDeviance;
B0 = FitInfo.Intercept(idxMinDeviance);
coef = [B0; B(:,idxMinDeviance)];

yhat = glmval(coef,XTest,'logit');
yhatBinom = (yhat>=0.5);
[con,order] = confusionmat(yTest,double(yhatBinom));
conf = conf + con/sum(sum(con));
end
conf = conf/5;

disp(conf);

