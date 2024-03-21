%% Dr Ed Darnbrough University of Oxford Materials Department 2024
% If in the unfortunate case that your video data was recorded with dropped
% frames the code in LoadDataAndVideo will lead to a misalignment in the
% data extracted from the frames with that from the test rig. 

% This script will "correct" the frame rate by making the displacement rate
% observed from the images match the displacement rate recorded by the test
% rig. 

%% NOTE ONLY DO THIS IF REALLY NESSACARY!!

% This correction makes implict assumptions that your test rig is recording
% properly and that there is no compliance in the test set up not observed
% within the videos.

%% First check that the total displacement in the images and recorded by the test rig are similar.
% This is to confirm that dropped frames are the video duration issue not that some of the test wasn't recorded

DistanceTraveled_mm = max(TensileData.Stroke)-min(TensileData.Stroke);
DistanceObserved_mm = (max(Gap(Times))-min(Gap(Times)))/Zoom2mm; 

if abs((DistanceObserved_mm./DistanceTraveled_mm)-1)>0.1
    fprintf('The difference between the image observed displacement and the test measurement is %.1f percent. \n', 100*abs((DistanceObserved_mm./DistanceTraveled_mm)-1))
    fprintf('Check your grip.width_mm value is correct and that the video contains the entire test. \n')
end
figure, hold on 
plot(TensileData.Time, TensileData.Stroke, 'DisplayName', 'Tensile Data')
plot(Times./video.FrameRate,(Gap(Times)-Gap(1))/Zoom2mm, 'DisplayName', 'Image Data')
title('Difference in displacement rate from the test jig and images')
DisplacementRateJig = [mean(gradient(TensileData.Stroke,TensileData.Time(2)-TensileData.Time(1))), std(gradient(TensileData.Stroke,TensileData.Time(2)-TensileData.Time(1)))];
DisplacmenteRateImages = [mean(gradient((Gap(Times)-Gap(1))./Zoom2mm,Times(2)-Times(1))), std(gradient((Gap(Times)-Gap(1))./Zoom2mm,Times(2)-Times(1)))];
video_info.NewFPS = DisplacementRateJig(1)./DisplacmenteRateImages(1);
plot(Times./video_info.NewFPS,(Gap(Times)-Gap(1))/Zoom2mm, 'DisplayName', 'Image Data "corrected"')

video_info.AutoFrameTime = video_info.FrameTime; %keep the orginal if needed
video_info.FrameTime = ([1:video.NumFrames]./video_info.NewFPS); %update frametime
% this assumes that your video and jig data start at the same point in time

TestDifferenceFromTime = max(TensileData.Time)-video.NumFrames/video_info.NewFPS; % value in seconds where positive means the video is shorter

TestDifferenceFromDisplacement = (DistanceTraveled_mm-DistanceObserved_mm)/DisplacementRateJig(1); % value in seconds where positive means the video is shorter
