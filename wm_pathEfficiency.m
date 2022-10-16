% function returns absolute heading error to location & calculates a path-efficiency
% index

% input: x-&z-coordinates, location (e.g target)
% output: average absolute heading error (int) & path efficiency index(int)

function [error, efficiency,alpha]= wm_pathEfficiency(xCoordinates, zCoordinates, location_x, location_z)

nLength = length(xCoordinates);

% average absolute heading error
j = 1; alpha = zeros(nLength,1);
while j < nLength
    m1       = (xCoordinates(j+1)-xCoordinates(j))/(zCoordinates(j+1)-zCoordinates(j));
    m2       = ((location_x)-xCoordinates(j))/((location_z)-zCoordinates(j));
    alpha(j) = atand((m2-m1)/(1+m1*m2));
    j = j+1;
end

alpha = alpha(~isnan(alpha));
error = mean(abs(alpha(:,1)));

%path efficiency index
aLength = length(alpha);
j = 1; eff = 0;
while j < aLength+1
    if abs(alpha(j,1)) < 15
        eff = eff+1;
    end
    j = j+1;
end
efficiency = eff/aLength*100;

end
