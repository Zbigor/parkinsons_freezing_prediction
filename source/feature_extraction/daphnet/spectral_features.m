function [features_out] = spectral_features(window, Fs)
%STD_SPECTRAL_FEATURES Calculating spectral features
% expected all windows from a recording session as a 3D matrix input
% output gives spectral features for all windows, output dimensions:
% output = #windows x #spectral features
% extracting window data without time axis
window_data = window(:,2:10,:);
dim = size(window_data);
% number of windows
N_w = dim(3);

% bandpass filtering on the defined regions
% last filter is for full gait spectral range in which the peak search will
% be performed
% filtering is performed in parallel, with respect to windows

% initializing filter output matrix              
bp_window_data = [];

% initializing the matrix of autoregression coefficients
% Auto regression coefficients provide information of how the signal is
% correlated with a time-shifted version of itself
ar= [];
% creating bandpass filters
% maybe 0.5 instead of 0.68 Hz
[b1,a1] = butter(3,[0.1 0.68]/(Fs/2),'bandpass');
[b2,a2] = butter(3,[0.68 3]/(Fs/2),'bandpass');
[b3,a3] = butter(3,[3 8]/(Fs/2),'bandpass');
[b4,a4] = butter(3,[8 20]/(Fs/2),'bandpass');
[b5,a5] = butter(3,[0.68 3]/(Fs/2),'bandpass');
[b6,a6] = butter(3,[3 8]/(Fs/2),'bandpass');

parfor it_w = 1:N_w
    % filtering with filtfilt to avoid phase delay
    bp_window_data(:,:,it_w) = [filtfilt(b1,a1,window_data(:,:,it_w)), ...
                                filtfilt(b2,a2,window_data(:,:,it_w)),...
                                filtfilt(b3,a3,window_data(:,:,it_w)),...
                                filtfilt(b4,a4,window_data(:,:,it_w)),...
                                filtfilt(b5,a5,window_data(:,:,it_w)),...
                                filtfilt(b6,a6,window_data(:,:,it_w))...
                                ];
    ar(:,:,it_w) = arburg(squeeze(window_data(:,:,it_w)),4)';
end

% repacking autoregression coefficients as separate features
ar_features = [squeeze(ar(1,:,:))', squeeze(ar(2,:,:))',...
               squeeze(ar(3,:,:))', squeeze(ar(4,:,:))', ... 
               squeeze(ar(5,:,:))'];

% length of the window

L = dim(1);
% calculating window fft for all axes of all sensors
% zero padding used for optimizing the calculation
n = 2^nextpow2(L);
Y = fft(bp_window_data,n,1);
% two sided spectrum
P2 = abs(Y/n);
% one-sided spectrum
P1 = P2(1:n/2+1,:,:);
P1(2:end-1,:,:) = 2*P1(2:end-1,:,:);

% Standard deviation on specific spectral bands
%   Provides information about the distribution of harmonics in 
% these bands, which define if the harmonics are distributed along the band
% or if there are significant harmonics. It can give information about 
% stability or specific significant peaks in a band.
% excluding the full [0.1,20] Hz spectre from the calculation
stdev_features = squeeze(std(P1(:,1:end-9,:)))';

% Highest harmonic peaks  
% Useful for detecting concrete events in specific spectral bands
% (e.g. high peaks in 0.1Hz to 0.68 Hz band can be considered as a candidate to be a postural
% transition)
% Extracting 2 highest peaks

% finding 2 highest peaks for each axis of each sensor
full_spectre = P1(:,end-8:end,:);
[maxvalues, ind] = maxk(full_spectre, 2);
maxval_features = [squeeze(maxvalues(1,:,:))', squeeze(maxvalues(2,:,:))'];
clearvars maxvalues
% maxvalues has dimensions 2 x #channels x #windows and it represents
% amplitudes of maximum harmonics

% extracting the respective frequencies of the maximum harmonics using the
% above calculated indices
% frequency axis
f = Fs*(0:(n/2))/n;
fmax = f(ind);
clearvars ind
maxfreq_features = [squeeze(fmax(1,:,:))', squeeze(fmax(2,:,:))'];

% Power in the freezing band
% It was found that leg trembling during freezing is characterized by a 
% higher frequency pattern
% with respect to the one that is characteristic of walking (7, 8, 14, 15). This feature is the
% power in this freezing band, which is defined to be between 3 and 8 Hz, as in Ref. (8). This
% total power: over each axis of each sensor
total_pow_freezing = (sum(squeeze(sum(P1(:,19:27,:).*P1(:,19:27,:)))))';

% Power in the locomotor band
total_pow_locomotor = (sum(squeeze(sum(P1(:,10:18,:).*P1(:,10:18,:)))))';
% Freezing index
% It is the ratio between the power in the freezing band and the power in the locomotor band
% (8). It is usually used in studies for detecting freezing of gait with inertial sensors. When
% freezing is already in place, this index tends to show a high value (8, 14, 15).
% total power: over each axis of each sensor
freezing_index = total_pow_freezing/total_pow_locomotor;


% Spectral density centre of mass gives information about the overall 
% quantity of movement performed and the frequency band in which most of 
% the movement is concentrated.

% first normalize each column in each window (normalize each axis spectrum)
% by dividing it with its sum, then applying the mean operator
centroid_features = squeeze(mean(full_spectre./sum(full_spectre)))';

% calculating skewness for each axis of each sensor in the time domain
skewness_features_t = squeeze(skewness(window_data,0,1))';
% calculating skewness for each axis of each sensor in the spectral domain
skewness_features_f = squeeze(skewness(P1,0,1))';

% calculating skewness for each axis of each sensor in the time domain
kurtosis_features_t = squeeze(kurtosis(window_data,0,1))';
% calculating skewness for each axis of each sensor in the spectral domain
kurtosis_features_f = squeeze(kurtosis(P1,0,1))';

% packing all features into a design matrix, to be merged with other
% features
features_out = [ar_features, stdev_features, maxval_features, ...
                maxfreq_features, total_pow_freezing, total_pow_locomotor,...
                freezing_index, centroid_features, skewness_features_t,...
                skewness_features_f, kurtosis_features_t, ... 
                kurtosis_features_f];

            
            
end

