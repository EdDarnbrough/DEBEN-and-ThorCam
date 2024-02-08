%% Dr Ed Darnbrough University of Oxford Materials Department 2024
% Load images and data then look at scaling
[video, video_info, TensileData, Tensile_info] = LoadDataAndVideo;
% Getting scaling
Starting_frame = read(video,1);
grip.location_horizontal = 200:1200; %pixel range containing full grip width
grip.location_vertical = 1:600; %pixel range containing just top grip
grip.width_px = diff(ECFedgefit(Starting_frame,1,grip.location_horizontal,grip.location_vertical)); 
grip.width_mm = 16; %measured by user with a sensible instrument 
Zoom2mm = grip.width_px/grip.width_mm; 
%%
run QuickLook.m 

%% Now improve the fitting if the data set is ok

run FittedEdges.m

%% Consider Barrelling rather than an average width

run BarrellEdge.m 

%% Get sample height
% % Assume that the sample is darker than background and that the gap is and
% % is in the centre of your image
% % below the sample in the Zoomed_Im 
% % if not use dummy.flat = sum(Zoomed_Im(end:-1:1,:,1),2);
% 
% dummy.half_size = 50; %only sample in the middle 100 pixels of the image
% dummy.middle = round(size(Zoomed_Im,2)./2)-dummy.half_size:round(size(Zoomed_Im,2)./2)+dummy.half_size; 
% dummy.height = ECFedgefit(Zoomed_Im,2,dummy.middle); %gap above sample
% dummy.gap = ECFedgefit(Zoomed_Im,2,50); %gap between grips
% 
% video_info.Sample_height_px = range(dummy.gap)-range(dummy.height);
% Tensile_info.Sample_height_mm = video_info.Sample_height_px./Zoom2mm;
%% Convert all measurements into mm and then stress and strain (after you have sample height, see bottom)

TensileData.Width_mm = interp1(video_info.FrameTime(Times),Width(Times)./Zoom2mm,TensileData.Time);

TensileData.Gap_mm = interp1(video_info.FrameTime(Times),Gap(Times)./Zoom2mm,TensileData.Time);

TensileData.Stress_Pa = TensileData.Force./((TensileData.Width_mm.*10^(-3)).^2); %assumed square sectioned

TensileData.Strain = TensileData.Gap_mm./min(TensileData.Gap_mm,[],'omitnan'); %1D strain

%display result where negative strain is before contact and positive strain
%is tensile
figure, plot(TensileData.Strain-1, TensileData.Stress_Pa, 'o')
title('Stress Strain')
xlabel('Strain (-)')
ylabel('Stress (Pa)')

figure, plot(TensileData.Time, TensileData.Stress_Pa, 'o')
title('Stress Time')
xlabel('Time (s)')
ylabel('Stress (Pa)')

figure, plot(TensileData.Time, TensileData.Strain, 'o')
title('Strain Time')
xlabel('Time (s)')
ylabel('Strain (-)')

% Select linear section as elastic modulus start strain 0.04 end 0.14
% dummy.elastic(1) =find(1-TensileData.Strain>0.04,1); dummy.elastic(2) =find(1-TensileData.Strain>0.14,1);
% [m,c,dm,dc,r] = linfit((1-TensileData.Strain(dummy.elastic(1):dummy.elastic(2))),TensileData.Stress_Pa(dummy.elastic(1):dummy.elastic(2)),0.1.*ones(1+range(dummy.elastic),1));

