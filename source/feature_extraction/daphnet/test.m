Fs = 64;                    % Sampling frequency
T = 1/Fs;                     % Sampling period
L = floor(3.2*64);            % Length of signal
t = (0:L-1)*T;                % Time vector
x = [1/(4*sqrt(2*pi*1.5))*(exp(-t.^2/(2*1.5)))',...
    1/(4*sqrt(2*pi*0.8))*(exp(-t.^2/(2*0.8)))', ...
    1/(4*sqrt(2*pi*1.1))*(exp(-t.^2/(2*1.1)))'];
x = cat(3,x,x);
x = cat(3,x,x);
x = cat(3,x,x);
x = cat(3,x,x);
% y = [bandpass(window_data,[0.1 0.68],Fs), ...
%      bandpass(window_data,[0.68 3],Fs),...
%      bandpass(window_data,[3 8],Fs)];
n = 2^nextpow2(L);
Y = fft(x,n,1);
% two sided spectrum
P2 = abs(Y/L);
% one-sided spectrum
P1 = P2(1:L/2+1,:,:);
P1(2:end-1,:,:) = 2*P1(2:end-1,:,:);


