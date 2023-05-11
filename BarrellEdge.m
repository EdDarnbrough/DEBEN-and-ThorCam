%% Dr Ed Darnbrough University of Oxford Materials Department 2023
%% Using ECF fit to find a better vertical gap and individual pixel strips to measure sample width throughout, so an outline can be found.
%%Quick.width = Width; Quick.gap = Gap; % save quick look things
% User select
dummy.Decimate = 50; %1 in every X images looked at for speed 
dummy.region = 50; %Region close to the boundary of the image to track in to avoid sample
dummy.exclude = 25; %Assume that the total edge is contained within 2x this number of pixels 

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
    
    % Look vertically for gap if no data
    if length(GapFine)<i
        GapFine(i,:) = ECFedgefit(dummy.Im,2,50); %looks at 1:50 pixels from im
    end
    % Look horizontally for sample width
    if range(GapFine(i,:))>500; fprintf('The sample is %d pixels tall and might take a while \n', range(GapFine(i,:))); end
    a = 0;
    Precision2round = -1; %Can chose here to be -1 for 10, -2 for 100 etc. if doing every pixel is takeing too long
    for j = round(GapFine(i,1),Precision2round):10^(-Precision2round):round(GapFine(i,2),Precision2round)
        a = a+1;
        WidthFine(i,:,a) = ECFedgefit(dummy.Im,1,1280,j); %looks at all 1280 wide but only one pixel deep at a time
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
Precision2round = 10^(-Precision2round);
x = [0:Precision2round:Precision2round*(size(WidthFine,3)-1)];
figure, hold on
for i = 1:40:length(Times)
plot(reshape(WidthFine(Times(i),1,:),[],1), x, 'DisplayName', ['Left time ' num2str(video_info.FrameTime(Times(i)))])
plot(reshape(WidthFine(Times(i),2,:),[],1), x, 'DisplayName', ['Right time ' num2str(video_info.FrameTime(Times(i)))])
end

dummy.barrelwidth =range(WidthFine,2);
dummy.barrelwidth =reshape(dummy.barrelwidth,[],43);
dummy.nanbarrel = dummy.barrelwidth; 
dummy.nanbarrel(dummy.nanbarrel==0) = nan;
[Minmum_pos,Minmum_val] = nanmin(dummy.nanbarrel(Times,:)');
[Max_pos, Max_val] = max(dummy.barrelwidth(Times,:)');
clear i j Precision2round a

%% Barrelling maths 
DR =  Max_val-Minmum_val; %DR = Rmax-Rtop; 
m= [0.1;0.5;0.9]; 
H = range(GapFine(Times,:)'); 
R = nanmean(dummy.nanbarrel(Times,:)');
b = (4.*m./sqrt(3)) ./ ((R./H)+(2.*m/(3.*sqrt(3))));
Pav_flow = ((8.*b.*R)./(H)).*( (1/12 + (H./(b.*R)).^2).^(3/2) - (H./(b.*R)).^3 - ((m./(24.*sqrt(3))).*(exp(-b./2)./(exp(-2./b)-1))) );
Load = DebenData.Force(1:10:end);
Pav = Load(1:length(Pav_flow))'./(pi.*(Minmum_pos).^2); 
flow = Pav./Pav_flow; 
