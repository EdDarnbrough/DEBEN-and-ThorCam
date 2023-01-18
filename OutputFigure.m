%% Dr Ed Darnbrough University of Oxford Materials Department 2022
% Load images and data then look at scaling
[video, video_info, DebenData, Deben_info] = LoadDataAndVideo;
[Zoom2mm, Full_Im, Zoomed_Im] = PixelScaling; 
run QuickLook.m 

%% Convert all measurements into mm and then stress and strain (after you have sample height, see bottom)

DebenData.Width_mm = interp1(video_info.FrameTime(Times),Width(Times)./Zoom2mm,DebenData.Sec);

DebenData.Gap_mm = interp1(video_info.FrameTime(Times),Gap(Times)./Zoom2mm,DebenData.Sec);

DebenData.Stress_Pa = DebenData.Force./(pi.*(0.5*DebenData.Width_mm.*10^(-3)).^2);

DebenData.Strain = DebenData.Gap_mm./Deben_info.Sample_height_mm; 

%display result where negative strain is before contact and positive strain
%is compressive
figure, plot(1-DebenData.Strain, DebenData.Stress_Pa, 'o')
title('Example Data from Sample 3 first loading')
xlabel('Strain (-)')
ylabel('Stress (Pa)')

% Select linear section as elastic modulus start strain 0.04 end 0.14
dummy.elastic(1) =find(1-DebenData.Strain>0.04,1); dummy.elastic(2) =find(1-DebenData.Strain>0.14,1);
[m,c,dm,dc,r] = linfit((1-DebenData.Strain(dummy.elastic(1):dummy.elastic(2))),DebenData.Stress_Pa(dummy.elastic(1):dummy.elastic(2)),0.1.*ones(1+range(dummy.elastic),1));

%% Get sample height 
% Assume that the sample is darker than background and that the gap is
% below the sample in the Zoomed_Im 
% if not use dummy.flat = sum(Zoomed_Im(end:-1:1,:,1),2);

dummy.flat = sum(Zoomed_Im(:,:,1),2);
dummy.window = 200;
[a,b] = sort(dummy.flat(dummy.window+1:dummy.window:end)-dummy.flat(1:dummy.window:end-dummy.window), 'descend');
for i = 1:2
dummy.range = ((b(i)-1)*dummy.window:b(i)*dummy.window);dummy.step = 0.1;FuncShape = 600; 
dummy.ResClose = Fitting(dummy,FuncShape);
[~,dummy.posinx] = min(dummy.ResClose);
dummy.pos(i) = dummy.range(1)+dummy.posinx.*dummy.step;
end
video_info.Sample_height_px = range(dummy.pos);
Deben_info.Sample_height_mm = range(dummy.pos)./Zoom2mm;

function Result = Fitting(dummy,FuncShape)
c= 1;
for i = dummy.range(1):dummy.step:dummy.range(end)
    Result(c) = sum(abs(dummy.flat(dummy.range)-(0.5*range(dummy.flat(dummy.range)).*erf(([dummy.range]-i)./sqrt(FuncShape))'+min(dummy.flat(dummy.range))+range(dummy.flat(dummy.range))./2)));
    c=c+1;
end
end