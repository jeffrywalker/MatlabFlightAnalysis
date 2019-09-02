% write flight servo commands to file for bench testing
% C1 AILERON
% C2 ELEVATOR
% C3 COLLECTIVE
% C4 RUDDER
%------------------------------------------------------------------------------
chan = {'C1','C2','C3','C4'};
chanName = {'AIL','ELV','COL','RUD'};
logNum = 1;
figure
for j=1:4
    ax(j) = subplot(2,2,j);
    plot(mfa.logs{logNum}.log.RCOU.TimeS,mfa.logs{logNum}.log.RCOU.(chan{j}))
    hold on
    ylabel('PWM (us)')
    title(chanName{j})
    grid on
    if j > 2
        xlabel('time (s)')
    end
end
linkaxes(ax,'x')
%-- plot all together, zero mean
figure
for j=1:4
    tvec = mfa.logs{logNum}.log.RCOU.TimeS;
    data = mfa.logs{logNum}.log.RCOU.(chan{j});
    data = data - mean(data);
    plot(tvec,data)
    hold on
    ylabel('PWM (us)')
    grid on
    xlabel('time (s)')
end
legend(chanName)
%% selection to extract
expChan = 'C4';
expTime = [410 490];
tmp.time = mfa.logs{logNum}.log.RCOU.TimeS;
tmp.data = mfa.logs{logNum}.log.RCOU.(expChan);
i1 = find(tmp.time >= expTime(1),1);
i2 = find(tmp.time >= expTime(2),1);
idx = i1:i2;
tmp.time = tmp.time(idx);
tmp.time = tmp.time - tmp.time(1); % shift to zero
tmp.data  = tmp.data(idx);
figure,plot(tmp.time,tmp.data)
%% write to file
fid = fopen('tmp.txt','w+');
npts = length(tmp.time);
% write the time
tstr = sprintf('%0.2f,',tmp.time);
tstr(end) = [];
fprintf(fid,'const double flightT[%u] = {%s};\n',npts,tstr);
% write the pwm
tstr = sprintf('%u,',tmp.data);
tstr(end) = [];
fprintf(fid,'const int flightPWM[%u] = {%s};\n',npts,tstr);
fprintf(fid,'const int flightSz = %u;\n',npts);
fclose(fid);
winopen('tmp.txt');

