%% Dr Ed Darnbrough University of Oxford Materials Department 2022
%% Using ECF fit to find a better vertical gap and sample width
Quick.width = Width; Quick.gap = Gap; % save quick look things
% User select
dummy.Decimate = 25; %1 in every X images looked at for speed 
dummy.region = 50; %Region close to the boundary of the image to track in to avoid sample
dummy.exclude = 25; %Assume that the total edge is contained within 2x this number of pixels 

% Generated from users selection the frames to look at, starting where
% Quick look goes wrong
Times = 1:dummy.Decimate:length(video_info.FrameTime);
dummy.inx_h = zeros(max(Times),2); %empty generated for speed of loop
dummy.inx_v = zeros(max(Times),2); %empty generated for speed of loop

% Loop to look at each image
for i = Times
    %read in frame
    dummy.Im = read(video,i); %costs ~0.6s per loop
    
    % Look vertically for gap
    GapFine(i,:) = ECFedgefit(dummy.Im,2,50); %looks at 1:50 pixels from im

    % Look horizontally for sample width
    WidthFine(i,:) = ECFedgefit(dummy.Im,1,1024); %looks at 1:1024

    if rem(max(Times)-i,2000)==0
        fprintf('%d left to complete \n', ((max(Times)-i))) % show progress *I like this to know everything is still running happily
    end
end

Gap = range(GapFine'); 
Width = range(WidthFine'); 