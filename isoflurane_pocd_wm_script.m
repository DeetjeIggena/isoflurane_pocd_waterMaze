% Script for analysing trajectory-data (x,y) acquired via video-tracking
% in the water maze task to examine spatial memory performance

% script based upon data analysis in Garthe A et al. 2009, PlosOne
% "Adult-Generated Hippocampal Neurons Allow the Flexible Use of
% Spatially Precise Learning Strategies"
% & Garthe A et al. 2014, Genes Brain Behaviour, 
% "Not all water mazes are created equal: cyclin D2 knockout mice with 
% constitutively suppressed adult hippocampal neurogenesis do show 
% specific spatial learning deficits"

% input: .txt-files containing x & y-coordinates (named xc, yc),
%         information of the quadrant-number (named i_reg)
%        & information about the subject
% output: .mat-file and .xlsx-file containing tables
%          output-tables report the following measures:

% @author D.Iggena (deetje.iggena@charite.de), @date: 02.05.2022
% @update 16.10.2022: removed quadrant analysis
% @last update 30.12.2022: new order, updated distance calculation

clear; close all; clc; format compact;
tic

%% Preparation (get data-files & provide results-folder)

% construct a path to the data file
dataDirectory    = pwd; % provide the folder containing your data
addpath(genpath(pwd));  % add subfolder containing functions

% construct a path to the result folder
resultFolder   = [dataDirectory '\wm_results'];   % provide the name for your result folder

% if result folder does not exist, create result folder
if ~exist(resultFolder, 'dir')
    mkdir(resultFolder);
end

% create table for saving data or load existing file
targetFileName         = ['\wm.mat'];
targetFilePath         = fullfile(resultFolder, targetFileName);
if isfile(targetFilePath)
    load(targetFilePath, 'wm');
elseif ~exist('wm','var')
    wm = [];
    save(targetFilePath, 'wm');
end

% set counter for table rows
n = length(wm) + 1;

%% Get set-up information

% get min & max of water maze data  (required for data normalization)
xmin = 140; xmax = 690;
ymin = 10;  ymax = 570;
data_min = 0; data_max = 1; % min & max of normalized data

% get coordinatess of the goal location
goal_old_x = 463; goal_old_y = 152; %old goal-position
goal_new_x = 380; goal_new_y = 425; %new goal-position

% normalize the coordnates of goal locations
gox = (goal_old_x-xmax)/(xmin-xmax);
goy = (goal_old_y-ymax)/(ymin-ymax);
gnx = (goal_new_x-xmax)/(xmin-xmax);
gny = (goal_new_y-ymax)/(ymin-ymax);

% get coordinates of the center of the arena
center_x = 0.5; center_y = 0.5;

% zone borders -> normalized arena
arena_radius    = 0.5;
radius1         = arena_radius/2.75;
radius_circle_1 = 1-radius1*2;
radius2         = arena_radius/1.75;
radius_circle_2 = 1-radius2*2;

z0_radius = sqrt((radius1-arena_radius)^2+(arena_radius-arena_radius)^2);
z1_radius = sqrt((radius2-arena_radius)^2+(arena_radius-arena_radius)^2);

% read in data
foldercontent  = dir('*.txt'); % get txt-files
files          = {foldercontent.name};
[~,noDatasets] = size(files);

%% data analysis

% loop through data files
for i = 1:length(foldercontent)
    
    data            = readtable(files{1,i});
    [~,data_name,~] = fileparts(files{1,i});
    data_info       = strsplit(data_name,'_'); % get data info from txt-file
    
    % assign group names according provided data information
    if contains(data_info{1,3},'C')
        subject  = str2double(regexp(data_info{1,4},'\d*','match'));
        groupS     = 'ctr';
        group_no   = 1;
        anesthesia = 1;
        treatment  = 1;
        if contains(data_info{1,4},'runningWheel')
            groupS     = 'ctr_rw';
            group_no   = 2;
            treatment  = 2;
            subject    = str2double(regexp(data_info{1,3},'\d*','match'));
        end
    elseif contains(data_info{1,3},'I')
        groupS     = 'iso';
        group_no   = 3;
        anesthesia = 2;
        treatment  = 1;
        subject    = str2double(regexp(data_info{1,4},'\d*','match'));
        if contains(data_info{1,4},'runningWheel')
            groupS     = 'iso_rw';
            group_no   = 4;
            treatment  = 2;
            subject    = str2double(regexp(data_info{1,3},'\d*','match'));
        end
    end
    
    % assign experimental details % setup information
    wm(n).day          = str2double(regexp(data_info{1,1},'\d*','match'));
    wm(n).trial        = str2double(regexp(data_info{1,2},'\d*','match'));
    wm(n).sub_ID       = subject;
    wm(n).group_name   = groupS;
    wm(n).group_no     = group_no;
    wm(n).anesthesia   = anesthesia;
    wm(n).treatment    = treatment;
    
    % assign correct goal location (goal location was moved on day 4 to the
    % opposite quadrant)
    if wm(n).day > 3
        wm(n).phase  = 2;
        gx = gnx; gy = gny;
    else
        wm(n).phase  = 1;
        gx = gox; gy = goy;
    end
    
    
    % get x- & y- coordinates
    x = data.xc; y = data.yc;
    % normalize coordinates
    y = (y-ymax)/(ymin-ymax); x = (x-xmax)/(xmin-xmax);
    
    % get data length
    [rows_real,~] = size(x);
    
    % calculate latency to target/ trial duration
    duration_ms  = data.t_start(end,1) - data.t_start(1,1); % in miliseconds
    wm(n).duration_sec = duration_ms/1000; % in seconds
    
    % calculate path length
    path = zeros(rows_real,1);
    for k = 1:rows_real-1
        path(k,1) = wm_distance(x(k,1),x(k+1,1),y(k,1),y(k+1,1));
    end
    wm(n).path_length = sum(path);
    
    % calculate path error
    ideal_path       = wm_distance(x(1,1),gx,y(1,1),gy);
    wm(n).path_error = wm_accuracy(wm(n).path_length, ideal_path);
    
    % calculate velocity
    wm(n).velocity    = wm(n).path_length/wm(n).duration_sec;
    
    % calculate avg. distance to actual and old target-location
    wm(n).avg_distance_to_goal     = zeros(rows_real-1,1);
    wm(n).avg_distance_to_goal_old = zeros(rows_real-1,1);
    
    [~, wm(n).avg_distance_goal, distance]     = wm_distanceToXZ(x,y,gx,gy);
    [~, wm(n).avg_distance_goal_old, distance_old] = wm_distanceToXZ(x,y,gox,goy);
    
    % get time in target area to analyze probe trial performance
    k = 2; zone = 0; zoneEntry = 0; zone_old = 0; zone_old_Entry = 0;
    platform_radius = 0.05;
    
    % assorting datapoints to target zone
    distance = distance';
    while k<rows_real
        if distance(k,1)< platform_radius
            zone = zone+1;
            if distance(k-1,1)> platform_radius
                zoneEntry = zoneEntry+1;
            end
        end
        k = k+1;
    end
    
    wm(n).zone_rel_5   = zone/rows_real;
    wm(n).zone_time_5  = wm(n).zone_rel_5*wm(n).duration_sec;
    wm(n).zone_entry_5 = zoneEntry;
    
    % assorting datapoints to old target zone
    distance_old = distance_old'; k = 2;
    while k<rows_real
        if distance_old(k,1)< platform_radius
            zone_old = zone_old+1;
            if distance_old(k-1,1)> platform_radius
                zone_old_Entry = zone_old_Entry+1;
            end
        end
        k = k+1;
    end
    
    wm(n).zone_old_rel_5   = zone_old/rows_real;
    wm(n).zone_old_time_5  = wm(n).zone_old_rel_5*wm(n).duration_sec;
    wm(n).zone_old_entry_5 = zone_old_Entry;
    
    % calculate surface coverage
    wm(n).covsurface_rel = wm_surfaceCoverage(x,y);
    
    % get coordinates outside goal-directed corridor
    phi = 40; %this defines the angle directed toward the goal
    wm(n).outlier = wm_outlier(x,y,gx,gy,phi); % in percentage
    
    % calculate heading error and path efficiency
    [ wm(n).heading_error,  wm(n).path_efficiency, ~]    = ...
        wm_pathEfficiency(x, y, gx, gy);
    
    % assorting datapoints to zones according radius
    k = 1; inzone = zeros(1,3);
    wallzone = 0; centerzone  = 0; annuluszone = 0;
    while k<rows_real+1
        dis(k,1) = wm_distanceToXZ(x(k,1),y(k,1),center_x, center_y);
        if dis(k,1)>z0_radius
            inzone(1,1)=inzone(1,1)+1;
            wallzone=wallzone+1;
        elseif dis(k,1)>z1_radius
            inzone(1,2)=inzone(1,2)+1;
            annuluszone=annuluszone+1;
        else
            inzone(1,3)=inzone(1,3)+1;
            centerzone=centerzone+1;
        end
        k = k+1;
    end
    wall_rel    = wallzone/rows_real;
    annulus_rel = annuluszone/rows_real;
    center_rel  = centerzone/rows_real;
    
    % calculate distance to point of gravity/centroid(=point of gravity, POG)
    xsum = sum(x); ysum = sum(y);
    pogx = xsum/rows_real;
    pogy = ysum/rows_real;
    distance_pog = wm_distanceToXZ(x,y,pogx, pogy);
    avg_distance_pog       = sum(distance_pog)/rows_real;
    
    % calculate distance to center
    distance_center  = wm_distanceToXZ(x,y,center_x, center_y);
    avg_distance_center       = sum(distance_center)/rows_real;
    
    % get search strategy (classification adapted from Garthe et al., 2009)
    [wm(n).strategy, wm(n).reference_frame] = wm_spatialStrategies(wm(n).path_error,...
        wm(n).heading_error, avg_distance_pog,avg_distance_center,...
        wm(n).avg_distance_goal,...
        wm(n).avg_distance_goal_old, wm(n).outlier, annulus_rel,...
        wall_rel, wm(n).covsurface_rel, wm(n).day);

    
    n = n +1; % count
    
    clear data xc yc
end

wm_writeToXLSX(wm, resultFolder, 'wm');


