function [rotated_window] = rotate_window_9chan(window_data)
%ROTATE_WINDOW_9CHAN generating synthetic data by data window rotation
% maybe separate the window into 2-3 subwindows, and perform a rotation
% by a different angle for each window
% for DAPHNET

sigma_x = 2;
sigma_y = 7;
sigma_z = 10;
% sampling from a gaussian 
x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);
% rotation matrix for the ankle as a compositon of rotation 
% around all 3 axes
R_ra = rotx(x)*roty(y)*rotz(z);
acc_a = window_data(:,2:4)';
acc_a_rot = R_ra * acc_a;

% sampling from a gaussian 
x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);
% rotation matrix for the thigh sensor
R_t = rotx(x)*roty(y)*rotz(z);
acc_t = window_data(:,5:7)';
acc_t_rot = R_t * acc_t;

% deviations for lumbar region (trunk)
sigma_x = 10;
sigma_y = 15;
sigma_z = 3.5;
% sampling from a gaussian 
x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);

R_l = rotx(x)*roty(y)*rotz(z);
acc_l = window_data(:,8:10)';
acc_l_rot = R_t * acc_l;

% concatenating rotated columns to obtain the synthetic window
rotated_window = [window_data(:,1), acc_a_rot', acc_t_rot',acc_l_rot',...
                  window_data(:,11)];

end





























