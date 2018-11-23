window_length = 2.5;
sample_rate = 64;
overlap_length = 1.25;

error = create_windows(window_length, sample_rate, overlap_length);
disp(error);

windows1 = load('~/lab_rotation/parkinsons_freezing_project/data/DAPHNET_mat_files/windows/length25/S09R01.mat');