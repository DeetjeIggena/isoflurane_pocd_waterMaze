% function assigns spatial search strategies according to predefined
% criteria
% criteria adapted from Garthe A. et al., 2009 PlosOne

function [strategy, reference_frame] = wm_spatialStrategies(path_error,...
    heading_error, avg_distance_pog, avg_distance_center , avg_distance_goal,...
    avg_distance_goal_old, outlier, annulus_rel, wall_rel, covsurface_rel, day)



if path_error < 30 & heading_error < 25
    strategy = 7;
    reference_frame = 1;
elseif  avg_distance_pog < 0.35 &  avg_distance_goal <0.3
    strategy = 6;
    reference_frame = 1;
elseif outlier <= 20
    strategy = 5;
    reference_frame = 1;
elseif day > 3 & avg_distance_goal_old < 0.3 & avg_distance_pog < 0.35
    strategy = 8;
    reference_frame = 3;
elseif annulus_rel >= 0.5
    strategy = 4;
    reference_frame = 2;
elseif covsurface_rel > 0.1 & covsurface_rel < 0.5 & wall_rel < 0.7 & ...
        avg_distance_center < 0.7
    strategy = 3;
    reference_frame = 2;
elseif wall_rel > 0.7
    strategy = 1;
    reference_frame = 2;
elseif covsurface_rel >= 0.5 & wall_rel < 0.7
    strategy = 2;
    reference_frame = 2;
else
    strategy = 0; 
    reference_frame = 0;
end

end