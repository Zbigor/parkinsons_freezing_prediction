Fs = 64;
[b2,a2] = butter(3,[0.5 3]/(Fs/2),'bandpass');
[b3,a3] = butter(3,[3 8]/(Fs/2),'bandpass');
[b6,a6] = butter(3,[0.1 20]/(Fs/2),'bandpass');


filters = [b2',a2',b3',a3',b6',a6'];
path = "../../test/";
name = "filters";
savename = strcat(path,name);
save(savename,"filters");


% filter1 = filters(:,1:2);
% 
% t = 1:1/64:3;
% x = [sin(2*pi*5*t)', sin(2*pi*7*t)'];
% y = filter(filter1(:,1),filter1(:,2),x);
% figure
% plot(t,y);
% figure
% plot(t,x);
