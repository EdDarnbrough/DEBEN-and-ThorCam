%% Dr Ed Darnbrough University of Oxford Materials Department 2022
%% Allows user to select the files to work with loading in the data and file information
function [video, video_info, DebenData, Deben_info] = LoadDataAndVideo

StartingFolder= cd;
[file,path] = uigetfile('*.avi', 'Select the video file');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
   cd(path)
   video = VideoReader(file); %load video 
   video_info = dir(file); %load video file information
end
% Clear temporary variables
clear path file 
cd(StartingFolder) %return

[file,path] = uigetfile('*.CSV', 'Select the Deben Data file');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
   cd(path)
   % Create options for importing data CSV into a table
   opts = delimitedTextImportOptions("NumVariables", 7);

   % Specify range and delimiter
   opts.DataLines = [21, Inf];
   opts.Delimiter = ",";
    
   % Specify column names and types
   opts.VariableNames = ["Sec", "Elongation", "Force", "Position", "Code", "Samplerate", "Motorspeed"];
   opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];
    
   % Specify file level properties
   opts.ExtraColumnsRule = "ignore";
   opts.EmptyLineRule = "read";
    
   % Specify variable properties
   opts = setvaropts(opts, "Motorspeed", "TrimNonNumeric", true);
   opts = setvaropts(opts, "Motorspeed", "ThousandsSeparator", ",");
   
   % Import the data
   DebenData = readtable(file, opts);
   Deben_info = dir(file);
end

% Clear temporary variables
clear opts path file
cd(StartingFolder) %return

[~, ~, ~, video_info.h, video_info.m, video_info.s] = datevec(video_info.datenum);
[~, ~, ~, Deben_info.h, Deben_info.m, Deben_info.s] = datevec(Deben_info.datenum);
video_info.Time_ofset_s = (Deben_info.h*3600+ Deben_info.m*60 + Deben_info.s)-(video_info.h*3600+ video_info.m*60+ video_info.s); %if positive then DEBEN data longer than video, if negative video longer than data
video_info.starttime = max(DebenData.Sec) - (video.Duration+video_info.Time_ofset_s);
video_info.FrameTime = ([1:video.NumFrames]./video.FrameRate)+video_info.starttime;

end