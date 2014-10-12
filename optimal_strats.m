% OPTIMAL STRATS    Compute optimal pit-stop strategies for each driver
% (assuming running in clean air)

leaddrivers = []; % Initialize list of lead drivers for each team (they get pit-stop preference)

for i = 1:11, % For each team, check which driver qualified in front
    pos1=find(dorder==teammates(i,1));
    pos2=find(dorder==teammates(i,2));
    if pos1<pos2,
        leaddriver = [leaddrivers,teammates(i,1)];
    else
        leaddriver = [leaddrivers,teammates(i,2)];
    end
end


for jacker = 1:length(dorder),

drsfact = 1;
dhash = dorder(jacker);
degfact = dprofiles(dhash).degfactors;

moreprimes = [0,1];

dprofiles(dhash).esttime = 9600;

inlap = tprofiles(tnum).inlap;
pitdur = tprofiles(tnum).outlap;

for cranko = 1:length(moreprimes)

moreprime = moreprimes(cranko); % more stints on hard tyre (1 = yes, 0 = no)

pitnums = [1:6];
cols = rand(length(pitnums),3);

for jimmy = 1:length(pitnums),
    
    stratnum = pitnums(jimmy);

    X = [1:floor((laps-1)/stratnum)]; % laps on preferred tyre

basetime = dprofiles(dhash).longrun*laps + stratnum*(pitdur+inlap+1) + 6;

strattime = zeros(length(X),1);

for i = 1:length(X),
    alaps = laps - stratnum*X(i); % preferred compound laps per stint
    blaps = X(i); % less preferred compound laps (single stint)
    %strattime(i) = sum(tyremodel([0:drsfact*degfact:drsfact*degfact*(alaps-1)],1,1+moreprime)) + stratnum*sum(tyremodel([0:drsfact*degfact:drsfact*degfact*(blaps-1)],1,2-moreprime)) + basetime;

    strattime(i) = sum(tyremodel([0:1:(alaps-1)],degfact,1+moreprime)) + stratnum*sum(tyremodel([0:1:(blaps-1)],degfact,2-moreprime)) + basetime;
end

quickest = min(strattime);
if quickest < dprofiles(dhash).esttime,
    dprofiles(dhash).esttime = quickest;
    beststrat = [];
    quickestind = find(strattime == min(strattime));
    if moreprime == 1,
        primestints = stratnum;
        optstints = 1;
        primelength = X(quickestind);
        optlength = laps - X(quickestind)*primestints;
        
    else
        primestints = 1;
        optstints = stratnum;
        primelength = laps - X(quickestind)*optstints;
        optlength = X(quickestind);
    end
     optimalstrat = [2*ones(1,optstints),1*ones(1,primestints); optlength*ones(1,optstints),primelength*ones(1,primestints)];
     if sum(leaddrivers==dhash)==1,
        optimalstrat(2,1) = optimalstrat(2,1)-1;
        optimalstrat(2,end) = optimalstrat(2,end)+1;
     else
     end
     dprofiles(dhash).pitstrat = optimalstrat;
else
end

%figure(11+cranko)
%plot(X,strattime,'Color',cols(jimmy,:))
%hold on

end

% legend('1 stop', '2 stops', '3 stops', '4 stops')

end

end

% %% 2 stops
% 
% X = [1:25];
% 
% basetime = dprofiles(dhash).longrun*laps + 2*(pitdur+inlap) + 6;
% 
% strat2time = zeros(length(X),1);
% 
% for i = 1:length(X),
%     hlaps = 52 - 2*X(i);
%     slaps = X(i);
%     strat2time(i) = sum(tyremodel([0:drsfact:drsfact*(hlaps-1)],1,1)) + 2*sum(tyremodel([0:drsfact:drsfact*(slaps-1)],1,2)) + basetime;
% end
% 
% plot(X,strat2time,'b')
% hold on
% 
% %% 1 stop
% 
% X = [1:51];
% 
% basetime = 101*52 + 1*15 + 6;
% 
% strat1time = zeros(length(X),1);
% 
% for i = 1:length(X),
%     hlaps = 52 - 1*X(i);
%     slaps = X(i);
%     strat1time(i) = sum(tyremodel([0:drsfact:drsfact*(hlaps-1)],1,1)) + 1*sum(tyremodel([0:drsfact:drsfact*(slaps-1)],1,2)) + basetime;
% end
% 
% plot(X,strat1time,'r')
% hold off
%xlabel('Laps on medium stint')
%ylabel('Total race time (seconds)')

