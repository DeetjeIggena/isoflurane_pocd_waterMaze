% function returns the relative amount of covered surface of the arena
% assumes normalized arena surface

% input: x & y coordinates (normalized)
% output: relative amount of covered surface of the arena

function covsurface_rel = wm_surfaceCoverage(x,y)

rows_real = length(x);

%surface coverage - ellipsoid; [%]
xpos3 = zeros(rows_real,1);
ypos3 = zeros(rows_real,1);

j=1;
while j<rows_real+1
    xpos3(j,1) = x(j,1);
    ypos3(j,1) = y(j,1);
    j=j+1;
end

% get min- and max-coordinates
minX = min(xpos3(:,1));
maxX = max(xpos3(:,1));
minY = min(ypos3(:,1));
maxY = max(ypos3(:,1));

% get distance between min- and max-coordinates
xdist = abs(minX-maxX);
ydist = abs(minY-maxY);

% get pool surface (normalized pool)
covsurface_max = pi*1*1;

% get surface covered
covsurface = pi*(xdist*ydist);
covsurface_rel = (covsurface/covsurface_max);  % relative to pool surface

end