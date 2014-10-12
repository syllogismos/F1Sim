% TRACK_PROFILES   Define variables for each track

% Define:
% - name
% - laps
% - fuelgain (time gain per lap due to fuel burn)

% - SCprob (probability of SC per retirement)
% - DNFfactor (for increasing likelihood of retirements)
% - SClaps (number of laps per SC period)
% - SClaptime
% - SCfollow (closest time gap between cars under safety car)
% - pitwindow (laps for pit window under SC)

% - inlap (minimum time lost on in-lap)
% - outlap (minimum time lost on out-lap)

% - DRSgain (time gained per lap through DRS)
% - DRSwear (additional laps of tyre wear per lap under DRS)
% - follow (closest a car can follow another without overtaking)
% - defensetime (time lost being overtaken)
% - ot (overtaking threshold)
% - ospeed (change to overtaking threshold per km/h of delta vmax)

% - startsd (standard deviation in start times)

% - tdiff (time difference between tyre compounds when fresh)
% - relwear (relative durability of option vs, prime compound [0-1])
% - trackwear (wear factor for track)

%% 12 - SPA

tprofiles(12).name = 'Spa';
tprofiles(12).laps = 44;
tprofiles(12).fuelgain = 0.12;
tprofiles(12).SCprob = 0.1;
tprofiles(12).DNFfactor = 1;
tprofiles(12).SClaps = 4;
tprofiles(12).SClaptime = 160;
tprofiles(12).SCfollow = 0.4;
tprofiles(12).pitwindow = 10;
tprofiles(12).inlap = 5;
tprofiles(12).outlap = 13;
tprofiles(12).DRSgain = 0.4;
tprofiles(12).DRSwear = 0.1;
tprofiles(12).follow = 0.2;
tprofiles(12).defensetime = 0.4;
tprofiles(12).ot = 1.0;
tprofiles(12).ospeed = 0.02;
tprofiles(12).startsd = 1;
tprofiles(12).tdiff = 1.3;
tprofiles(12).relwear = 0.5;
tprofiles(12).trackwear = 15;


%% 13 - MONZA

tprofiles(13).name = 'Monza';
tprofiles(13).laps = 53;
tprofiles(13).fuelgain = 0.08;
tprofiles(13).SCprob = 0.05;
tprofiles(13).DNFfactor = 1;
tprofiles(13).SClaps = 6;
tprofiles(13).SClaptime = 130;
tprofiles(13).SCfollow = 0.4;
tprofiles(13).pitwindow = 10;
tprofiles(13).inlap = 4.5;
tprofiles(13).outlap = 21;
tprofiles(13).DRSgain = 0.4;
tprofiles(13).DRSwear = 0.1;
tprofiles(13).follow = 0.2;
tprofiles(13).defensetime = 0.4;
tprofiles(13).ot = 1.0;
tprofiles(13).ospeed = 0.02;
tprofiles(13).startsd = 1;
tprofiles(13).tdiff = 1.3;
tprofiles(13).relwear = 0.4;
tprofiles(13).trackwear = 3;

%% 16 - RUSSIA

tprofiles(16).name = 'Sochi';
tprofiles(16).laps = 53;
tprofiles(16).fuelgain = 0.08;
tprofiles(16).SCprob = 0.1;
tprofiles(16).DNFfactor = 1;
tprofiles(16).SClaps = 6;
tprofiles(16).SClaptime = 145;
tprofiles(16).SCfollow = 0.4;
tprofiles(16).pitwindow = 9;
tprofiles(16).inlap = 4;
tprofiles(16).outlap = 27;
tprofiles(16).DRSgain = 0.4;
tprofiles(16).DRSwear = 0.1;
tprofiles(16).follow = 0.2;
tprofiles(16).defensetime = 0.4;
tprofiles(16).ot = 1.0;
tprofiles(16).ospeed = 0.02;
tprofiles(16).startsd = 1;
tprofiles(16).tdiff = 1.3;
tprofiles(16).relwear = 0.5;
tprofiles(16).trackwear = 5;