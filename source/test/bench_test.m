% transform into a function with input arguments window length and latency

% set the input file paths (here you can iterate through all test files)
input_path = "../../data/DAPHNET_txt_data/";
filename = "S03R01.txt";
data_file = strcat(input_path,filename);
% load the data
data = load(data_file);

sample_rate = 64;
% extracting test data (removing parts marked as non-experimental)
% also removing very long standing sequences at the start and at the end

% For S03R02 [260,384] sec interval
% data = data(260*sample_rate:384*sample_rate,:);
% For S03R01 [1944 2062] sec interval
% data = data(1944*sample_rate:2062*sample_rate,:);

% data = data(1280*sample_rate:end,:);

% for s5
% data = data(342*sample_rate:1470*sample_rate,:);

% load the filter coefficients
filter_struct = load('filters.mat');
filters = filter_struct.filters;

filter1 = filters(:,1:2);
filter2 = filters(:,3:4);
filter3 = filters(:,5:6);




% load the prediction model
% model_struct = load("model_99.mat");
% model = model_struct.Model;

% model for s5
model_struct = load("Model_svml99_s3.mat");
model = model_struct.Model;

window_length = 3;
latency = 0.3;
y_log = [];
t_log = [];

head = 1;
tail = floor(window_length*sample_rate);

average_time = 0;
processed_windows = 0;
t_start = tic;

% stimulus signal for the patient
% upon a detection/prediction, stimulus starts being active for 2-3 seconds
% which amounts to 7-10 cycles since chosen latency is 0.3 seconds
% active stimulus -> stimulus = 1;

stim_duration_counter = 0;
stimulus = 0;
stimulus_log = zeros(1,10);

while (tail<length(data))

stimulus_log = [stimulus_log,stimulus];    
    
% data processing only when the stimulus is zero
if(stimulus == 0)||(stim_duration_counter>=10)

  old_head = head;
  old_tail = tail;
  
if(stim_duration_counter>=10)
    head = head - floor(10*latency * sample_rate);
   
    tail = tail - floor(10*latency * sample_rate);
    
     if (head<0)||(tail<0)
        head = old_head;
        tail = old_tail;
    end
end

stim_duration_counter = 0;
    
data_window = data(head:tail,:)/1000;

head = old_head;
tail = old_tail;

Xtest = online_feature_extraction(data_window,filter1,filter2,filter3);
yhat = predict(model,Xtest);

y_log = [y_log, yhat];

% abnormal gait detected
if (yhat == -1)
    timepoint = data(tail,1)/1000;
    t_log = [t_log, timepoint]; 
    stimulus = 1;
    % reseting stimulus counter
    stim_duration_counter = 0;
end

end

if (stimulus == 1)
   stim_duration_counter = stim_duration_counter + 1;
   if stim_duration_counter == 10
       stimulus = 0;
     
   end
end    
head = head + floor(latency * sample_rate); 
tail = tail + floor(latency * sample_rate);

processed_windows = processed_windows + 1;

end

t_elapsed = toc(t_start);
t_average = t_elapsed/processed_windows;

figure
plot(0:0.3:(processed_windows+10-1)*0.3,stimulus_log);
figure
stem(t_log,ones(1,length(t_log)))


