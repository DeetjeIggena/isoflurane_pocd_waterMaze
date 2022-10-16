% function returns distance between two points
% point-distance is the square root of the sum of 
% the squares of the horizontal and vertical sides

% input: coordinates of the two locations
% output: distance

function D = wm_distance(x1,x2,y1,y2)

D = sqrt((x2-x1).^2+(y2-y1).^2); 

end