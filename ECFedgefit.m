%% Dr Ed Darnbrough University of Oxford Materials Department 2022
%% Fitting an erf to the out of focus edge to get a sub-pixel resolution on the position
function Edges = ECFedgefit(Im,dimension,region)
if length(region)==1; dummy.region(1) = 1; else; dummy.region(1) = region(1); end
dummy.region(2) = region(end); %50; %number of pixels from the edge of the original image to take
FuncShape = 100; % this is how steep the ecr funciton is and can be changed based on image defoucs. 

dummy.flat = sum(Im(:,dummy.region(1):dummy.region(2)),dimension).*(-1.5+dimension); % or dummy.flat = sum(Im(:,end-dummy.region:end),2);
dummy.flat = dummy.flat-min(dummy.flat); %this strange work around is becuase for the grips the sample is light region and for width it is the dark region
[~,b] = max(dummy.flat); %take the maximum value as the middle of the image where there will be one edge before and one after
%find first edge
dummy.range = 1:b;dummy.step = 1;
dummy.Res = Fitting(dummy,FuncShape);
%figure, plot(dummy.range,dummy.Res, 'o') use for diagnosing problems but
%comment out if running loop 

[~,a] = min(dummy.Res); 
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
dummy.range = b+a-10:b+a+10;dummy.step = 0.1;
dummy.ResClose = FittingBack(dummy,FuncShape);
%hold on; plot(min(dummy.range):dummy.step:max(dummy.range),dummy.ResClose, 'x')

[~,dummy.posinx] = min(dummy.ResClose);
dummy.pos(2) = dummy.range(1)+dummy.posinx.*dummy.step;  

Edges = dummy.pos; %save values

end

function Result = Fitting(dummy,FuncShape)
c= 1;
for i = dummy.range(1):dummy.step:dummy.range(end)
    ECF = (0.5*range(dummy.flat(dummy.range)).*erf(([dummy.range]-i)./sqrt(FuncShape))'+min(dummy.flat(dummy.range))+range(dummy.flat(dummy.range))./2);
    Interest = reshape(dummy.flat(dummy.range), length(dummy.range),1);
    Result(c) = sum(abs(Interest-ECF),1);
    c=c+1;
end
end

function Result = FittingBack(dummy,FuncShape)
c= 1;
for i = dummy.range(1):dummy.step:dummy.range(end)
    ECF = (0.5*range(dummy.flat(dummy.range)).*erf(-([dummy.range]-i)./sqrt(FuncShape))'+min(dummy.flat(dummy.range))+range(dummy.flat(dummy.range))./2);
    Interest = reshape(dummy.flat(dummy.range), length(dummy.range),1);
    Result(c) = sum(abs(Interest-ECF),1);
    c=c+1;
end
end