%% Dr Ed Darnbrough University of Oxford Materials Department 2024
%% Fitting an erf to the out of focus edge to get a sub-pixel resolution on the position
function Edges = ECFedgefit(Im,dimension,region,barrel_width,previous)
if nargin == 3; barrel_width = 1:size(Im,1); previous = [0,0]; end %Can use this to cycle through pixel by pixel for gettting the sample outline and to do fitting of neighbouring regions following an edge
if nargin == 4; previous = [0,0]; end
if length(region)==1; dummy.region(1) = 1; else; dummy.region(1) = region(1); end
dummy.region(2) = region(end); %50; %number of pixels from the edge of the original image to take
FuncShape = 100; % this is how steep the ecr funciton is and can be changed based on image defoucs. 
% Check which is the highest contrast image to use
RGB = std(double(Im(:,round((size(Im,2)./2)),:))); [~,pos] = max(RGB);Im = Im(:,:,pos);

dummy.flat = sum(Im(barrel_width,dummy.region(1):dummy.region(2)),dimension).*(-1.5+dimension); % or dummy.flat = sum(Im(:,end-dummy.region:end),2);
dummy.flat = dummy.flat-min(dummy.flat); %this strange work around is becuase for the grips the sample is light region and for width it is the dark region

% if max(region)>100 %only if looking at sample not gap
% %Check if the sample is darker than the background or lighter, assuming
% %that the sample takes up less than half the width of the image
% TopDownFlatten = sum(Im(1:1024,1:1280,1),1)./range(1:1024);[m,c,~,~,~] = linfit(1:1280, TopDownFlatten, ones(1,1280));diff = (((1:1280).*m +c) -TopDownFlatten);
% if (sum(diff<0)>sum(diff>0)) == 0; dummy.flat = dummy.flat.*(-1) + max(dummy.flat) ; end
% end

[~,b] = max(dummy.flat); %take the maximum value as the middle of the image where there will be one edge before and one after
%find first edge
dummy.range = 1:b;dummy.step = 1;
dummy.Res = Fitting(dummy,FuncShape);
%figure, plot(dummy.range,dummy.Res, 'o') use for diagnosing problems but
%comment out if running loop 

[~,a] = min(dummy.Res);
if abs(a-previous(1))>10 
    dummy.flat = movmedian(movmedian(dummy.flat,10),10); %do this to remove any spikes that could have ruined the fitting
    dummy.Res = Fitting(dummy,FuncShape);
    [~,a] = min(dummy.Res); %only does this once so if it persists it is real
end

dummy.range = a-10:a+10;dummy.step = 0.1;
if dummy.range(1)<1; dummy.range = 1:a+10; end
dummy.ResClose = Fitting(dummy,FuncShape);
%hold on; plot(min(dummy.range):dummy.step:max(dummy.range),dummy.ResClose, 'x')

[~,dummy.posinx] = min(dummy.ResClose);
dummy.pos(1) = dummy.range(1)+dummy.posinx.*dummy.step; 

dummy = rmfield(dummy,'Res');
dummy = rmfield(dummy,'ResClose');
%find second edge 
dummy.range = b:length(dummy.flat);dummy.step = 1;
dummy.Res = FittingBack(dummy,FuncShape);
%figure, plot(dummy.range,dummy.Res, 'o')

[~,a] = min(dummy.Res);
if abs(a-previous(2))>10 
    dummy.flat = movmedian(dummy.flat,10); %do this to remove any spikes that could have ruined the fitting
    dummy.Res = FittingBack(dummy,FuncShape);
    [~,a] = min(dummy.Res); %only does this once so if it persists it is real
end
dummy.range = b+a-10:b+a+10;dummy.step = 0.1;
dummy.ResClose = FittingBack(dummy,FuncShape);
%hold on; plot(min(dummy.range):dummy.step:max(dummy.range),dummy.ResClose, 'x')

[~,dummy.posinx] = min(dummy.ResClose);
dummy.pos(2) = dummy.range(1)+dummy.posinx.*dummy.step;  

Edges = dummy.pos; %save values
% To check if interested
% figure, hold on
% plot(dummy.flat)
% plot((0.5*range(dummy.flat(:)).*erf(((1:length(dummy.flat))-dummy.pos(1))./sqrt(FuncShape))'+min(dummy.flat(:))+range(dummy.flat(:))./2))
% plot((0.5*range(dummy.flat(:)).*erf((-(1:length(dummy.flat))+dummy.pos(2))./sqrt(FuncShape))'+min(dummy.flat(:))+range(dummy.flat(:))./2))

end

function Result = Fitting(dummy,FuncShape)
c= 1;
if dummy.range(1)<1; dummy.range(1)=1; shorten = find(dummy.range==1,1); dummy.range = dummy.range(shorten:end); end
if dummy.range(end)>length(dummy.flat); shorten = find(dummy.range==length(dummy.flat),1); dummy.range = dummy.range(1:shorten); end
for i = dummy.range(1):dummy.step:dummy.range(end)
    ECF = (0.5*range(dummy.flat(dummy.range)).*erf(([dummy.range]-i)./sqrt(FuncShape))'+min(dummy.flat(dummy.range))+range(dummy.flat(dummy.range))./2);
    Interest = reshape(dummy.flat(dummy.range), length(dummy.range),1);
    Result(c) = sum(abs(Interest-ECF),1);
    c=c+1;
end
end

function Result = FittingBack(dummy,FuncShape)
c= 1;
if dummy.range(1)<1; dummy.range(1)=1; shorten = find(dummy.range==1,1); dummy.range = dummy.range(shorten:end); end
if dummy.range(end)>length(dummy.flat); shorten = find(dummy.range==length(dummy.flat),1); dummy.range = dummy.range(1:shorten); end
for i = dummy.range(1):dummy.step:dummy.range(end)
    ECF = (0.5*range(dummy.flat(dummy.range)).*erf(-([dummy.range]-i)./sqrt(FuncShape))'+min(dummy.flat(dummy.range))+range(dummy.flat(dummy.range))./2);
    Interest = reshape(dummy.flat(dummy.range), length(dummy.range),1);
    Result(c) = sum(abs(Interest-ECF),1);
    c=c+1;
end
end

function [value] = range(varible)
value = abs(max(varible)-min(varible));
end