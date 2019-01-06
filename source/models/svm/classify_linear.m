function [mcc] = classify_linear(XTest,yTest,XTrain,yTrain)
%CLASSIFY_LINEAR Summary of this function goes here
%   Detailed explanation goes here


c_opt = cvpartition(yTrain,'KFold',5,'Stratify',true);
% Model = fitcsvm(XTrain,yTrain,'KernelFunction','rbf',...
%     'BoxConstraint',Inf,'ClassNames',[-1,1],'Standardize',true);
opts = struct('Optimizer','bayesopt','ShowPlots',false,'CVPartition',c_opt,...
    'AcquisitionFunctionName','expected-improvement-plus','UseParallel',true);

Model = fitclinear(XTrain',yTrain,'ObservationsIn','columns',...
    'Learner','svm',...
    'OptimizeHyperparameters',{'Lambda','Regularization'},'HyperparameterOptimizationOptions',...
    opts);


[yhat,scores1] = predict(Model,XTest);

[conf,order] = confusionmat(yTest,double(yhat));

conf = conf';
tp = conf(1,1);
fp = conf(1,2);
fn = conf(2,1);
tn = conf(2,2);

% move it to a function
% matthews correlation coefficient
% is used as the criterion for feature selection
mcc = (tp*tn - fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));



end

