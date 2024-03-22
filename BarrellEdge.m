%% Dr Ed Darnbrough University of Oxford Materials Department 2023
%% Using ECF fit to find a better vertical gap and individual pixel strips to measure sample width throughout, so an outline can be found.
%%Quick.width = Width; Quick.gap = Gap; % save quick look things
% User select
dummy.Decimate = 50; %1 in every X images looked at for speed 
dummy.regionv = [450:600]; %Vertical strip close to the boundary of the image to track grips in to avoid sample
dummy.exclude = 25; %Assume that the total edge is contained within 2x this number of pixels 
Precision2round = -1; %Can chose here to be -1 for 10, -2 for 100 etc. if doing every pixel is takeing too long
horizontal_region = 1:1280;
if ismember('location_horizontal', fields(grip)); horizontal_region = grip.location_horizontal; end %if a region containing the full view of the grips was previously set use that
% Generated from users selection the frames to look at, starting where
% Quick look goes wrong
Times = 1:dummy.Decimate:length(video_info.FrameTime);
dummy.inx_h = zeros(max(Times),2); %empty generated for speed of loop
dummy.inx_v = zeros(max(Times),2); %empty generated for speed of loop
%figure(99); hold on
% Loop to look at each image
for i = Times
    %read in frame
    dummy.Im = read(video,i); %costs ~0.6s per loop
    previous = [0,0];
    % Look vertically for gap if no data
    if length(GapFine)<i
        GapFine(i,:) = ECFedgefit(dummy.Im,2,dummy.regionv,previous);%looks at 1:50 pixels from im
        previous = GapFine(i,:);
    end
    % Look horizontally for sample width
    if range(GapFine(i,:))>500; fprintf('The sample is %d pixels tall and might take a while \n', range(GapFine(i,:))); end
    a = 0;
    previous = [0,0];
    for j = round(GapFine(i,1),Precision2round):10^(-Precision2round):round(GapFine(i,2),Precision2round)
        a = a+1;
        WidthFine(i,:,a) = ECFedgefit(dummy.Im,1,horizontal_region,j,previous); %looks at all of horizontal region but only one pixel deep at a time
        previous = WidthFine(i,:,a);
    end
    %a=1; for j = ceil(GapFine(i,1)):floor(GapFine(i,2)); check.width_profile(a,:) = ECFedgefit(dummy.Im(j,:,1),1,1:1280); a=a+1; end
    
    if rem(max(Times)-i,200)==0
        fprintf('%d left to complete \n', ((max(Times)-i))) % show progress *I like this to know everything is still running happily
        %figure(99), plot(reshape(WidthFine(i,1,:),[],1),round(GapFine(i,1),Precision2round):10^-Precision2round:round(GapFine(i,2),Precision2round), 'o')
        %figure(99), plot(reshape(WidthFine(i,2,:),[],1),round(GapFine(i,1),Precision2round):10^-Precision2round:round(GapFine(i,2),Precision2round), 'o')
    end
end
beep
%Gap = range(GapFine'); 
%Width = range(WidthFine'); 
section_height = 10^(-Precision2round);
x = [0:section_height:section_height*(size(WidthFine,3)-1)];
figure, hold on
for i = 1:40:length(Times)
plot(reshape(WidthFine(Times(i),1,:),[],1), x, 'DisplayName', ['Left time ' num2str(video_info.FrameTime(Times(i)))])
plot(reshape(WidthFine(Times(i),2,:),[],1), x, 'DisplayName', ['Right time ' num2str(video_info.FrameTime(Times(i)))])
end

dummy.barrelwidth =reshape(abs(WidthFine(:,1,:)-WidthFine(:,2,:)),[],size(WidthFine,3));
dummy.nanbarrel = dummy.barrelwidth; 
dummy.nanbarrel(dummy.nanbarrel==0) = nan;
[Min_value,Min_index] = min(dummy.nanbarrel(Times,:),[],2,'omitnan'); %value is the width in pixels
[Max_value, Max_index] = max(dummy.barrelwidth(Times,:),[],2); %index is the number of pixels from the bottom that has the width value
clear i j Precision2round a

VolumePixelbyPixel = Volume_calc(WidthFine, Times, 1:length(Times),section_height);


%% Barrelling maths 
% DR =  Max_val-Minmum_val; %DR = Rmax-Rtop; 
% m= [0.1;0.5;0.9]; 
% H = range(GapFine(Times,:)'); 
% R = nanmean(dummy.nanbarrel(Times,:)');
% b = (4.*m./sqrt(3)) ./ ((R./H)+(2.*m/(3.*sqrt(3))));
% Pav_flow = ((8.*b.*R)./(H)).*( (1/12 + (H./(b.*R)).^2).^(3/2) - (H./(b.*R)).^3 - ((m./(24.*sqrt(3))).*(exp(-b./2)./(exp(-2./b)-1))) );
% Load = DebenData.Force(1:10:end);
% Pav = Load(1:length(Pav_flow))'./(pi.*(Minmum_pos).^2); 
% flow = Pav./Pav_flow; 

function [value] = range(varible)
value = abs(max(varible)-min(varible));
end