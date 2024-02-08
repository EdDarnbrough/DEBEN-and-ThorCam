%% Dr Ed Darnbrough University of Oxford Materials Department 2022
%% Using ECF fit to find a better vertical gap and sample width
Quick.width = Width; Quick.gap = Gap; % save quick look things
% User select
dummy.Decimate = 50; %1 in every X images looked at for speed 
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
    %GapFine(i,:) = ECFedgefit(dummy.Im,2,50); %looks at 1:50 pixels from
    %im for just a single value of fit, below takes 5 measures to find mean
    %and error
    limits = [1,11,21,31,41,51];
    for a= 1:5
        GapPos(a,:) = ECFedgefit(dummy.Im,2,[limits(a):limits(a+1)]);
    end
    GapFine(i,:) = mean(GapPos); GapFineStandardErr(i,:) = std(GapPos)./sqrt(length(GapPos));

    % Look horizontally for sample width
    WidthFine(i,:) = ECFedgefit(dummy.Im,1,1280,[floor(GapFine(i,1)):ceil(GapFine(i,2))]); %looks at 1:1024 and the gap between the grips
    
    %a=1; for j = ceil(GapFine(i,1)):floor(GapFine(i,2)); check.width_profile(a,:) = ECFedgefit(dummy.Im(j,:,1),1,1:1280); a=a+1; end
    
    % Look where the sample is for any gap above i.e. is the platen in
    % contact? 
    Contact(i,:) = ECFedgefit(dummy.Im,2,[floor(WidthFine(i,1)):ceil(WidthFine(i,2))]);

    if rem(max(Times)-i,2000)==0
        fprintf('%d left to complete \n', ((max(Times)-i))) % show progress *I like this to know everything is still running happily
    end
end

Gap = range(GapFine'); 
Width = range(WidthFine'); 

figure, hold on
plot(video_info.FrameTime(Times),range(GapFine(Times,:)'),'o', 'DisplayName','GapFine')
plot(video_info.FrameTime(Times),Quick.gap(Times),'o', 'DisplayName','Gapquick')
plot(video_info.FrameTime(Times),Quick.width(Times),'o', 'DisplayName','Widthquick')
plot(video_info.FrameTime(Times),range(WidthFine(Times,:)'),'o', 'DisplayName','WidthFine')
errorbar(video_info.FrameTime(Times),range(GapFine(Times,:)'), mean(GapFineStandardErr(Times,:)'),'o', 'DisplayName','GapFineWithErr')

figure, hold on 
plot(video_info.FrameTime(Times),GapFine(Times,:)','o', 'DisplayName','GapFine')
plot(video_info.FrameTime(Times),Contact(Times,:)','o', 'DisplayName','Contact')
plot(video_info.FrameTime(Times),Contact(Times,1)'-Contact(Times,2)','o', 'DisplayName','Contact Difference')
plot(video_info.FrameTime(Times),range(GapFine(Times,:)')+(Contact(Times,1)'-Contact(Times,2)'),'o', 'DisplayName','Sample Height')
plot(video_info.FrameTime(Times),range(GapFine(Times,:)'),'o', 'DisplayName','Gap Height')

function [value] = range(varible)
value = abs(max(varible)-min(varible));
end