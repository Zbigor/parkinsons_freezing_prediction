function [features_out] = spectral_features(window, Fs,filter1,...
                                            filter2, filter3)
%STD_SPECTRAL_FEATURES Calculating spectral features
% expected a window from the test session as a 2D matrix input
% output gives spectral features for the window, output dimensions:
% output = #spectral features
% extracting window data without time axis
window_data = window(:,2:10);




% filtering with filtfilt to avoid phase delay
bp_window_data = [filtfilt(filter1(:,1),filter1(:,2),window_data), ...
                  filtfilt(filter2(:,1),filter2(:,2),window_data),...
                  filtfilt(filter3(:,1),filter3(:,2),window_data)...
%                                 filtfilt(b4,a4,window_data(:,:,it_w)),...
%                                 filtfilt(b5,a5,window_data(:,:,it_w)),...
%                                 filtfilt(b6,a6,window_data(:,:,it_w))...
                                ];
%     ar(:,:,it_w) = arburg(squeeze(window_data(:,:,it_w)),4)';
%     disp(it_w);


% repacking autoregression coefficients as separate features
% ar_features = [squeeze(ar(1,:,:))', squeeze(ar(2,:,:))',...
%                squeeze(ar(3,:,:))', squeeze(ar(4,:,:))', ... 
%                squeeze(ar(5,:,:))'];
% disp('ar_features dimension');
% disp(size(ar_features));
% length of the window
dim = size(window_data);
L = dim(1);
% calculating window fft for all axes of all sensors
% zero padding used for optimizing the calculation
n = 2^nextpow2(L);
Y = fft(bp_window_data,n);
% two sided spectrum
P2 = abs(Y/n);
% one-sided spectrum
P1 = P2(1:n/2+1,:);
P1(2:end-1,:) = 2*P1(2:end-1,:);

% Standard deviation on specific spectral bands
%   Provides information about the distribution of harmonics in 
% these bands, which define if the harmonics are distributed along the band
% or if there are significant harmonics. It can give information about 
% stability or specific significant peaks in a band.
% excluding the full [0.1,20] Hz spectre from the calculation
% disp('Calculate standard deviations');

stdev_features = (std(P1(:,1:end-9)));

% disp('standard deviation dimension');
% disp(size(stdev_features));
% % Highest harmonic peaks  
% Useful for detecting concrete events in specific spectral bands
% (e.g. high peaks in 0.1Hz to 0.68 Hz band can be considered as a candidate to be a postural
% transition)
% Extracting 2 highest peaks
% disp('Extracting 2 highest peaks');
% finding 2 highest peaks for each axis of each sensor
full_spectre = P1(:,end-8:end);
[maxvalues, ind] = maxk(full_spectre, 2);
% maxval_features = [(maxvalues(1,:))', (maxvalues(2,:))'];
% disp('2 highest peaks dim');
% disp(size(maxval_features));
% clearvars maxvalues
% maxvalues has dimensions 2 x #channels x #windows and it represents
% amplitudes of maximum harmonics

% extracting the respective frequencies of the maximum harmonics using the
% above calculated indices
% frequency axis
% disp('extracting frequencies with max amplitudes');
f = Fs*(0:(n/2))/n;
fmax = f(ind);
% clearvars ind
% disp('Calculating maxfreq features');
maxfreq_features = [(fmax(1,:)), (fmax(2,:))];
% disp('dim of maxfreq features');
% disp(size(maxfreq_features));
% Power in the freezing band
% It was found that leg trembling during freezing is characterized by a 
% higher frequency pattern
% with respect to the one that is characteristic of walking (7, 8, 14, 15). This feature is the
% power in this freezing band, which is defined to be between 3 and 8 Hz, as in Ref. (8). This
% total power: over each axis of each sensor
% disp('Calculating power in the freezing band');
total_pow_freezing = [];

for it_chan = 1:9

total_pow_freezing(:,it_chan) = (...
                      (sum(P1(:,it_chan+9).*P1(:,it_chan+9)))); 

end
% total_pow_freezing = squeeze(total_pow_freezing);
% total_pow_freezing = (sum(squeeze(sum(P1(:,10:18,:).*P1(:,10:18,:)))))';
% disp('power in the freezing band size');
% disp(size(total_pow_freezing));
% Power in the locomotor band
% disp('calc total power locomotor');

total_pow_loc = [];

for it_chan = 1:9

total_pow_loc(:,it_chan) = ((sum(P1(:,it_chan).*P1(:,it_chan))));

end
% total_pow_loc = squeeze(total_pow_loc);
% total_pow_locomotor = (sum(squeeze(sum(P1(:,1:9,:).*P1(:,1:9,:)))))';

% disp('dimensions of total pow locom');
% disp(size(total_pow_loc));
% Freezing index
% It is the ratio between the power in the freezing band and the power in the locomotor band
% (8). It is usually used in studies for detecting freezing of gait with inertial sensors. When
% freezing is already in place, this index tends to show a high value (8, 14, 15).
% total power: over each axis of each sensor
% disp('calculating freezing index');

freezing_index = total_pow_freezing./total_pow_loc;

% disp('dimensions of freezing index');
% disp(size(freezing_index));
% Spectral density centre of mass gives information about the overall 
% quantity of movement performed and the frequency band in which most of 
% the movement is concentrated.

% first normalize each column in each window (normalize each axis spectrum)
% by dividing it with its sum, then applying the mean operator

% FIX THIS IN FEATURE EXTRACTION, MIGHT BE A GOOD FEATURE
% disp('calculating centre of mass');
% centroid_features = squeeze(mean(full_spectre./sum(full_spectre)))';
% disp('dimensions of center of mass');
% disp(size(centroid_features));

% disp('calculating skewness');
% calculating skewness for each axis of each sensor in the time domain
% skewness_features_t = squeeze(skewness(window_data,0,1))';
% calculating skewness for each axis of each sensor in the spectral domain
% skewness_features_f = squeeze(skewness(P1,0,1))';
% disp('dimensions of skewness');
% disp(size(skewness_features_t));
% disp(size(skewness_features_f));
% calculating skewness for each axis of each sensor in the time domain
% disp('calculating kurtosis');
% kurtosis_features_t = squeeze(kurtosis(window_data,0,1))';
% calculating skewness for each axis of each sensor in the spectral domain
% kurtosis_features_f = squeeze(kurtosis(P1,0,1))';
% disp(size(kurtosis_features_f));
% disp(size(kurtosis_features_t));
% packing all features into a design matrix, to be merged with other
% features

% disp('start freq')
% disp(size(stdev_features));
% disp(size(maxfreq_features));
% disp(size(total_pow_freezing));
% disp(size(total_pow_loc));
% disp(size(freezing_index));
% disp('end_freq');

features_out = [stdev_features, maxfreq_features,...
                total_pow_freezing, total_pow_loc,...
                freezing_index];
            
% disp('total size of spectral features');
% disp(size(features_out));            
            
end

