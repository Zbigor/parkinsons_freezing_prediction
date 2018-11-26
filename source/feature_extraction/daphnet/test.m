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
N_w = 16;
y = [];
ar = [];
tic
[b1,a1] = butter(3,[0.1 0.68]/32,'bandpass');
[b2,a2] = butter(3,[0.68 3]/32,'bandpass');
[b3,a3] = butter(3,[3 8]/32,'bandpass');

parfor it_w = 1:N_w
    y(:,:,it_w) = [filtfilt(b1,a1,x(:,:,it_w)), ...
                   filtfilt(b2,a2,x(:,:,it_w)),...
                   filtfilt(b3,a3,x(:,:,it_w))];
    ar(:,:,it_w) = arburg(squeeze(x(:,:,it_w)),4)';            
end
time = toc;
n = 2^nextpow2(L);
Y = fft(y,n,1);
% two sided spectrum
P2 = abs(Y/n);
% one-sided spectrum
P1 = P2(1:n/2+1,:,:);
P1(2:end-1,:,:) = 2*P1(2:end-1,:,:);


features3 = squeeze(std(P1))';
[maxvalues, ind] = maxk(P1, 2);
maxval_features = [squeeze(maxvalues(1,:,:))', squeeze(maxvalues(2,:,:))'];
clearvars maxvalues
% frequency axis
f = Fs*(0:(n/2))/n;
fmax = f(ind);
clear ind
maxfreq_features = [squeeze(fmax(1,:,:))', squeeze(fmax(2,:,:))'];
centroid = squeeze(mean(x./sum(x)))';
sk = squeeze(skewness(x,0,1))';
ar_features = [squeeze(ar(1,:,:))', squeeze(ar(2,:,:))',...
               squeeze(ar(3,:,:))', squeeze(ar(4,:,:))', ... 
               squeeze(ar(5,:,:))'];


vel = squeeze(trapz(x))';




