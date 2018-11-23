function[rotated_window] = rotate_window_27chan(window_data)
%ROTATE_WINDOW_27CHAN generating synthetic data by data window rotation
% maybe separate the window into 2-3 subwindows, and perform a rotation
% by a different angle for each window
% each sensor rotated by a different angle
% low rotation range for ankle sensors
% instead of random rotations, maybe a pre-defined set of angles

% generating random rotation angles (in degrees) around x,y and z axis for
% sensors in the lumbar region
% assuming that the angles are normally distributed around 0 degrees
% e.g. with standard deviation of 10 degrees (30 degrees = 3 sigma)
sigma_x = 2;
sigma_y = 7;
sigma_z = 10;
% sampling from a gaussian 
x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);
% rotation matrix for the right ankle as a compositon of rotation 
% around all 3 axes
R_ra = rotx(x)*roty(y)*rotz(z);

acc_ra = window_data(:,2:4)';
acc_ra_rot = R_ra * acc_ra;

gyr_ra = window_data(:,5:7)';
gyr_ra_rot = R_ra * gyr_ra;

mag_ra = window_data(:,8:10)';
mag_ra_rot = R_ra * mag_ra;

% same for left ankle

x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);
R_la = rotx(x)*roty(y)*rotz(z);

acc_la = window_data(:,2:4)';
acc_la_rot = R_la * acc_la;

gyr_la = window_data(:,5:7)';
gyr_la_rot = R_la * gyr_la;

mag_la = window_data(:,8:10)';
mag_la_rot = R_la * mag_la;

% generating random rotation angles (in degrees) around x,y and z axis for
% sensors in the lumbar region
% assuming that the angles are normally distributed around 0 degrees
% with standard deviation of 10 degrees (30 degrees = 3 sigma)
sigma_x = 10;
sigma_y = 15;
sigma_z = 3.5;
% sampling from a gaussian
x = sigma_x*randn(1,1);
y = sigma_y*randn(1,1);
z = sigma_z*randn(1,1);
% rotation matrix as a compositon of rotation around all 3 axes
R_lum = rotx(x)*roty(y)*rotz(z);

acc_lum = window_data(:,2:4)';
acc_lum_rot = R_lum*acc_lum;

gyr_lum = window_data(:,5:7)';
gyr_lum_rot = R_lum*gyr_lum;

mag_lum = window_data(:,8:10)';
mag_lum_rot = R_lum * mag_lum;

% concatenating rotated columns to obtain the synthetic window
rotated_window = [window_data(:,1),acc_ra_rot',gyr_ra_rot',mag_ra_rot',acc_la_rot',...
    gyr_la_rot', mag_la_rot',acc_lum_rot',gyr_lum_rot',mag_lum_rot'...
    window_data(:,end)];

end