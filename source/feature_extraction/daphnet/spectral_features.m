function [features] = spectral_features(window, Fs)
%STD_SPECTRAL_FEATURES Calculating spectral features
% expected all windows from a recording session as a 3D matrix input
% output gives spectral features for all windows, output dimensions:
% output = #windows x #spectral features
% extracting window data without time axis
window_data = window(:,2:10,:);

% bandpass filtering on the defined regions
% last filter is for full gait spectral range in which the peak search will
% be performed
bp_window_data = [bandpass(window_data,[0.1 0.68],Fs), ...
                  bandpass(window_data,[0.68 3],Fs),...
                  bandpass(window_data,[3 8],Fs),...
                  bandpass(window_data,[8 20],Fs),...
                  bandpass(window_data,[0.1 8],Fs),...
                  bandpass(window_data,[0.1 20],Fs)];
% length of the window
dim = size(bp_window_data);
L = dim(1);
% calculating window fft for all axes of all sensors
n = 2^nextpow2(L);
Y = fft(y,n,1);
% two sided spectrum
P2 = abs(Y/L);
% one-sided spectrum
P1 = P2(1:L/2+1,:,:);
P1(2:end-1,:,:) = 2*P1(2:end-1,:,:);

% Standard deviation on specific spectral bands
%   Provides information about the distribution of harmonics in 
% these bands, which define if the harmonics are distributed along the band
% or if there are significant harmonics. It can give information about 
% stability or specific significant peaks in a band.
% excluding the full [0.1,20] Hz spectre from the calculation
stdev_features = std(P1(:,1:end-9,:));

% Highest harmonic peaks  
% Useful for detecting concrete events in specific spectral bands
% (e.g. high peaks in 0.1Hz to 0.68 Hz band can be considered as a candidate to be a postural
% transition)
% Extracting 2 highest peaks

% finding 2 highest peaks for each axis of each sensor
full_spectre = P1(:,end-8:end,:);
[maxvalues, ind] = maxk(a, 2);






end

