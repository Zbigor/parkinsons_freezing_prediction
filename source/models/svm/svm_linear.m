
path = '../../../data/DAPHNET_mat_files/windows/personalized/S03/settings13/';

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

path = '../../../data/DAPHNET_mat_files/windows/personalized/S02/settings2/';

% loading the full design matrix with all extracted features
file = strcat(path,'design_matrix_s2.mat');
design_matrix_struct = load(file);
design_matrix = [design_matrix; design_matrix_struct.design_matrix];
clear design_matrix_struct

% loading the labels
file = strcat(path,'training_labels.mat');
labels_struct = load(file);
labels = [labels; labels_struct.training_labels];
clear labels_struct


path = '../../../data/DAPHNET_mat_files/windows/personalized/S05/settings1/';

% loading the full design matrix with all extracted features
file = strcat(path,'design_matrix_s5.mat');
design_matrix_struct = load(file);
design_matrix = [design_matrix; design_matrix_struct.design_matrix];
clear design_matrix_struct

% loading the labels
file = strcat(path,'training_labels.mat');
labels_struct = load(file);
labels = [labels; labels_struct.training_labels];
clear labels_struct

path = '../../../data/DAPHNET_mat_files/windows/personalized/S07/settings2/';

% loading the full design matrix with all extracted features
file = strcat(path,'design_matrix_s7.mat');
design_matrix_struct = load(file);
design_matrix = [design_matrix; design_matrix_struct.design_matrix];
clear design_matrix_struct

% loading the labels
file = strcat(path,'training_labels.mat');
labels_struct = load(file);
labels = [labels; labels_struct.training_labels];
clear labels_struct




% minimal set of features
% just using first channnel (ankle acc horiz forward)

% X = [design_matrix(:,1:99), design_matrix(:,109:123)];
% X = design_matrix(:,1:99);

% just the features from the sensor on the ankle 
% X = design_matrix(:,[1,2,3,10,11,12,28,29,30,37,38,39,46,47,48,55,56,57,...
%     64,65,66,73,74,75,82,83,84,91,92,93]);

% just the unsupervised on 
% X = design_matrix(:,109:123);

%  sequential feature selection 
% X = design_matrix(:,[2,41,89,94]);

% MI feature selection
% top10_feat_struct = load('top10q.mat');
% X = design_matrix(:,top10_feat_struct.top10q(1:4));



X = design_matrix(:,1:99);
dim = size(X);





% X = X(:,[6,8,10]);
% labeling as -1 and 1 needed for binomial distribution
labels(labels == 2) = -1;
y_full = labels;

% partition for MI feature selection

hold_MI = cvpartition(y_full,'Holdout',3/4,'Stratify',true);  

idxTrain = training(hold_MI,1);
idxTest = ~idxTrain;
XT = X(idxTrain,:);
yT = y_full(idxTrain);
Xtr = X(idxTest,:);
y = y_full(idxTest);

[top_features] = mrmr_miq_d(XT, yT, 99);
sensitivities = {};
specificities = {};
conf_matrices = {};

for n_features = 1:99

    
X = Xtr(:,top_features(1:n_features));    
c = cvpartition(y,'KFold',5,'Stratify',true);
conf = zeros(2,2);

conf_matrix_list = {};

numfog = sum(y==-1);
numgait = sum(y==1);

% false positive cost reversly proportionate to the ratio between the
% number of training classes of Fog and Gait
fn_cost = 1/(numfog/numgait);


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

% cost matrix for s07
% cost = [0, 5;1, 0];

% cost matrix for s02
% cost = [0, 2;1, 0];

% cost matrix for s03
% cost = [0, 1.3725;1, 0];

cost = [0, fn_cost;1, 0];

Model = fitclinear(XTrain',yTrain,'ObservationsIn','columns',...
    'Learner','svm','Cost',cost,...
    'OptimizeHyperparameters',{'Lambda','Regularization'},'HyperparameterOptimizationOptions',...
    opts);


[yhat,scores1] = predict(Model,XTest);

[con,order] = confusionmat(yTest,double(yhat));
conf_matrix_list{fold} = con/sum(sum(con));
conf = conf + conf_matrix_list{fold};
end


conf_matrices{n_features} = conf_matrix_list;

conf = conf/5;
disp(conf);
conf = conf';
tp = conf(1,1);
fp = conf(1,2);
fn = conf(2,1);
tn = conf(2,2);

% move it to a function
% matthews correlation coefficient

mcc = (tp*tn - fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));

% with respect to FoG class - order is [-1,1]
sensitivity = tp/(tp+fn);
specificity = tn/(tn+fp);

sensitivities{n_features} = sensitivity;
specificities{n_features} = specificity;

% F1 score
F1 = 2*tp/(2*tp+fp+fn);

report = {conf,sensitivity,specificity,F1,mcc,Model};





end




