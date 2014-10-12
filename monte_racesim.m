%% MONTE RACESIM    Repeat racesim multiple times to construct distributions and compute expected results.
% Race reports should be toggled off [report=0] in racesim.

tic

iters = 1000; % Number of race simulations to run

ots = zeros(iters,1); % initialize vector for number of overtakes per race (excluding pit-stops and first lap)
SCs = ots; % Initiatlize vector for number of SC periods per race
DNFs = ots; % Initialize vector for number of DNFs per race
rts = ots; % Initialize vector for winning race times per race

sim_prep

finmatrix = zeros(length(dorder),iters+1); % Initialize matrix of race positions for each driver in each simulation
finmatrix(:,1) = dorder; % First row is driver numbers


for iii = 1:iters, % Run simulations
    racesim
    ots(iii) = overtakecount;
    SCs(iii) = sccount;
    DNFs(iii) = dnfcount;
    rts(iii) = winnertimes(end);
    for jjj = 1:length(dorder),
        compnum = dorder(jjj);
        finmatrix(jjj,iii+1) = find(endclass(:,1)==compnum);
    end
end


%% Plot results

figure(55)
for i = 1:length(dorder),
    figure(28)
    subplot(5,5,i)
    [n,x] = hist(finmatrix(i,2:end),[1:length(dorder)],'g');
    bar(x,n)
    title(dprofiles(dorder(i)).name)
    xlim([0 length(dorder)+1])
    ylim([0 max(n)*1.5])
    text(1,max(n)*1.3,dprofiles(dorder(i)).name)
end
%tightfig

toc