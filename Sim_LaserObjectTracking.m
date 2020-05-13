% clear all 
clc

%% Load data from .mat file
% % % temp_scans.seq = [];
% % % temp_scans.secs = [];
% % % temp_scans.nsecs = [];
% % % temp_scans.angle_min = [];
% % % temp_scans.angle_max = [];
% % % temp_scans.angle_increment = [];
% % % temp_scans.time_increment = [];
% % % temp_scans.scan_time = [];
% % % temp_scans.range_min =[];
% % % temp_scans.range_max = [];
% % % temp_scans.ranges = [];
% % % temp_scans.intensities = [];

% load('laser_scan.mat');

scan_intensity_threshold=100;
dist_thresholds = 0.5;
h1 = [];
%% Simulate real time laser point processing

for sim_index = 1:1:length(Laser_scans)%simulate laser scan by replaying data
    
    Objects = [];
    
    %% convert the polar coordinate into Cartesian coordinate
    scan_angle_min = Laser_scans(sim_index).angle_min;
    scan_angle_max = Laser_scans(sim_index).angle_max;
    scan_angle_increment = Laser_scans(sim_index).angle_increment;
    scan_angle = scan_angle_min:scan_angle_increment:scan_angle_max;
    
    scan_intensities = Laser_scans(sim_index).intensities;
    scan_range = Laser_scans(sim_index).ranges;
%     Laser_scans(sim_index).range_min
%     Laser_scans(sim_index).range_max
    
    scan_x = scan_range.*sin(scan_angle);   %lateral 
    scan_y = scan_range.*cos(scan_angle);   %horizontal
    
    scan_x = scan_x(scan_intensities>=scan_intensity_threshold);
    scan_y = scan_y(scan_intensities>=scan_intensity_threshold);
    
%     if(isempty(h1))
%         figure()
%         h1 = scatter(scan_x,scan_y);
%     else
%         h1.XData =scan_x;
%         h1.YData = scan_y; 
%     end
% 
%     drawnow
    
    %% ====TODO : cluster points into object
    
    dist = sqrt((scan_x(2:end)-scan_x(1:end-1)).^2 + (scan_y(2:end)-scan_y(1:end-1)).^2);
    break_points = find(dist>dist_thresholds);
    
    for obj_index = 1:1:length(break_points)+1 %n+1 objects
        if(obj_index ==1)
            obj_pts_x = scan_x(1:break_points(1));
            obj_pts_y = scan_y(1:break_points(1));
        elseif(obj_index ==length(break_points)+1)
            obj_pts_x = scan_x(break_points(obj_index-1)+1:end);
            obj_pts_y = scan_y(break_points(obj_index-1)+1:end);    
        else
            obj_pts_x = scan_x(break_points(obj_index-1)+1:break_points(obj_index));
            obj_pts_y = scan_y(break_points(obj_index-1)+1:break_points(obj_index));
        end
        object.xpts = obj_pts_x;
        object.ypts = obj_pts_y;
        object.cx = mean(obj_pts_x);
        object.cy = mean(obj_pts_y);
        object.length = sqrt((obj_pts_x(end)-obj_pts_x(1))^2+(obj_pts_y(end)-obj_pts_y(1))^2);
        Objects = [Objects;object];
    end
    
    %% ====TODO : visualize points on the figure.
    figure(10)  
    for obj_index = 1:1:length(Objects)
        plot(Objects(obj_index).xpts,Objects(obj_index).ypts,'*')    
        hold on
        scatter(Objects(obj_index).cx,Objects(obj_index).cy)
        txt = ['Obj-',num2str(obj_index),'Length = ',num2str(Objects(obj_index).length)];
        text(Objects(obj_index).cx,Objects(obj_index).cy,txt);
    end

    xlabel('X[m]','FontSize',30)
    ylabel('Y[m]','FontSize',30)
    set(gca,'FontSize',30)
%     xlim([-10 10]);
%     ylim([-10 20]);
    hold off

%     if(isempty(h1))
% 
%     else
%         
%         
%     end
end
