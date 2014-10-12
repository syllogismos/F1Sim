%RACESIM    Formula 1 race simulator
% Formula 1 race simulator, which takes driver and track data from sim_prep.m and
% gives driver times on each lap of the race as outputs,
% Developed by AJK Phillips, 2014

%% Define global variables

global tprofiles tnum

%% Initializing race data

dtimes = [0:0.25:0.25*(dnum-1)]; % times at end of lap 0.
dlaps = zeros(laps+1,dnum); % laps completed on tyres by each driver
dlaps(1,:) = [0*ones(1,10),0*ones(1,dnum-10)]; % set initial wear on tyres

dcompounds = zeros(laps+1,dnum); 

for i = 1:dnum,
    dcompounds(1,i) = dprofiles(dorder(i)).pitstrat(1,1); % set initial compounds for each driver
end

dpitted = zeros(1,dnum); % Initialize number of pit stops completed by each driver

scflag = 0; % Set safety car flag off
sccount = 0; % Initialize number of safety car periods
overtakecount = 0; % Initiatlize number of overtakes
dnfcount = 0; % Intialize number of DNFs

lapcharts = zeros(1+2*laps,dnum); % Initialize lapchart
lapcharts(1,:) = dorder; % Set initial positions on lapchart


%% Race simulation

for i = 1:tprofiles(tnum).laps,
    afterpits = dtimes(i,:)'; % Initialize vector for storing timings after pit stops
    for j = 1:dnum, % Sort through drivers in order that they finished the previous lap for pit-stops
        di = dorder(j);
        pitting = 0; % set pit flag
        DRSon = 0; % set DRS flag
        
        %% check for pit-stops

        nextpitnum = dpitted(j)+1; % number of next pit-stop
        pitlaps = cumsum(dprofiles(di).pitstrat(2,:));
        pitlaps = pitlaps(1:end-1);
        if nextpitnum > length(pitlaps), % check if all pit stops have been completed
        else % if not, check for possible pit-stops.
            nextpitlap = pitlaps(nextpitnum);
            if scflag == tprofiles(tnum).SClaps, % if first lap of a safety car, check pit window
                if nextpitlap<i+tprofiles(tnum).pitwindow, % if within pit window, make pit-stop
                    pitting = 1;
                else
                end
            else % otherwise, check if on the exact target pit lap
                if nextpitlap==i-1, % if so, pit
                    pitting = 1;
                else
                end
            end
        end
        
        %% Make pit-stops
        
        if pitting==1,
            dcompounds(i+1,j)=dprofiles(di).pitstrat(1,nextpitnum); % if pitted, then attach new tyres
            dtimes(i,j) = dtimes(i,j) + tprofiles(tnum).inlap; % add in-lap time to end of last lap
            afterpits(j) = dtimes(i,j)+ tprofiles(tnum).outlap + llogcdfinv(rand,0.97168,1.5277); % set timing after pit-stop
            dlaps(i,j) = 0; % refresh tyre lap count from end of last lap
            dpitted(j) = dpitted(j)+1; % update number of pit-stops
        else
            dcompounds(i+1,j)=dcompounds(i,j); % otherwise, keep the same tyres on
        end
    end
    
    %% Update order on track after pit-stops
    
    afterpits = [dorder', afterpits];
    afterpitsordered = sortrows(afterpits,2);
    
    for j = 1:dnum,
        lapcharts(2*i,j) = 22-sum(afterpits(:,2)>afterpits(j,2)); % Update lap-chart to reflect new order
    end
    
    %% Simulate rest of lap
    for j = 1:dnum,
        laptime = 0;
        ti = dcompounds(i+1,j); % current tyre compound
        
        
        %% Normal conditions
        if scflag == 0, % if no safety car, simulate DRS and lap times as normal
            di = dorder(j); % current driver
            
            % check for DRS based on times at beginning of lap (after pit
            % stops), assuming lap 3 or later
            if overtaking==1,
                if i > 2,
                    if sum(((afterpits(j,2)-afterpits(:,2))>0).*((afterpits(j,2)-afterpits(:,2))<=1))>0, % check if there is a car ahead within 1 second
                        laptime = laptime - tprofiles(tnum).DRSgain;
                        DRSon = 1; % flag DRS on/off
                    else
                        DRSon = 0; % flag DRS on/off
                    end
                else
                end
            else
            end
            
            % calculate driver's lap time as function of tyres and fuel
            laptime = laptime + dprofiles(di).longrun + randn*dprofiles(di).sd + tyremodel(dlaps(i,j),dprofiles(di).degfactors,ti) - i*tprofiles(tnum).fuelgain;
            
            if i == 1, % starting bonus
                laptime = laptime - dprofiles(di).start + tprofiles(tnum).startsd*randn + 6; % subtract starting bonus for driver and add starting time
            else
            end
            
            dlaps(i+1,j) = dlaps(i,j)+1 + DRSon*tprofiles(tnum).DRSwear; % update tyre age
            dtimes(i+1,j) = afterpits(j,2) + laptime; % enter new race time for this lap
            
        %% Safety car conditions
        else % if under safety car, then run to safety car deltas
            laptime = 0;
            di = afterpitsordered(j,1); % sort through drivers in running order after pit-stops
            dindox = find(dorder==di);
            if j == 1,
                laptime = tprofiles(tnum).SClaptime;
                dtimes(i+1,dindox) = afterpitsordered(j,2) + tprofiles(tnum).SClaptime;
                dlaps(i+1,j) = dlaps(i,j); % no age on tyres if running at safety car speed
            else
                laptime = laptime + tprofiles(tnum).SClaptime*6/7; % SC delta pace
                if afterpitsordered(j,2) + laptime > aheadtime + tprofiles(tnum).SCfollow, % if running at SC delta pace doesn't get driver ahead of car in front, do that
                    dtimes(i+1,dindox) = afterpitsordered(j,2) + laptime;
                    dlaps(i+1,j) = dlaps(i,j)+0.5; % tyres take only half lap of wear if running at SC delta pace
                else % if this would get the driver too close, then they run slower so that they just catch up
                    dtimes(i+1,dindox) = aheadtime + tprofiles(tnum).SCfollow;
                    dlaps(i+1,j) = dlaps(i,j); % no wear on tyres if running below max speed
                end
                    
            end
            
            aheadtime = dtimes(i+1,dindox); % time for the driver ahead, who cannot be overtaken
        end       
    end
    
    %% Overtaking
    if scflag == 0, % if no safety car, simulate overtaking
        if overtaking==1,
            
            % overtaking possibility at the end of each lap
            drank_start = sortrows([dorder',dtimes(i,:)'],2);
            drank_end = sortrows([dorder',dtimes(i+1,:)'],2);
            
            for j = 1:dnum,
                dio = drank_start(j,1); % sort through driver order from beginning of lap, starting with leader
                dahead_before = drank_start(1:j-1,1);
                endpos = find(drank_end(:,1)==dio);
                endtime = drank_end(endpos,2);
                aheadind = find(drank_end(:,2)<endtime+tprofiles(tnum).follow); % find any drivers ahead of following buffer
                aheadind = aheadind(aheadind~=endpos); % remove the driver himself/herself
                dahead_after = drank_end(aheadind,1);
                for k = 1:length(dahead_after),
                    dover = dahead_after(k); % consider each driver who was ahead at the end of the lap
                    if sum(dahead_before==dover)==0, % check if the driver was NOT ahead before
                        othresh = tprofiles(tnum).ot+tprofiles(tnum).DRSgain + tprofiles(tnum).ospeed*(dprofiles(dio).vmax - dprofiles(dover).vmax); % check if they surpassed the overtaking threshold
                        dio_ind = find(drank_end(:,1)==dio);
                        dover_ind = find(drank_end(:,1)==dover);
                        delta = drank_end(dio_ind,2)-drank_end(dover_ind,2);
                        if delta>othresh, % if driver exceeds threshold, they pass successfully
                            %if i > 1,
                            %overtakecount = overtakecount+1;
                            %else
                            %end
                            drank_end(dio_ind,2) = drank_end(dio_ind,2)+tprofiles(tnum).defensetime; % defender takes a time penalty
                        else
                            drank_end(dover_ind,2) = drank_end(dio_ind,2)+tprofiles(tnum).follow; % if driver does not exceed threshold, they are forced to follow the defender
                        end
                        
                    else
                    end
                end
                
                
            end
            for j = 1:dnum,
                dio = drank_end(j,1);
                dind = find(dorder==dio);
                dtimes(i+1,dind) = drank_end(j,2);
            end
        else
        end
    else
    end
    
    for j = 1:dnum,
        lapcharts(2*i+1,j) = 22-sum(dtimes(i+1,:)>dtimes(i+1,j)); % Update lapchart
    end
    
    if scflag > 0, % Update safety car flag
        scflag = scflag-1;
    else
    end
    
    for j = 1:dnum, % check for crashes and failures
        drand = rand;
        mrand = rand;
        diz = dorder(j);
        if (drand<(dprofiles(diz).dDNF*tprofiles(tnum).DNFfactor))+(mrand<(dprofiles(diz).mechDNF*tprofiles(tnum).DNFfactor))>0,
            dtimes(i+1,j) = dtimes(i+1,j)+10^6 - i*10^4;
            dnfcount = dnfcount + 1;
            scrand = rand;
            if scrand<tprofiles(tnum).SCprob, % check if a safety car should be issued
                scflag = tprofiles(tnum).SClaps;
                sccount = sccount + 1;
            else
            end
        else
        end
    end
%     
%     %% Update order to real timings at end of first lap
%     if i == 1,
%         %dtimes(2,:) = min(dtimes(2,:))+[2.33,0,6.43,2.05,1.44,3.91,4.42,3.22,6.68,5.15,6,7.29,5.72,8.56,8.79,7.90,10.90,9.15,10.02,10.04,10.43,13.01];
%     else
%     end
    
end

%% Race statistics

leadertime = zeros(laps+1,1); % record winning race time
for i = 1:length(leadertime),
    leadertime(i) = min(dtimes(i,:));
end

endclass = sortrows([dorder',dtimes(end,:)'],2);

overtakecount = 0;
for i = 1:dnum, % count overtakes in the race, not including overtakes on the first lap or changes of position associated with pit-stops
    changes = diff(lapcharts(2:end,i));
    changes = changes(3:2:end);
    overtakecount = overtakecount + sum(abs(changes));
end
overtakecount = overtakecount/2;

%% Report race results

if report == 1, 
    
    plotting = [19,77,6,14,44,11,20,3,27,7]; % drivers to plot
    
    figure(12)
    for i = 1:dnum,
        io = find(dorder==endclass(end-i+1,1));
        if length(find(plotting==endclass(end-i+1,1)))==1,
            dcolor = dprofiles(endclass(end-i+1,1)).color;
            plot([0:laps],dtimes(:,io)-leadertime,'Color',dcolor,'LineWidth',2)
            hold on
        else
        end
    end
    hold off
    ylim([-0.1 70])
    xlim([0 laps])
    
    endclass(:,2) = endclass(:,2)-endclass(1,2);
    
    winner = endclass(1,1);
    
    winind = find(dorder==winner);
    winnertimes = dtimes(:,winind);
    
    disp('Race classification')
    disp('-------------------')
    for i = 1:dnum,
        diind = find(dorder==endclass(i,1));
        ditimes = dtimes(:,diind);
        if ditimes(end-1)<winnertimes(end), % check if driver finished on lead lap
            disp([num2str(i),'. ',dprofiles(endclass(i,1)).name,'    ',num2str(endclass(i,2))])
        else
            lapscompl = sum(ditimes<winnertimes(end));
            lapsdown = laps-lapscompl;
            if lapsdown == 1,
                disp([num2str(i),'. ',dprofiles(endclass(i,1)).name,'    ',num2str(endclass(i,2)),' (+1 lap)'])
            else
                disp([num2str(i),'. ',dprofiles(endclass(i,1)).name,'    ',num2str(endclass(i,2)),' (+', num2str(lapsdown),' laps)'])
            end
        end
    end
    disp('-------------------')
    
else
end
