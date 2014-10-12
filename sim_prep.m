%SIM_PREP    Prepare variables to be used by racesim
% Developed by AJK Phillips, 2014

%% Define track variables

global tprofiles tnum

track_profiles

tnum = 16; % Choose track number at which race is occurring

%% Define driver variables

driver_profiles

dorder = [44,6,77,22,26,3,14,7,25,1,20,11,21,99,8,9,27,19,10,13,4]; % Give starting order (1st to last) using driver numbers

teammates = [44,6; % list of teammate pairs
    77,19;
    20,22;
    25,26;
    7,14;
    4,17;
    8,13;
    11,27;
    1,3;
    9,10;
    21,99];

%% Import driver stats from excel sheet

[NUM0,TXT0,RAW0] = xlsread('ddata_template.xlsx'); % Specify excel file from which to import driver data.

dsize = size(NUM0); % Size of driver data matrix
dcount = dsize(2)/2;

avgstints = zeros(dcount,2);

for i = 1:dcount,
    dn = NUM0(1,2*i-1); % driver number
    tyrestints = NUM0(8:end,[2*i-1:2*i]); % all tyre stints for the season for that driver
    avgstints(i,:) = [mean(tyrestints(tyrestints(:,1)==1,2)),mean(tyrestints(tyrestints(:,1)==2,2))]; % average length of stints [prime,option]
    dprofiles(dn).avgstints = avgstints(i,:); 
    dprofiles(dn).start = 0.25*NUM0(6,2*i-1); % average time bonus at start
    dprofiles(dn).dDNF = 1 - nthroot((NUM0(2,2*i-1)-NUM0(3,2*i-1))/NUM0(2,2*i-1),tprofiles(tnum).laps); % probability of not crashing per lap
    dprofiles(dn).mechDNF = 1 - nthroot((NUM0(4,2*i-1)-NUM0(5,2*i-1))/NUM0(4,2*i-1),tprofiles(tnum).laps); % probability of not having a car failure per lap
end

for i = 1:dcount,
    dn = NUM0(1,2*i-1); % driver number
    dprofiles(dn).degfactors = (dprofiles(dn).avgstints./mean(avgstints));
end



%% Import FP2 and qualifying times for each driver from excel sheet

[NUM,TXT,RAW] = xlsread('times_template.xlsx'); % Specify excel file from which to import timing data. The spreadsheet should include all lap times from the longest stint in FP2 and qualifying times.

tsize = size(NUM); % Size of timing data matrix
dcount = tsize(2); % Number of columns in matrix corresponds to number of drives
basetimes = zeros(1,dcount); % initialize vector of base FP2 times
qtimes = NUM(end-1,:); % qualifying times

fp2all = [];

for i = 1:dcount,
    dn = NUM(1,i); % driver number
    dcompound = NUM(2,i); % tyre compound on long run
    
    fp2laps = [1:tsize(1)-4]';
    fp2times =NUM(3:end-2,i); % lap times from FP2
    
    fp2laps = fp2laps(isfinite(fp2times));
    fp2times = fp2times(isfinite(fp2times)); % remove laps where there are no times
    
    % Remove lap times that are at least 1 second per lap slower than laps
    % before or after
    
    timediffs = diff(fp2times)./diff(fp2laps);
    while sum(abs(timediffs)>1)>0, % while there are any differences that are too big...
        fcase = min(find(abs(timediffs)>1)); % first case of timediff being too big
        if timediffs(fcase)>0, % if time difference is positive, remove lap after
            fp2times = fp2times([1:fcase,fcase+2:end]);
            fp2laps = fp2laps([1:fcase,fcase+2:end]);
        else
            fp2times = fp2times([1:fcase-1,fcase+1:end]);
            fp2laps = fp2laps([1:fcase-1,fcase+1:end]);
        end
        timediffs = diff(fp2times)./diff(fp2laps);
    end
    
    
    
    if length(fp2times)>0, % check if there are any FP2 times
        
        fp2all = [fp2all; fp2laps,fp2times-fp2times(1)];
        
        tfun = @(beta,x)(tyremodel(x,dprofiles(dn).degfactors,dcompound) + beta); % define tyre model function
        basetimes(i) = nlinfit(fp2laps,fp2times,tfun,mean(fp2times)); % estimate base time on tyre compound for this driver by fitting tyre model
    else
        basetimes(i) = 1000;
    end
    
    dprofiles(dn).basetime = basetimes(i); % store base time for long run
    dprofiles(dn).qtime = qtimes(i); % qualifying time
    dprofiles(dn).vmax = NUM(end,i); % maximum speed
end

% Compute long-run pace, comparing times to teammate
for i = 1:dcount,
    dn = NUM(1,i); % driver number
    fp2delta = min(dprofiles(dn).basetime - min(basetimes),20);
    qdelta = min(dprofiles(dn).qtime - min(qtimes),20);
    
    dind = find(teammates==dn);
    tmind = dind + (2*mod(dind,2)-1);
    tmn = teammates(tmind);
    qgood = ((dprofiles(dn).qtime-dprofiles(tmn).qtime)<2)*(qdelta<10); % check if within 2 seconds of teammate in qualifying
    fp2good = ((dprofiles(dn).basetime-dprofiles(tmn).basetime)<2)*(fp2delta<10); % check if within 2 seconds of teammate in FP2
    
    if (qgood+fp2good)>0,
        dprofiles(dn).longrun = min(basetimes) + fp2good*(1-0.5*qgood)*fp2delta + qgood*(1-0.5*fp2good)*qdelta;
    else
        fp2delta = min(dprofiles(tmn).basetime - min(basetimes) + 1,20);
        qdelta = min(dprofiles(tmn).qtime - min(qtimes) + 1,20);
        
        dprofiles(dn).longrun = min(basetimes) + (1-0.5*(qdelta<10))*fp2delta + (1-0.5*(fp2delta<10))*qdelta;
    end
    
end


%% Race simulation settings
report = 1; % include race report at end
overtaking = 1; % include car interactions
optimize = 1; % choose optimal pit strategies


%% Initializing race data

dnum = length(dorder); % number of drivers
laps = tprofiles(tnum).laps; % number of race laps

if optimize == 1,
    optimal_strats % Optimize pit strategies
else
end