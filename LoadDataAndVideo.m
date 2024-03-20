%% Dr Ed Darnbrough University of Oxford Materials Department 2024
%% Allows user to select the files to work with loading in the data and file information
function [video, video_info, TensileData, Tensile_info] = LoadDataAndVideo

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

[file,path] = uigetfile('*.*', 'Select the Data file');

if isequal(file,0)
   disp('User selected Cancel');
elseif strcmp(file(end-2:end),'csv') == 1
   disp(['User selected ', fullfile(path,file)]);
   cd(path)
   %% Set up the Import Options and import the data
   opts = delimitedTextImportOptions("NumVariables", 3);
    
   % Specify range and delimiter
   opts.DataLines = [4, Inf];
   opts.Delimiter = ",";
    
   % Specify column names and types
   opts.VariableNames = ["Time", "Force", "Stroke"];
   opts.VariableTypes = ["double", "double", "double"];
    
   % Specify file level properties
   opts.ExtraColumnsRule = "ignore";
   opts.EmptyLineRule = "read";
      
   % Import the data
   TensileData = readtable(file, opts);
   Tensile_info = dir(file);

elseif strcmp(file(end-2:end),'txt') == 1 % not yet updated for Instron Tensile data - probably won't work
    disp(['User selected ', fullfile(path,file)]);
    cd(path)
    %% Set up the Import Options and import the data
    opts = delimitedTextImportOptions("NumVariables", 5);
    
    % Specify range and delimiter
    opts.DataLines = [6, Inf];
    opts.Delimiter = ";";
    
    % Specify column names and types
    opts.VariableNames = ["Force", "Elongation", "Sec", "VarName4", "VarName5"];
    opts.VariableTypes = ["double", "double", "double", "string", "string"];
    
    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    
    % Specify variable properties
    opts = setvaropts(opts, ["VarName4", "VarName5"], "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["VarName4", "VarName5"], "EmptyFieldRule", "auto");
    
    % Import the data
    TensileData = readtable(file, opts);
    Tensile_info = dir(file);
else 
    disp('User picked a file with no data.');
end

% Clear temporary variables
clear opts path file
cd(StartingFolder) %return

[~, ~, ~, video_info.h, video_info.m, video_info.s] = datevec(video_info.datenum);
[~, ~, ~, Tensile_info.h, Tensile_info.m, Tensile_info.s] = datevec(Tensile_info.datenum);
video_info.Time_ofset_s = (Tensile_info.h*3600+ Tensile_info.m*60 + Tensile_info.s)-(video_info.h*3600+ video_info.m*60+ video_info.s); %if positive then data longer than video, if negative video longer than data
video_info.starttime = max(TensileData.Time) - (video.NumFrames/video.FrameRate+video_info.Time_ofset_s);
video_info.FrameTime = ([1:video.NumFrames]./video.FrameRate)+video_info.starttime;

end