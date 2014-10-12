function tpenalty = tyremodel(laps,degfactor,compound)

global tprofiles tnum

deg0 = 0.01*tprofiles(tnum).trackwear;
deg30 = 0.04*tprofiles(tnum).trackwear;

if compound == 2, % option tyre
    c = -tprofiles(tnum).tdiff;
    laps = laps;
else
    c = 0; % prime tyre
    laps = laps*tprofiles(tnum).relwear;
end

laps = laps/degfactor(compound); % effect of individual driver/car on deg rate

b = deg0;
a = (deg30-b)/60;

tpenalty = a*laps.^2 + b*laps + c;

end