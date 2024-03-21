%% Dr Ed Darnbrough University of Oxford Materials Department 2024
%% First pass to get rough vertical gap and sample width
% User select
dummy.Decimate = 25; %1 in every X images looked at for speed 
dummy.exclude = 10; %Assume that the total edge is contained within 2x this number of pixels 

% Generated from users selection the frames to look at
Times = 1:dummy.Decimate:length(video_info.FrameTime);
dummy.inx_h = zeros(max(Times),2); %empty generated for speed of loop
dummy.inx_v = zeros(max(Times),2); %empty generated for speed of loop

% Loop to look at each image
for i = Times
    %read in frame
    dummy.Im = read(video,i); %costs ~0.6s per loop

    % Look vertically for gap
    dummy.flat = sum(dummy.Im(dummy.top:dummy.bottom,dummy.regionv),2); %take the sum of all image in 1D for the region of interest
    dummy.points2consider = 1:length(dummy.flat); %first consider all the pixels
    % Loop to find edge and then ignore that area when looking for the
    % other edge
    for j = 1:2
        % Looking for points that are closest to half of the range of all values plus the minimum to give a middle value that will equate to half way up the change in intensity seen at an edge.
        [~,dummy.inx_v(i,j)] = min(abs(dummy.flat(dummy.points2consider) - (min(dummy.flat)+range(dummy.flat)/2))); 
        dummy.points2consider = [1:dummy.inx_v(i,j)-dummy.exclude*4,dummy.inx_v(i,j)+dummy.exclude*4:length(dummy.points2consider)]; %once found now ignore this region to look for the other edge. 
        %this edge looks chunkier than the width so I artifically increase
        %the exclusion zone
    end
    %remove dummies
    dummy.VertMap(:,i) = dummy.flat;
    dummy = rmfield(dummy, 'flat'); dummy = rmfield(dummy, 'points2consider');

    % Look horizontally for sample width
    dummy.flat = sum(dummy.Im(dummy.regionh,:,1),1);
    dummy.points2consider = 1:length(dummy.flat); %first consider all the pixels
    for j = 1:2     % Loop to find edge and then ignore that area when looking for the other edge
        [~,dummy.inx_h(i,j)] = min(abs(dummy.flat(dummy.points2consider) - (min(dummy.flat)+range(dummy.flat)/2)));
        dummy.points2consider = [1:dummy.inx_h(i,j)-dummy.exclude,dummy.inx_h(i,j)+dummy.exclude:length(dummy.points2consider)];
    end
    %remove dummies
    dummy.HoriMap(:,i) = dummy.flat;
    dummy = rmfield(dummy, 'flat'); dummy = rmfield(dummy, 'points2consider');

    if rem(max(Times)-i,2000)==0
        fprintf('%d left to complete \n', ((max(Times)-i))) % show progress *I like this to know everything is still running happily
    end
end

% Any edges found after the exclusion step will need correction as their
% inital index will be wrong. Created as loop incase in future you want to
% look at more than two edges in a flattend image
for i = 2 %horizontal correction
    dummy.NeedsCorrection = find(dummy.inx_h(:,i)-dummy.exclude*2>dummy.inx_h(:,i-1)); %any value greater than the min point minus the exclusion will need adjusting up
    dummy.inx_h(dummy.NeedsCorrection,i) = dummy.inx_h(dummy.NeedsCorrection,i)+4*dummy.exclude; %increase by 4 for the horizontal that is double the vert exculsion
    %fprintf('Corrected %d edges \n', length(dummy.NeedsCorrection)) 
    dummy = rmfield(dummy,'NeedsCorrection'); %number of values to change will be different on each loop so it is best to just remove it rather than get a size mismatch error
end
for i = 2 %vertical correction
    dummy.NeedsCorrection = find(dummy.inx_v(:,i)-dummy.exclude>dummy.inx_v(:,i-1)); 
    dummy.inx_v(dummy.NeedsCorrection,i) = dummy.inx_v(dummy.NeedsCorrection,i)+2*dummy.exclude;
    %fprintf('Corrected %d edges \n', length(dummy.NeedsCorrection)) 
    dummy = rmfield(dummy,'NeedsCorrection'); %number of values to change will be different on each loop so it is best to just remove it rather than get a size mismatch error
end

fprintf('Complete displaying \n')
Gap = range(dummy.inx_v'); % Gap is the difference between the two edges
Width = range(dummy.inx_h'); % Width is the difference between the two edges
figure, plot(video_info.FrameTime(Times),Gap(Times),'o', 'DisplayName','Gap')
hold on 
plot(video_info.FrameTime(Times),Width(Times),'x', 'DisplayName','Width')
title('Measurements made on each processed frame')
ylabel('Distance in pixels')
xlabel('Experiment time (s)')

function [value] = range(varible)
value = abs(max(varible)-min(varible));
end

%% Looking to isolate the erronous values - not needed

% dummy.jump = 20; %Number of pixels above which is considered a jump between frames
% dummy.JumpUp = find((gradient(Gap(Times)))>dummy.jump)+1;
% dummy.JumpUp = [dummy.JumpUp, find((-gradient(Gap(Times)))>dummy.jump)-1;];
% [C,ai,ci]= unique(dummy.JumpUp);
% a_counts = accumarray(ci,1);
% JumpUp = C(find(a_counts>1));
% 
% dummy.JumpDown = find((-gradient(Gap(Times)))>dummy.jump)+1;
% dummy.JumpDown = [dummy.JumpDown, find((gradient(Gap(Times)))>dummy.jump)-1;];
% [C,ai,ci]= unique(dummy.JumpDown);
% a_counts = accumarray(ci,1);
% JumpDown = C(find(a_counts>1));

