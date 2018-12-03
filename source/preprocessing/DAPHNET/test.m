window_length = 2.5;
sample_rate = 64;
overlap_length = 1.25;

error = create_windows(window_length, sample_rate, overlap_length);
disp(error);
% data_struct = load('3D_S01R02.mat');
% data = data_struct.windows_3D;
% window = data(:,:,154);

% windows1 = load('~/lab_rotation/parkinsons_freezing_project/data/DAPHNET_mat_files/windows/length25/S09R01.mat');
% data1 = windows1.windows(1).data;
% data2 = windows1.windows(2).data;
% data3 = windows1.windows(3).data;
% 
% lab1 = windows1.windows(1).label;
% lab2 = windows1.windows(2).label;
% lab = cat(1,lab1,lab2);
% data = cat(3,data1,data2);
% data = cat(3,data,data3);
% 
% % initialization testing
% windows_count = 16;
% num_samp = 160;
% dat_st = load('S05R01.mat');
% dat = dat_st.data;
% dim = size(dat);
% init = zeros(num_samp,dim(2),1);
% data_init = repmat(zeros(num_samp,dim(2),1),[1,1,windows_count]);
% data_init(:,:,1) = data1;
% data_init(:,:,2) = data2;
% data_init(:,:,3) = data3;

% input_path = '../../../data/DAPHNET_mat_files/';
% output_data_path = '../../../data/DAPHNET_mat_files/windows/';
% files = dir(strcat(input_path,'*.mat'));

% 
% for file = files'
%     input_data_file = strcat(input_path,file.name);
%   
%     % creating training and test set 3d window data matrices  
%     % leaving 2 patients data out exclusively for testing
%     % they amount to 35 percent of the freezing events
%     if (file.name == "S03R01.mat")||(file.name == "S05R01.mat")
%         disp('test');
%     
%     else
%         disp('train');
%         
%     end
%     
% end





