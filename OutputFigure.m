%% Dr Ed Darnbrough University of Oxford Materials Department 2022
% Load images and data then look at scaling
[video, video_info, DebenData, Deben_info] = LoadDataAndVideo;
[Zoom2mm, Full_Im, Zoomed_Im] = PixelScalingErrFunc; 
run QuickLook.m 

%% Now improve the fitting if the data set is ok

run FittedEdges.m

%% Consider Barrelling rather than an average width

run BarrellEdge.m 

%% Get sample height
% Assume that the sample is darker than background and that the gap is and
% is in the centre of your image
% below the sample in the Zoomed_Im 
% if not use dummy.flat = sum(Zoomed_Im(end:-1:1,:,1),2);

dummy.half_size = 50; %only sample in the middle 100 pixels of the image
dummy.middle = round(size(Zoomed_Im,2)./2)-dummy.half_size:round(size(Zoomed_Im,2)./2)+dummy.half_size; 
dummy.height = ECFedgefit(Zoomed_Im,2,dummy.middle); %gap above sample
dummy.gap = ECFedgefit(Zoomed_Im,2,50); %gap between grips

video_info.Sample_height_px = range(dummy.gap)-range(dummy.height);
Deben_info.Sample_height_mm = video_info.Sample_height_px./Zoom2mm;
%% Convert all measurements into mm and then stress and strain (after you have sample height, see bottom)

DebenData.Width_mm = interp1(video_info.FrameTime(Times),Width(Times)./Zoom2mm,DebenData.Sec);

DebenData.Gap_mm = interp1(video_info.FrameTime(Times),Gap(Times)./Zoom2mm,DebenData.Sec);

DebenData.Stress_Pa = DebenData.Force./(pi.*(0.5*DebenData.Width_mm.*10^(-3)).^2);

DebenData.Strain = DebenData.Gap_mm./Deben_info.Sample_height_mm; 

%display result where negative strain is before contact and positive strain
%is compressive
figure, plot(1-DebenData.Strain, DebenData.Stress_Pa, 'o')
title('Stress Strain')
xlabel('Strain (-)')
ylabel('Stress (Pa)')

figure, plot(DebenData.Sec, DebenData.Stress_Pa, 'o')
title('Stress Time')
xlabel('Time (s)')
ylabel('Stress (Pa)')

figure, plot(DebenData.Sec, DebenData.Strain, 'o')
title('Strain Time')
xlabel('Time (s)')
ylabel('Strain (-)')

% Select linear section as elastic modulus start strain 0.04 end 0.14
% dummy.elastic(1) =find(1-DebenData.Strain>0.04,1); dummy.elastic(2) =find(1-DebenData.Strain>0.14,1);
% [m,c,dm,dc,r] = linfit((1-DebenData.Strain(dummy.elastic(1):dummy.elastic(2))),DebenData.Stress_Pa(dummy.elastic(1):dummy.elastic(2)),0.1.*ones(1+range(dummy.elastic),1));

