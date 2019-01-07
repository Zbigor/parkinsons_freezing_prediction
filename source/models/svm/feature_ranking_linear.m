
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

X = design_matrix(:,1:99);

dim = size(X);
% X = X(:,[6,8,10]);
% labeling as -1 and 1 needed for binomial distribution
labels(labels == 2) = -1;
y = labels;
c = cvpartition(y,'KFold',5,'Stratify',true);

opts = statset('display','iter','UseParallel',false);
fun = @(XT,yT,Xt,yt)(classify_linear(Xt,yt,XT,yT));

[fs,history] = sequentialfs(fun,X,y,'cv',c,'direction','forward',...
                            'options',opts);
