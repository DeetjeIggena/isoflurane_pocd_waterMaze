% function returns average distance to provided location

% input: x-&z-coordinates, location-coordinates
% output: absolute distance to location (int), averaged distance to
% location, vector with distances

function [distance_abs,distance_rel,distPerSample]= wm_distanceToXZ(xCoordinates,...
    zCoordinates, location_x, location_z)

nSamples        = length(xCoordinates);

% initialize an empty array to store distance per sample
distPerSample   = NaN(1,(nSamples));

% distance traveled between sample points
for i = 1:(nSamples)
    distPerSample(i) = sqrt((location_x-xCoordinates(i)).^2+(location_z-zCoordinates(i)).^2);
end

distance_abs    = sum(distPerSample);
distance_rel    = sum(distPerSample)/length(distPerSample);

end
